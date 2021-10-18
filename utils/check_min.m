function [I,J]= check_min(x_trains,y_trains,parass,stats,jobid,stats_weights_binary)



[IS,JS] = mink(y_trains, length(y_trains));



is_valid = 0;

if stats_weights_binary(jobid,3) ==1
	for i = 1:length(y_trains)


	    J=JS(i);
	    pa1 = x_trains(J,1);
	    J = parass{:,1} == pa1;
	    pas = parass{J,:};
	    pas = pas(1,:);
	    tmp=mean(stats{J,[2,4:end]},1);

	    if ~((tmp(3)>=0.025 & tmp(6)>=10))  %(tmp(1)<=60 & tmp(6)<=30) 
	    	I = IS(i);
	    	J = JS(i);
	    	return
	    end

	end

end

[I,J]=min(y_trains);