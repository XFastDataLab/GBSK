function results = run_gbsk(data, config)
%RUN_GBSK Shared execution entrypoint for GBSK and AGBSK.
%   results = RUN_GBSK(data, config) runs the clustering pipeline on the
%   given data matrix and writes outputs to config.resultsRoot.

    if nargin < 2
        error('run_gbsk requires data and config.');
    end
    if ~isfield(config, 'datasetName') || ~isfield(config, 'resultsRoot') || ~isfield(config, 'k')
        error('config must contain datasetName, resultsRoot, and k.');
    end
    if ~isfield(config, 'numSampleSets') || isempty(config.numSampleSets)
        config.numSampleSets = 30;
    end
    if ~isfield(config, 'alpha') || isempty(config.alpha)
        config.alpha = 0;
    end
    if ~isfield(config, 'multiplierM') || isempty(config.multiplierM)
        config.multiplierM = 10;
    end
    if ~isfield(config, 'seed')
        config.seed = [];
    end

    if isempty(config.seed)
        rng('shuffle');
    else
        rng(config.seed);
    end
    seedData = rng;

    numPoints = size(data, 1);
    if config.alpha > 0
        sampleSize = max(1, round(config.alpha * numPoints));
        alphaTag = sprintf('a_%.4f', config.alpha);
        alphaValue = config.alpha;
    else
        alphaValue = 1 / sqrt(numPoints);
        sampleSize = max(1, round(sqrt(numPoints)));
        alphaTag = 'a_sqrt';
    end

    M = config.multiplierM * config.k;
    resultsDir = fullfile(config.resultsRoot, config.datasetName, sprintf('Seed_%d s_%d %s M_%d', seedData.Seed, config.numSampleSets, alphaTag, M));
    if ~exist(resultsDir, 'dir')
        mkdir(resultsDir);
    end

    aggRepBallCenters = [];
    totalTimeTic = tic;
    step1TimeAll = zeros(1, config.numSampleSets);
    step2TimeAll = zeros(1, config.numSampleSets);

    for sIdx = 1:config.numSampleSets
        step1TimeTic = tic;
        sampleIndices = randperm(size(data, 1), sampleSize);
        sampleSet = data(sampleIndices, :);
        step1TimeAll(sIdx) = toc(step1TimeTic);

        step2TimeTic = tic;
        [ballCenters, ballRadii, numPointsPerBall] = GB_generation(sampleSet, M);
        medianRadius = median(ballRadii);
        ballDensities = calculateDensity2(ballRadii, numPointsPerBall, medianRadius);
        delta = calculateDelta(ballDensities, ballCenters);
        gamma = ballDensities .* delta;
        repBallCenters = getTopKPeaks(gamma, ballCenters, config.k);
        aggRepBallCenters(end + 1:end + size(repBallCenters, 1), :) = repBallCenters;
        step2TimeAll(sIdx) = toc(step2TimeTic);
    end

    step1Time = sum(step1TimeAll);
    step2Time = sum(step2TimeAll);
    disp(['Time for Step1: ', num2str(step1Time), ' s']);
    disp(['Time for Step2: ', num2str(step2Time), ' s']);

    aggRepBallCenters = unique(aggRepBallCenters, 'rows');
    writematrix(aggRepBallCenters, fullfile(resultsDir, 'aggRepBallCenters.txt'));
    numARBC = size(aggRepBallCenters, 1);

    step3TimeTic = tic;
    [keyBallCenters, keyBallRadii, numPointsPerKeyBall] = GB_generation_2(aggRepBallCenters);
    step3Time = toc(step3TimeTic);
    disp(['Time for Step3: ', num2str(step3Time), ' s']);
    writematrix(keyBallCenters, fullfile(resultsDir, 'keyBallCenters.txt'));
    W = size(keyBallCenters, 1);
    if W < config.k
        error('Not enough key balls.');
    end

    step4TimeTic = tic;
    [labelKeyBalls, ~, ~, ~] = sketchSkeleton(keyBallCenters, keyBallRadii, numPointsPerKeyBall, config.k);
    step4Time = toc(step4TimeTic);
    disp(['Time for Step4: ', num2str(step4Time), ' s']);

    step5TimeTic = tic;
    labels = assignLabelsToPoints(labelKeyBalls, keyBallCenters, data);
    step5Time = toc(step5TimeTic);
    disp(['Time for Step5: ', num2str(step5Time), ' s']);

    totalTime = toc(totalTimeTic);
    disp(['Total time for Clustering: ', sprintf('%.4f', totalTime), ' s']);

    writematrix(labels, fullfile(resultsDir, 'labels.txt'));
    fileID = fopen(fullfile(resultsDir, 'log.txt'), 'w');
    fprintf(fileID, '%s\n', resultsDir);
    fprintf(fileID, 'dataset: %s\n', config.datasetName);
    fprintf(fileID, 'seed: %d\n', seedData.Seed);
    fprintf(fileID, 'k: %d\n', config.k);
    fprintf(fileID, 's: %d\n', config.numSampleSets);
    fprintf(fileID, 'alpha: %.8f\n', alphaValue);
    fprintf(fileID, 'M: %d\n', M);
    fprintf(fileID, 'Total time: %.6f s\n', totalTime);
    fprintf(fileID, 'Time for Step1: %.6f s\n', step1Time);
    fprintf(fileID, 'Time for Step2: %.6f s\n', step2Time);
    fprintf(fileID, 'Time for Step3: %.6f s\n', step3Time);
    fprintf(fileID, 'Time for Step4: %.6f s\n', step4Time);
    fprintf(fileID, 'Time for Step5: %.6f s\n', step5Time);
    fprintf(fileID, 'numARBC (number of aggregated representative ball centers): %d\n', numARBC);
    fprintf(fileID, 'W (number of key balls): %d\n', W);
    fclose(fileID);

    results = struct();
    results.datasetName = config.datasetName;
    results.resultsDir = resultsDir;
    results.seed = seedData.Seed;
    results.alpha = alphaValue;
    results.k = config.k;
    results.s = config.numSampleSets;
    results.M = M;
    results.totalTime = totalTime;
    results.stepTimes = [step1Time, step2Time, step3Time, step4Time, step5Time];
    results.numARBC = numARBC;
    results.W = W;
end
