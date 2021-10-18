function [optimization_opt] = config_my_optimization(max_time,max_iter,x_range,epsilon,n_sample,n_local,n_data,save_name,std_tol,min_cost_eval,max_cost_eval,n_check)

optimization_opt.x_range=x_range;
optimization_opt.epsilon=epsilon;
optimization_opt.n_sample=n_sample;
optimization_opt.n_local=n_local;
optimization_opt.n_data=n_data;
optimization_opt.max_iter=max_iter;
optimization_opt.max_time=max_time;
optimization_opt.save_name=save_name;
optimization_opt.std_tol=std_tol;
optimization_opt.min_cost_eval=min_cost_eval;
optimization_opt.max_cost_eval=max_cost_eval;
optimization_opt.n_check=n_check;
