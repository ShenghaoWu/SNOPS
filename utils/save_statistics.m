function  save_statistics(stats_weights,paras_tmp,full_stats_tmp,surrogate_stats_tmp,execution_time_tmp,stats_filename)

try
	load(stats_filename);
	paras=[paras; paras_tmp];
	full_stats=[full_stats;full_stats_tmp];
	surrogate_stats=[surrogate_stats;surrogate_stats_tmp];
	execution_time=[execution_time;execution_time_tmp];
	save(stats_filename,'stats_weights','paras','full_stats','surrogate_stats','execution_time');
catch
	try
		load(stats_filename);
		paras=[paras; paras_tmp];
		full_stats=[full_stats;full_stats_tmp];
		surrogate_stats=[surrogate_stats;surrogate_stats_tmp];
		execution_time=[execution_time;execution_time_tmp];
		save(stats_filename,'stats_weights','paras','full_stats','surrogate_stats','execution_time');
	
	catch 
	end

end

end
