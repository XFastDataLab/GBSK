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

