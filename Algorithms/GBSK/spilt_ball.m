function [ball1, ball2] = spilt_ball(gb)
    splits_k = 2;
    [label, ~] = kmeans(gb, splits_k, 'Start', 'plus', 'MaxIter', 100, 'Replicates', 1);    % 原先的迭代次数100
    ball1 = gb(label == 1, :);
    ball2 = gb(label == 2, :);
end
