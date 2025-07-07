function [labelKeyBalls, rootBallCenters, nearestNeighbors, orderGamma] = sketchSkeleton(keyBallCenters, keyBallRadii, numPointsPerKeyBall, k)
    % Input:
    %   keyBallCenters - a matrix where each row represents a peak point
    %   keyBallRadii - a vector containing the radius of each ball
    %   numPointsPerKeyBall - a vector containing the number of points in each ball
    %   k - the number of cluster centers to select
    % Output:
    %   labelKeyBalls - a vector containing the cluster label for each peak
    %   rootBallCenters - a matrix containing the selected cluster center peaks
    %   nearestNeighbors - a vector containing the index of the nearest neighbor with higher density for each key ball
    %   orderGamma - a vector containing the indices of points sorted by gamma value in descending order

    % Initialize points with the input key ball centers
    points = keyBallCenters;

    % Get the number of points
    [numPoints, ~] = size(points);

    % Calculate the number of unique point pairs
    numPairs = (numPoints * numPoints - numPoints) / 2;

    % Initialize a matrix to store distances between point pairs
    distances = zeros(numPairs, 3);

    % Calculate the pairwise distance matrix
    distMat = pdist2(points, points);

    % Initialize the pair index
    pairIndex = 1;

    % Loop through each point to populate the distances matrix
    for i = 1:numPoints - 1
        % Set the row index for the current point
        distances(pairIndex:pairIndex + (numPoints - i) - 1, 1) = i * ones(numPoints - i, 1);

        % Set the column index for the current point
        distances(pairIndex:pairIndex + (numPoints - i) - 1, 2) = (i + 1:numPoints)';

        % Set the distance values for the current point
        distances(pairIndex:pairIndex + (numPoints - i) - 1, 3) = distMat(i, i + 1:numPoints)';

        % Update the pair index for the next iteration
        pairIndex = pairIndex + (numPoints - i);
    end

    % Convert the distances matrix to a full distance matrix
    xx = distances;

    % Find the maximum index value in the distances matrix
    maxIndex = max(xx(:, 2));

    % Find the maximum row value in the distances matrix
    maxRow = max(xx(:, 1));

    % Ensure the maximum index is the larger of the two values
    if (maxRow > maxIndex)   
        maxIndex = maxRow;
    end

    % Get the total number of pairs
    numPairs = size(xx, 1);  

    % Initialize a full distance matrix
    fullDistMatrix = zeros(maxIndex, maxIndex);

    % Populate the full distance matrix with the calculated distances
    for i = 1:numPairs
        row = xx(i, 1);
        col = xx(i, 2);
        fullDistMatrix(row, col) = xx(i, 3);
        fullDistMatrix(col, row) = xx(i, 3);
    end

    % Calculate the median radius
    medianRadius = median(keyBallRadii);

    % Calculate the density of key balls
    density = calculateDensity2(keyBallRadii, numPointsPerKeyBall, medianRadius);

    % Find the maximum distance in the full distance matrix
    maxDist = max(max(fullDistMatrix));

    % Sort the density values in descending order
    [~, orderDensity] = sort(density, 'descend');

    % Initialize delta and nearestNeighbors arrays
    delta(orderDensity(1)) = -1;
    nearestNeighbors(orderDensity(1)) = 0;

    % Calculate delta values and nearest neighbors
    for i = 2:maxIndex
        delta(orderDensity(i)) = maxDist;
        for j = 1:i - 1
            if(fullDistMatrix(orderDensity(i), orderDensity(j)) < delta(orderDensity(i)))
                delta(orderDensity(i)) = fullDistMatrix(orderDensity(i), orderDensity(j));
                nearestNeighbors(orderDensity(i)) = orderDensity(j);
            end
        end
    end

    % Set the delta value for the first point
    delta(orderDensity(1)) = max(delta(:));

    % Initialize index and gamma arrays
    for i = 1:maxIndex
%         index(i) = i; % unused
        gamma(i) = density(i) * delta(i);
    end

    % Sort gamma values in descending order
    [gammaSorted, orderGamma] = sort(gamma, 'descend');  

    % Select the top k indices as cluster centers (root key balls)
    rootIndex = orderGamma(1:k);

    % Extract the cluster centers
    rootBallCenters = keyBallCenters(rootIndex, :);

    % Initialize the number of clusters
    numClusters = 0;

    % Initialize cluster labels
    for i = 1:maxIndex
        clusterLabel(i) = -1;
    end

    % Assign cluster labels based on density and delta values
    for i = 1:maxIndex
        if(density(i) * delta(i) >= gammaSorted(k))      
            numClusters = numClusters + 1;
            clusterLabel(i) = numClusters; 
%             clusterCenters(numClusters) = i; % unused
        end
    end

    % TO BE REFINED: FIND THE CORRESPONDING ROOT OF THE CURRENT BALL
    % Assign cluster labels to remaining key balls
    for i = 1:maxIndex
        if (clusterLabel(orderDensity(i)) == -1)
            clusterLabel(orderDensity(i)) = clusterLabel(nearestNeighbors(orderDensity(i)));
        end
    end

    % Reshape the cluster labels to a column vector
    labelKeyBalls = reshape(clusterLabel, length(clusterLabel), 1);
end