function [spike_train] =  SBN(input_para,T)
%input_para: [1, number of parameters to optimize]
%T: simulation length
%spike_train: [2, number of spikes], the first row is time (in ms), the
%second row is the neuron id. The first 1 - Ne neurons are E neurons, the
%rest are I neurons.

JrEX= input_para;
x= table(JrEX);
dt=0.05;
is_small=1;
Ne1=50;
Ni1=25;
ParamChange=configure_params(x,Ne1,Ni1,dt,T,is_small);

opt.save=0; % save data
opt.CompCorr=0; % compute correlations
opt.Layer1only=1; % 1 for two-layer network, 0 for three-layer network
opt.loadS1=0;
opt.plotPopR=0; % plot population rate
opt.fixW=0;  % use the same weight matrices for multiple simulations
opt.givenW=0;
opt.verbose=0;
opt.check_firing_rates=0;


[~,~,spike_train]=spatial_nn_simulation_weight(opt, ParamChange);



