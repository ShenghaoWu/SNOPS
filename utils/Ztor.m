function r = Ztor(Z)
% r = Ztor(Z)
%
% ZTOR translates Z scores into Fisher r correlations
%  aka the "inverse Fisher r-to-Z' transformation"
%

% Matthew A. Smith
% Revised: 2014.06.18

r = (exp(2*Z) - 1) ./ (exp(2*Z) + 1);

