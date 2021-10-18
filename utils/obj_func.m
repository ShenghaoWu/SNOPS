function [objective] = obj_func(x, is_surrogate, obj_configs)
%initialization
addpath('fa_Yu/');
rng shuffle;
tic
opt=obj_configs.opt;
is_small=obj_configs.is_small;
T0=obj_configs.T0;
T_short=obj_configs.T_short;
T=obj_configs.T;
n_sampling = obj_configs.n_sampling;
Tw=obj_configs.Tw;
Tburn=obj_configs.Tburn;

dt=obj_configs.dt;
Ne1=obj_configs.Ne1;
Ni1=obj_configs.Ni1;
true_statistics=obj_configs.true_statistics;
tolerance=obj_configs.tolerance;
stats_filename=obj_configs.stats_filename;
is_simulation=obj_configs.is_simulation;
save_stats=obj_configs.save_stats;
metric_norm=obj_configs.metric_norm;
statistics_group=obj_configs.statistics_group;
try 
	n_neuron = obj_configs.n_neuron;
catch
	n_neuron=true_statistics.n_neuron;
end
dim_method = obj_configs.dim_method;
%%%%%%%%%%%%%%%%%%%%%%%%
%%% surrogate stats %%%
%%%%%%%%%%%%%%%%%%%%%%%%
ParamChange_short=configure_params(x,Ne1,Ni1,dt,T0,is_small);
opt.givenW=0;
opt.fixW=0;

warning_flag=0;
if is_surrogate
	try
		[~,~,s1]=spatial_nn_simulation_weight(opt, ParamChange_short);
		% if the simulation is terminated not too earlier from T, we still compute its stats
		if max(s1(1,:))<0.9*ParamChange_short{strcmp(ParamChange_short(:,1),'T'),2}
			error('simulation terminated due to max spikes, parameters discarded')
		end
		Ic1 = sample_e_neurons(s1,Ne1,is_simulation);
		[rate0,var0, FanoFactor0, ~, ~, ~, ~,low_rate_flag]=compute_stats(s1,Ic1,Tw,Tburn,n_sampling,n_neuron,0);
		if low_rate_flag
			error('low firing rate in surrogate simulation!')
		end
		 
		switch (metric_norm)
			case 'L2'
				cost_surrogate=mean([true_statistics.default_weights(1)*(rate0-true_statistics.rate_mean)^2/true_statistics.rate_var,...
				                    true_statistics.default_weights(2)*(FanoFactor0-true_statistics.fano_mean)^2/true_statistics.fano_var]);
			case 'L1'
				cost_surrogate=mean([true_statistics.default_weights(1)*abs(rate0-true_statistics.rate_mean)/sqrt(true_statistics.rate_var),...
				                    true_statistics.default_weights(2)*abs(FanoFactor0-true_statistics.fano_mean)/sqrt(true_statistics.fano_var)]);
		end
		if isnan(cost_surrogate)||cost_surrogate>tolerance
			warning_flag=1;
		end
	catch 
		warning_flag=1;
		warning('something wrong happended during surrogate stage')
	end
else
	cost_surrogate=NaN;
	rate0=NaN;
	var0=NaN;
	FanoFactor0=NaN;
end
%%%%%saving stats (even NaNs)
objective=NaN;
if save_stats
	surrogate_time=toc;
	full_stats_time=0;
	execution_time=table(surrogate_time,full_stats_time);
	[rate1,var1,FanoFactor1,mean_corr1,fa_percentshared100,fa_dshared100,fa_normevals100] = nan_stats(n_neuron);
	full_stats_to_record = generate_full_stats_to_record(statistics_group,objective,rate1,var1,FanoFactor1,mean_corr1,fa_percentshared100,fa_dshared100,fa_normevals100);
	if warning_flag
		try
			surrogate_stats=table(cost_surrogate,rate0,var0,FanoFactor0);
		catch
			cost_surrogate=NaN;
			rate0=NaN;
			var0=NaN;
			FanoFactor0=NaN;
			surrogate_stats=table(cost_surrogate,rate0,var0,FanoFactor0);
		end

		stats_weights=true_statistics.default_weights;
		save_statistics(stats_weights,x,full_stats_to_record,surrogate_stats,execution_time,stats_filename);
		return
	end
end 

if warning_flag
	return
end

%%%%%%%%%%%%%%%%%%%%%%%%
%%% full stats %%%
%%%%%%%%%%%%%%%%%%%%%%%%
tic
opt.fixW=0;
opt.givenW=0;
if contains(statistics_group,'3')
	ParamChange_full=configure_params(x,Ne1,Ni1,dt,T,is_small);
else 
	ParamChange_full=configure_params(x,Ne1,Ni1,dt,T_short,is_small);
end 
warning_flag=0; 

try
	[~,~,s1]=spatial_nn_simulation_weight(opt, ParamChange_full);
	if max(s1(1,:))<0.9*ParamChange_full{strcmp(ParamChange_full(:,1),'T'),2}
		error('simulation terminated due to max spikes, parameters discarded')
	end
	Ic1 = sample_e_neurons(s1,Ne1,is_simulation);
	[rate1,var1, FanoFactor1, mean_corr1, unstable_flag, sampling_inds, re,low_rate_flag]=compute_stats(s1,Ic1,Tw,Tburn,n_sampling, n_neuron, 1);
	if low_rate_flag
		error('low firing rate in main simulation!')
	end

	if unstable_flag
		
		if contains(statistics_group,'3')
			ParamChange_full=configure_params(x,Ne1,Ni1,dt/2,T,is_small);
		else 
			ParamChange_full=configure_params(x,Ne1,Ni1,dt/2,T_short,is_small);
		end
		[~,~,s1]=spatial_nn_simulation_weight(opt, ParamChange_full);
		if max(s1(1,:))<0.9*ParamChange_full{strcmp(ParamChange_full(:,1),'T'),2}
			error('simulation terminated due to max spikes, parameters discarded')
		end
		Ic1 = sample_e_neurons(s1,Ne1,is_simulation);
		[rate1,var1, FanoFactor1, mean_corr1, unstable_flag, sampling_inds, re, low_rate_flag]=compute_stats(s1,Ic1,Tw,Tburn,n_sampling, n_neuron,1);
		if low_rate_flag
			error('low firing rate in surrogate simulation!')
		end
    end

    if contains(statistics_group,'3')
		[fa_percentshared100, fa_normevals100, fa_dshared100] = compute_pop_stats(sampling_inds, re, n_neuron, Tw, dim_method);
    end

	switch metric_norm
	case 'L2'
		single_obj=mean([true_statistics.default_weights(1)*(rate1-true_statistics.rate_mean)^2/true_statistics.rate_var,...
	                    true_statistics.default_weights(2)*(FanoFactor1-true_statistics.fano_mean)^2/true_statistics.fano_var]);		
		pair_obj=true_statistics.default_weights(3)*(mean_corr1-true_statistics.mean_corr_mean)^2/true_statistics.mean_corr_var;		
		if contains(statistics_group,'3')
			pop_obj=mean([true_statistics.default_weights(4)*(fa_percentshared100-true_statistics.fa_percent_mean)^2/true_statistics.fa_percent_var,...
			                    true_statistics.default_weights(5)*(fa_dshared100-true_statistics.fa_dim_mean)^2/true_statistics.fa_dim_var,...
			                    true_statistics.default_weights(6)*norm(fa_normevals100-true_statistics.fa_normeval_mean,2)^2/true_statistics.fa_normeval_var]);		
		end

	case 'L1'
		single_obj=mean([true_statistics.default_weights(1)*abs(rate1-true_statistics.rate_mean)/sqrt(true_statistics.rate_var),...
	                    true_statistics.default_weights(2)*abs(FanoFactor1-true_statistics.fano_mean)/sqrt(true_statistics.fano_var)]);		
		pair_obj=true_statistics.default_weights(3)*abs(mean_corr1-true_statistics.mean_corr_mean)/sqrt(true_statistics.mean_corr_var);		
		if contains(statistics_group,'3')
			pop_obj=mean([true_statistics.default_weights(4)*abs(fa_percentshared100-true_statistics.fa_percent_mean)/sqrt(true_statistics.fa_percent_var),...
			                    true_statistics.default_weights(5)*abs(fa_dshared100-true_statistics.fa_dim_mean)/sqrt(true_statistics.fa_dim_var),...
			                    true_statistics.default_weights(6)*norm(fa_normevals100-true_statistics.fa_normeval_mean,1)/sqrt(true_statistics.fa_normeval_var)]);		
		end
	end  
	
	switch statistics_group
	case '1'
		objective=single_obj;
	case '2'
		objective=pair_obj;
	case '3'
		objective=pop_obj;
	case '12'
		objective=(2*single_obj+pair_obj)/3;
	case '13'
		objective=(2*single_obj+3*pop_obj)/5;
	case '23'
		objective=(pair_obj+3*pop_obj)/4;
	case '123'
		objective=(2*single_obj+pair_obj+3*pop_obj)/6;
	end
catch 
	warning_flag=1;
	warning('something wrong happened in main simulation')
end

if warning_flag
	objective=NaN;
end

if save_stats
	
		[full_stats_to_record] = generate_full_stats_to_record(statistics_group,objective,rate1,var1,FanoFactor1,mean_corr1,fa_percentshared100,fa_dshared100,fa_normevals100);
		full_stats_time=toc;
		execution_time=table(surrogate_time,full_stats_time);
		surrogate_stats=table(cost_surrogate,rate0,var0,FanoFactor0);
		stats_weights=true_statistics.default_weights;
		save_statistics(stats_weights,x,full_stats_to_record,surrogate_stats,execution_time,stats_filename);

end


end