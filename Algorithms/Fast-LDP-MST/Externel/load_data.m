function [data,annotation_data,ClustN,dataName] = load_data(dataName)
    if strcmp(dataName,'minist')  % 检查是否是PenDigits数据集
        tic
        data = load('L:\experiment\合成聚类数据集\3M2D5\data.txt');  % 加载数据集
     %   data = load('Datasets/ConfLongDemo_JSI_data.txt');  % 加载数据集
        load_time = toc;
        disp(['Time for loading data: ', num2str(load_time), ' s']);
        annotation_data = load('L:\experiment\合成聚类数据集\3M2D5\labels.txt');  % 加载标签
     %   annotation_data = load('Datasets/ConfLongDemo_JSI_labels.txt');  % 加载标签
        ClustN = length(unique(annotation_data));  % 计算不同标签的数量
    else
        % 保留原始代码以处理其他数据集
        if exist([dataName,'.mat'],'file')
            load([dataName,'.mat'],'data','annotation_data');
            if exist('annotation_data','var') && (min(annotation_data) == 0)
                annotation_data = annotation_data + 1;
            end
        else
            error(['Data file ',dataName,'.mat does not exist']);
        end
    end
    [N,dim] = size(data);
    disp(['dataName: ',dataName, '; #objects: ',num2str(N),'; #features: ',num2str(dim),'; #Clusters: ',num2str(ClustN)]);
end
