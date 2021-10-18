function run_bayesopt_11paras(base_name,epsilon,T,is_spatial,real_data_name, stats_name,results_name,n_data,tolerance,is_simulation,max_time,max_iter,std_tol,min_cost_eval,max_cost_eval,stats_weights,survival_rate,x_range,n_check,is_log)
[opt,obj_configs]=initialize_optimization(real_data_name);
obj_configs.survival_rate=survival_rate;
obj_configs.true_statistics.default_weights=stats_weights;
obj_configs.tolerance=Inf; % default no threshold
obj_configs.metric_norm='L2';
obj_configs.statistics_group='123';
obj_configs.stats_filename=config_statsfile(stats_name);
obj_configs.is_simulation=is_simulation;
obj_configs.is_small=1;
obj_configs.n_sampling=10;
obj_configs.Ne1=50;
obj_configs.Ni1=25;
obj_configs.save_stats=1;
obj_configs.dim_method = 'CV_skip';
obj_configs.T=T;
obj_configs.Tw=200;
obj_configs.Tw_fa=200;
obj_configs.is_spatial=is_spatial;

%optimization configuration

%if is_spatial
%	x_range=[1,25;1,25;0,0.25;0,0.25;0,0.25;-150,0;0,150;-150,0;0,150;0,150;0,150];
%else
%	x_range=[1,25;1,25;-150,0;0,150;-150,0;0,150;0,150;0,150];
%end
n_sample=100000;
n_local=10;
%n_data=10;%initial pts
optimization_opt=config_my_optimization(max_time,max_iter,x_range,epsilon,n_sample,n_local,n_data,results_name,std_tol,min_cost_eval,max_cost_eval,n_check);
optimization_opt.is_log=is_log;
if isfile(results_name)
	warning('file exists, resuming!')
	load(results_name)
	optimization_opt.x_train=x_train;
	optimization_opt.y_train=y_train;
	optimization_opt.incumbent_std=incumbent_std;
	optimization_opt.optimization_time=optimization_time;
	optimization_opt.y_feasibility=y_feasibility;
	load(stats_name)
	obj_configs.default_weights = stats_weights;
elseif ~isempty(base_name)

	[optimization_opt,obj_configs] = intensify(base_name,obj_configs,optimization_opt);
	warning('intensifying base results!')
end


if is_spatial
	fun=@(x,is_surrogate)obj_func(x,is_surrogate,obj_configs);
	func=@(x,is_surrogate)obj_interface(x,is_surrogate,fun);
else
	fun=@(x,is_surrogate)obj_func_nospatial(x,is_surrogate,obj_configs);
	func=@(x,is_surrogate)obj_interface_nospatial(x,is_surrogate,fun);	
end
[x_train,y_train,y_feasibility,optimization_time] = bayesian_optimization(func,optimization_opt,obj_configs);
