clear;clc;
close all;

%%
addpath(genpath('EvalFuncs/'));
addpath(genpath('ScaleSpaceFuncs/'));
addpath(genpath('InputData/Renoir-LineSegment/'));
load('LineSegmentAnnotation/Image_ID_List.mat');

eval_param.thres_dist = 1;
eval_param.thres_ang = pi*5/180;
eval_param.thres_length_ratio = .75;
lambda = 0.6;
line_scale = 0.25;

Detectors = {'MPG-LSD-RLS'};
NoieseLevels = {'Reference'};

%%
for iDetector = 1
    disp('********************************************************************');
    disp('-------------------------------------------------------------------');
    for iNoieseLevels = 1
        
        Detector = Detectors{iDetector};
        NoieseLevel = NoieseLevels{iNoieseLevels};
        addpath(genpath(['InputData/',Detector,'/']));
        InputD = [Detector,'/',NoieseLevel];
        OutputD = ['OutputData/SS' Detector,'/',NoieseLevel];
        disp(['Evaluating the Scale-Space ',Detector,' in the ', NoieseLevel, ' noise case:']);
        
        %%
        NoI = 40;
        prF = zeros(1,NoI); reF = zeros(1,NoI); iouF = zeros(1,NoI); F_scF = zeros(1,NoI);
        run_time = zeros(1,NoI);
        MaxScale = 10;
        LineSet_Scale = cell(1,MaxScale);
        num = 1;
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
            
            if mod(i_im,10)==0
                fprintf('\n')
            end
            
            str_gnd = sprintf('LineSegmentAnnotation/%s.mat', Image_ID_List(i_im).name);
            load(str_gnd);
            LS_Num = LS_Num + size(LineSet,1);
            line_gnd = LineSet;
            line_gnd = line_gnd * line_scale;
            str_est = sprintf([InputD '/im' num2str(i_im) '/literature.mat']);
            load(str_est);
            LineSet_SingleScale = lineset;
            LineSet_SingleScale = LineSet_SingleScale * line_scale;

            [pr(num),re(num),iou(num),F_sc(num)] = BaseEvaluation(LineSet_SingleScale, line_gnd,eval_param);
            num = num+1;
        end
        ls_n = LS_Num / NoI;

        %%
        fprintf(['Performance of the seed ',Detector,' detector:\n']);
        fprintf('[Precision, Recall, IOU, F-Score] = [%0.4f  %0.4f  %0.4f  %0.4f] \n', [mean(pr) mean(re) mean(iou) mean(F_sc)]);
        fprintf('Average Run Time: %0.0f ms \n', mean(run_time)*1000);
        disp('--------------------------------------------------------------------');
    end
    rmpath(genpath(['InputData/',Detector,'/']));
end
disp('********************************************************************');

%%
rmpath(genpath('InputData/Renoir-LineSegment/'));
rmpath(genpath('EvalFuncs/'));
rmpath(genpath('ScaleSpaceFuncs/'));

%%
load gong
sound(y,Fs)