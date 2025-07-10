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

function labelPoints = assignLabelsToPoints(labelKeyBalls, keyBallCenters, dataPoints)
    % assignLabelsToData assigns labels to each data point based on the nearest point in all_peaks
    % Input:
    %   labelKeyBalls - labels for key balls
    %   keyBallCenters - centers of key balls
    %   dataPoints - points to be clustered
    % Output:
    %   labelPoints - clustering labels for data points

    % Calculate distances between points and key ball centers
    distances = pdist2(dataPoints, keyBallCenters);

    % Find nearest key ball for each point
    [~, nearestKeyBallIndices] = min(distances, [], 2);

    % Label points according to nearest key balls
    labelPoints = labelKeyBalls(nearestKeyBallIndices);
end

