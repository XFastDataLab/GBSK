function [data, labelPath] = load_gbsk_dataset(repoRoot, datasetName)
    datasetsRoot = fullfile(repoRoot, 'datasets');
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

    selectedDataFile = '';
    directDatasetDir = fullfile(datasetsRoot, datasetName);
    preferredPatterns = {'data.mat', 'data.txt', [datasetName '_data.h5'], 'anisotropic_gaussian_clusters.bin'};
    if exist(directDatasetDir, 'dir')
        for i = 1:numel(preferredPatterns)
            candidate = fullfile(directDatasetDir, preferredPatterns{i});
            if exist(candidate, 'file')
                selectedDataFile = candidate;
                break;
            end
        end
        if isempty(selectedDataFile)
            listing = [dir(fullfile(directDatasetDir, '*.mat')); dir(fullfile(directDatasetDir, '*.txt')); dir(fullfile(directDatasetDir, '*.h5')); dir(fullfile(directDatasetDir, '*.bin'))];
            for i = 1:numel(listing)
                candidate = fullfile(listing(i).folder, listing(i).name);
                if ~contains(lower(candidate), 'label')
                    selectedDataFile = candidate;
                    break;
                end
            end
        end
    end

    if isempty(selectedDataFile)
        listing = [dir(fullfile(datasetsRoot, '**', '*.mat')); dir(fullfile(datasetsRoot, '**', '*.txt')); dir(fullfile(datasetsRoot, '**', '*.h5')); dir(fullfile(datasetsRoot, '**', '*.bin'))];
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
                selectedDataFile = candidate;
            end
        end
    end

    if isempty(selectedDataFile)
        error('Dataset %s not found under %s.', datasetName, datasetsRoot);
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

    labelCandidates = [];
    if exist(directDatasetDir, 'dir')
        labelCandidates = [labelCandidates; dir(fullfile(directDatasetDir, 'labels.txt')); dir(fullfile(directDatasetDir, 'label.txt')); dir(fullfile(directDatasetDir, 'groundtruth.txt'))]; %#ok<AGROW>
    end
    labelCandidates = [labelCandidates; dir(fullfile(datasetsRoot, '**', 'labels.txt')); dir(fullfile(datasetsRoot, '**', 'label.txt')); dir(fullfile(datasetsRoot, '**', 'groundtruth.txt'))]; %#ok<AGROW>
    for i = 1:numel(labelCandidates)
        candidate = fullfile(labelCandidates(i).folder, labelCandidates(i).name);
        lowerCandidate = lower(candidate);
        if contains(lowerCandidate, lower(datasetName)) || any(cellfun(@(t) contains(lowerCandidate, lower(t)), searchTerms))
            labelPath = candidate;
            break;
        end
    end
end
