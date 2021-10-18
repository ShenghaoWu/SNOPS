function [Ic1] = sample_e_neurons(s1,Ne1,is_simulation)
%would always st is_simulation b/c no periodic boundary condition
if  is_simulation   
	Ic1=transpose(unique(s1(2,:)));
	Ic1=Ic1(Ic1<=Ne1^2);

else
	I1=transpose(unique(s1(2,:)));
	I1=I1(I1<=Ne1^2);
	Ix10=(ceil(I1/Ne1))/Ne1;
	Iy10=(mod((I1-1),Ne1)+1)/Ne1;
	I1=I1(Ix10<0.75 & Ix10>0.25 & Iy10<0.75 & Iy10>0.25);
    Ic1 = I1;
end