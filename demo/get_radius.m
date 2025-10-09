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

function radius = get_radius(gb)
    center = mean(gb, 1);   % 1返回每一列的平均值，2返回每一行的平均值
    diff_mat = bsxfun(@minus, center, gb);
    sq_diff_mat = diff_mat .^ 2;
    sq_distances = sum(sq_diff_mat, 2);
    distances = sqrt(sq_distances);
    radius = max(distances);
end
