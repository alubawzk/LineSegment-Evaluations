function [pr,re,iou,F_sc] = BaseEvaluation(LineSet, LineGT,eval_param)

% Remove invalid ground truth
idx_invalid =  LineGT(:,1) == 0 & LineGT(:,2) == 0 & LineGT(:,3) == 0 & LineGT(:,4) == 0 ;
LineGT(idx_invalid,:) = [];
% Rearrange line segment so that elements become (x1, y1, x2, y2, center_x, center_y, length, angle)
cp = [LineGT(:,1) + LineGT(:,3) LineGT(:,2) + LineGT(:,4)]/2;
dx = LineGT(:,3) - LineGT(:,1); dy = LineGT(:,4) - LineGT(:,2);
LineGT = [LineGT, cp, sqrt(dx.^2 + dy.^2), atan2(dy, dx)];

x1 = LineSet(:,1); y1 = LineSet(:,2);
x2 = LineSet(:,3); y2 = LineSet(:,4);

cp = [x1 + x2 y1 + y2]/2;
dx = x2 - x1; dy = y2 - y1;
line_est = [x1,y1,x2,y2, cp, sqrt(dx.^2 + dy.^2), atan2(dy, dx)];
if ~isempty(x1)
    [pr, re, iou] = evaluate_line_segment(line_est, LineGT, eval_param);
else
    pr = 0; re=0; iou=0;
end
if pr~=0 && re~=0
    F_sc = 2 * (pr* re) / (pr + re);
else
    F_sc = 0;
end

return