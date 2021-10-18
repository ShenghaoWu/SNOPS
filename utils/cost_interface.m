function [result] = cost_interface(x,is_surrogate,fun)

if length(x) == 8
	taudsynI=x(1);
	taudsynE=x(2);
	JrEI= x(3);
	JrIE= x(4);
	JrII= x(5);
	JrEE= x(6);
	JrEX= x(7);
	JrIX= x(8);
	input_paras=table(taudsynI,taudsynE,JrEI, JrIE, JrII, JrEE,JrEX,JrIX);
	result=fun(input_paras,is_surrogate);

else

	taudsynI=x(1);
	taudsynE=x(2);
	mean_sigmaRRIs=x(3);
	mean_sigmaRREs=x(4);
	mean_sigmaRXs= x(5);
	JrEI= x(6);
	JrIE= x(7);
	JrII= x(8);
	JrEE= x(9);
	JrEX= x(10);
	JrIX=x(11);
	input_paras=table(taudsynI,taudsynE,mean_sigmaRRIs,mean_sigmaRREs, mean_sigmaRXs, JrEI, JrIE, JrII, JrEE,JrEX,JrIX);
	result=fun(input_paras,is_surrogate);


end