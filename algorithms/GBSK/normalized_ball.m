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

function [gb_list_temp, gb_list_not] = normalized_ball(gb_list, gb_list_not, radius_detect)
    gb_list_temp = {};
    for i = 1:length(gb_list)
        gb = gb_list{i};
        if size(gb, 1) < 2
            gb_list_not{end+1} = gb;
        else
            if get_radius(gb) <= 2 * radius_detect
                gb_list_not{end+1} = gb;
            else
                [ball_1, ball_2] = spilt_ball(gb);
                gb_list_temp{end+1} = ball_1;
                gb_list_temp{end+1} = ball_2;
            end
        end
    end
end