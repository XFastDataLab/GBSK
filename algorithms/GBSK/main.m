% GBSK public entrypoint.
clear; clc;

scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(scriptDir));
addpath(genpath(fullfile(repoRoot, 'algorithms', 'GBSK')));

config = struct();
config.datasetName = '3M2D5';
config.resultsRoot = fullfile(repoRoot, 'experiment outcomes');
config.k = 5;
config.numSampleSets = 30;
config.alpha = 0;
config.multiplierM = 10;
config.seed = [];

[data, ~] = load_gbsk_dataset(repoRoot, config.datasetName);
results = run_gbsk(data, config);
disp(results);
