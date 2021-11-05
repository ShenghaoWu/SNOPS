function [rate0, var0, FanoFactor0, mean_corr0, unstable_flag, sampling_inds, re,low_rate_flag] = compute_stats(s1,Ic1,Tw,Tburn,n_sampling, n_neuron,check_stability) 
%compute the single-neuron and pairwise statistics of the spike train

low_rate_flag=0;
unstable_flag=0;

rate_th = 0.5;
s1=s1(:,ismember(s1(2,:), Ic1));
T_total=max(s1(1,:));
s1=s1(:,s1(1,:)>=Tburn&s1(1,:)<=T_total); 
s1(1,:)=s1(1,:)-Tburn;
re=spktime2count(s1,unique(s1(2,:)),Tw,floor((T_total-Tburn)/Tw),0);

unstable_flag=is_unstable(re);
unstable_flag=0;%%!!!
if unstable_flag
    rate0=NaN;
    var0=NaN;
    FanoFactor0=NaN;
    mean_corr0=NaN;
    sampling_inds=NaN;
    re=NaN;
    warning('long transient oscillation, unstable simulation!')
    return 
end

re=re(mean(re,2)*1000/Tw>rate_th,:);

if check_stability
    low_rate_flag= (size(re,1)<n_neuron) | (mean(mean(re,2))*1000/Tw>60) ; %mar 27: add high thres rejection
    if low_rate_flag
        rate0=NaN;
        var0=NaN;
        FanoFactor0=NaN;
        mean_corr0=NaN;
        sampling_inds=NaN;
        re=NaN;
        warning('too few neurons fire > threshold, low rate!')
        return 
    end
end

%{



if mean(mean(re,2))*1000/Tw <2

    rate_flag=1;
    return
end

xpdf=sort(mean(re,1));
try
    [~, p_value, ~, ~] = HartigansDipSignifTest(xpdf, 500);
catch
    warning('dip test failed, likely due to bad spike trains')
    return
end
if  p_value<0.05
    rate0=NaN;
    var0=NaN;
    FanoFactor0=NaN;
    mean_corr0=NaN;
    sampling_inds=NaN;
    return
end
%}

%re=re(mean(re,2)*1000/Tw>2,:);%only sample neurons > 2hz
[sampling_inds]=random_sample_neurons(1:size(re,1),n_sampling, n_neuron);
rate0s=zeros(n_sampling,1);
var0s=zeros(n_sampling,1);
FanoFactor0s=zeros(n_sampling,1);
mean_corr0s=zeros(n_sampling,1);
for cnt = 1:n_sampling
    tmp = re(sampling_inds(cnt,:),:);
    [rate0,var0, FanoFactor0, mean_corr0]=compute_statistics_only(tmp);
    rate0s(cnt)=rate0*1000/Tw; % look at all neurons for rate
    var0s(cnt)=var0;
    FanoFactor0s(cnt)=FanoFactor0;
    mean_corr0s(cnt)=mean_corr0;
end

rate0=mean(rate0s,1);
var0=mean(var0s,1);
FanoFactor0=mean(FanoFactor0s,1);
mean_corr0=mean(mean_corr0s,1);

if isnan(rate0) || isnan(var0) || isnan(FanoFactor0) || isnan(mean_corr0)
    error('invalid stats, possibly due to low firing rate and <=1 neuron passes the rate threshold!')
end

end
