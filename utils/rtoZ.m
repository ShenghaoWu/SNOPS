function Z = rtoZ(r)
% Z = rtoZ(r)
%
% RTOZ translates fisher r correlations into Z scores
%  aka the "Fisher r-to-Z' transformation"
%

% Matthew A. Smith
% Revised: 2001.04.21

if (~isempty(find(r<-1,1)) || ~isempty(find(r>1,1))) & ~isnan(r)
    error('r values must be bounded by -1 and 1');
end

Z = 0.5 * log((1 + r-1e-6) ./ (1 - (r-1e-6)));
end