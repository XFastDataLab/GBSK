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

function density = calculateDensity2(ball_radius, points_per_ball, adjusted_radius)
    % This function calculates the density of each ball given their radius,
    % the number of points per ball, and an adjusted radius value.
    
    % Inputs:
    %   ball_radius - A vector of radii for each ball.
    %   points_per_ball - A vector of the number of points associated with each ball.
    %   adjusted_radius - A scalar value used to adjust the radius in the density calculation.

    % Output:
    %   density - A vector containing the density for each ball.

    density = zeros(length(ball_radius), 1); 
  
    for j = 1:length(ball_radius)
        if ball_radius(j) == 0
            density(j) = 0; % If the radius is zero, set density to zero
        else
            % Compute density using the formula: points per ball / (radius + adjusted radius)
            density(j) = points_per_ball(j) / (ball_radius(j) + adjusted_radius);
        end
    end
end

