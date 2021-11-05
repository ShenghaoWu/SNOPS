function [Ic1] = sample_e_neurons(s1,Ne)
%would always st is_simulation b/c no periodic boundary condition
Ic1=transpose(unique(s1(2,:)));
Ic1=Ic1(Ic1<=Ne);

end