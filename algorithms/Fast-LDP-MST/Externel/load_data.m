function [data,annotation_data,ClustN,dataName] = load_data(dataName)
    scriptDir = fileparts(mfilename('fullpath'));
    repoRoot = fileparts(fileparts(fileparts(scriptDir)));
    datasetsRoot = fullfile(repoRoot, 'datasets');

    if strcmpi(dataName,'minist')
        dataName = 'MNIST';
    end

    dataFileCandidates = { ...
        fullfile(datasetsRoot, dataName, 'data.mat'), ...
        fullfile(datasetsRoot, dataName, 'data.txt'), ...
        fullfile(datasetsRoot, dataName, 'mocap_norm.txt'), ...
        fullfile(datasetsRoot, [dataName '_data.h5']), ...
        fullfile(datasetsRoot, [dataName '.mat']), ...
        fullfile(datasetsRoot, [dataName '.txt']) ...
    };

    dataFile = '';
    for i = 1:numel(dataFileCandidates)
        if exist(dataFileCandidates{i}, 'file')
            dataFile = dataFileCandidates{i};
            break;
        end
    end
    if isempty(dataFile)
        error(['Data file for ', dataName, ' not found under ', datasetsRoot]);
    end

    [~, ~, ext] = fileparts(dataFile);
    if strcmpi(ext, '.mat')
        loaded = load(dataFile);
        fieldNames = fieldnames(loaded);
        data = loaded.(fieldNames{1});
    else
        data = load(dataFile);
    end

    labelCandidates = { ...
        fullfile(datasetsRoot, dataName, 'labels.txt'), ...
        fullfile(datasetsRoot, dataName, 'annotation_data.txt'), ...
        fullfile(datasetsRoot, dataName, 'annotation.txt'), ...
        fullfile(datasetsRoot, [dataName '_labels.txt']), ...
        fullfile(datasetsRoot, [dataName '.labels.txt']) ...
    };

    annotation_data = [];
    for i = 1:numel(labelCandidates)
        if exist(labelCandidates{i}, 'file')
            annotation_data = load(labelCandidates{i});
            break;
        end
    end

    if ~isempty(annotation_data) && min(annotation_data) == 0
        annotation_data = annotation_data + 1;
    end
    if isempty(annotation_data)
        ClustN = NaN;
    else
        ClustN = length(unique(annotation_data));
    end

    [N,dim] = size(data);
    if isempty(annotation_data)
        disp(['dataName: ',dataName, '; #objects: ',num2str(N),'; #features: ',num2str(dim)]);
    else
        disp(['dataName: ',dataName, '; #objects: ',num2str(N),'; #features: ',num2str(dim),'; #Clusters: ',num2str(ClustN)]);
    end
end
