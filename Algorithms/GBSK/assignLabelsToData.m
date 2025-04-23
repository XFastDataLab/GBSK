function labels_data = assignLabelsToData(label_all_peaks, all_peaks, data)
    % assignLabelsToData assigns labels to each data point based on the nearest point in all_peaks
    % 输入参数:
    %   Label_all_peaks - all_peaks 中每个点的标签
    %   all_peaks - 选定的峰值点的坐标数组
    %   data - 需要分配标签的数据点的数组
    % 输出参数:
    %   labels_data - 分配给每个数据点的标签数组

    % 使用 pdist2 计算 data 和 all_peaks 之间的距离
    distances = pdist2(data, all_peaks);

    % 对于每个数据点，找到距离最近的峰值点
    [~, nearest_peak_indices] = min(distances, [], 2);

    % 根据最近的峰值点分配标签
    labels_data = label_all_peaks(nearest_peak_indices);
end

