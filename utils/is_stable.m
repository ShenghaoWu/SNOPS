function [stable_flag]=is_stable(re) 

%check if the mean of first 5 entires is within 3 std of the mean of the last 5 entries
%to rule out the case of long transient oscillation
stable_flag = abs(mean(mean(re(:,1:5),1))-mean(mean(re(:,end-4:end),1)))<3*std(mean(re(:,end-4:end),1));

