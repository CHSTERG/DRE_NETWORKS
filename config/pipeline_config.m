function config = pipeline_config()
%
% This function returns a configuration structure containing all parameters
% needed to run the iEEG connectivity analysis pipeline.
%
% HOW TO EDIT THIS FILE:
%   1. Open this file in any text editor or MATLAB editor
%   2. Modify the values you want to change (e.g., config.ml.n_iterations = 200)
%   3. Save the file
%   4. The changes will take effect next time you run the pipeline

%% PATH CONFIGURATION
%
%  IMPORTANT: You need to set these paths to match YOUR system!

config.paths = struct();

% Root directory of this project
config.paths.project_root = fileparts(fileparts(mfilename('fullpath')));

% Directory containing the original data
config.paths.data_root = fullfile(config.paths.project_root, ...
    'Replace with your data folder');

% Input data paths
config.paths.segments = fullfile(config.paths.data_root, ...
    'Replace with your segments forlder');

% Output paths for new refactored pipeline
config.paths.output_root = fullfile(config.paths.project_root, 'results');
config.paths.connectivity_out = fullfile(config.paths.output_root, 'connectivity');
config.paths.metrics_out = fullfile(config.paths.output_root, 'metrics');
config.paths.stats_out = fullfile(config.paths.output_root, 'statistics');
config.paths.classification_out = fullfile(config.paths.output_root, 'classification');
config.paths.figures_out = fullfile(config.paths.output_root, 'figures');

% Patient metadata file
config.paths.patient_metadata = fullfile(config.paths.project_root, ...
    'config', 'patient_metadata.mat');

% REQUIRED TOOLBOXES FOR dDTF PIPELINE:
% 1. FieldTrip - For MVAR analysis and dDTF computation
% 2. Brain Connectivity Toolbox (BCT) - For graph metrics

% FieldTrip path 
config.paths.fieldtrip = 'Replace with your Fieldtrip folder';

% Brain Connectivity Toolbox path 
config.paths.bct = 'Replace with your BCT folder';

%% FREQUENCY BAND DEFINITIONS
%  
%  Define the frequency ranges (in Hz) for each band of interest

config.freq_bands = struct();
config.freq_bands.delta = [2, 4];            % Delta: 2-4 Hz
config.freq_bands.theta = [5, 7];            % Theta: 5-7 Hz
config.freq_bands.alpha = [8, 12];           % Alpha: 8-12 Hz
config.freq_bands.beta = [15, 29];           % Beta: 15-29 Hz
config.freq_bands.gamma1 = [30, 59];         % Low Gamma: 30-59 Hz
config.freq_bands.gamma2 = [60, 79];         % High Gamma: 60-79 Hz
config.freq_bands.ripples = [80, 249];       % Ripples: 80-249 Hz
config.freq_bands.fast_ripples = [250, 500]; % Fast Ripples: 250-500 Hz

% Get ordered list of frequency band names
config.freq_band_names = {'delta', 'theta', 'alpha', 'beta', ...
    'gamma1', 'gamma2', 'ripples', 'fast_ripples'};

%% DATA PROCESSING PARAMETERS

config.data = struct();

% Sampling rate (Hz)
config.data.sampling_rate = 2000;

% Number of 3-second segments per condition (20 segments × 3 seconds = 60 seconds total per condition)
config.data.n_segments = 20;
config.data.segment_duration = 3; 

% State names
config.data.state_names = {'with HFOs', 'without HFOs'};

%% CONNECTIVITY COMPUTATION PARAMETERS

config.connectivity = struct();

% Direct Directed Transfer Function (dDTF) Parameters 
config.connectivity.ddtf = struct();
config.connectivity.ddtf.mvar_order = 10;  
config.connectivity.ddtf.toi = 0:0.005:59.99;  
config.connectivity.ddtf.foi = 1:500;          
config.connectivity.ddtf.t_ftimwin = 1./config.connectivity.ddtf.foi; 
config.connectivity.ddtf.taper = 'hanning';    

%% GRAPH METRICS PARAMETERS

config.graph = struct();

% Metrics to compute (using Brain Connectivity Toolbox functions)
config.graph.metrics = {'CC', 'STRENGTH'};

% Normalization method for metrics
config.graph.normalization = 'min-max'; 

% Network types 
config.graph.directed_methods = {'dDTF'};  
config.graph.undirected_methods = {'oAEC'};

%% PIPELINE EXECUTION OPTIONS

config.options = struct();

% Verbosity level
config.options.verbose = 2;

% Save intermediate results
config.options.save_intermediate = true;

end
