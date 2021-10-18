

addpath('fa_Yu/');
file_path='/afs/ece/project/nspg/data/smith/v4pfc_attention/attention_pupil/';
file_prefix = 'Wa'; %Pe
file_folder = '/afs/ece/project/nspg/data/smith/v4pfc_attention/attention_pupil/';
filenames = dir(strcat(file_folder,file_prefix,'*.mat'));
cue1_ori1_stats_v4 = [];
cue1_ori1_stats_pfc = [];
cue1_ori2_stats_v4 = [];
cue1_ori2_stats_pfc = [];
cue2_ori1_stats_v4 = [];
cue2_ori1_stats_pfc = [];
cue2_ori2_stats_v4 = [];
cue2_ori2_stats_pfc = [];
Tw=200;
is_normalize=0;
n_neuron_select = 50;
n_trial_select = 700;

for data_ind=1:size(filenames,1)
    load(strcat(file_folder,filenames(data_ind).name))

    ntrials = size(dat,2);
    nneurons = size(dat(1).V4spikes,1);
    nneurons_pfc = size(dat(1).PFCspikes,1);

    cues = zeros(ntrials,1);
    oris = zeros(ntrials,1);
    for i = 1: ntrials
        cues(i) = dat(i).cue;
        oris(i) = dat(i).rfOri;
    end

    data1=zeros(nneurons,sum(cues==1 & oris ==1));
    data1_pfc=zeros(nneurons_pfc,sum(cues==1 & oris ==1));

    data2=zeros(nneurons,sum(cues==1 & oris ==2));
    data2_pfc=zeros(nneurons_pfc,sum(cues==1 & oris ==2));


    data3=zeros(nneurons,sum(cues==2 & oris ==1));
    data3_pfc=zeros(nneurons_pfc,sum(cues==2 & oris ==1));

    data4=zeros(nneurons,sum(cues==2 & oris ==2));
    data4_pfc=zeros(nneurons_pfc,sum(cues==2 & oris ==2));

    cnt1=1;
    cnt2=1;
    cnt3=1;
    cnt4=1;

    for i = 1: ntrials
        tmp=dat(i).V4spikes;
        tmp_pfc=dat(i).PFCspikes;
        switch dat(i).cue+10*dat(i).rfOri
            case 11

                data1(:,cnt1)=sum(tmp(:,101:101+Tw-1),2);
                data1_pfc(:,cnt1)=sum(tmp_pfc(:,101:101+Tw-1),2);
                cnt1=cnt1+1;

            case 21

                data2(:,cnt2)=sum(tmp(:,101:101+Tw-1),2);
                data2_pfc(:,cnt2)=sum(tmp_pfc(:,101:101+Tw-1),2);
                cnt2=cnt2+1;

            case 12
                data3(:,cnt3)=sum(tmp(:,101:101+Tw-1),2);
                data3_pfc(:,cnt3)=sum(tmp_pfc(:,101:101+Tw-1),2);
                cnt3=cnt3+1;

            case 22
                data4(:,cnt4)=sum(tmp(:,101:101+Tw-1),2);
                data4_pfc(:,cnt4)=sum(tmp_pfc(:,101:101+Tw-1),2);
                cnt4=cnt4+1;
        end
    end
    cue1_ori1_stats_v4 = real_stats_proc(data1,n_trial_select,n_neuron_select,Tw,is_normalize,cue1_ori1_stats_v4);
    cue1_ori2_stats_v4 = real_stats_proc(data2,n_trial_select,n_neuron_select,Tw,is_normalize,cue1_ori2_stats_v4);
    cue2_ori1_stats_v4 = real_stats_proc(data3,n_trial_select,n_neuron_select,Tw,is_normalize,cue2_ori1_stats_v4);
    cue2_ori2_stats_v4 = real_stats_proc(data4,n_trial_select,n_neuron_select,Tw,is_normalize,cue2_ori2_stats_v4);
    cue1_ori1_stats_pfc = real_stats_proc(data1_pfc,n_trial_select,n_neuron_select,Tw,is_normalize,cue1_ori1_stats_pfc);
    cue1_ori2_stats_pfc = real_stats_proc(data2_pfc,n_trial_select,n_neuron_select,Tw,is_normalize,cue1_ori2_stats_pfc);
    cue2_ori1_stats_pfc = real_stats_proc(data3_pfc,n_trial_select,n_neuron_select,Tw,is_normalize,cue2_ori1_stats_pfc);
    cue2_ori2_stats_pfc = real_stats_proc(data4_pfc,n_trial_select,n_neuron_select,Tw,is_normalize,cue2_ori2_stats_pfc);

end


save_real_stats(cue1_ori1_stats_v4,n_neuron_select,'wakko_cue1_ori1_v4.mat')
save_real_stats(cue1_ori2_stats_v4,n_neuron_select,'wakko_cue1_ori2_v4.mat')
save_real_stats(cue2_ori1_stats_v4,n_neuron_select,'wakko_cue2_ori1_v4.mat')
save_real_stats(cue2_ori2_stats_v4,n_neuron_select,'wakko_cue2_ori2_v4.mat')
save_real_stats(cue1_ori1_stats_pfc,n_neuron_select,'wakko_cue1_ori1_pfc.mat')
save_real_stats(cue1_ori2_stats_pfc,n_neuron_select,'wakko_cue1_ori2_pfc.mat')
save_real_stats(cue2_ori1_stats_pfc,n_neuron_select,'wakko_cue2_ori1_pfc.mat')
save_real_stats(cue2_ori2_stats_pfc,n_neuron_select,'wakko_cue2_ori2_pfc.mat')



save_real_stats(cue1_ori1_stats_v4,n_neuron_select,'pepe_cue1_ori1_v4.mat')
save_real_stats(cue1_ori2_stats_v4,n_neuron_select,'pepe_cue1_ori2_v4.mat')
save_real_stats(cue2_ori1_stats_v4,n_neuron_select,'pepe_cue2_ori1_v4.mat')
save_real_stats(cue2_ori2_stats_v4,n_neuron_select,'pepe_cue2_ori2_v4.mat')
save_real_stats(cue1_ori1_stats_pfc,n_neuron_select,'pepe_cue1_ori1_pfc.mat')
save_real_stats(cue1_ori2_stats_pfc,n_neuron_select,'pepe_cue1_ori2_pfc.mat')
save_real_stats(cue2_ori1_stats_pfc,n_neuron_select,'pepe_cue2_ori1_pfc.mat')
save_real_stats(cue2_ori2_stats_pfc,n_neuron_select,'pepe_cue2_ori2_pfc.mat')
%save_real_stats(cue1_stats_v4,n_neuron_select,'pepe_cue1_ori2_v4.mat')

load('./q/pepe_cue1_ori1_v4.mat')
es_std = std(cue_stats{:,6});
save('./q/pepe_cue1_ori1_v4_es.mat','es_std')


real_names = {'wakko_cue1_ori1_v4',
'wakko_cue1_ori2_v4',
'wakko_cue2_ori1_v4',
'wakko_cue2_ori2_v4',
'wakko_cue1_ori1_pfc',
'wakko_cue1_ori2_pfc',
'wakko_cue2_ori1_pfc',
'wakko_cue2_ori2_pfc',
'pepe_cue1_ori1_v4',
'pepe_cue1_ori2_v4',
'pepe_cue2_ori1_v4',
'pepe_cue2_ori2_v4',
'pepe_cue1_ori1_pfc',
'pepe_cue1_ori2_pfc',
'pepe_cue2_ori1_pfc',
'pepe_cue2_ori2_pfc'};



for i = 1:16
    statsname=real_names{i};
    load(strcat('./q/',statsname,'.mat'));
    true_stats=table(true_statistics.rate_mean,true_statistics.fano_mean,true_statistics.mean_corr_mean,true_statistics.fa_percent_mean,true_statistics.fa_dim_mean,true_statistics.fa_normeval_mean);
    true_stats=true_stats{1,:};
    true_stats_var=table(true_statistics.rate_var,true_statistics.fano_var,true_statistics.mean_corr_var,true_statistics.fa_percent_var,true_statistics.fa_dim_var,true_statistics.fa_normeval_var);
    true_stats_var=true_stats_var{1,:};
    save(strcat('./q/',statsname,'_python.mat'),'true_stats','true_stats_var')
end









%%%remember don't modify cue1ori2!!!!!!!!!!


save('./q/pepe_v4_cue1_ori1_groundtruth.mat','true_statistics','cue1_stats_v4')






rate_mean=mean(cue1_stats_pfc.rate0);
rate_var=var(cue1_stats_pfc.rate0);

fano_mean=mean(cue1_stats_pfc.FanoFactor0); 
fano_var=var(cue1_stats_pfc.FanoFactor0);             

mean_corr_mean=mean(cue1_stats_pfc.mean_corr0); 
mean_corr_var=var(cue1_stats_pfc.mean_corr0);    

fa_percent_mean=mean(cue1_stats_pfc.fa_percentshared100);
fa_percent_var=var(cue1_stats_pfc.fa_percentshared100);    

fa_dim_mean=mean(cue1_stats_pfc.fa_dshared100); 
fa_dim_var=var(cue1_stats_pfc.fa_dshared100);   

fa_normeval_mean=mean(cue1_stats_pfc.fa_normevals100,1);    
fa_normeval_var=mean(vecnorm(cue1_stats_pfc.fa_normevals100-fa_normeval_mean,2,2).^2);

n_neuron=n_neuron_select;
default_weights=ones(1,6);
true_statistics=table(n_neuron,rate_mean,rate_var,fano_mean,fano_var,mean_corr_mean,mean_corr_var,fa_percent_mean,fa_percent_var,fa_dim_mean,fa_dim_var,fa_normeval_mean,fa_normeval_var,default_weights);
save('./q/pepe_pfc_cue1_ori1_groundtruth.mat','true_statistics','cue1_stats_pfc')











load('./q/pepe_v4_cue1_ori1_groundtruth.mat');
true_stats=table(true_statistics.rate_mean,true_statistics.fano_mean,true_statistics.mean_corr_mean,true_statistics.fa_percent_mean,true_statistics.fa_dim_mean,true_statistics.fa_normeval_mean);
true_stats=true_stats{1,:};
true_stats_var=table(true_statistics.rate_var,true_statistics.fano_var,true_statistics.mean_corr_var,true_statistics.fa_percent_var,true_statistics.fa_dim_var,true_statistics.fa_normeval_var);
true_stats_var=true_stats_var{1,:};

save('./q/pepe_v4_cue1_ori1_groundtruth_python.mat','true_stats','true_stats_var')



load('./q/pepe_pfc_cue1_ori1_groundtruth.mat');
true_stats=table(true_statistics.rate_mean,true_statistics.fano_mean,true_statistics.mean_corr_mean,true_statistics.fa_percent_mean,true_statistics.fa_dim_mean,true_statistics.fa_normeval_mean);
true_stats=true_stats{1,:};
true_stats_var=table(true_statistics.rate_var,true_statistics.fano_var,true_statistics.mean_corr_var,true_statistics.fa_percent_var,true_statistics.fa_dim_var,true_statistics.fa_normeval_var);
true_stats_var=true_stats_var{1,:};
save('./q/pepe_pfc_cue1_ori1_groundtruth_python.mat','true_stats','true_stats_var')

