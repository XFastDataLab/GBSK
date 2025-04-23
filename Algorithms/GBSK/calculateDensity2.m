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

