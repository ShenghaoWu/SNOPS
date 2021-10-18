function save_real_stats(cue_stats,n_neuron_select,save_name)



rate_mean=mean(cue_stats.rate0);
rate_var=var(cue_stats.rate0);

fano_mean=mean(cue_stats.FanoFactor0); 
fano_var=var(cue_stats.FanoFactor0);             

mean_corr_mean=mean(cue_stats.mean_corr0); 
mean_corr_var=var(cue_stats.mean_corr0);    

fa_percent_mean=mean(cue_stats.fa_percentshared100);
fa_percent_var=var(cue_stats.fa_percentshared100);    

fa_dim_mean=mean(cue_stats.fa_dshared100); 
fa_dim_var=var(cue_stats.fa_dshared100);   

fa_normeval_mean=mean(cue_stats.fa_normevals100,1);  
fa_normeval_var=mean(vecnorm(cue_stats.fa_normevals100-fa_normeval_mean,2,2).^2);

n_neuron=n_neuron_select;
default_weights=ones(1,6);
true_statistics=table(n_neuron,rate_mean,rate_var,fano_mean,fano_var,mean_corr_mean,mean_corr_var,fa_percent_mean,fa_percent_var,fa_dim_mean,fa_dim_var,fa_normeval_mean,fa_normeval_var,default_weights);


save(strcat('./q/',save_name),'true_statistics','cue_stats')


