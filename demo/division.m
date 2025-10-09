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

function [gb_list_new, gb_list_not] = division(gb_list, gb_list_not)
    gb_list_new = {};
    for i = 1:length(gb_list)
        gb = gb_list{i};
        if size(gb, 1) > 1   % 用来控制颗粒球数量，可以1,2,4,8,16...的取，越大颗粒球数量少，执行速度越快,默认代码是1
            [ball_1, ball_2] = spilt_ball(gb);
            if size(ball_2, 1) <= 1 || size(ball_1, 1) <= 1
                gb_list_not{end+1} = gb;
                continue;
            end
            dm_parent = 1 / (get_radius(gb) + 0.01);
            dm_child_1 = 1 / (get_radius(ball_1) + 0.01);
            dm_child_2 = 1 / (get_radius(ball_2) + 0.01);
            w = size(ball_1, 1) + size(ball_2, 1);
            w1 = size(ball_1, 1) / w;
            w2 = size(ball_2, 1) / w;
            w_child = w1 * dm_child_1 + w2 * dm_child_2;
            t2 = w_child > dm_parent;
            if t2
                gb_list_new{end+1} = ball_1;
                gb_list_new{end+1} = ball_2;
            else
                gb_list_not{end+1} = gb;
            end
        else
            gb_list_not{end+1} = gb;
        end
    end
end
