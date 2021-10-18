function run_bayes(obj_configs, optimization_opt, is_random)

%random seed for running on cluster
seed_offset = randi(floor(intmax/10));
rng(rand(1)*1000 + seed_offset);

warning('optmization begins!')
if isfile(optimization_opt.save_name) %resume if results files already exist
	warning('file exists, resuming!')
	load(optimization_opt.save_name)
	optimization_opt.x_train=x_train;
	optimization_opt.y_train=y_train;
	optimization_opt.incumbent_std=incumbent_std;
	optimization_opt.optimization_time=optimization_time;
	optimization_opt.y_feasibility=y_feasibility;
elseif ~isempty(optimization_opt.base_name) %intensify if base file is there
	[optimization_opt,obj_configs] = intensification_vanilla(optimization_opt.base_name,obj_configs,optimization_opt);
	warning('intensifying base results!')
end


%preparing cost function
fun=@(x,is_surrogate)cost_func(x,is_surrogate,obj_configs);
func=@(x,is_surrogate)cost_interface(x,is_surrogate,fun);	

if is_random
	[x_train,y_train,y_feasibility,optimization_time] = random_search_vanilla(func,optimization_opt,obj_configs);

else
	[x_train,y_train,y_feasibility,optimization_time] = bayesian_optimization(func,optimization_opt,obj_configs);

end

