clc;clear;
close all;

%%
addpath(genpath('InputData/'));
addpath(genpath('EvalFuncs/'));
load('LineSegmentAnnotation/Image_ID_List.mat');

%%
eval_param.thres_dist = 1;
eval_param.thres_ang = pi*5/180;
eval_param.thres_length_ratio = .75;

%%
Detectors = {'MPG-LSD'}; 
NoieseLevels = {'Reference'};

%%
for iDetector = 1
    disp('********************************************************************');
    disp('-------------------------------------------------------------------');
    for iNoieseLevels = 1
        Detector = Detectors{iDetector};
        NoieseLevel = NoieseLevels{iNoieseLevels};
        InputD = [Detector,'/',NoieseLevel];
        OutputD = ['OutputData/SS' Detector,'/',NoieseLevel];
        disp(['Evaluating the ',Detector,' in the ', NoieseLevel, ' noise case:']);
        
        %%
        NoI = 102;
        pr = zeros(1,NoI); re = zeros(1,NoI); iou = zeros(1,NoI); F_sc = zeros(1,NoI);
        prF = zeros(1,NoI); reF = zeros(1,NoI); iouF = zeros(1,NoI); F_scF = zeros(1,NoI);
        MaxScale = 10;
        LineSet_Scale = cell(1,MaxScale);
        LS_Num = 0;
        
        %%        
        for i_im = 1:NoI
            if i_im<10
                fprintf('   %d',i_im)
            elseif i_im<100
                fprintf('  %d',i_im)
            else
                fprintf(' %d',i_im)
            end
            if mod(i_im,17)==0
                fprintf('\n')
            end
            str_gnd = sprintf('LineSegmentAnnotation/%s_GND.mat', Image_ID_List(i_im).name);
            load(str_gnd);
            line_gnd = unique(line_gnd, 'rows');
            LS_Num = LS_Num + size(line_gnd,1); 
            str_est = sprintf([InputD '/im' num2str(i_im) '/literature.mat']);
            load(str_est);
            LineSet_SingleScale = lineset(:,1:4);
            [pr(i_im),re(i_im),iou(i_im),F_sc(i_im)] = BaseEvaluation(LineSet_SingleScale, line_gnd,eval_param);
        end
        %%
        fprintf(['Performance of the detector ',Detector,' detector:\n']);
        fprintf('[Precision, Recall, IOU, F-Score] = [%0.4f  %0.4f  %0.4f  %0.4f] \n', [mean(pr) mean(re) mean(iou) mean(F_sc)]);
        disp('--------------------------------------------------------------------');
    end
end
disp('********************************************************************');

%%
rmpath(genpath('InputData/'));
rmpath(genpath('EvalFuncs/'));

%% sound
% load gong
% sound(y,Fs)
