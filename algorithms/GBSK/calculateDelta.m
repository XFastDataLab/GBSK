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