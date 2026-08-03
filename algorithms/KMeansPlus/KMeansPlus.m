clear; clc;

scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(scriptDir));
addpath(genpath(fullfile(repoRoot, 'algorithms', 'GBSK')));

try
    dataset_name = 'Pendigits';
    [data, ~] = load_gbsk_dataset(repoRoot, dataset_name);
    k = 10;

    rng('shuffle');
    seedData = rng;
    disp(['Seed: ', num2str(seedData.Seed)]);

    results_dir = fullfile(repoRoot, 'experiment outcomes', 'KMeansPlus', dataset_name, sprintf('Seed_%d', seedData.Seed));
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
    end

    total_time_tic = tic;
    [labels, ~] = kmeans(data, k, 'Start', 'plus', 'Replicates', 1);
    total_time = toc(total_time_tic);
    disp(['Total time for Clustering: ', sprintf('%.4f', total_time), ' s']);

    writematrix(labels, fullfile(results_dir, 'labels.txt'));
    fileID = fopen(fullfile(results_dir, 'log.txt'), 'w');
    fprintf(fileID, '%s\n', results_dir);
    fprintf(fileID, 'dataset: %s\n', dataset_name);
    fprintf(fileID, 'seed: %d\n', seedData.Seed);
    fprintf(fileID, 'k: %d\n', k);
    fprintf(fileID, 'Total time: %.6f s\n', total_time);
    fclose(fileID);
catch e
    disp(getReport(e, 'basic'));
end
