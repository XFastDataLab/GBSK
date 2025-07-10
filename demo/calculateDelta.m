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

function delta = calculateDelta(density, ball_centers)
    % Calculate delta for each point in the sampled set based on the density

    % Initialize delta array
    delta = zeros(size(ball_centers, 1), 1);

    % Loop through each point in the sampled set
    for j = 1:size(ball_centers, 1)
        % Current point
        current_point = ball_centers(j, :);

        % Find points with higher density
        higher_density_points = ball_centers(density > density(j), :);

        % Calculate the distance to these points and find the minimum
        if ~isempty(higher_density_points)
            distances = pdist2(higher_density_points, current_point);   % Euclidean distances
            delta(j) = min(distances); % Minimum distance to a point with higher density
        else
            delta(j) = Inf; % Assign NaN if no point has a higher density
        end
    end
end