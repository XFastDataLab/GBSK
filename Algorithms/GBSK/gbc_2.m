function gb_list = gbc_2(data_list)
    gb_list_temp = {data_list};
    gb_list_not_temp = {};

    % 第一个循环
    while true
        ball_number_old = length(gb_list_temp) + length(gb_list_not_temp);     
        [gb_list_temp, gb_list_not_temp] = division(gb_list_temp, gb_list_not_temp);
        ball_number_new = length(gb_list_temp) + length(gb_list_not_temp);
        
        if ball_number_new == ball_number_old
            gb_list_temp = gb_list_not_temp;
            break;
        end
    end

    % 计算半径并全局归一化
    radius = zeros(1, length(gb_list_temp));
    for i = 1:length(gb_list_temp)
        gb = gb_list_temp{i};
        if size(gb, 1) >= 2
            radius(i) = get_radius(gb);
        end
    end
    radius_median = median(radius);
    radius_mean = mean(radius);
    radius_detect = max(radius_median, radius_mean);
    gb_list_not_temp = {};

    % 第二个循环
    while true
        ball_number_old = length(gb_list_temp) + length(gb_list_not_temp);
        [gb_list_temp, gb_list_not_temp] = normalized_ball(gb_list_temp, gb_list_not_temp, radius_detect);
        ball_number_new = length(gb_list_temp) + length(gb_list_not_temp);

        if ball_number_new == ball_number_old
            gb_list_temp = gb_list_not_temp;
            break;
        end
    end

    gb_list = gb_list_temp;
end