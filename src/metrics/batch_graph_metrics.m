function results = batch_graph_metrics(patient_ids, config, patient_meta)
% BATCH_GRAPH_METRICS - Batch computation of graph metrics across patients
%
% Processes connectivity outputs from Phase 2, averages across nights,
% and computes graph-theoretic metrics for all patients, states, and
% frequency bands.
%
% INPUT:
%   patient_ids  - 'all' or array of patient IDs [1, 2, 3, ...]
%   config       - Pipeline configuration
%   patient_meta - Patient metadata structure 

%% Initialize
results.n_patients = 0;
results.n_total_files = 0;
results.failed = {};

%% Determine which patients to process
if ischar(patient_ids) && strcmpi(patient_ids, 'all')
    patient_ids = [patient_meta(~[patient_meta.excluded]).id];
end

%% Get frequency bands and states
band_names = fieldnames(config.freq_bands);
state_names = config.data.state_names;

%% Create output directory
metrics_dir = config.paths.metrics_out;
if ~exist(metrics_dir, 'dir')
    mkdir(metrics_dir);
end

%% Define connectivity methods to process
all_methods = [config.graph.directed_methods, config.graph.undirected_methods];
all_directed = [true(1, length(config.graph.directed_methods)), ...
                false(1, length(config.graph.undirected_methods))];

%% Process each method
for m = 1:length(all_methods)
    method = all_methods{m};
    method_directed = all_directed(m);

    for p = 1:length(patient_ids)
        patient_id = patient_ids(p);

        % Get patient metadata
        patient_idx = find([patient_meta.id] == patient_id);
        if isempty(patient_idx)
            warning('Patient %d not found in metadata, skipping', patient_id);
            continue;
        end

        patient = patient_meta(patient_idx);

        % Skip excluded patients
        if patient.excluded
            if config.options.verbose >= 2
                fprintf('  Patient %02d: EXCLUDED, skipping\n', patient_id);
            end
            continue;
        end

        %% Process each state
        for state_idx = 1:length(state_names)
            state = state_names{state_idx};
            state_label = state_labels{state_idx};

            try
                %% Step 1: Load connectivity outputs for all nights and average

                % Initialize averaged adjacency matrices
                avg_adjacency = struct();
                for b = 1:length(band_names)
                    avg_adjacency.(band_names{b}) = [];
                end

                % Load and accumulate all nights
                n_nights_loaded = 0;
                patient_output_dir = fullfile(config.paths.connectivity_out, method, ...
                    sprintf('Patient_%02d', patient_id));

                for night = 1:patient.n_nights
                    % Check if connectivity files exist for this night
                    night_exists = true;

                    % Load each frequency band separately
                    for b = 1:length(band_names)
                        band = band_names{b};

                        conn_file = fullfile(patient_output_dir, ...
                            sprintf('patient%02d_night%d_%s_ADJACENCY_%s.mat', ...
                            patient_id, night, state, band));

                        if ~exist(conn_file, 'file')
                            if b == 1
                                warning('Connectivity files not found for Patient %02d, Night %d, %s (%s)', ...
                                    patient_id, night, state, method);
                            end
                            night_exists = false;
                            break;
                        end

                        % Load connectivity file
                        conn_data = load(conn_file);

                        % Extract adjacency matrix (variable name: mean_adj_BAND)
                        var_name = sprintf('mean_adj_%s', band);
                        if ~isfield(conn_data, var_name)
                            warning('Variable %s not found in %s', var_name, conn_file);
                            night_exists = false;
                            break;
                        end

                        adj_matrix = conn_data.(var_name);

                        % Accumulate
                        if isempty(avg_adjacency.(band))
                            avg_adjacency.(band) = adj_matrix;
                        else
                            avg_adjacency.(band) = avg_adjacency.(band) + adj_matrix;
                        end
                    end

                    if night_exists
                        n_nights_loaded = n_nights_loaded + 1;
                    end
                end

                if n_nights_loaded == 0
                    warning('Patient %d, %s (%s): No connectivity files found, skipping', ...
                        patient_id, state, method);
                    results.failed{end+1} = sprintf('Patient %02d, %s (%s): No connectivity files', ...
                        patient_id, state, method);
                    continue;
                end

                % Compute average across nights
                for b = 1:length(band_names)
                    avg_adjacency.(band_names{b}) = avg_adjacency.(band_names{b}) / n_nights_loaded;
                end

                %% Step 2: Compute graph metrics for each frequency band

                graph_metrics = struct();

                for b = 1:length(band_names)
                    band = band_names{b};

                    % Compute metrics
                    graph_metrics.(band) = compute_graph_metrics(...
                        avg_adjacency.(band), config, method_directed);
                end

                %% Step 3: Add metadata
                graph_metrics.metadata.patient_id = patient_id;
                graph_metrics.metadata.state = state;
                graph_metrics.metadata.state_label = state_label;
                graph_metrics.metadata.method = method;
                graph_metrics.metadata.is_directed = method_directed;
                graph_metrics.metadata.n_nights_averaged = n_nights_loaded;
                graph_metrics.metadata.n_nodes = size(avg_adjacency.(band_names{1}), 1);
                graph_metrics.metadata.frequency_bands = band_names;
                graph_metrics.metadata.computation_date = datestr(now, 'yyyy-mm-dd HH:MM:SS');

                %% Step 4: Save results
                if strcmpi(method, 'dDTF')
                    output_file = fullfile(metrics_dir, ...
                        sprintf('patient_%02d_%s_metrics.mat', patient_id, state));
                else
                    output_file = fullfile(metrics_dir, ...
                        sprintf('patient_%02d_%s_%s_metrics.mat', patient_id, state, method));
                end

                save(output_file, 'graph_metrics', '-v7');

                results.n_total_files = results.n_total_files + 1;

            catch ME
                warning('Error processing Patient %d, %s (%s): %s', ...
                    patient_id, state, method, ME.message);
                results.failed{end+1} = sprintf('Patient %02d, %s (%s): %s', ...
                    patient_id, state, method, ME.message);
            end

        end % End states

        results.n_patients = results.n_patients + 1;

    end % End patients

end % End methods

end
