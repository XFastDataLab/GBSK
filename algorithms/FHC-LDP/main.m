clear all; close all; clc;

scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(scriptDir));
addpath(genpath(repoRoot));

%% load dataset
coverTypeDir = fullfile(repoRoot, 'datasets', 'CoverType');
datasetFile = fullfile(coverTypeDir, 'data.mat');
if exist(datasetFile, 'file')
    loaded = load(datasetFile);
    fieldNames = fieldnames(loaded);
    data = loaded.(fieldNames{1});
else
    datasetFile = fullfile(coverTypeDir, 'data.txt');
    if exist(datasetFile, 'file')
        data = readmatrix(datasetFile);
    else
        error('CoverType dataset not found under %s.', coverTypeDir);
    end
end

%answer = data(:,end);  % label
%answer = importdata('dataset/pendigits_labels.txt');
tic
%% parameter setting
k = 5;
C = 7;
%% FHC_LPD clustering
[cl] = FHC_LPD(data,k,C);
toc

outputDir = fullfile(repoRoot, 'experiment outcomes', 'FHC-LDP', 'CoverType');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
dlmwrite(fullfile(outputDir, 'labels_by_FHCLDP.txt'), cl');
