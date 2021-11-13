function [s1] = spiketrain_to_spiketime(spiketrain)

n=sum(spiketrain(:)==1); 
s1=zeros(2,n);


inds=spiketrain.*(1:size(spiketrain,1))';
inds=inds(:);
inds=inds(inds~=0);

time=spiketrain.*(1:size(spiketrain,2));
time=time(:);
time=time(time~=0);

s1(1,:)=time;
s1(2,:)=inds;