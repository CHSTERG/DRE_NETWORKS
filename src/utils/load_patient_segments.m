function [data, metadata] = load_patient_segments(patient_id, night, state, config, patient_meta)
% LOAD_PATIENT_SEGMENTS - Load 3-second iEEG segments for a patient/night/state
%
% This function loads the segmented iEEG data and handles channel removal
% according to patient-specific configuration.
%
% INPUTS:
%   patient_id   - Patient ID number (e.g., 1, 2, 3, ...)
%   night        - Recording night number (1, 2, ...)
%   state        - Epileptic state: 'with HFOs' or 'without HFOs'
%   config       - Configuration structure
%   patient_meta - Patient metadata structure 

%% Validate inputs
assert(isnumeric(patient_id) && patient_id > 0, ...
    'patient_id must be a positive number');
assert(isnumeric(night) && night > 0, ...
    'night must be a positive number');
assert(ismember(state, config.data.state_names), ...
    'state must be ''with HFOs'' or ''without HFOs''');

%% Find patient in metadata
patient_idx = find([patient_meta.id] == patient_id);
if isempty(patient_idx)
    error('load_patient_segments:PatientNotFound', ...
        'Patient %d not found in metadata', patient_id);
end

%% Construct filename
filename = sprintf('patient%d_night%d_%s.mat', patient_id, night, state);

% Full path to segment file
patient_dir = sprintf('Patient_%02d', patient_id);
filepath = fullfile(config.paths.segments, patient_dir, filename);

% Check if file exists
if ~exist(filepath, 'file')
    error('load_patient_segments:FileNotFound', ...
        'Segment file not found: %s', filepath);
end

%% Load segment data

file_data = load(filepath);

if ~isfield(file_data, 'SEGMENTS')
    error('load_patient_segments:InvalidFile', ...
        'File does not contain SEGMENTS variable: %s', filepath);
end

SEGMENTS = file_data.SEGMENTS;

%% Concatenate 20 3-second segments into 60-second recording

if ~isfield(SEGMENTS, 'F') || length(SEGMENTS.F) ~= config.data.n_segments
    error('load_patient_segments:InvalidSegments', ...
        'Expected %d segments, found %d in file: %s', ...
        config.data.n_segments, length(SEGMENTS.F), filepath);
end

% Concatenate all segments vertically
data = [];
for seg = 1:config.data.n_segments
    data = [data; SEGMENTS.F{seg}];
end

%% Extract channel information
if isfield(SEGMENTS, 'channel_names')
    channel_names = SEGMENTS.channel_names;
else
    warning('load_patient_segments:NoChannelNames', ...
        'No channel names found in file: %s', filepath);
    n_chans = size(data, 2);
    channel_names = arrayfun(@(x) sprintf('Chan%02d', x), 1:n_chans, 'UniformOutput', false);
end

if isfield(SEGMENTS, 'channel_locations')
    channel_locations = SEGMENTS.channel_locations;
else
    channel_locations = {};
end

%% Remove specified channels
removed_indices = patient_meta(patient_idx).removed_indices;

if ~isempty(removed_indices)
    % Remove channels from data
    data(:, removed_indices) = [];

    % Remove from channel information
    channel_names(removed_indices) = [];

    if ~isempty(channel_locations)
        channel_locations(removed_indices) = [];
    end

end

%% Build metadata structure
metadata = struct();
metadata.channel_names = channel_names;
metadata.channel_locations = channel_locations;
metadata.patient_id = patient_id;
metadata.night = night;
metadata.state = state;
metadata.fs = config.data.sampling_rate;
metadata.n_channels = length(channel_names);
metadata.n_samples = size(data, 1);
metadata.removed_indices = removed_indices;
metadata.filename = filename;

%% Validate output
expected_samples = config.data.n_segments * config.data.segment_duration * config.data.sampling_rate;
if metadata.n_samples ~= expected_samples
    warning('load_patient_segments:UnexpectedLength', ...
        'Expected %d samples, got %d in file: %s', ...
        expected_samples, metadata.n_samples, filepath);
end

end
