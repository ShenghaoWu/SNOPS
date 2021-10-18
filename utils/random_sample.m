function [x_star] = random_sample(x_range)

rng shuffle;

lb = x_range(:,1)';
ub = x_range(:,2)';
x_star = (ub-lb).*rand(1,size(x_range,1)) + lb;


end