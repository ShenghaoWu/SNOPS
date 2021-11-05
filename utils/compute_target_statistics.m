function output_file_name = compute_target_statistics(target_train_name,obj_configs)
%compute the activity statistics of the target spike train to fit

load(strcat('./data/',target_train_name,'.mat'));
n_sampling = obj_configs.n_sampling;
Tw=obj_configs.Tw;
Tburn=obj_configs.Tburn;
Ne=obj_configs.Ne;
n_neuron = obj_configs.n_neuron;
dim_method = obj_configs.dim_method;
Ic1 = sample_e_neurons(spike_train,Ne);
[rate1,var1, FanoFactor1, mean_corr1, unstable_flag, sampling_inds, re,low_rate_flag]=compute_stats(spike_train,Ic1,Tw,Tburn,n_sampling, n_neuron, 1);
if low_rate_flag
    error('low firing rate, use a different spike train')
end
if unstable_flag
    error('unrealistic spiking, use a different spike train')
end

[fa_percentshared100, fa_normevals100, fa_dshared100] = compute_pop_stats(sampling_inds, re, n_neuron, Tw, dim_method);




rate_mean=rate1;
rate_var=1;

fano_mean=FanoFactor1; 
fano_var=0.005;             

mean_corr_mean=mean_corr1; 
mean_corr_var=0.0001;    

fa_percent_mean=fa_percentshared100;
fa_percent_var=0.05;    

fa_dim_mean=fa_dshared100; 
fa_dim_var=0.5;   

fa_normeval_mean=fa_normevals100;  
fa_normeval_var=40;

default_weights=ones(1,6);
true_statistics=table(n_neuron,rate_mean,rate_var,fano_mean,fano_var,mean_corr_mean,mean_corr_var,fa_percent_mean,fa_percent_var,fa_dim_mean,fa_dim_var,fa_normeval_mean,fa_normeval_var,default_weights);

output_file_name = strcat(target_train_name,'_stats');
save(strcat('./data/',output_file_name,'.mat'),'true_statistics');