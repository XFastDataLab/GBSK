% GBSK Clustering Algorithm
% Copyright (C) 2025 Junfeng Li (https://github.com/MarveenLee), Qinghong Lai
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

% Requires MATLAB version R2021a or later
% Random indexing without loading the entire file into memory
% Note that the script requires 105GB memory at most.
%% GBSK dealing with binary data files
clear; % clear working area
clc; % clean command window
datasetName = 'MNIST8M';
% Data path
dataFile = 'D:\Datasets\MNIST8M\MNIST8M_data.h5';
data = h5read(dataFile, '/MNIST8M');
data = double(data);
dataInfo = h5info(dataFile);
dataSize = dataInfo.Datasets.Dataspace.Size;
numPoints = dataSize(1);   % Total number of points
numDim = dataSize(2);       % Number of dimensions

% Seed
% rng(619);
rng('shuffle'); % Shuffle the seed based on the current time
seedData = rng; % Record the current seed and the random number generator settings
disp(['Seed: ', num2str(seedData.Seed)]); % Display the seed

multiplierM = 10;
%% Parameters of GBSK
% Parameter s: number of sample sets
numSampleSets = 30;

% Parameter alpha: portion of sampling
% alpha = 1e-3;                     %*** when alpha is defined manually ***
alpha = 1 / sqrt(numPoints);

% Parameter k: category number, the number of peak balls in step 2
k = 10;

% Parameter M: number of balls
M = multiplierM * k;
try
    % *** sampleSize when alpha is defined manually ***
%     sampleSize = round(alpha * numPoints); % sample size of a sample set

    % *** sampleSize when alpha is defined automatically ***
    sampleSize = round(sqrt(numPoints)); % sample size of a sample set
    % Generate dynamic folder name
    resultsDir = sprintf('D:/GBSK/experiment outcomes/%s/Seed_%d s_%d a_%d M_%d', datasetName, seedData.Seed, numSampleSets, alpha, M);
    if ~exist(resultsDir, 'dir')
        mkdir(resultsDir);
    end
    %% Run GBSK
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
    [numARBC, ~] = size(aggRepBallCenters); % number of aggRepBallCenters
    %% Step3: Identifying Key Balls
    step3TimeTic = tic;
    [aggRepBallCenters, ballRadii, numPointsPerBall] = GB_generation_2(aggRepBallCenters);
    step3Time = toc(step3TimeTic); 
    disp(['Time for Step3: ', num2str(step3Time), ' s']);
    dlmwrite(fullfile(resultsDir, 'keyBallCenters.txt'), aggRepBallCenters);
    [W, ~] = size(aggRepBallCenters); % number of key balls
    if W < k
        error('Not enough key balls.');
    end
    %% Step4: Sketching Out the Skeleton
    step4TimeTic = tic;
    [labelKeyBalls, repBallCenters, nneigh, ordgamma] = obtain_skeleton2(aggRepBallCenters, ballRadii, numPointsPerBall, k);
    step4Time = toc(step4TimeTic);
    disp(['Time for Step4: ', num2str(step4Time), ' s']);
    %% Step5: Final Clustering
    step5TimeTic = tic;
    labels = assignLabelsToData(labelKeyBalls, aggRepBallCenters, data);
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