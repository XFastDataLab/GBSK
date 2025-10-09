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

function gb_list = gbc_2(data_list)
    gb_list_temp = {data_list};
    gb_list_not_temp = {};

    % 第一个循环
    while true
        ball_number_old = length(gb_list_temp) + length(gb_list_not_temp);     
        [gb_list_temp, gb_list_not_temp] = division(gb_list_temp, gb_list_not_temp);
        ball_number_new = length(gb_list_temp) + length(gb_list_not_temp);
        
        if ball_number_new == ball_number_old
            gb_list_temp = gb_list_not_temp;
            break;
        end
    end

    % 计算半径并全局归一化
    radius = zeros(1, length(gb_list_temp));
    for i = 1:length(gb_list_temp)
        gb = gb_list_temp{i};
        if size(gb, 1) >= 2
            radius(i) = get_radius(gb);
        end
    end
    radius_median = median(radius);
    radius_mean = mean(radius);
    radius_detect = max(radius_median, radius_mean);
    gb_list_not_temp = {};

    % 第二个循环
    while true
        ball_number_old = length(gb_list_temp) + length(gb_list_not_temp);
        [gb_list_temp, gb_list_not_temp] = normalized_ball(gb_list_temp, gb_list_not_temp, radius_detect);
        ball_number_new = length(gb_list_temp) + length(gb_list_not_temp);

        if ball_number_new == ball_number_old
            gb_list_temp = gb_list_not_temp;
            break;
        end
    end

    gb_list = gb_list_temp;
end