% STEP1_COMPUTE_CONNECTIVITY - Pipeline Stage 1: dDTF Connectivity Computation
%
% This script computes dDTF-based connectivity matrices for all patients
% using FieldTrip's MVAR analysis pipeline.
%
% WHAT THIS SCRIPT DOES:
%   1. Loads configuration and patient metadata
%   2. Sets up toolbox paths (FieldTrip, BCT)
%   3. Processes all patients, nights, and epileptic states
%   4. Computes 8 frequency band adjacency matrices per recording
%   5. Saves results to results/connectivity/dDTF/
%
% REQUIREMENTS:
%   - Patient metadata must exist
%   - FieldTrip toolbox must be available

%% Initialize MATLAB path for pipeline
% Get project root directory
project_root = fileparts(fileparts(mfilename('fullpath')));

% Add necessary directories to MATLAB path
addpath(fullfile(project_root, 'config'));
addpath(fullfile(project_root, 'src', 'utils'));
addpath(fullfile(project_root, 'src', 'connectivity'));

% Load configuration
config = pipeline_config();

% Setup paths and toolboxes
setup_paths(config);

% Load patient metadata
patient_meta = load_patient_metadata(config);
n_included = sum(~[patient_meta.excluded]);

% Configure processing
patient_ids = 'all';  % Change this to process specific patients

% Run batch connectivity computation
start_time = tic;
results = batch_connectivity(patient_ids, config, patient_meta);

% Save results summary
results_file = fullfile(config.paths.connectivity_out, ...
    'step1_connectivity_results.mat');
save(results_file, 'results', '-v7');