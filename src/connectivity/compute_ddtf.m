function adjacency_matrices = compute_ddtf(data, metadata, config)
% COMPUTE_DDTF - Compute direct Directed Transfer Function (dDTF) connectivity
%
% This function computes dDTF-based connectivity matrices using FieldTrip's
% MVAR analysis pipeline. 
%
% INPUTS:
%   data     - Data matrix [timepoints × channels]
%              Concatenated 60-second recording (20 × 3-second segments)
%
%   metadata - Structure with fields
%
%   config   - Configuration structure from pipeline_config()
%
% WORKFLOW:
%   1. Split 60-second recording into 20 3-second segments
%   2. For each segment:
%      a. Convert to FieldTrip format
%      b. Compute MVAR model 
%      c. Convert to frequency domain 
%      d. Compute dDTF
%      e. Extract frequency bands by averaging specific Hz ranges
%   3. Average across all 20 segments
%   4. Return adjacency matrices for each frequency band

%% Split concatenated data back into 20 3-second segments
% Original script processed each segment individually
n_segments = config.data.n_segments;  
segment_duration = config.data.segment_duration; 
samples_per_segment = segment_duration * metadata.fs; 

% Pre-allocate segment storage
segments = cell(n_segments, 1);

for seg = 1:n_segments
    start_idx = (seg - 1) * samples_per_segment + 1;
    end_idx = seg * samples_per_segment;
    segments{seg} = data(start_idx:end_idx, :);

%% Initialize storage for frequency band matrices
% Pre-allocate 3D matrices: [channels × channels × segments]
n_chans = metadata.n_channels;

ddtf_delta = zeros(n_chans, n_chans, n_segments);
ddtf_theta = zeros(n_chans, n_chans, n_segments);
ddtf_alpha = zeros(n_chans, n_chans, n_segments);
ddtf_beta = zeros(n_chans, n_chans, n_segments);
ddtf_gamma1 = zeros(n_chans, n_chans, n_segments);
ddtf_gamma2 = zeros(n_chans, n_chans, n_segments);
ddtf_ripples = zeros(n_chans, n_chans, n_segments);
ddtf_fast_ripples = zeros(n_chans, n_chans, n_segments);

%% Process each segment using FieldTrip MVAR → dDTF pipeline
for seg = 1:n_segments

    %% Convert to FieldTrip format
    ft_data = struct();
    ft_data.label = metadata.channel_names;  
    ft_data.fsample = metadata.fs;           

    % Time vector for this segment 
    time_vector = (0:samples_per_segment-1) / metadata.fs;
    ft_data.time = {time_vector};

    % Data must be [channels × timepoints] for FieldTrip
    ft_data.trial = {segments{seg}'};  

    % Sample info: [start_sample, end_sample]
    ft_data.sampleinfo = [1, samples_per_segment];

    %% Compute MVAR model in time domain
    cfg_mvar = [];
    cfg_mvar.order = config.connectivity.ddtf.mvar_order;  
    cfg_mvar.method = 'bsmart'; 

    mvar_data = ft_mvaranalysis(cfg_mvar, ft_data);

    %% Convert MVAR model to frequency domain
    cfg_freq = [];
    cfg_freq.method = 'mvar';         
    cfg_freq.output = 'fourier';      
    cfg_freq.foi = config.connectivity.ddtf.foi; 

    freq_data = ft_freqanalysis(cfg_freq, mvar_data);

    %% Compute direct DTF 
    cfg_conn = [];
    cfg_conn.method = 'ddtf';  

    ddtf_data = ft_connectivityanalysis(cfg_conn, freq_data);

    %% Extract frequency bands by averaging specific Hz ranges
    ddtf_delta(:, :, seg) = mean(ddtf_data.ddtfspctrm(:, :, 2:4), 3);
    ddtf_theta(:, :, seg) = mean(ddtf_data.ddtfspctrm(:, :, 5:7), 3);
    ddtf_alpha(:, :, seg) = mean(ddtf_data.ddtfspctrm(:, :, 8:12), 3);
    ddtf_beta(:, :, seg) = mean(ddtf_data.ddtfspctrm(:, :, 15:29), 3);
    ddtf_gamma1(:, :, seg) = mean(ddtf_data.ddtfspctrm(:, :, 30:59), 3);
    ddtf_gamma2(:, :, seg) = mean(ddtf_data.ddtfspctrm(:, :, 60:79), 3);
    ddtf_ripples(:, :, seg) = mean(ddtf_data.ddtfspctrm(:, :, 80:249), 3);
    ddtf_fast_ripples(:, :, seg) = mean(ddtf_data.ddtfspctrm(:, :, 250:500), 3);

    clear ft_data cfg_mvar mvar_data cfg_freq freq_data cfg_conn ddtf_data;

end

%% Average across all 20 segments
adjacency_matrices = struct();
adjacency_matrices.delta = mean(ddtf_delta, 3);
adjacency_matrices.theta = mean(ddtf_theta, 3);
adjacency_matrices.alpha = mean(ddtf_alpha, 3);
adjacency_matrices.beta = mean(ddtf_beta, 3);
adjacency_matrices.gamma1 = mean(ddtf_gamma1, 3);
adjacency_matrices.gamma2 = mean(ddtf_gamma2, 3);
adjacency_matrices.ripples = mean(ddtf_ripples, 3);
adjacency_matrices.fast_ripples = mean(ddtf_fast_ripples, 3);

end
