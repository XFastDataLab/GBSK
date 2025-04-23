clear; % clear variables
clc; % clean command window

% Seed
% rng(54508909);
rng('shuffle');
seedData = rng;
disp(['Seed: ', num2str(seedData.Seed)]);

dataset_name = '3M2D5';
data = importdata('D:\Datasets\3M2D5\data.mat');
n_points = size(data, 1);

% ------------------------Parameters---------------------------------------
num_samples = 30; % Parameter s: number of sample sets
alpha = 0; % Parameter alpha: sampling proportion                           set to '0' for default sqrt
k = 10; % Parameter k: number of peak balls, category number
target_ball_count = 10 * k; % Parameter M
%--------------------------------------------------------------------------
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

    % Create directories if they do not exist
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
    end
    
    %% GBSK
    all_peaks = [];
    total_time_tic = tic;
    step1_time_all = zeros(1, num_samples);
    step2_time_all = zeros(1, num_samples);
    for s_idx = 1:num_samples
        %% Step1: Random sampling
        step1_time_tic = tic;
        sampled_set = data(randperm(size(data, 1), sample_size), :);
        step1_time_all(s_idx) = toc(step1_time_tic);
        %% Step2: Find peaks of balls and merge
        step2_time_tic = tic;
        [ball_centers, ball_radius, points_per_ball] = GB_generation(sampled_set, target_ball_count);  % Generate balls for each sample set 
        median_radius = median(ball_radius);

        density = calculateDensity2(ball_radius, points_per_ball, median_radius);
        delta = calculateDelta(density, ball_centers);   % Calculate delta for each ball
        gamma = density .* delta;
        peaks = getTopKPeaks(gamma, ball_centers, k);
        all_peaks(end + 1:end + size(peaks, 1), :) = peaks;
        step2_time_all(s_idx) = toc(step2_time_tic);
    end
    step1_time = sum(step1_time_all);
    disp(['Time for Step1: ', num2str(step1_time), ' s']);
    step2_time = sum(step2_time_all);
    disp(['Time for Step2: ', num2str(step2_time), ' s']);

    % remove repeating peaks
    all_peaks = unique(all_peaks, 'rows');
    dlmwrite(fullfile(results_dir, 'ori_all_peaks.txt'), all_peaks);
    [num_All_RBC, ~] = size(all_peaks); % number of All_RBC
    %% Step3: Generate balls on merged peaks
    step3_time_tic = tic;
    [all_peaks, ball_radius, points_per_ball] = GB_generation_2(all_peaks);
    step3_time = toc(step3_time_tic); 
    disp(['Time for Step3: ', num2str(step3_time), ' s']);
    dlmwrite(fullfile(results_dir, 'all_peaks.txt'), all_peaks);
    [num_KM, ~] = size(all_peaks); % number of KM
    if size(all_peaks, 1) < k
        error('Not enough data points after sampling.');
    end
    %% Step4: Construct the skeleton by DPeak-like on balls
    step4_time_tic = tic;
    [label_all_peaks, peaks, nneigh, ordgamma] = obtain_skeleton2(all_peaks, ball_radius, points_per_ball, k);
    step4_time = toc(step4_time_tic);
    disp(['Time for Step4: ', num2str(step4_time), ' s']);
    %% Step5: Calculate the min distance between all_peaks and all data points to assign labels
    step5_time_tic = tic;
    labels = assignLabelsToData(label_all_peaks, all_peaks, data);
    step5_time = toc(step5_time_tic);
    disp(['Time for Step5: ', num2str(step5_time), ' s']);
    total_time = toc(total_time_tic);
    disp(['Total time for Clustering: ', sprintf('%.4f', total_time), ' s']);
    %% Saving results
    % Save labels to a .txt file
    writematrix(labels, fullfile(results_dir, 'labels.txt'));
    % Log
    fileID = fopen(fullfile(results_dir, 'log.txt'), 'w');
    fprintf(fileID, results_dir);
    fprintf(fileID, '\nTotal time: %.6f s\n', total_time);
    fprintf(fileID, 'Time for Step1: %.6f s\n', step1_time);
    fprintf(fileID, 'Time for Step2: %.6f s\n', step2_time);
    fprintf(fileID, 'Time for Step3: %.6f s\n', step3_time);
    fprintf(fileID, 'Time for Step4: %.6f s\n', step4_time);
    fprintf(fileID, 'Time for Step5: %.6f s\n', step5_time);
    fprintf(fileID, 'All_RBC: %d \n', num_All_RBC);
    fprintf(fileID, 'KM: %d \n', num_KM);
    fclose(fileID);
catch e
    disp(getReport(e, 'basic'));
end % end try