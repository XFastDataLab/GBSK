% Public large-scale demo: MNIST8M.
clear; clc;
scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(scriptDir));
addpath(genpath(fullfile(repoRoot, 'algorithms', 'GBSK')));
config = struct('datasetName','MNIST8M','resultsRoot',fullfile(repoRoot,'experiment outcomes'),'k',10,'numSampleSets',30,'alpha',0,'multiplierM',10,'seed',[]);
[data, ~] = load_gbsk_dataset(repoRoot, config.datasetName);
results = run_gbsk(data, config);
disp(results);
