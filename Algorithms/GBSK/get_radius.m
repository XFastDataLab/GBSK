function radius = get_radius(gb)
    center = mean(gb, 1);   % 1返回每一列的平均值，2返回每一行的平均值
    diff_mat = bsxfun(@minus, center, gb);
    sq_diff_mat = diff_mat .^ 2;
    sq_distances = sum(sq_diff_mat, 2);
    distances = sqrt(sq_distances);
    radius = max(distances);
end
