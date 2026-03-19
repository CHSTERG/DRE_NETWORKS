function create_patient_metadata(patient_data, output_file)
% CREATE_PATIENT_METADATA - Create patient metadata structure from input data
%
% This function creates a standardized patient metadata file that the
% pipeline uses to access patient-specific information.
%                         
%% Handle inputs
if nargin < 2 || isempty(output_file)
    % Default output location
    script_dir = fileparts(mfilename('fullpath'));
    output_file = fullfile(script_dir, 'patient_metadata.mat');
end

%% Convert input to standard structure format
if iscell(patient_data)

    n_patients = size(patient_data, 1);
    temp_data = struct();

    for p = 1:n_patients
        temp_data(p).id = patient_data{p, 1};
        temp_data(p).outcome = patient_data{p, 2};
        temp_data(p).resected_channels = patient_data{p, 3};
        temp_data(p).removed_indices = patient_data{p, 4};
        temp_data(p).n_nights = patient_data{p, 5};
    end

    patient_data = temp_data;
end

%% Validate input data
n_patients = length(patient_data);

for p = 1:n_patients
    % Check required fields
    assert(isfield(patient_data(p), 'id'), ...
        'Patient %d missing ''id'' field', p);
    assert(isfield(patient_data(p), 'outcome'), ...
        'Patient %d missing ''outcome'' field', p);
    assert(isfield(patient_data(p), 'resected_channels'), ...
        'Patient %d missing ''resected_channels'' field', p);

    % Validate outcome
    assert(ismember(patient_data(p).outcome, {'Good', 'Poor'}), ...
        'Patient %d outcome must be ''Good'' or ''Poor'', got: %s', ...
        p, patient_data(p).outcome);

    % Ensure resected_channels is a cell array
    if ischar(patient_data(p).resected_channels)
        patient_data(p).resected_channels = {patient_data(p).resected_channels};
    end

    % Set defaults for optional fields
    if ~isfield(patient_data(p), 'removed_indices')
        patient_data(p).removed_indices = [];
    end
    if ~isfield(patient_data(p), 'n_nights')
        patient_data(p).n_nights = [];  % Will be detected automatically
    end
end

%% Create patient metadata structure

% Initialize metadata structure
patient_meta = struct();

for p = 1:n_patients
    pid = patient_data(p).id;

    patient_meta(p).id = pid;
    patient_meta(p).outcome = patient_data(p).outcome;
    patient_meta(p).resected_channels = patient_data(p).resected_channels;
    patient_meta(p).removed_indices = patient_data(p).removed_indices;
    patient_meta(p).n_nights = patient_data(p).n_nights;

    % Initialize channel_labels (will be populated when loading data)
    patient_meta(p).channel_labels = {};

end

%% Save metadata file

% Create output directory if needed
output_dir = fileparts(output_file);
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% Save with compression
save(output_file, 'patient_meta', '-v7.3');

end
