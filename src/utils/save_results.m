function save_results(data, output_path, var_name, config, varargin)
% SAVE_RESULTS - Standardized function for saving pipeline results
%
% This function provides a consistent interface for saving results
% with optional compression, metadata, and logging.

%% Parse optional inputs
p = inputParser;
addParameter(p, 'metadata', struct(), @isstruct);
addParameter(p, 'append', false, @islogical);
addParameter(p, 'compress', [], @(x) isempty(x) || islogical(x));
parse(p, varargin{:});

metadata = p.Results.metadata;
append_mode = p.Results.append;
compress = p.Results.compress;

%% Create output directory if needed
output_dir = fileparts(output_path);
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%% Determine compression based on data size if not specified
if isempty(compress)
    % Use compression for files > 100 MB
    data_info = whos('data');
    data_size_mb = data_info.bytes / 1024^2;
    compress = (data_size_mb > 100);
end

%% Save the data
% Prepare variables to save
save_vars = {var_name};

% Create a temporary variable with the specified name
eval(sprintf('%s = data;', var_name));

% Add metadata if provided
if ~isempty(fieldnames(metadata))
    metadata_var_name = sprintf('%s_metadata', var_name);
    eval(sprintf('%s = metadata;', metadata_var_name));
    save_vars{end+1} = metadata_var_name;
end

% Determine save options
if compress
    save_options = '-v7.3';  
else
    save_options = '-v7';    
end

% Append mode
if append_mode
    if exist(output_path, 'file')
        save_options = [save_options, ' -append'];
    else
        warning('save_results:AppendToNonexistent', ...
            'Append mode requested but file does not exist. Creating new file.');
    end
end

% Perform the save
try
    save(output_path, save_vars{:}, save_options);

catch ME
    error('save_results:SaveFailed', ...
        'Failed to save file: %s\nError: %s', output_path, ME.message);
end

end
