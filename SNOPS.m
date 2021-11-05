function SNOPS(target_train_name,simulator,parameter_range,max_iter,T,Ne,save_name,is_plot,varargin)
warning('off')
addpath('utils')
addpath('./utils/fa_Yu')


[obj_configs,optimization_opt]=generate_config('n_neuron',50,...
                                               'n_data',1,...
                                               'base_name',[],...
                                               'min_cost_eval',1,...
                                               'max_cost_eval',1,...                                          
                                               'T', T,...
                                               'Ne', Ne,...
                                               'max_iter',max_iter,...
                                               'x_range',parameter_range,...
                                               'real_data_name', target_train_name,...
                                               'filename',save_name);
                                         
                                           

if ~contains(target_train_name,'_stats')
    disp('Computing target statistics')
    target_train_name = compute_target_statistics(target_train_name,obj_configs);
end
%configure real data attribute of the config
obj_configs.real_data_name = strcat(obj_configs.root,target_train_name,'.mat');
load(obj_configs.real_data_name);
obj_configs.true_statistics=true_statistics;
obj_configs.true_statistics.default_weights=obj_configs.stats_weights;




seed_offset = randi(floor(intmax/10));
rng(rand(1)*1000 + seed_offset);

tt=obj_configs.true_statistics;
disp('Fitting begins')
disp('================================================================================')
disp('Target statistics:')
disp(strcat('firing rate: ', string(tt.rate_mean),' || Fano: ', string(tt.fano_mean),' || rsc: ', string(tt.mean_corr_mean)))
disp(strcat('percent shared: ', string(tt.fa_percent_mean),' || d shared: ', string(tt.fa_dim_mean),' || eigenspectrum(top3): ', strjoin(string(tt.fa_normeval_mean(1:3)),',')))
pause(10)

%preparing cost function
func=@(x,is_surrogate)cost_func(x,is_surrogate,obj_configs,simulator);


%%%%%%%%%%%%%%%%%


x_range=optimization_opt.x_range;
epsilon=optimization_opt.epsilon;
n_sample=optimization_opt.n_sample;
n_local=optimization_opt.n_local;
max_time=optimization_opt.max_time;
max_iter=optimization_opt.max_iter;
save_name=optimization_opt.save_name;
std_tol=optimization_opt.std_tol;
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
    y_train_best = NaN(n_data,1);
	for i =1:n_data
	    t_init=tic;
	    y_hat=func(x_train(i,:),1);
	    if isnan(y_hat)
	        y_feasibility(i)=0;
	    else 
	    	if isnan(nanmin(y_train)) || nanmin(y_train)+2*incumbent_std>y_hat
		    	intens_cnt = 1;
		    	tmp_yhat=[y_hat];
		    	current_std=Inf;
                while (intens_cnt< min_cost_eval) && (~any(isnan(tmp_yhat)))&&((mean(tmp_yhat)<nanmin(y_train)+2*incumbent_std)||isnan(nanmin(y_train)))
		    		intens_cnt=intens_cnt+1;
		    		tmp_yhat=[tmp_yhat,func(x_train(i,:),1)];
		    		current_std=std(tmp_yhat)/sqrt(intens_cnt);
		    	end
		    	while (intens_cnt< max_cost_eval) && current_std>std_tol && (~any(isnan(tmp_yhat)))&&((mean(tmp_yhat)<nanmin(y_train)+2*incumbent_std)||isnan(nanmin(y_train)))
		    		intens_cnt=intens_cnt+1;
		    		tmp_yhat=[tmp_yhat,func(x_train(i,:),1)];
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

    
    
    
    y_train_best(i)=nanmin(y_train);
    ts = obj_configs.true_statistics;
    load(strcat('./data/',obj_configs.filename,'_stats.mat'))  
    [I,J] = min(y_train);
    tt = full_stats(J,:);
        
    if is_plot

        figure('Name',strcat('iteration ', string(i)),'NumberTitle','off')
        set(gcf, 'Position',  [500, 400, 1200, 1000])
        tiledlayout(2,8)

        ax1 = nexttile;
        hold(ax1,'on')
        scatter(0,tt.rate1,35,'black','filled')
        scatter(0,ts.rate_mean,35,'red','filled')
        xlabel('firing rate')
        set(ax1,'XTick',[])
        %drawnow;
        hold(ax1,'off')

        ax2 = nexttile;
        hold(ax2,'on')
        scatter(0,tt.FanoFactor1,35,'black','filled')
        scatter(0,ts.fano_mean,35,'red','filled')
        xlabel('Fano')
        set(ax2,'XTick',[])
        %drawnow;
        hold(ax2,'off')

        ax3 = nexttile;
        hold(ax3,'on')
        scatter(0,tt.mean_corr1,35,'black','filled')
        scatter(0,ts.mean_corr_mean,35,'red','filled')
        xlabel('rsc')
        set(ax3,'XTick',[])
        %drawnow;
        hold(ax3,'off')

        ax4 = nexttile;
        hold(ax4,'on')
        scatter(0,tt.fa_percentshared100,35,'black','filled')
        scatter(0,ts.fa_percent_mean,35,'red','filled')
        xlabel(sprintf('percent \nshared'))
        set(ax4,'XTick',[])
        %drawnow;
        hold(ax4,'off')

        ax5 = nexttile;
        hold(ax5,'on')
        scatter(0,tt.fa_dshared100,35,'black','filled')
        scatter(0,ts.fa_dim_mean,35,'red','filled')
        xlabel(sprintf('d \nshared'))
        set(ax5,'XTick',[])
        %drawnow;
        hold(ax5,'off')

        ax6 = nexttile([1,3]);
        hold(ax6,'on')
        scatter(1:3,tt.fa_normevals100(1:3),35,'black','filled')
        scatter(1:3,ts.fa_normeval_mean(1:3),35,'red','filled')
        plot(1:3,tt.fa_normevals100(1:3),'LineWidth',2.5,'Color','black')
        plot(1:3,ts.fa_normeval_mean(1:3),'LineWidth',2.5,'Color','red')
        xlabel('eigenspectrum (top 3)')
        legend('best','target','Location','northeast')
        set(ax6,'XTick',[])
        %drawnow;
        hold(ax6,'off')
        sgtitle('Activity statistics','FontSize',20,'FontWeight','bold'); 


        ax7 = nexttile([1,5]);
        plot(1:length(y_train_best),log(y_train_best),'LineWidth',2.5,'Color','black');
        hold(ax7,'on')
        scatter(1:length(y_train_best),log(y_train_best),35,'black','filled');
         
        xlim([1,optimization_opt.max_iter+1])
        title('Cost trace')
        xlabel('iteration')
        ylabel('log best(cost)')
        %drawnow;
        hold(ax7,'off') 
        set(findall(gcf,'-property','FontSize'),'FontSize',20)
        drawnow
    
    else 
    
        disp('================================================================================')
        if y_feasibility(end)==1
            load(strcat('./data/',obj_configs.filename,'_stats.mat'))  
            tt = full_stats(end,:);
            disp(strcat('iteration ', string(i)))
            disp('--------------------------------------------------------------------------------')
            disp(strcat('current parameter set:  ',join(string(x_train(end,:)),',')))
            disp('--------------------------------------------------------------------------------')
            disp(strcat('current cost=',string(y_train(end)),'; || current best=',string(nanmin(y_train))))
            disp('--------------------------------------------------------------------------------')
            disp(strcat('firing rate: ', string(tt.rate1),' || Fano: ', string(tt.FanoFactor1),' || rsc: ', string(tt.mean_corr1)))
            disp(strcat('percent shared: ', string(tt.fa_percentshared100),' || dshared: ', string(tt.fa_dshared100),' || eigenspectrum(top3): ', strjoin(string(tt.fa_normevals100(1:3)),',')))

        else 
            disp(strcat('iteration ', string(i)))
            disp('--------------------------------------------------------------------------------')
            disp(strcat('current parameter set:  ',join(string(x_train(end,:)),',')))
            disp('--------------------------------------------------------------------------------')
            disp( 'infeasible parameter')
        end
    
    end
    
    
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

save(save_name,'x_train','y_train','y_feasibility','optimization_time','incumbent_std')

is_better=0;
%main loop
for kk=1:max_iter-1
    if sum(optimization_time)<=max_time
        t_init=tic;
        if mod (kk, n_check)==0
            [x_star,y_star,is_better]=check_threads(x_train,y_train,obj_configs.root,obj_configs.stats_filename,obj_configs.true_statistics); 
        end
        if is_better

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
		    		tmp_yhat=[tmp_yhat,func(x_train(n_data+kk,:),1)];
		    		current_std=std(tmp_yhat)/sqrt(intens_cnt);
		    	end
		    	while (intens_cnt< max_cost_eval) && current_std>std_tol && (~any(isnan(tmp_yhat)))&&((mean(tmp_yhat)<nanmin(y_train)+2*incumbent_std)||isnan(nanmin(y_train))) 
		    		intens_cnt=intens_cnt+1;
		    		tmp_yhat=[tmp_yhat,func(x_train(n_data+kk,:),1)];
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
   
    

    y_train_best(end+1)=nanmin(y_train);
    load(strcat('./data/',obj_configs.filename,'_stats.mat'))  
    [I,J] = min(y_train);
    tt = full_stats(J,:);
    
    if is_plot

        figure('Name',strcat('iteration ', string(size(x_train,1))),'NumberTitle','off')
        set(gcf, 'Position',  [500, 400, 1200, 1000])
        tiledlayout(2,8)

        ax1 = nexttile;
        hold(ax1,'on')
        scatter(0,tt.rate1,35,'black','filled')
        scatter(0,ts.rate_mean,35,'red','filled')
        xlabel('firing rate')
        set(ax1,'XTick',[])
        %drawnow;
        hold(ax1,'off')

        ax2 = nexttile;
        hold(ax2,'on')
        scatter(0,tt.FanoFactor1,35,'black','filled')
        scatter(0,ts.fano_mean,35,'red','filled')
        xlabel('Fano')
        set(ax2,'XTick',[])
        %drawnow;
        hold(ax2,'off')

        ax3 = nexttile;
        hold(ax3,'on')
        scatter(0,tt.mean_corr1,35,'black','filled')
        scatter(0,ts.mean_corr_mean,35,'red','filled')
        xlabel('rsc')
        set(ax3,'XTick',[])
        %drawnow;
        hold(ax3,'off')

        ax4 = nexttile;
        hold(ax4,'on')
        scatter(0,tt.fa_percentshared100,35,'black','filled')
        scatter(0,ts.fa_percent_mean,35,'red','filled')
        xlabel(sprintf('percent \nshared'))
        set(ax4,'XTick',[])
        %drawnow;
        hold(ax4,'off')

        ax5 = nexttile;
        hold(ax5,'on')
        scatter(0,tt.fa_dshared100,35,'black','filled')
        scatter(0,ts.fa_dim_mean,35,'red','filled')
        xlabel(sprintf('d \nshared'))
        set(ax5,'XTick',[])
        %drawnow;
        hold(ax5,'off')

        ax6 = nexttile([1,3]);
        hold(ax6,'on')
        scatter(1:3,tt.fa_normevals100(1:3),35,'black','filled')
        scatter(1:3,ts.fa_normeval_mean(1:3),35,'red','filled')
        plot(1:3,tt.fa_normevals100(1:3),'LineWidth',2.5,'Color','black')
        plot(1:3,ts.fa_normeval_mean(1:3),'LineWidth',2.5,'Color','red')
        xlabel('eigenspectrum (top 3)')
        legend('best','target','Location','northeast')
        set(ax6,'XTick',[])
        %drawnow;
        hold(ax6,'off')
        sgtitle('Activity statistics','FontSize',20,'FontWeight','bold'); 

        ax7 = nexttile([1,5]);
        plot(1:length(y_train_best),log(y_train_best),'LineWidth',2.5,'Color','black');
        hold(ax7,'on')
        scatter(1:length(y_train_best),log(y_train_best),35,'black','filled');
        xlim([1,optimization_opt.max_iter+1])
        title('Cost trace')
        xlabel('iteration')
        ylabel('log best(cost)')
        %drawnow;
        hold(ax7,'off') 
        set(findall(gcf,'-property','FontSize'),'FontSize',20)
        drawnow
    else 
        disp('================================================================================')
        if y_feasibility(end)==1
            load(strcat('./data/',obj_configs.filename,'_stats.mat'))  
            tt = full_stats(end,:);
            disp(strcat('iteration ', string(size(x_train,1))))
            disp('--------------------------------------------------------------------------------')
            disp(strcat('current parameter set:  ',join(string(x_train(end,:)),',')))
            disp('--------------------------------------------------------------------------------')
            disp(strcat('current cost=',string(y_train(end)),'; || current best=',string(nanmin(y_train))))
            disp('--------------------------------------------------------------------------------')
            disp(strcat('firing rate: ', string(tt.rate1),' || Fano: ', string(tt.FanoFactor1),' || rsc: ', string(tt.mean_corr1)))
            disp(strcat('percent shared: ', string(tt.fa_percentshared100),' || d shared: ', string(tt.fa_dshared100),' || eigenspectrum(top3): ', strjoin(string(tt.fa_normevals100(1:3)),',')))

        else 
            disp(strcat('iteration ', string(size(x_train,1))))
            disp('--------------------------------------------------------------------------------')
            disp(strcat('current parameter set:  ',join(string(x_train(end,:)),',')))
            disp('--------------------------------------------------------------------------------')
            disp( 'infeasible parameter')
        end
    
    end

end


load(strcat('./data/',obj_configs.filename,'_stats.mat'))  
[I,J] = min(y_train);
tt = full_stats(J,:);
ps = paras(J,:);



 
disp('================================================================================')
disp('Optimization terminates: max iterations reached')
disp('--------------------------------------------------------------------------------')
disp(strcat('best parameter set:  ',join(string(x_train(J,:)),',')))
disp('--------------------------------------------------------------------------------')
disp(strcat('best cost =',string(nanmin(y_train))))
disp('--------------------------------------------------------------------------------')
disp(strcat('firing rate: ', string(tt.rate1),' || Fano: ', string(tt.FanoFactor1),' || rsc: ', string(tt.mean_corr1)))
disp(strcat('percent shared: ', string(tt.fa_percentshared100),' || d shared: ', string(tt.fa_dshared100),' || eigenspectrum(top3): ', strjoin(string(tt.fa_normevals100(1:3)),',')))

    


end