function [sampling_inds]=random_sample_neurons(Ic1,n_sampling, n_neuron) 

sampling_inds = zeros(n_sampling, n_neuron);
for cnt = 1:n_sampling
    sampling_inds(cnt,:) = randsample(Ic1,n_neuron);
end

end