clear; % Clear variables
clc; % Clean command window

% Seed
% rng(54508909);
rng('shuffle');
seedData = rng;
disp(['Seed: ', num2str(seedData.Seed)]);

% data: n*d matrix where each row represents a data point
datasetName = 'Pendigits';
data = importdata('D:\Datasets\Pendigits\data.mat');
numPoints = size(data, 1);

multiplierM = 10; % 10 times of k granular-balls
%% Parameter Setting-------------------------------------------------
k = 10; % Parameter k: number of clusters, number of peak balls, category number
numSampleSets = 30; % Parameter s: number of sample sets
alpha = 0; % Parameter alpha: sampling proportion        set to '0' for default
M = multiplierM * k; % Parameter M: number of granular-balls from each sample set
% -------------------------------------------------------------------------
try
    if alpha
        % Define manually sampling proportion
        sampleSize = round(alpha * numPoints); % Sample size of a sample set
        % Generate dynamic folder name
        resultsDir = sprintf('D:/GBSK/experiment outcomes/%s/Seed_%d s_%d a_%.4f M_%d', datasetName, seedData.Seed, numSampleSets, alpha, M);
    else
        % Default setting: square root sampling
        alpha = 1 / sqrt(numPoints);
        sampleSize = round(sqrt(numPoints)); % Sample size of a sample set
        % Generate dynamic folder name
        resultsDir = sprintf('D:/GBSK/experiment outcomes/%s/Seed_%d s_%d a_sqrt M_%d', datasetName, seedData.Seed, numSampleSets, M);
    end

    % Create directories if they do not exist
    if ~exist(resultsDir, 'dir')
        mkdir(resultsDir);
    end
    %% GBSK
    aggRepBallCenters = [];
    totalTimeTic = tic;
    step1TimeAll = zeros(1, numSampleSets);
    step2TimeAll = zeros(1, numSampleSets);
    for sIdx = 1:numSampleSets
        %% Step1: Random Sampling
        step1TimeTic = tic;
        sampleSet = data(randperm(size(data, 1), sampleSize), :);
        step1TimeAll(sIdx) = toc(step1TimeTic);
        %% Step2: Identifying Representative Balls
        step2TimeTic = tic;
        % Obtain about M granular-balls from each sample set
        [ballCenters, ballRadii, numPointsPerBall] = GB_generation(sampleSet, M);
        medianRadius = median(ballRadii); % median radius consider across all granular-balls

        % Find k peaks (representative balls) from each sample set
        ballDensities = calculateDensity2(ballRadii, numPointsPerBall, medianRadius);
        delta = calculateDelta(ballDensities, ballCenters);   % Calculate delta for each granular-balls
        gamma = ballDensities .* delta; % gamma for each ball
        repBallCenters = getTopKPeaks(gamma, ballCenters, k);
        aggRepBallCenters(end + 1:end + size(repBallCenters, 1), :) = repBallCenters; % Aggregated Representative Ball Centers
        step2TimeAll(sIdx) = toc(step2TimeTic);
    end
    step1Time = sum(step1TimeAll);
    disp(['Time for Step1: ', num2str(step1Time), ' s']);
    step2Time = sum(step2TimeAll);
    disp(['Time for Step2: ', num2str(step2Time), ' s']);

    % Remove repeating centers
    aggRepBallCenters = unique(aggRepBallCenters, 'rows');
    dlmwrite(fullfile(resultsDir, 'aggRepBallCenters.txt'), aggRepBallCenters);
    [numARBC, ~] = size(aggRepBallCenters); % Number of aggRepBallCenters
    %% Step3: Identifying Key Balls
    step3TimeTic = tic;
    % Obtain KM key balls from aggRepBallCenters
    [keyBallCenters, keyBallRadii, numPointsPerKeyBall] = GB_generation_2(aggRepBallCenters);
    step3Time = toc(step3TimeTic); 
    disp(['Time for Step3: ', num2str(step3Time), ' s']);
    dlmwrite(fullfile(resultsDir, 'keyBallCenters.txt'), keyBallCenters);
    [W, ~] = size(keyBallCenters); % Number of key balls
    if W < k
        error('Not enough key balls.');
    end
    %% Step4: Sketching Out the Skeleton
    step4TimeTic = tic;
    [labelKeyBalls, ~, ~, ~] = sketchSkeleton(keyBallCenters, keyBallRadii, numPointsPerKeyBall, k);
    step4Time = toc(step4TimeTic);
    disp(['Time for Step4: ', num2str(step4Time), ' s']);
    %% Step5: Final Clustering
    step5TimeTic = tic;
    labels = assignLabelsToPoints(labelKeyBalls, keyBallCenters, data);
    step5Time = toc(step5TimeTic);
    disp(['Time for Step5: ', num2str(step5Time), ' s']);
    totalTime = toc(totalTimeTic);
    disp(['Total time for Clustering: ', sprintf('%.4f', totalTime), ' s']);
    %% Saving results
    % Save labels to a .txt file
    writematrix(labels, fullfile(resultsDir, 'labels.txt'));
    % Log
    fileID = fopen(fullfile(resultsDir, 'log.txt'), 'w');
    fprintf(fileID, resultsDir);
    fprintf(fileID, '\nTotal time: %.6f s\n', totalTime);
    fprintf(fileID, 'Time for Step1: %.6f s\n', step1Time);
    fprintf(fileID, 'Time for Step2: %.6f s\n', step2Time);
    fprintf(fileID, 'Time for Step3: %.6f s\n', step3Time);
    fprintf(fileID, 'Time for Step4: %.6f s\n', step4Time);
    fprintf(fileID, 'Time for Step5: %.6f s\n', step5Time);
    fprintf(fileID, 'numARBC (number of aggregated representative ball centers): %d \n', numARBC);
    fprintf(fileID, 'W (number of key balls): %d \n', W);
    fclose(fileID);
catch e
    disp(getReport(e, 'basic'));
end % end try