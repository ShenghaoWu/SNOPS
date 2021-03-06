function [obj_configs, optimization_opt] =  generate_config(varargin)

%opt file for SNN simulation
is_save=0; % save data
CompCorr=0; % compute correlations
Layer1only=1; % 1 for two-layer network, 0 for three-layer network
loadS1=0;
plotPopR=0; % plot population rate
fixW=0;  % use the same weight matrices for multiple simulations
verbose=0;
check_firing_rates=0;

%config file for evaluating the objective(cost) function
filename = '';
root = './data/';
real_data_name = 'demo';
is_surrogate=1;
n_sampling=10;
Tw=200;
Tburn=500;
T0=10000;
T_short=20000;
T=700*200+500;
dt=0.05;
N_groundtruth=50000;
tolerance=Inf;
metric_norm='L2';
statistics_group='123';
survival_rate=Inf;
is_simulation=1;
is_small=1;
Ne=50;
Ni1=25;
save_stats=1;
dim_method = 'CV_skip';
stats_weights = [1,1,1,1,1,1];

%config file for BO

x_range=[1,25;1,25;0,0.25;0,0.25;0,0.25;-150,0;0,150;-150,0;0,150;0,150;0,150];
epsilon=0;
n_sample=100000;
n_local=10;
n_data=50; %number of random seed for BO
max_iter=10000;
max_time=10000*3600;
std_tol=0.15;
min_cost_eval=5;
max_cost_eval=10;
n_check=1e6;
n_neuron = 50;
is_log=1;
base_name = [];
top_n=50;
sort_mode='random';
is_sort=0;

%assign values from varagin
for cnt = 1: length(varargin)/2
  eval([varargin{cnt*2-1} '=varargin{cnt*2};']);
end


opt={};
obj_configs={};
optimization_opt={};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt.save=is_save; % save data
opt.CompCorr=CompCorr; % compute correlations
opt.Layer1only=Layer1only; % 1 for two-layer network, 0 for three-layer network
opt.loadS1=loadS1;
opt.plotPopR=plotPopR; % plot population rate
opt.fixW=fixW;  % use the same weight matrices for multiple simulations
opt.verbose=verbose;
opt.check_firing_rates=check_firing_rates;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj_configs.opt=opt;
obj_configs.filename=filename;
obj_configs.root=root;
obj_configs.is_surrogate=is_surrogate;
obj_configs.n_sampling=n_sampling; %number of samplings for estimating spike train stats
obj_configs.Tw=Tw; %window for binning spike trains
obj_configs.Tburn=Tburn; %length for burning to exclude transient spikes
obj_configs.T0=T0; % for surrogate
obj_configs.T_short=T_short; % when population stats are excluded
obj_configs.T=T; % when population stats are included
obj_configs.dt=dt;
obj_configs.N_groundtruth=N_groundtruth;
obj_configs.tolerance=tolerance;
obj_configs.metric_norm=metric_norm;
obj_configs.statistics_group=statistics_group;
obj_configs.survival_rate=survival_rate;
obj_configs.is_simulation=is_simulation;
obj_configs.is_small=is_small;
obj_configs.Ne=Ne;
obj_configs.Ni1=Ni1;
obj_configs.save_stats=save_stats;
obj_configs.dim_method = dim_method;
obj_configs.stats_weights = stats_weights;
obj_configs.n_neuron = n_neuron;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
optimization_opt.x_range=x_range;
optimization_opt.epsilon=epsilon;
optimization_opt.n_sample=n_sample;
optimization_opt.n_local=n_local;
optimization_opt.n_data=n_data; %number of random seed for BO
optimization_opt.max_iter=max_iter;
optimization_opt.max_time=max_time;
optimization_opt.std_tol=std_tol;
optimization_opt.min_cost_eval=min_cost_eval;
optimization_opt.max_cost_eval=max_cost_eval;
optimization_opt.n_check=n_check;
optimization_opt.is_log=is_log;
optimization_opt.base_name = strcat(root,base_name,'.mat');
optimization_opt.top_n=top_n;
optimization_opt.sort_mode=sort_mode;
optimization_opt.is_sort=is_sort;

  


%configure save filenames

filename=obj_configs.filename; %filename contains jobid!
stats_name=strcat(obj_configs.root,filename,'_stats.mat');
results_name=strcat(obj_configs.root,filename,'.mat');
obj_configs.stats_filename=config_statsfile(stats_name);
optimization_opt.save_name=results_name;



%configure base for intensifications
if ~isempty(base_name)
	[base_name] = base_real(obj_configs.real_data_name,optimization_opt.base_name,obj_configs.filename,optimization_opt.top_n,optimization_opt.sort_mode,obj_configs.stats_weights,optimization_opt.is_sort);
    optimization_opt.base_name = base_name;
else 
	optimization_opt.base_name = [];
end






end
