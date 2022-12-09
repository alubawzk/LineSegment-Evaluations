function [ gt_covered, idx_valid,gt_valid, pd_covered ] = line_area_intersection( l_src, l_tar )
    %LINE_AREA_INTERSECTION Calculating overlapping area (non-overlapping between targets) between two line segments wrt l_src (source)
    
    % l_src = line_gnd(i_gnd,:); src = source 源
    % l_tar = line_est(idx_cand, :); tar = target 目标
        
    idx_valid = false(size(l_tar,1),1);
    
    
    gt_covered = zeros(size(l_tar,1),1);
    pd_covered = zeros(size(l_tar,1),1);
    
    
    % Project the source to the source coordinate 
    vec_base = l_src(3:4) - l_src(1:2); 
    vec_base = vec_base / norm(vec_base);
    
    vec_src = [l_src(1:2) - l_src(1:2); l_src(3:4) - l_src(1:2)] * vec_base';%结果也就是【0，d】d为线段长度
    
    if vec_src(1) > vec_src(2), [vec_src(1), vec_src(2)] = swap_vec(vec_src(1), vec_src(2)); end
    
    vec_tar = [(l_tar(:,1:2) - repmat(l_src(1:2), size(l_tar,1),1)) * vec_base'...
        (l_tar(:,3:4) - repmat(l_src(1:2), size(l_tar,1),1)) * vec_base'];%EST投影到GT的坐标
    
    for i = 1:size(l_tar, 1)
        if vec_tar(i,1) > vec_tar(i,2)
            [vec_tar(i,1), vec_tar(i,2)] = swap_vec(vec_tar(i,1), vec_tar(i,2));
        end
    end
    
    
    % clip left area
    idx = find(vec_tar < 0); vec_tar(idx) = 0;
    
    % clip right area
    idx = find(vec_tar > max(vec_src)); vec_tar(idx) = max(vec_src);
    
    
    for k = 1:size(l_tar, 1)
        
        bValid = true;
        %当EST（tar两端都在src里面的时候不用处理，所以没写）
        % EST（tar）与GT（src）错开的情况 
        if vec_tar(k,1) >= vec_src(2) || vec_tar(k,2) <= vec_src(1)
            % case 1
            % tar:                  *----------*
            % src: *---------*
            % case 2
            % tar: *----------*
            % src:                *---------*
            gt_covered(k) = 0;
            idx_valid(k) = false;
            pd_covered(k) = 0;
            bValid = false;
        elseif vec_tar(k,1) <= vec_src(1) && vec_tar(k,2) >= vec_src(1) && vec_tar(k,2) <= vec_src(2)
            % case 3
            % tar: *-------*
            % src:    *---------*
            vec_tar(k,1) = vec_src(1);
        elseif vec_tar(k,2) >= vec_src(2) && vec_tar(k,1) >= vec_src(1) && vec_tar(k,1) <= vec_src(2)
            % case 4
            % tar:      *----------*
            % src: *---------*
            vec_tar(k,2) = vec_src(2);
        elseif vec_tar(k,1) <= vec_src(1) && vec_tar(k,2) >= vec_src(2)
            % case 5
            % tar: *-------------------*
            % src:     *---------*
            vec_tar(k,:) = vec_src;
        end
        
        %         idx = abs(vec_tar(1) - vec_tar(2)) ./ l_tar(7) > .5;
        if bValid
            idx_valid(k) = true;
            pd_covered(k) = abs(vec_tar(k,1) - vec_tar(k,2)); % area covered by target
        end
    end
    
    % get purely overlapping area -- covered ground truth area
    %按照左边端点大小排序
    %[～ = 排序后的数组，idx = 对应的原来数组的位置]
    %这里对idx_valid重新排序会有问题，重新设个gt_valiad代替试试
    [~, idx] = sort(vec_tar(:,1));
    gt_valid = idx_valid(idx);
    vec_tar = vec_tar(idx,:);
    for i1 = 1:size(vec_tar,1)-1
        if ~gt_valid(i1), continue; end
        
        for i2 = i1+1:size(vec_tar,1)
            if ~gt_valid(i2), continue; end
            
            % tar2: *------*
            % tar1:   *----------*
            if vec_tar(i2,1) <= vec_tar(i1,1) && vec_tar(i2,2) <= vec_tar(i1,2) && vec_tar(i2,2) >= vec_tar(i1,1)
                vec_tar(i2,2) = vec_tar(i1,1);
            end
            
            % tar2:     *--------*
            % tar1: *----------*
            if vec_tar(i2,1) >= vec_tar(i1,1) && vec_tar(i2,2) >= vec_tar(i1,2) && vec_tar(i2,1) <= vec_tar(i1,2)
                vec_tar(i2,1) = vec_tar(i1,2);
            end
            
            % tar2:     *----*
            % tar1: *----------*
            if vec_tar(i2,1) >= vec_tar(i1,1) && vec_tar(i2,2) <= vec_tar(i1,2)
                vec_tar(i2,:) = 0;
            end
        end        
    end
    
    for k = 1:size(vec_tar, 1)
        gt_covered(k) = abs(vec_tar(k,1) - vec_tar(k,2));
    end    
       
end

