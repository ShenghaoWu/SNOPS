function x = ibuild_cbn_paras(taudsynI,taudsynE,JrEI, JrIE, JrII, JrEE,JrEX,JrIX)
	mean_sigmaRRIs=1e6;
	mean_sigmaRREs=1e6;
	mean_sigmaRXs=1e6;

	x=table(taudsynI,taudsynE,mean_sigmaRRIs,mean_sigmaRREs, mean_sigmaRXs, JrEI, JrIE, JrII, JrEE,JrEX,JrIX);
