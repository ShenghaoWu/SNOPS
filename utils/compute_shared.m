function [percentshared, d_shared,normevals] = compute_shared(estParams, thresh, normalize)
% compute three population statistics given FA infered parameters 


%% extract parameters
       
       
L = estParams.L;
Ph = estParams.Ph;
     
%% compute d_shared
if ~isempty(L)
    shared = L*L';
    evals = eig(shared);
    if normalize
        normevals = sort(evals,'descend')/sum(evals);
    else 
        normevals = sort(evals,'descend');
    end
    d_shared = sum(cumsum(normevals/sum(normevals))<thresh)+1;
else
    d_shared = 0;
    percentshared = 0;
end

%% compute % shared variance
        if ~isempty(L) && ~isempty(Ph)
            sharedvar = diag(L*L');
            percentshared = mean(sharedvar./(sharedvar+Ph));
        else
            percentshared = 0;
        end
end