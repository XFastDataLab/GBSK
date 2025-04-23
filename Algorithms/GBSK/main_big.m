% Random indexing without loading the entire file into memory
%% GBSK dealing with binary data files
clear; % clear working area
clc; % clean command window
dataset_name = 'AGC100M';
% Data path
data_file = 'D:\GBSK\Datasets\AGC100M\anisotropic_gaussian_clusters.bin';
n_points = 1e8;   % Total number of points
n_features = 256;       % Number of dimensions
% Size of each data point in bytes (single precision float is 4 bytes)
point_size = n_features * 4; % 256 features * 4 bytes/feature
records_table_path = 'D:\GBSK\experiment_records\GBSK run records.xlsx';

% Seed
% rng(619);
rng('shuffle'); % Shuffle the seed based on the current time
seedData = rng; % Record the current seed and the random number generator settings
disp(['Seed: ', num2str(seedData.Seed)]); % Display the seed
%% Parameters of GBSK
num_samples = 30; % Parameter s: number of sample sets
alpha = 0; % Parameter alpha: sampling proportion                           set to '0' for default sqrt
k = 10; % Parameter k: number of peak balls, category number
target_ball_count = 10 * k; % Parameter M
%% Create an index (file)
try
    if alpha
        % define manually sampling proportion
        sample_size = round(alpha * n_points); % sample size of a sampled set
        % Generate dynamic folder name
        results_dir = sprintf('D:/GBSK/experiment_outcomes/GBSK/%s/Seed_%d s_%d a_%.4f M_%d', dataset_name, seedData.Seed, num_samples, alpha, target_ball_count);
    else
        % default setting: square root sampling
        alpha = 1 / sqrt(n_points);
        sample_size = round(sqrt(n_points)); % sample size of a sampled set
        % Generate dynamic folder name
        results_dir = sprintf('D:/GBSK/experiment_outcomes/GBSK/%s/Seed_%d s_%d a_sqrt M_%d', dataset_name, seedData.Seed, num_samples, target_ball_count);
    end
    % Open the binary data file
    fid_data = fopen(data_file, 'r');
    if fid_data == -1
        error('Failed to open data file for reading.');
    end

    % Create an array to store the index
    % Use uint64 to ensure we can handle large files and offsets.
    index = zeros(n_points, 1, 'uint64');

    % Populate the index array with byte positions
    for byte_idx = 1:n_points
        % Returns the current byte offset in the file, which corresponds to the starting position of the current data point
        index(byte_idx) = ftell(fid_data);

        % Moves the file pointer forward by point_size bytes from the current position.
        % This positions the file pointer at the start of the next data point.
        fseek(fid_data, point_size, 'cof'); % 'cof' stands for "current offset"
    end
    %% Run GBSK
    % Initialize arrays to store timing information
    all_peaks = [];
    time_step1_all = zeros(1, num_samples);
    time_step2_all = zeros(1, num_samples);
    time_Step1_indices_sampling_all = zeros(1, num_samples);
    time_Step1_data_loading_all = zeros(1, num_samples);
    total_time_tic = tic;
    for s_idx = 1:num_samples
        %% Step1: Randomly sampling
        % Start timer for Step 1
        time_Step1 = tic;
        time_Step1_indices_sampling = tic;

        % Randomly select indices
        % Explicitly specifies sampling without replacement, ensuring all indices are unique
        sample_indices = randsample(length(index), sample_size, false);
        time_Step1_indices_sampling_all(s_idx) = toc(time_Step1_indices_sampling);

        time_Step1_data_loading = tic;
        % Initialize the output array
        sampled_set = zeros(sample_size, n_features, 'single');

        % Read the sampled data points
        for sample_size_idx = 1:sample_size
            % Use fseek to move the file pointer by the size of one data point to reach the next data point's starting position.
            fseek(fid_data, index(sample_indices(sample_size_idx)), 'bof');
            sampled_set(sample_size_idx, :) = fread(fid_data, n_features, 'single')';
        end

        % Record time for Step 1
        time_Step1_data_loading_all(s_idx) = toc(time_Step1_data_loading);
        time_step1_all(s_idx) = toc(time_Step1);
        %% Step2: Find peaks of GB and merge them
        % Start timer for Step 2
        time_Step2 = tic;

        [ball_centers, ball_radius, points_per_ball] = GB_generation(sampled_set, target_ball_count);  % Generate GB for each sample set 
        median_radius = median(ball_radius);

        % Calculate density for each GB
        density = calculateDensity2(ball_radius, points_per_ball, median_radius);
        delta = calculateDelta(density, ball_centers);   % Calculate delta for each GB
        gamma = density .* delta;
        peaks = getTopKPeaks(gamma, ball_centers, k);
        all_peaks(end + 1:end + size(peaks, 1), :) = peaks;

        % Record time for Step 2
        time_step2_all(s_idx) = toc(time_Step2);
    end
    % Close the binary data file
    fclose(fid_data);

    % Summarize total time for Step 1 & 2
    total_time_Step1 = sum(time_step1_all);
    total_time_Step2 = sum(time_step2_all);
    total_time_Step1_indices_sampling = sum(time_Step1_indices_sampling_all);
    total_time_Step1_data_loading = sum(time_Step1_data_loading_all);
    disp(['Time for Step1: ', num2str(total_time_Step1), ' s']);
    disp(['Time for Step1 (indices sampling): ', num2str(total_time_Step1_indices_sampling), ' s']);
    disp(['Time for Step1 (data loading): ', num2str(total_time_Step1_data_loading), ' s']);
    disp(['Time for Step2: ', num2str(total_time_Step2), ' s']);

    % remove repeating peaks
    all_peaks = unique(all_peaks, 'rows');
    dlmwrite(fullfile(results_dir, 'ori_all_peaks.txt'), all_peaks);
    [num_All_RBC, ~] = size(all_peaks); % number of All_RBC
    %% Step3: Generate GB on merged peaks
    step3_tic = tic; 
    [all_peaks, ball_radius, points_per_ball] = GB_generation_2(all_peaks);
    time_Step3 = toc(step3_tic); 
    disp(['Time for Step3: ', num2str(time_Step3), ' s']);
    dlmwrite(fullfile(results_dir, 'all_peaks.txt'), all_peaks);
    [num_KM, ~] = size(all_peaks); % number of KM
    if size(all_peaks, 1) < k
        error('Not enough data points after sampling.'); 
    end
    %% Step4: Construct the skeleton by DPeak-like on GB
    step4_tic = tic; 
    [label_all_peaks, peaks, nneigh, ordgamma] = obtain_skeleton2(all_peaks, ball_radius, points_per_ball, k);
    time_Step4 = toc(step4_tic); 
    disp(['Time for Step4: ', num2str(time_Step4), ' s']);
    %% Step5: Calculate the min distance between all_peaks and all data points to assign labels
    step5_tic = tic; 
    % Define chunk size
    chunk_size = 1e6;  % Number of data points per chunk, adjust based on available memory

    % Preallocate an array for storing labels
    labels_data = zeros(n_points, 1, 'uint8');

    % Open the binary data file for reading
    fid_data = fopen(data_file, 'r');
    if fid_data == -1
        error('Failed to open data file for reading.');
    end

    num_chunks = n_points / chunk_size;
    time_Step5_chunks_reading_all = zeros(1, num_chunks);

    % Loop through the file in chunks
    for step5_idx = 1:chunk_size:n_points
        %% Calculate the number of points in this chunk
        end_idx = min(step5_idx + chunk_size - 1, n_points);
        num_points_in_chunk = end_idx - step5_idx + 1;

        % Start timer for chunk reading
        time_Step5_chunks_reading = tic;

        % Read the chunk from the binary file
        data_chunk = fread(fid_data, [n_features, num_points_in_chunk], 'single')';

        time_Step5_chunks_reading_all(step5_idx) = toc(time_Step5_chunks_reading);

        %% Second Part: Process the Chunk
        % Compute distances between data_chunk and all_peaks
        distances = pdist2(data_chunk, all_peaks);

        % Find the nearest peak for each data point in the chunk
        [~, nearest_peak_indices] = min(distances, [], 2);

        % Assign labels based on the nearest peak
        labels_chunk = label_all_peaks(nearest_peak_indices);

        % Store the labels in the preallocated array
        labels_data(step5_idx:end_idx) = labels_chunk;
    end
    total_time_Step5_chunks_reading = sum(time_Step5_chunks_reading_all);
    disp(['Time for Step5 (chunks reading): ', num2str(total_time_Step5_chunks_reading), ' s']);

    time_Step5 = toc(step5_tic); 
    disp(['Time for Step5: ', num2str(time_Step5), ' s']);

    total_time = toc(total_time_tic);
    disp(['Total time for Clustering: ', sprintf('%.4f', total_time), ' s']);

    % Close the binary data file
    fclose(fid_data);
    %% Save labels and time to .txt
    labels_data_file = fullfile(results_dir, 'labels.txt');
    writematrix(labels_data, labels_data_file);

    % Export times recorded to text file
    fileID = fopen(fullfile(results_dir, 'log.txt'), 'w');
    fprintf(fileID, results_dir);
    fprintf(fileID, 'Total time: %.6f s\n', total_time);
    fprintf(fileID, 'Time for Step1: %.6f s\n', total_time_Step1);
    fprintf(fileID, 'Time for Step1 (indices sampling): %.6f s\n', total_time_Step1_indices_sampling);
    fprintf(fileID, 'Time for Step1 (data loading): %.6f s\n', total_time_Step1_data_loading);
    fprintf(fileID, 'Time for Step2: %.6f s\n', total_time_Step2);
    fprintf(fileID, 'Time for Step3: %.6f s\n', time_Step3);
    fprintf(fileID, 'Time for Step4: %.6f s\n', time_Step4);
    fprintf(fileID, 'Time for Step5: %.6f s\n', time_Step5);
    fprintf(fileID, 'Time for Step5 (chunks reading): %.6f s\n', total_time_Step5_chunks_reading);
    fprintf(fileID, 'All_RBC: %d \n', num_All_RBC);
    fprintf(fileID, 'KM: %d \n', num_KM);
    fclose(fileID);
    % Record in Excel
    records_table = readmatrix(records_table_path, 'Sheet', dataset_name, 'Range', 'E:E'); % Read all rows in column E
    records_table = records_table(2:end,:);
    nextRow = height(records_table) + 2; % Next row to write data
    newRow = {seedData.Seed, num_samples, alpha, target_ball_count, total_time, total_time_Step1, total_time_Step2, time_Step3, time_Step4, time_Step5, num_All_RBC, num_KM};
    % Write the new row to the next available row, starting from column F
    writecell(newRow, records_table_path, 'Sheet', dataset_name, 'Range', ['E' num2str(nextRow)]);
catch e
    disp(getReport(e, 'basic'));
end % end try