function [gb_list_temp, gb_list_not] = normalized_ball(gb_list, gb_list_not, radius_detect)
    gb_list_temp = {};
    for i = 1:length(gb_list)
        gb = gb_list{i};
        if size(gb, 1) < 2
            gb_list_not{end+1} = gb;
        else
            if get_radius(gb) <= 2 * radius_detect
                gb_list_not{end+1} = gb;
            else
                [ball_1, ball_2] = spilt_ball(gb);
                gb_list_temp{end+1} = ball_1;
                gb_list_temp{end+1} = ball_2;
            end
        end
    end
end