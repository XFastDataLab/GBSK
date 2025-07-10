clear; % clear variables
clc; % clean command window

% Seed
rng('shuffle');
seedData = rng;
disp(['Seed: ', num2str(seedData.Seed)]);
try
    dataset_name = 'N-BaIot';
    data = importdata('D:\Datasets\N-BaIot\data.mat');
    k = 9;
    
%     dataset_name = 'MNIST8M';
%     data = importdata('D:\Datasets\Letter Recognition\data.mat');
%     data_file = 'D:\Datasets\MNIST8M\MNIST8M_data.h5';
%     data = h5read(data_file, '/MNIST8M');
%     data = double(data); % convert uint8 to double
%     k = 10;

%     init_time_tic = tic;
%     dataset_name = 'AGC100M';
%     data_file = 'D:\Datasets\AGC100M\anisotropic_gaussian_clusters.bin';
%     n_points = 1e8;
%     n_features = 256;
%     k = 17;
%     % Open the binary data file
%     fid_data = fopen(data_file, 'r');
%     if fid_data == -1
%         error('Failed to open data file for reading.');
%     end
% %     data = fread(fid_data, [n_features, n_points], 'single')'; % column first
%     data = fread(fid_data, [n_features, n_points], 'single');
%     fclose(fid_data);
%     init_time = toc(init_time_tic);
%     disp(['Initializing time: ', sprintf('%.4f', init_time), ' s']);
%     whos data
    
    

    % Generate dynamic folder name
    results_dir = sprintf('D:/GBSK/experiment outcomes/KMeansPlus/%s/Seed_%d', dataset_name, seedData.Seed);
    % Create directories if they do not exist
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
    end
    %% k-means++
    total_time_tic = tic;
    [labels, ~] = kmeans(data, k, 'Start', 'plus', 'Replicates', 1); % default = 100
    total_time = toc(total_time_tic);
    disp(['Total time for Clustering: ', sprintf('%.4f', total_time), ' s']);
    %% Saving results
    % Save labels to a .txt file
    writematrix(labels, fullfile(results_dir, 'labels.txt'));
    % Log
    fileID = fopen(fullfile(results_dir, 'log.txt'), 'w');
    fprintf(fileID, results_dir);
    fprintf(fileID, '\nTotal time: %.6f s\n', total_time);
    fclose(fileID);
catch e
    disp(getReport(e, 'basic'));
end