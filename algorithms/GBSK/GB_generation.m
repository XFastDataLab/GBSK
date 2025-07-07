function [ball_centers, ball_radius,points_per_ball] = GB_generation(data_list, target_ball_count)
    % 调用gbc函数处理data_list
    gb = gbc(data_list, target_ball_count);
    points_per_ball = arrayfun(@(x) size(gb{x}, 1), 1:length(gb))';

    % 初始化中心点列表和半径列表
    center_list = {};
    radius_list = [];

    % 循环遍历gb中的每个元素
    for i = 1:length(gb)
        gb_ = gb{i};
        center_list{i} = mean(gb_, 1);         % 计算每个点集的中心
        radius_list(i) = get_radius(gb_);      % 计算每个点集的半径
    end

    % 将单元数组转换为矩阵
    ball_centers = cell2mat(center_list');
    ball_radius = radius_list';
end