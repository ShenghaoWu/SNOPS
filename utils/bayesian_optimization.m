function [x_train,y_train,y_feasibility,optimization_time] = bayesian_optimization(func,optimization_opt,obj_configs)
rng shuffle;
%initialization
x_range=optimization_opt.x_range;
epsilon=optimization_opt.epsilon;
n_sample=optimization_opt.n_sample;
n_local=optimization_opt.n_local;
max_time=optimization_opt.max_time;
max_iter=optimization_opt.max_iter;
save_name=optimization_opt.save_name;
std_tol=optimization_opt.std_tol;
%std_tol_upper=optimization_opt.std_tol_upper;
max_cost_eval=optimization_opt.max_cost_eval;
min_cost_eval=optimization_opt.min_cost_eval;

is_log= optimization_opt.is_log;
n_dim=size(x_range,1);
n_check = optimization_opt.n_check;
try 
	x_train=optimization_opt.x_train;
	y_train=optimization_opt.y_train;
	incumbent_std=optimization_opt.incumbent_std;
	n_data=size(x_train,1);
	optimization_time=optimization_opt.optimization_time;
	y_feasibility=optimization_opt.y_feasibility;

catch
	incumbent_std=0;
	n_data=optimization_opt.n_data;
	optimization_time=zeros(n_data,1);
	y_feasibility=NaN(n_data,1);
	try 
	    x_init=optimization_opt.x_init;  
	catch
	    x_init=rand(n_data,n_dim).*repmat((x_range(:,2)-x_range(:,1))', n_data,1)+ repmat(x_range(:,1)', n_data,1);
	end
	%evaluating seed points
	x_train=x_init;
	y_train=NaN(n_data,1);
	for i =1:n_data
	    t_init=tic;
	    y_hat=func(x_train(i,:),obj_configs.is_surrogate);
	    if isnan(y_hat)
	        y_feasibility(i)=0;
	    else 
	    	if isnan(nanmin(y_train)) || nanmin(y_train)+2*incumbent_std>y_hat
		    	intens_cnt = 1;
		    	tmp_yhat=[y_hat];
		    	current_std=Inf;
                while (intens_cnt< min_cost_eval) && (~any(isnan(tmp_yhat)))&&((mean(tmp_yhat)<nanmin(y_train)+2*incumbent_std)||isnan(nanmin(y_train)))
		    		intens_cnt=intens_cnt+1;
		    		tmp_yhat=[tmp_yhat,func(x_train(i,:),obj_configs.is_surrogate)];
		    		current_std=std(tmp_yhat)/sqrt(intens_cnt);
		    	end
		    	while (intens_cnt< max_cost_eval) && current_std>std_tol && (~any(isnan(tmp_yhat)))&&((mean(tmp_yhat)<nanmin(y_train)+2*incumbent_std)||isnan(nanmin(y_train)))
		    		intens_cnt=intens_cnt+1;
		    		tmp_yhat=[tmp_yhat,func(x_train(i,:),obj_configs.is_surrogate)];
		    		current_std=std(tmp_yhat)/sqrt(intens_cnt);
		    	end
		    	y_hat=mean(tmp_yhat);
		    	if y_hat < nanmin(y_train) || (isnan(nanmin(y_train))&& ~isnan(y_hat))
		    		incumbent_std=current_std;
		    	end
			end
			if isnan(y_hat)
		        y_feasibility(i)=0;
		    else
		        y_feasibility(i)=1;
		        y_train(i)=y_hat;
		    end
	    end
	    optimization_time(i)=toc(t_init);
	end

end 






%in case none of the initial points are feasible, gprMdl posterior is uniform 
if sum(y_feasibility==0)==n_data
    current_feas=0;
    gprMdl = fitrgp(x_train(1,:),0,...
                'KernelFunction','ardmatern52',...
                'BasisFunction', 'constant', ...
                'Standardize', false,...
                'ConstantSigma',false,...
                'FitMethod','exact','PredictMethod','exact');
        f_plus=0;
        epsilon_scaled=epsilon;
else
    current_feas=1;
	gprMdl=nan;
	f_plus=nan;
	epsilon_scaled=nan;

end
%x_train=[x_train;NaN(max_iter,n_dim)];
%y_train=[y_train;NaN(max_iter,1)];
save(save_name,'x_train','y_train','y_feasibility','optimization_time','incumbent_std')

is_better=0;
%main loop
for kk=1:max_iter
    if sum(optimization_time)<=max_time
        t_init=tic;
        if mod (kk, n_check)==0
            [x_star,y_star,is_better]=check_threads(x_train,y_train,obj_configs.root,obj_configs.stats_filename,obj_configs.true_statistics); 
        end
        if is_better
        	if ~obj_configs.is_spatial  
        		x_star=x_star([1,2,6,7,8,9,10,11]);
        	end  
            x_train(n_data+kk,:)=x_star;
            y_hat=y_star;
        else 
            [gprMdl,gprMdl_feas,f_plus,epsilon_scaled]=fit_gp(x_train,y_train,y_feasibility,epsilon,gprMdl,current_feas,f_plus,epsilon_scaled,is_log);
            [EI_maxx,~] = max_EI(gprMdl,gprMdl_feas,f_plus,epsilon_scaled,n_sample,x_range,n_local);
            x_train(n_data+kk,:)=EI_maxx;
            y_hat=func(EI_maxx,1);
        end
        is_better=0;
        
        if isnan(y_hat)
            y_feasibility(n_data+kk)=0;
            y_train(n_data+kk)=y_hat;
            current_feas=0;
        else
	        if isnan(nanmin(y_train)) || nanmin(y_train)+2*incumbent_std>y_hat
		    	intens_cnt = 1;
		    	tmp_yhat=[y_hat];
		    	current_std=Inf;
                while (intens_cnt< min_cost_eval) && (~any(isnan(tmp_yhat)))&&((mean(tmp_yhat)<nanmin(y_train)+2*incumbent_std)||isnan(nanmin(y_train))) 
		    		intens_cnt=intens_cnt+1;
		    		tmp_yhat=[tmp_yhat,func(x_train(n_data+kk,:),obj_configs.is_surrogate)];
		    		current_std=std(tmp_yhat)/sqrt(intens_cnt);
		    	end
		    	while (intens_cnt< max_cost_eval) && current_std>std_tol && (~any(isnan(tmp_yhat)))&&((mean(tmp_yhat)<nanmin(y_train)+2*incumbent_std)||isnan(nanmin(y_train))) 
		    		intens_cnt=intens_cnt+1;
		    		tmp_yhat=[tmp_yhat,func(x_train(n_data+kk,:),obj_configs.is_surrogate)];
		    		current_std=std(tmp_yhat)/sqrt(intens_cnt);
		    	end
		    	y_hat=mean(tmp_yhat);
		    	if y_hat < nanmin(y_train)|| (isnan(nanmin(y_train))&& ~isnan(y_hat))
		    		incumbent_std=current_std;
		    	end
			end
			if isnan(y_hat)
		        y_feasibility(n_data+kk)=0;
		        y_train(n_data+kk)=y_hat;
		        current_feas=0;
		    else
		        y_feasibility(n_data+kk)=1;
		        y_train(n_data+kk)=y_hat;
		        current_feas=1;
		    end

        end
        optimization_time(n_data+kk)=toc(t_init);
        save(save_name,'x_train','y_train','y_feasibility','optimization_time','incumbent_std')
    else
        save(save_name,'x_train','y_train','y_feasibility','optimization_time','incumbent_std')
        return
    end
end
