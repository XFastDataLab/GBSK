% Part of GBSK Clustering Algorithm
% Copyright (C) 2025 Junfeng Li (https://github.com/MarveenLee), Qinghong Lai
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

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