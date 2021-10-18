clear; clc; close all;
% user specifies: the name of the file containing the statistics to fit,
% the name of the output file, plot/not.
target_stats_name = 'demo_target_stats';
save_file_name = 'example';
is_plot = 1;
SNOPS(target_stats_name,save_file_name,is_plot);
