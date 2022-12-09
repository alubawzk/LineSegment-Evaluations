function [ precision, recall, iou ] = evaluate_line_segment( line_est, line_gnd, eval_param)
%EVALUATE_LSC Summary of this function goes here
%   Line segment instance should be in a form (x1, y1, x2, y2, center_x, center_y, length, angle)
%zhj changed
%
%%
b_plot = false;
precision = 0;
recall = 0;

% Initialize retrieval numbers -- 1st row: pixelwise, 2nd row: line segment wise

tp = 0;
% --------------------------------------------------------------------------------------------------

% --------------------------------------------------------------------------------------------------
% Convert a line segment to a set of indices -- gnd (x1, y1, x2, y2, center_x, center_y, length, angle)
num_gnd = size(line_gnd, 1);

% Convert a line segment to a set of indices -- est (x1, y1, x2, y2, center_x, center_y, length, angle)
num_est = size(line_est, 1);
idx_est = cell(num_est, 1);
num_total_pixel_est = 0;
bSteep_est = zeros(num_est,1);
% --------------------------------------------------------------------------------------------------

%%
for i_gnd = 1:num_gnd
    try
        % If the perpendicular distance and angle difference is less than
        % threshold, take it as true positive
        d = line_gnd(i_gnd, 3:4) - line_gnd(i_gnd, 1:2);
        d = d/norm(d); % direction vector of the line 方向向量
        n = [-d(2),d(1)]; % unit normal vector of the line
        
        % line structure: (x1, y1, x2, y2, center_x, center_y, length, angle)
        %连接2个的中点，从EST中点向GT直线做垂线的距离小于1
        idx_perpd = GetPerpDist(line_gnd(i_gnd, 5:6), line_est(:, 5:6), line_gnd(i_gnd, 8))' <= eval_param.thres_dist;
        %线段角度小于阈值的线段标1
        idx_ang = bAngleAligned(line_gnd(i_gnd, 8), line_est(:, 8), eval_param.thres_ang);
        idx_cand = find(idx_perpd & idx_ang);%与操作，1&0=0
        
        if isempty(idx_cand)
            % False negative

        else
            % True positive
            [ gt_covered, idx_valid, gt_valid, pd_covered ] = line_area_intersection(line_gnd(i_gnd,:), line_est(idx_cand,:));

            if ~sum(gt_valid)
                continue; 
            end            

            if (sum(gt_covered(gt_valid)) / line_gnd(i_gnd, 7)) >= eval_param.thres_length_ratio
                
                
                tp = tp + sum(gt_covered(gt_valid));
                
            end   
                  
        end    
    catch err
        % Give more information of the error
        fprintf('error a t evaluate_line_segment(), i_gnd: %d.\n', i_gnd);
        rethrow(err);
    end    
end

%%
precision = tp / sum(line_est(:,7));
recall = tp / sum(line_gnd(:,7));
iou = tp/(sum(line_est(:,7)) + sum(line_gnd(:,7)) - tp);

end