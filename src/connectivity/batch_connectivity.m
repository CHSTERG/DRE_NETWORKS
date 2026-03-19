function results = batch_connectivity(patient_ids, config, patient_meta)
% BATCH_CONNECTIVITY - Compute dDTF connectivity for multiple patients
%
% INPUTS:
%   patient_ids  - Vector of patient IDs to process (e.g., [1, 2, 3])
%                  Use 'all' to process all included patients
%   config       - Configuration structure from pipeline_config()
%   patient_meta - Patient metadata from load_patient_metadata()
%
% OUTPUT:
%   results - Structure summarizing processing:
%       .n_patients         - Number of patients processed
%       .n_total_files      - Total adjacency matrices computed
%       .patient_summary    - Per-patient statistics

%% Start timer
tic;

%% Handle 'all' patients option
if ischar(patient_ids) && strcmpi(patient_ids, 'all')
    % Get all included (non-excluded) patient IDs
    patient_ids = [patient_meta(~[patient_meta.excluded]).id];
end

%% Initialize results tracking
results = struct();
results.n_patients = length(patient_ids);
results.n_total_files = 0;
results.patient_summary = struct();

%% Process each patient
for p_idx = 1:length(patient_ids)
    patient_id = patient_ids(p_idx);

    % Find patient in metadata
    pat_idx = find([patient_meta.id] == patient_id);
    if isempty(pat_idx)
        warning('batch_connectivity:PatientNotFound', ...
            'Patient %d not found in metadata, skipping', patient_id);
        continue;
    end

    pat = patient_meta(pat_idx);

    % Skip excluded patients
    if pat.excluded
        if config.options.verbose >= 1
            fprintf('Patient %02d: EXCLUDED (%s), skipping\n', ...
                patient_id, pat.exclusion_reason);
        end
        continue;
    end

    % Create output directory for this patient
    patient_output_dir = fullfile(config.paths.connectivity_out, ...
        'dDTF', sprintf('Patient_%02d', patient_id));
    if ~exist(patient_output_dir, 'dir')
        mkdir(patient_output_dir);
    end

    % Initialize patient tracking
    n_files_this_patient = 0;
    patient_start_time = tic;

    %% Process each night
    for night = 1:pat.n_nights

        %% Process each epileptic state
        for state_idx = 1:length(config.data.state_names)
            state = config.data.state_names{state_idx};

            try
                %% Load patient segments
                [data, metadata] = load_patient_segments(patient_id, night, ...
                    state, config, patient_meta);

                %% Compute dDTF connectivity
                adjacency_matrices = compute_ddtf(data, metadata, config);

                %% Save each frequency band
                freq_names = config.freq_band_names;

                for f = 1:length(freq_names)
                    freq_name = freq_names{f};

                    % Get adjacency matrix for this band
                    adjac_matrix = adjacency_matrices.(freq_name);

                    % Construct output filename
                    filename = sprintf('patient%02d_night%d_%s_ADJACENCY_%s.mat', ...
                        patient_id, night, state, freq_name);
                    filepath = fullfile(patient_output_dir, filename);

                    % Save
                    var_name = sprintf('mean_adj_%s', freq_name);
                    eval(sprintf('%s = adjac_matrix;', var_name));
                    save(filepath, var_name, '-v7');

                    n_files_this_patient = n_files_this_patient + 1;
                end


            catch ME
                warning('batch_connectivity:ProcessingError', ...
                    'Patient %d, Night %d, %s failed: %s', ...
                    patient_id, night, state, ME.message);
                if config.options.verbose >= 3
                    fprintf('    Error details: %s\n', ME.getReport());
                end
            end

        end % states

    end % nights

    % Patient summary
    patient_elapsed = toc(patient_start_time);
    results.patient_summary(p_idx).id = patient_id;
    results.patient_summary(p_idx).n_files = n_files_this_patient;
    results.patient_summary(p_idx).time = patient_elapsed;

    results.n_total_files = results.n_total_files + n_files_this_patient;

end % patients

end
