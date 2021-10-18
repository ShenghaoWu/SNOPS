function filename=config_statsfile(filename)

try 
	load(filename);
	warning('filename exists!!!!!!!!!!!!!!!!!!!!!!!')

catch
	paras=[];
	full_stats=[];
	surrogate_stats=[];
	execution_time=[];
	save(filename,'paras','full_stats','surrogate_stats','execution_time');
end