function metrics = compute_graph_metrics(adjacency_matrix, config, is_directed)
% COMPUTE_GRAPH_METRICS - Compute graph-theoretic metrics using BCT
%
% Computes local graph metrics for a weighted directed and a weighted undirected connectivity matrix
% using the Brain Connectivity Toolbox (BCT).
%
%
% Inputs:
%   adjacency_matrix - [N x N] weighted directed or undirected adjacency matrix
%   config          - Pipeline configuration structure 

%% Validate inputs
if nargin < 2
    error('compute_graph_metrics:NotEnoughInputs', ...
        'Requires 2 inputs: adjacency_matrix and config');
end

if nargin < 3
    is_directed = true;
end

if ~ismatrix(adjacency_matrix) || size(adjacency_matrix, 1) ~= size(adjacency_matrix, 2)
    error('compute_graph_metrics:InvalidMatrix', ...
        'Adjacency matrix must be square [N x N]');
end

n_nodes = size(adjacency_matrix, 1);

if n_nodes == 0
    error('compute_graph_metrics:EmptyMatrix', ...
        'Adjacency matrix is empty');
end

%% Preprocessing: Weight conversions

% Step 1: Autofix - Remove NaN and Inf values
ADJAC_fix = weight_conversion(adjacency_matrix, 'autofix');

% Step 2: Normalize for connectivity measures
ADJAC_norm_connect = weight_conversion(ADJAC_fix, 'normalize');

%% Compute graph metrics using BCT functions

% 1. Clustering Coefficient
if is_directed
    metrics.CC = clustering_coef_wd(ADJAC_norm_connect);
else
    metrics.CC = clustering_coef_wu(ADJAC_norm_connect);
end

% 2. Strength measures
if is_directed
    [inp_str, out_str, tot_str] = strengths_dir(ADJAC_norm_connect);
    metrics.STRENGTH.inp_str = inp_str';
    metrics.STRENGTH.out_str = out_str';
    metrics.STRENGTH.tot_str = tot_str';
else
    tot_str = strengths_und(ADJAC_norm_connect);
    metrics.STRENGTH.tot_str = tot_str';
end

end
