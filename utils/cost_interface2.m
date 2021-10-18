function [result] = cost_interface2(x,is_surrogate,fun)
    %tmp=x;
    %load('./q/demo_june12.mat')
    %load('./q/june13_demo1.mat')
    JrEX= x;
    input_paras= table(JrEX);
    %input_paras = x;
	%input_paras.JrEX=tmp;
	%input_paras.mean_sigmaRRIs= tmp(2);
	result=fun(input_paras,is_surrogate);
end