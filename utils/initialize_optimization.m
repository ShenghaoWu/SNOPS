function [opt,obj_configs] = initialize_optimization(true_stats_file)

	taudsynE = optimizableVariable('taudsynE',[1 25],'Type','real');
	taudsynI = optimizableVariable('taudsynI',[1 25],'Type','real');
	%taursyn1 = optimizableVariable('taursyn1',[0,25],'Type','real');
	taursynE = optimizableVariable('taursynE',[0 25],'Type','real');
	taursynI = optimizableVariable('taursynI',[0 25],'Type','real');
	sigmaRREE = optimizableVariable('sigmaRREE',[0 0.5],'Type','real');
	sigmaRREI = optimizableVariable('sigmaRREI',[0 0.5],'Type','real');
	sigmaRRIE = optimizableVariable('sigmaRRIE',[0 0.5],'Type','real');
	sigmaRRII = optimizableVariable('sigmaRRII',[0 0.5],'Type','real');
	mean_sigmaRRIs = optimizableVariable('mean_sigmaRRIs',[0 0.25],'Type','real');
	mean_sigmaRREs= optimizableVariable('mean_sigmaRREs',[0 0.25],'Type','real');
	mean_sigmaRXs= optimizableVariable('mean_sigmaRXs',[0 0.25],'Type','real');

	mean_JrIs = optimizableVariable('mean_JrIs',[-200 0],'Type','real');
	mean_PrrIs=optimizableVariable('mean_PrrIs',[0 1],'Type','real');
	PrrEE = optimizableVariable('PrrEE',[0 0.5],'Type','real');
	PrrEI = optimizableVariable('PrrEI',[0 0.5],'Type','real');
	PrrIE = optimizableVariable('PrrIE',[0 0.5],'Type','real');
	PrrII = optimizableVariable('PrrII',[0 0.5],'Type','real');
	JrEE = optimizableVariable('JrEE',[0 150],'Type','real');
	JrEI = optimizableVariable('JrEI',[-150 0],'Type','real');
	JrIE = optimizableVariable('JrIE',[0 150],'Type','real');
	JrII = optimizableVariable('JrII',[-150 0],'Type','real');
	taudsynX = optimizableVariable('taudsynX',[1 25],'Type','real');
	taursynX = optimizableVariable('taursynX',[0 25],'Type','real');
	sigmaREX = optimizableVariable('sigmaREX',[0 0.25],'Type','real');
	sigmaRIX = optimizableVariable('sigmaRIX',[0 0.25],'Type','real');
	PrrEX = optimizableVariable('PrrEX',[0 0.5],'Type','real');
	PrrIX = optimizableVariable('PrrIX',[0 0.5],'Type','real');
	JrEX = optimizableVariable('JrEX',[0 150],'Type','real');
	JrIX = optimizableVariable('JrIX',[0 150],'Type','real');
	PstimRX=optimizableVariable('PstimRX',[0 0.5],'Type','real');

    assignin('base','taudsynE',taudsynE);
    assignin('base','taudsynI',taudsynI);
    assignin('base','taursynE',taursynE);
    assignin('base','taursynI',taursynI);
    assignin('base','sigmaRREE',sigmaRREE);
    assignin('base','sigmaRREI',sigmaRREI);
	assignin('base','sigmaRRIE',sigmaRRIE);
    assignin('base','sigmaRRII',sigmaRRII);
    assignin('base','mean_sigmaRRIs',mean_sigmaRRIs);
    assignin('base','mean_sigmaRREs',mean_sigmaRREs);
    assignin('base','mean_sigmaRXs',mean_sigmaRXs);
    assignin('base','mean_JrIs',mean_JrIs);
    assignin('base','mean_PrrIs',mean_PrrIs);
    assignin('base','PrrEE',PrrEE);
    assignin('base','PrrEI',PrrEI);
    assignin('base','PrrIE',PrrIE);
    assignin('base','PrrII',PrrII);
    assignin('base','JrEE',JrEE);
    assignin('base','JrEI',JrEI);
    assignin('base','JrIE',JrIE);
    assignin('base','JrII',JrII);
    assignin('base','taudsynX',taudsynX);
    assignin('base','taursynX',taursynX);
    assignin('base','sigmaREX',sigmaREX);
    assignin('base','sigmaRIX',sigmaRIX);
    assignin('base','PrrEX',PrrEX);
    assignin('base','PrrIX',PrrIX);
    assignin('base','JrEX',JrEX);
    assignin('base','JrIX',JrIX);
    assignin('base','PstimRX',PstimRX);
	
	load(true_stats_file);
	opt.save=0; % save data
	opt.CompCorr=0; % compute correlations
	opt.Layer1only=1; % 1 for two-layer network, 0 for three-layer network
	opt.loadS1=0;
	opt.plotPopR=0; % plot population rate
	opt.fixW=0;  % use the same weight matrices for multiple simulations
	opt.verbose=0;
	opt.check_firing_rates=0;
	obj_configs.opt=opt;
	obj_configs.nrealizations=1;
	obj_configs.ntrials=1;
	obj_configs.n_sampling=1;
	obj_configs.Tburn=500;
	obj_configs.Tburn_fa=500;
	obj_configs.T0=10000;
	obj_configs.T_short=20000;
	obj_configs.T=140000;
	obj_configs.dt=0.05;
	obj_configs.N_groundtruth=50000;
	obj_configs.true_statistics=true_statistics;
	obj_configs.tolerance=10;
	obj_configs.metric_norm='L2';
	obj_configs.statistics_group='1'

end