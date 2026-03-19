function patient_meta = load_patient_metadata(config)
% LOAD_PATIENT_METADATA - Load and validate patient metadata
%
% Loads the patient metadata file containing surgical outcomes,
% resected channels, and other patient-specific information.
%
% INPUT:
%   config - Configuration structure
%
% OUTPUT:
%   patient_meta - Structure array with fields:
%       .id                - Patient ID number
%       .outcome           - Surgical outcome ('Good' or 'Poor')
%       .resected_channels - Cell array of resected channel names
%       .removed_indices   - Indices of channels to exclude
%       .n_nights          - Number of recording nights
%       .channel_labels    - Cell array of all channels with status

%% Load metadata file
if ~exist(config.paths.patient_metadata, 'file')
    error("load_patient_metadata:FileNotFound");
end

% Load the metadata
data = load(config.paths.patient_metadata);

if ~isfield(data, 'patient_meta')
    error('load_patient_metadata:InvalidFile', ...
        'Metadata file does not contain ''patient_meta'' variable');
end

patient_meta = data.patient_meta;

%% Validate metadata structure

required_fields = {'id', 'outcome', 'resected_channels'};
for p = 1:length(patient_meta)
    for f = 1:length(required_fields)
        if ~isfield(patient_meta(p), required_fields{f})
            error('load_patient_metadata:MissingField', ...
                'Patient %d missing required field: %s', ...
                patient_meta(p).id, required_fields{f});
        end
    end

    % Validate outcome values
    if ~patient_meta(p).excluded
        if ~ismember(patient_meta(p).outcome, {'Good', 'Poor'})
            error('load_patient_metadata:InvalidOutcome', ...
                'Patient %d has invalid outcome: %s (must be ''Good'' or ''Poor'')', ...
                patient_meta(p).id, patient_meta(p).outcome);
        end
    end
end

end
