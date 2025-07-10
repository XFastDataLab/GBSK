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

function peaks = getTopKPeaks(gamma, ball_centers, k)
    % This function returns the coordinates of the top k peaks from a list of gamma values,
    % where each peak is represented by its center coordinates.

    % Inputs:
    %   gamma - A vector containing the gamma values for each point.
    %   ball_centers - A matrix where each row represents the coordinates of a ball center.
    %   k - The number of top peaks to return.

    % Output:
    %   peaks - A matrix containing the coordinates of the top k peaks.

    % Sort gamma in descending order and get the indices
    [sorted_gamma, sorted_indices] = sort(gamma, 'descend');

     % Get the indices of the top k gamma values
    max_length = min(k, length(sorted_gamma));
    index_topk_gamma = sorted_indices(1:max_length);

    % Retrieve the coordinates of the top k peaks based on the indices
    peaks = ball_centers(index_topk_gamma, :);
end

