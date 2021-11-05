function [fa_percentshared100, fa_normevals100, fa_dshared100] = compute_pop_stats(sampling_inds, re, n_neuron, Tw, dim_method)
%compute the population statistics of the spike count vector


n_samples=size(sampling_inds,1);
fa_percentshared100=zeros(n_samples,1);
fa_normevals100=zeros(n_samples,n_neuron);
fa_dshared100=zeros(n_samples,1);
		
for k =1:n_samples
	tmp = re(sampling_inds(k,:),:);
    %tmp=tmp(mean(tmp,2)*1000/Tw>rate_th,:);
    if rcond(cov(tmp')) <1e-8
    	n_latent=1;
    else
    	switch dim_method
			case 'PA'
				[n_latent] = PA_dim(tmp);
			case 'CV'
				[n_latent] = CV_dim(tmp);
			case 'CV_skip'
				[n_latent] = CV_skip(tmp);
			case 'overfit'
				[n_latent] = size(tmp,1)-1;
		end
    end

	if n_latent==0
		fa_percentshared100(k)=0;
		fa_normevals100(k,1:size(tmp,1))=repelem(0,size(tmp,1));
		fa_dshared100(k)=0;
	else 
			[estParams, ~]=fastfa(tmp,n_latent);
			[percentshared, d_shared, normevals] = compute_shared(estParams, 0.95,0);
			fa_percentshared100(k)=percentshared;
			fa_normevals100(k,1:size(tmp,1))=normevals(1:size(tmp,1));
			fa_dshared100(k)=d_shared;

	end
end

fa_percentshared100=mean(fa_percentshared100,1);
%{
if any(fa_dshared100==0) & max(unique(fa_dshared100))<=1
	fa_normevals100= mean(zeros(n_samples,n_neuron),1);
else 
	fa_normevals100=mean(fa_normevals100,1);
end
%}
fa_normevals100=mean(fa_normevals100,1);
fa_dshared100=mean(fa_dshared100,1);
end

function [n_latent] = PA_dim(tmp)
	tmp=tmp';
	nperm=300;
	prctile_level=100;
	%tmp=tmp-mean(tmp,1);
	svd_x = svd(tmp);
	svd_perm = zeros(nperm,size(tmp,2));
	for np = 1: nperm
		for ncol=1:size(tmp,2)
			tmp(:,ncol)=tmp(randperm(size(tmp,1)),ncol);
		end
		svd_perm(np,:)=svd(tmp);
	end
	cpr_ind=svd_x>prctile(svd_perm,prctile_level,1)';
	n_latent=find(cpr_ind(2:end)==0,1);
	if isempty(n_latent)
		n_latent = size(tmp,2);
	end
end

function [n_latent] = CV_dim(tmp)
	zDimList=1:ceil(size(tmp,1)/2);
	dim = crossvalidate_fa(tmp,'zDimList',zDimList,'numFolds',5,'tol',1e-5);
		% Identify optimal latent dimensionality
	n_latent = zDimList(find([dim.sumLL] == max([dim.sumLL])));

end



function [n_latent] = CV_skip(tmp)
	try
		zDimList=[0,1:2:floor(size(tmp,1)/2)];
		dim = crossvalidate_fa(tmp,'zDimList',zDimList,'numFolds',5,'tol',1e-5);
		n_latent = zDimList(find([dim.sumLL] == max([dim.sumLL])));
		if  n_latent == 1
			dim_local = crossvalidate_fa(tmp,'zDimList',[2],'numFolds',5,'tol',1e-5);
			LL = [ [dim_local.sumLL],max([dim.sumLL])];
			zDimList = [2,1];
		
		elseif n_latent == max(zDimList)
			dim_local = crossvalidate_fa(tmp,'zDimList',[max(zDimList)-1],'numFolds',5,'tol',1e-5);
			LL = [ [dim_local.sumLL],max([dim.sumLL])];
			zDimList = [max(zDimList)-1,max(zDimList)];	

		elseif n_latent == 0
			return
		else 
			dim_local = crossvalidate_fa(tmp,'zDimList',[n_latent-1,n_latent+1],'numFolds',5,'tol',1e-5);
			LL = [ [dim_local.sumLL],max([dim.sumLL])];
			zDimList = [n_latent-1,n_latent+1,n_latent];	
		end
		n_latent = zDimList(find([LL] == max([LL])));
	catch 
		n_latent=1;
	end
end
