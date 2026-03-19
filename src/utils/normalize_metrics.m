function normalized = normalize_metrics(data, method)
% NORMALIZE_METRICS - Normalize data using specified method
%
% This function normalizes data to a standard range or distribution.
% Used throughout the pipeline to standardize graph metrics.
%
% INPUTS:
%   data   - Data to normalize
%   method - Normalization method:
%            'min-max'  : Scale to [0, 1] range
%            'z-score'  : Standardize to mean=0, std=1
%            'none'     : Return data unchanged

%% Handle default input
if nargin < 2
    method = 'min-max';
end

%% Handle structure input 
if isstruct(data)
    normalized = data;  
    field_names = fieldnames(data);

    for f = 1:length(field_names)
        normalized.(field_names{f}) = normalize_metrics(data.(field_names{f}), method);
    end

    return;
end

%% Handle no normalization
if strcmpi(method, 'none')
    normalized = data;
    return;
end

%% Validate input
if ~isnumeric(data)
    error('normalize_metrics:InvalidInput', ...
        'Data must be numeric or a structure with numeric fields');
end

%% Apply normalization based on method
switch lower(method)
    case 'min-max'

        data_min = min(data(:), [], 'omitnan');
        data_max = max(data(:), [], 'omitnan');

        % Handle constant data 
        if data_max == data_min || isnan(data_max) || isnan(data_min)
            normalized = zeros(size(data));
            return;
        end

        % Normalize
        normalized = (data - data_min) / (data_max - data_min);

    case 'z-score'

        data_mean = mean(data(:), 'omitnan');
        data_std = std(data(:), 'omitnan');

        % Handle constant data
        if data_std == 0 || isnan(data_std)
            normalized = nan(size(data));
            return;
        end

        % Normalize
        normalized = (data - data_mean) / data_std;

    otherwise
        error('normalize_metrics:UnknownMethod', ...
            'Unknown normalization method: %s\nOptions: ''min-max'', ''z-score'', ''none''', ...
            method);
end

%% Handle special values
normalized(isinf(normalized)) = NaN;

end
