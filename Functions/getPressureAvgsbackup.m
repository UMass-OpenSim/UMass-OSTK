% This function is written for raw .asc files that is saved in the Novel
% software without a mask. It will have to be modified if ascii data files
% are saved with a mask.

% written by Andrew LaPre

function [S1_avg, S2_avg] = getPressureAvgs(data_folder, frameData)


trials = dir(fullfile(data_folder, '*.asc'));
nTrials = size(trials,1);
pathname = data_folder;
S1 = cell(nTrials,2);
S2 = cell(nTrials,2);
S1_resamp = zeros(101,nTrials);
S2_resamp = zeros(101,nTrials);

for trial = 1:nTrials;

    % get filename for this trial
    file_input = trials(trial).name;

    % load data
    data = dlmread(strcat(pathname,file_input),'',12,0);
%     nFrames = size(data(1));
    framesConverted = round(frameData./2400.*240);
    nFrames = framesConverted(trial,3)-framesConverted(trial,2);
    S1{trial,1} = zeros(nFrames,1);
    S2{trial,1} = zeros(nFrames,1);
    for frame = 1:nFrames
        S1data(1:4) = data(frame+framesConverted(trial,2)-framesConverted(trial,1),222:225);
        S1data(5:8) = data(frame+framesConverted(trial,2)-framesConverted(trial,1),238:241);
        S1data(9:12) = data(frame+framesConverted(trial,2)-framesConverted(trial,1),254:257);
        S2data(1:4) = data(frame+framesConverted(trial,2)-framesConverted(trial,1),154:157);
        S2data(5:8) = data(frame+framesConverted(trial,2)-framesConverted(trial,1),170:173);
        S2data(9:12) = data(frame+framesConverted(trial,2)-framesConverted(trial,1),186:189);
        S1{trial,1}(frame,1) = mean(S1data);
        S2{trial,1}(frame,1) = mean(S2data);
    end
%     figure
%     subplot(2,1,1)
%     plot(S1{trial,1})
%     subplot(2,1,2)
%     plot(S2{trial,1})
    
    temp = S1{trial,1}(:,1);
    P = 101;
    Q = size(temp,1);
    S1_resamp(:,trial) = resample(temp,P,Q);
    temp = S2{trial,1}(:,1);
    P = 101;
    Q = size(temp,1);
    S2_resamp(:,trial) = resample(temp,P,Q);
    
    figure
    subplot(2,1,1)
    plot(S1_resamp(:,trial))
    subplot(2,1,2)
    plot(S2_resamp(:,trial))
    
end


S1_avg = zeros(101,2);
S2_avg = zeros(101,2);
for frame = 1:101
    S1_avg(frame,1) = mean(S1_resamp(frame,:));
    S1_avg(frame,2) = std(S1_resamp(frame,:));
    S2_avg(frame,1) = mean(S2_resamp(frame,:));
    S2_avg(frame,2) = std(S2_resamp(frame,:));
end

stance = 0:1:100;
figure
subplot(2,1,1)
boundedline(stance,S1_avg(:,1),S1_avg(:,2),'r','alpha');
title('Sensor 1 Avg Pressure (kPa)')
subplot(2,1,2)
boundedline(stance,S2_avg(:,1),S2_avg(:,2),'r','alpha');
title('Sensor 2 Avg Pressure (kPa)')