% STEP2_COMPUTE_METRICS - Pipeline Stage 2: Graph Metrics Computation
%
% This script computes graph-theoretic metrics from dDTF and oAEC connectivity
% matrices using the Brain Connectivity Toolbox (BCT).
%
% WORKFLOW:
%   For each patient and state:
%     1. Load connectivity for all nights
%     2. Average: ADJAC = (night1 + night2 + night3 + night4) / N
%     3. For each frequency band:
%        - Preprocess: autofix, normalize
%        - Compute metrics using BCT functions
%     4. Save all metrics in one file per patient/state
%
%
% REQUIREMENTS:
%   - Stage 1 must be complete (step1_compute_connectivity.m)
%   - BCT toolbox must be available
%   - Patient metadata must exist: config/patient_metadata.mat

%% Initialize MATLAB path for pipeline
% Get project root directory 
project_root = fileparts(fileparts(mfilename('fullpath')));

% Add necessary directories to MATLAB path
addpath(fullfile(project_root, 'config'));
addpath(fullfile(project_root, 'src', 'utils'));
addpath(fullfile(project_root, 'src', 'connectivity'));
addpath(fullfile(project_root, 'src', 'metrics'));

% Load configuration
config = pipeline_config();

% Setup paths and toolboxes
setup_paths(config);


% Load patient metadata
patient_meta = load_patient_metadata(config);
n_included = sum(~[patient_meta.excluded]);


% Verify Stage 1 outputs exist
connectivity_dir = config.paths.connectivity_out;
if ~exist(connectivity_dir, 'dir')
    error(['Stage 1 connectivity outputs not found!\n' ...
           'Please run: pipelines/step1_compute_connectivity.m first']);
end

% Count connectivity files
conn_files = dir(fullfile(connectivity_dir, '**', '*_connectivity.mat'));

% Configure processing
patient_ids = 'all'; 

% Run batch graph metrics computation
start_time = tic;
results = batch_graph_metrics(patient_ids, config, patient_meta);

% Save results summary
results_file = fullfile(config.paths.metrics_out, ...
    'step2_metrics_results.mat');
save(results_file, 'results', '-v7');

