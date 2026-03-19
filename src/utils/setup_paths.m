function setup_paths(config)
% SETUP_PATHS - Add required toolbox paths and validate directories
%
% This function adds all necessary external toolboxes to the MATLAB path
% and validates that required directories exist.
%
% INPUT:
%   config - Configuration structure 

%% Validate configuration input
if ~isstruct(config)
    error('setup_paths: config must be a structure. Use config = pipeline_config() first.');
end

%% Add external toolboxes to path 
toolboxes = {'fieldtrip', 'bct'};
toolbox_names = {'FieldTrip', 'Brain Connectivity Toolbox'};

for i = 1:length(toolboxes)
    toolbox = toolboxes{i};
    toolbox_path = config.paths.(toolbox);

    % Check if toolbox directory exists
    if ~exist(toolbox_path, 'dir')
        warning('setup_paths:MissingToolbox', ...
            '%s directory not found: %s\nPlease update config.paths.%s', ...
            toolbox_names{i}, toolbox_path, toolbox);
        continue;
    end

    % Add to path
    addpath(genpath(toolbox_path));

end

%% Initialize FieldTrip 
if ~isempty(config.paths.fieldtrip) && exist(config.paths.fieldtrip, 'dir')
    try
        
        ft_defaults;  

    catch ME
        warning('setup_paths:FieldTripInit', ...
            'Failed to initialize FieldTrip: %s', ME.message);
    end
end

%% Validate input directories

% Check segments directory
if ~exist(config.paths.segments, 'dir')
    error('setup_paths:MissingData', ...
        'Segments directory not found: %s\nPlease update config.paths.segments', ...
        config.paths.segments);
end

% Check patient metadata file 
if ~exist(config.paths.patient_metadata, 'file')
    warning('setup_paths:MissingMetadata', ...
        ['Patient metadata file not found: %s\n', ...
        'Run config/patient_data_template.m to create it.'], ...
        config.paths.patient_metadata);
end

%% Create output directories if they don't exist
output_dirs = {
    config.paths.output_root
    config.paths.connectivity_out
    config.paths.metrics_out
    config.paths.stats_out
    config.paths.classification_out
    config.paths.figures_out
};

n_created = 0;
for i = 1:length(output_dirs)
    if ~exist(output_dirs{i}, 'dir')
        mkdir(output_dirs{i});
        n_created = n_created + 1;
    end
end

 %% Add src directory to path
 src_path = fullfile(config.paths.project_root, 'src');
 if  exist(src_path, 'dir')
     addpath(genpath(src_path));
 end

end
