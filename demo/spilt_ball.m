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

function [ball1, ball2] = spilt_ball(gb)
    splits_k = 2;
    [label, ~] = kmeans(gb, splits_k, 'Start', 'plus', 'MaxIter', 100, 'Replicates', 1);    % 原先的迭代次数100
    ball1 = gb(label == 1, :);
    ball2 = gb(label == 2, :);
end
