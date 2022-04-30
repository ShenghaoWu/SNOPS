Code package for SNOPS (Spiking Network Optimization using Population Statistics).  
For more details, see the paper

_Automated customization of large-scale spiking network models to neuronal population activity_    Shenghao Wu, Chengcheng Huang, Adam Snyder, Matthew Smith*, Brent Doiron*, and Byron Yu*

**The following toolboxes are required to run the code:**
1. Signal Processing Toolbox
2. Statistics and Machine Learning Toolbox

**If you are running the code on mac OS, the mex files (EIF1DRFfastslowSyn.mexa64 and spktime2count.mexa64) in the /utils folder may be blocked due to security measures. There are two options to solve this issue:**
1. Override the security protocals by typing the following code on the command line interface (replace the path with the one in your local system):

sudo xattr -r -d com.apple.quarantine /path/to/utils
 
2. If you don't not want to override system security protocals, you may compile the code on your own after deleting the existing mex files. Open the Matlab commandline, move to the utils folder, and type:
mex EIF1DRFfastslowSyn.c 
mex spktime2count.c



The file structure is as follows:

- **data**: contains sample target spike train and the log file for the optimization
	- **save_name.mat**: optimization log file. Contains the parameter sets (x_train), cost (y_train), running time (optimization_time), and feasibility (y_feasibility) of each iteration.
	- **save_name_stats.mat**: activity statistics log file. Contains the parameter sets (paras), activity statistics of the full simulation (full_stats), activity statistics of the surrogate simulation (surrogate_stats), running time for the full and surrogate statistics (execution_time) of each parameter set evaluated. Note that the number of rows may exceed that in the optimization log file because there may be multiple evaluations of the same parameter set for one optimization iteration.

- **utils**: contains helper functions
    - **fa_Yu**: functions for performing Factor Analysis, written by Byron Yu (https://users.ece.cmu.edu/~byronyu/software.shtml)
    
- **example.m**: contains a short demo where a spatial balanced spiking network is fitted to a target spike train generated by the same type of network with a ground truth parameter set. Expect 10-15 mins to run the demo.

- **SNOPS.m**: main fitting function. The following eight input variables need to be specified:
    - target_train_name:  [2, number of spikes], spike trains to fit the network model to. The first row is time (in ms), the second row is the neuron id. The first Ne neurons are E neurons, the rest are I neurons. If your spike train has the shape [number of neurons, number of timesteps], you can use /utils/spiketrain_to_spiketime.m to convert it to the required format.  
    - simulator: function handle to network model. See /utils/SBN.m for details of the input/output of this function.
    - parameter_range:  [n_parameters, 2], range of parameters. First and second columns are lower and upper bounds.
    - max_iter: int, stopping criterion (in iterations).
    - T: int, network model simulation length (in ms). We recommend using the same length as the target spike train for consistency.
    - Ne: int, number of E neurons in the read-out layer. This is the neurons on which activity statistics are computed
    - save_name: string, name of the log file for optimization. This is located in the data folder and can be used to check the details of the optimization for each iteration.
    - is_plot: int(0/1), if illustrative plot is needed. If turned off, fitting information will be printed in the stout.


 
