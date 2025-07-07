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

