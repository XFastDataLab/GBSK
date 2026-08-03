function [data, labelPath] = load_gbsk_dataset(repoRoot, datasetName)
    datasetsRoot = fullfile(repoRoot, 'datasets');
    externalRoot = 'H:\Datasets';
    labelPath = '';

    if strcmpi(datasetName, 'Segmentation')
        searchTerms = {'segment', 'segmentation'};
    elseif strcmpi(datasetName, 'Twenty')
        searchTerms = {'twenty'};
    elseif strcmpi(datasetName, 'Chainlink') || strcmpi(datasetName, 'ChainLink')
        searchTerms = {'chainlink'};
    elseif strcmpi(datasetName, 'EngyTime')
        searchTerms = {'engytime'};
    elseif strcmpi(datasetName, 'Waveform')
        searchTerms = {'waveform'};
    elseif strcmpi(datasetName, 'S3')
        searchTerms = {'s3'};
    elseif strcmpi(datasetName, '3M2D5')
        searchTerms = {'3m2d5'};
    elseif strcmpi(datasetName, 'MNIST8M')
        searchTerms = {'mnist8m'};
    elseif strcmpi(datasetName, 'AGC100M')
        searchTerms = {'agc100m', 'anisotropic_gaussian_clusters'};
    elseif strcmpi(datasetName, 'N-BaIoT') || strcmpi(datasetName, 'N-BaIot')
        searchTerms = {'nbaiot', 'n-baiot', 'whole_data'};
    else
        searchTerms = {datasetName};
    end

    selectedDataFile = find_dataset_file(datasetsRoot, datasetName, searchTerms);
    if isempty(selectedDataFile) && exist(externalRoot, 'dir')
        selectedDataFile = find_dataset_file(externalRoot, datasetName, searchTerms);
    end

    if isempty(selectedDataFile)
        error('Dataset %s not found under %s or %s.', datasetName, datasetsRoot, externalRoot);
    end

    [~, ~, ext] = fileparts(selectedDataFile);
    switch lower(ext)
        case '.mat'
            loaded = load(selectedDataFile);
            fieldNames = fieldnames(loaded);
            data = loaded.(fieldNames{1});
        case '.txt'
            data = readmatrix(selectedDataFile);
        case '.h5'
            data = double(h5read(selectedDataFile, ['/' datasetName]));
        case '.bin'
            fid = fopen(selectedDataFile, 'r');
            if fid == -1
                error('Unable to open dataset file: %s', selectedDataFile);
            end
            cleanup = onCleanup(@() fclose(fid)); %#ok<NASGU>
            data = fread(fid, inf, 'single=>double');
        otherwise
            error('Unsupported dataset format: %s', selectedDataFile);
    end

    selectedLabelFile = find_label_file(fileparts(selectedDataFile), datasetsRoot, externalRoot, datasetName, searchTerms);
    if ~isempty(selectedLabelFile)
        labelPath = selectedLabelFile;
    end
end

function selectedFile = find_dataset_file(searchRoot, datasetName, searchTerms)
    selectedFile = '';
    directDatasetDir = fullfile(searchRoot, datasetName);
    preferredPatterns = {'data.mat', 'data.txt', [datasetName '_data.h5'], 'anisotropic_gaussian_clusters.bin', [datasetName '.mat'], [datasetName '.txt']};

    if exist(directDatasetDir, 'dir')
        for i = 1:numel(preferredPatterns)
            candidate = fullfile(directDatasetDir, preferredPatterns{i});
            if exist(candidate, 'file')
                selectedFile = candidate;
                return;
            end
        end
        listing = [dir(fullfile(directDatasetDir, '*.mat')); dir(fullfile(directDatasetDir, '*.txt')); dir(fullfile(directDatasetDir, '*.h5')); dir(fullfile(directDatasetDir, '*.bin'))];
        for i = 1:numel(listing)
            candidate = fullfile(listing(i).folder, listing(i).name);
            if ~contains(lower(candidate), 'label')
                selectedFile = candidate;
                return;
            end
        end
    end

    listing = [dir(fullfile(searchRoot, '**', '*.mat')); dir(fullfile(searchRoot, '**', '*.txt')); dir(fullfile(searchRoot, '**', '*.h5')); dir(fullfile(searchRoot, '**', '*.bin'))];
    bestScore = -inf;
    for i = 1:numel(listing)
        candidate = fullfile(listing(i).folder, listing(i).name);
        [~, baseName, ext] = fileparts(candidate);
        lowerName = lower([baseName ext]);
        if contains(lowerName, 'label')
            continue;
        end
        score = 0;
        for t = 1:numel(searchTerms)
            if contains(lowerName, lower(searchTerms{t}))
                score = score + 10;
            end
        end
        if strcmpi(baseName, datasetName)
            score = score + 20;
        end
        if strcmpi(baseName, 'data')
            score = score + 5;
        end
        if score > bestScore
            bestScore = score;
            selectedFile = candidate;
        end
    end
end

function selectedLabelFile = find_label_file(preferredDir, datasetsRoot, externalRoot, datasetName, searchTerms)
    selectedLabelFile = '';
    labelCandidates = [];
    if exist(preferredDir, 'dir')
        labelCandidates = [labelCandidates; dir(fullfile(preferredDir, 'labels.txt')); dir(fullfile(preferredDir, 'label.txt')); dir(fullfile(preferredDir, 'groundtruth.txt'))]; %#ok<AGROW>
    end
    if exist(datasetsRoot, 'dir')
        labelCandidates = [labelCandidates; dir(fullfile(datasetsRoot, '**', 'labels.txt')); dir(fullfile(datasetsRoot, '**', 'label.txt')); dir(fullfile(datasetsRoot, '**', 'groundtruth.txt'))]; %#ok<AGROW>
    end
    if exist(externalRoot, 'dir')
        labelCandidates = [labelCandidates; dir(fullfile(externalRoot, '**', 'labels.txt')); dir(fullfile(externalRoot, '**', 'label.txt')); dir(fullfile(externalRoot, '**', 'groundtruth.txt'))]; %#ok<AGROW>
    end
    for i = 1:numel(labelCandidates)
        candidate = fullfile(labelCandidates(i).folder, labelCandidates(i).name);
        lowerCandidate = lower(candidate);
        if contains(lowerCandidate, lower(datasetName)) || any(cellfun(@(t) contains(lowerCandidate, lower(t)), searchTerms))
            selectedLabelFile = candidate;
            return;
        end
    end
end
