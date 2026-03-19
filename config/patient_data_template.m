% PATIENT_DATA_TEMPLATE - Template for entering patient metadata
%
% This script shows you how to input your patient-specific information
% to create the metadata file needed.
%
% INSTRUCTIONS:
%   1. Fill in the information for each patient below
%   2. Run this script in MATLAB
%   3. The metadata file will be created automatically
%
% WHAT YOU NEED TO PROVIDE:
%   - Patient ID number
%   - Surgical outcome ('Good' or 'Poor')
%   - Names of resected channels (as cell array)
%   - Channel indices to remove from analysis (as array)
%   - Number of recording nights 

%% ENTER YOUR PATIENT DATA BELOW
%  
%  Copy and modify the template for each patient.

% --- Patient 01 ---
patient_data(1).id = 1;
patient_data(1).outcome = 'Good';  % Options: 'Good' or 'Poor'
patient_data(1).resected_channels = {'LA1',..};  
patient_data(1).removed_indices = [4,5,..];
patient_data(1).n_nights = 4; 

% --- Patient 02 ---
patient_data(2).id = 2;
patient_data(2).outcome = 'Poor';  
patient_data(2).resected_channels = {};  
patient_data(2).removed_indices = [];
patient_data(2).n_nights = 2;

% --- Patient 03 ---
patient_data(3).id = 3;
patient_data(3).outcome = 'Good';
patient_data(3).resected_channels = {}; 
patient_data(3).removed_indices = [];
patient_data(3).n_nights = 4;

% --- Patient 04 ---
patient_data(4).id = 4;
patient_data(4).outcome = 'Poor';  
patient_data(4).resected_channels = {};  
patient_data(4).removed_indices = [];
patient_data(4).n_nights = 4;

% --- Patient 05 ---
patient_data(5).id = 5;
patient_data(5).outcome = 'Good'; 
patient_data(5).resected_channels = {}; 
patient_data(5).removed_indices = [];
patient_data(5).n_nights = 4;

% --- Patient 06 ---
patient_data(6).id = 6;
patient_data(6).outcome = 'Poor';  
patient_data(6).resected_channels = {};  
patient_data(6).removed_indices = [];
patient_data(6).n_nights = 4;

% --- Patient 07 ---
patient_data(7).id = 7;
patient_data(7).outcome = 'Good';
patient_data(7).resected_channels = {}; 
patient_data(7).removed_indices = [];
patient_data(7).n_nights = 1;

% --- Patient 09 (note: 08 is missing) ---
patient_data(8).id = 9;
patient_data(8).outcome = 'Poor';  
patient_data(8).resected_channels = {};  
patient_data(8).removed_indices = [];
patient_data(8).n_nights = 2;

% --- Patient 10 ---
patient_data(9).id = 10;
patient_data(9).outcome = 'Good';  
patient_data(9).resected_channels = {};  
patient_data(9).removed_indices = []; 
patient_data(9).n_nights = 1;

% --- Patient 11 ---
patient_data(10).id = 11;
patient_data(10).outcome = 'Poor';
patient_data(10).resected_channels = {};  
patient_data(10).removed_indices = [];
patient_data(10).n_nights = 2;

% --- Patient 12 ---
patient_data(11).id = 12;
patient_data(11).outcome = 'Good';
patient_data(11).resected_channels = {};  
patient_data(11).removed_indices = [];
patient_data(11).n_nights = 2;

% --- Patient 13 ---
patient_data(12).id = 13;
patient_data(12).outcome = 'Poor'; 
patient_data(12).resected_channels = {};  
patient_data(12).removed_indices = [];
patient_data(12).n_nights = 2;

% --- Patient 14 ---
patient_data(13).id = 14;
patient_data(13).outcome = 'Good'; 
patient_data(13).resected_channels = {};  
patient_data(13).removed_indices = [];
patient_data(13).n_nights = 2;

% --- Patient 16 (note: 15 is missing) ---
patient_data(14).id = 16;
patient_data(14).outcome = 'Poor';
patient_data(14).resected_channels = {};  
patient_data(14).removed_indices = [];
patient_data(14).n_nights = 2;

% --- Patient 17 ---
patient_data(15).id = 17;
patient_data(15).outcome = 'Good';
patient_data(15).resected_channels = {};  
patient_data(15).removed_indices = [];
patient_data(15).n_nights = 1;

% --- Patient 18 ---
patient_data(16).id = 18;
patient_data(16).outcome = 'Poor';  
patient_data(16).resected_channels = {};  
patient_data(16).removed_indices = [];
patient_data(16).n_nights = 1;

% --- Patient 19 ---
patient_data(17).id = 19;
patient_data(17).outcome = 'Good';  
patient_data(17).resected_channels = {}; 
patient_data(17).removed_indices = [];
patient_data(17).n_nights = 2;

% --- Patient 20 ---
patient_data(18).id = 20;
patient_data(18).outcome = 'Poor'; 
patient_data(18).resected_channels = {};
patient_data(18).removed_indices = [];
patient_data(18).n_nights = 4;

%% CREATE METADATA FILE
%  
%  Once you've filled in the data above, run this section to create
%  the metadata file that the pipeline will use.

% Call the creation function
create_patient_metadata(patient_data);
