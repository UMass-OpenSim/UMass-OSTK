% -------------------------------------------------------------------------
% getPressureAvgs.m
%
% This function is written for raw .asc files that are saved in the Novel
% software without a mask. It will have to be modified if ascii data files
% are saved with a mask, if different sensor combinations are used, or if
% they are used with the wrong cables
% 
% written by Andrew LaPre
% last modified 3/2017
% 
% example function call:
% load frames.mat
% clear options
% % add as many folders as you want
% options.dataSets{1} = [pwd '\Pressure\Passive\'];
% options.dataSets{2} = [pwd '\Pressure\Active2\'];
% options.Frames{1} = frames.passive;
% options.Frames{2} = frames.active2;
% options.label{1} = 'Passive';
% options.label{2} = 'Active Alignment';
% options.outputLevel = 2;
% options.matchOffset = 'Yes';
% % in case of sensor failure
% options.omit{1} = [0; 0; 0];
% % options.omit{2} = [0; 0; 0];
% options.omit{2} = [0; 0; 1];
% options.filter = 5;
% 
% getPressureAvgs(options);
% -------------------------------------------------------------------------


function getPressureAvgs(options)

nSets = size(options.dataSets,2);

windowSize = options.filter;

pressure{1,1} = 'dataset';
pressure{1,2} = 'S1 trials';
pressure{1,3} = 'S2 trials';
pressure{1,4} = 'S1 mean,std';
pressure{1,5} = 'S2 mean,std';
pressure{1,6} = 'S1 meanPeak,std';
pressure{1,7} = 'S2 meanPeak,std';

S1_offset = 1000; 
S2_offset = 1000;

dataLabel = cell(nSets);

for set = 1:nSets
    
    try
        label = options.label{set};
    catch
        label = ['dataset ' num2str(set)];
    end
    
    pressure{set+1,1} = set;
    
    data_folder = options.dataSets{set};
    frameData = options.Frames{set};

    trials = dir(fullfile(data_folder, '*.asc'));
    nTrials = size(trials,1);
    pathname = data_folder;
    S1 = cell(nTrials,2);
    S2 = cell(nTrials,2);
    S1_resamp = zeros(101,nTrials);
    S2_resamp = zeros(101,nTrials);
    S1_maxResamp = zeros(101,nTrials);
    S2_maxResamp = zeros(101,nTrials);

    for trial = 1:nTrials;
        
        try
            omitFlag = options.omit{set}(trial,1);
        catch
            omitFlag = 0;
        end
%         omitFlag
        if omitFlag == 1
            continue
        end
        
        % get filename for this trial
        file_input = trials(trial).name;
        % load data
        data = dlmread(strcat(pathname,file_input),'',7,0);
    %     nFrames = size(data(1));
        framesConverted = round(frameData./2400.*240);
        nFrames = framesConverted(trial,6)-framesConverted(trial,2);
        S1{trial,1} = zeros(nFrames,2);
        S2{trial,1} = zeros(nFrames,2);
        
        % grab data from novel .asc file (without sensor mask)
        for frame = 1:nFrames
            S1data(1:4) = data(frame+framesConverted(trial,2)-framesConverted(trial,1),222:225);
            S1data(5:8) = data(frame+framesConverted(trial,2)-framesConverted(trial,1),238:241);
            S1data(9:12) = data(frame+framesConverted(trial,2)-framesConverted(trial,1),254:257);
            S2data(1:4) = data(frame+framesConverted(trial,2)-framesConverted(trial,1),154:157);
            S2data(5:8) = data(frame+framesConverted(trial,2)-framesConverted(trial,1),170:173);
            S2data(9:12) = data(frame+framesConverted(trial,2)-framesConverted(trial,1),186:189);
            S1{trial,1}(frame,1) = mean(S1data);
            S1{trial,2}(frame,1) = max(S1data);
            S2{trial,1}(frame,1) = mean(S2data);
            S2{trial,2}(frame,1) = max(S2data);
        end
        
        pressure{set+1,2}{trial} = S1{trial,1};
        pressure{set+1,3}{trial} = S2{trial,1};
        
        
        if options.outputLevel >= 4
            figure
            subplot(2,1,1)
            hold on
            plot(S1{trial,1},'b')
            plot(S1{trial,2},'r')
            ylabel('sensor 1')
            title([label ', trial ' num2str(trial) ' raw']) 
            legend('average pressure (kPa)','peak pressure (kPa)')
            subplot(2,1,2)
            hold on
            plot(S2{trial,1},'b')
            plot(S2{trial,2},'r')
            ylabel('sensor 2')
        end
        
        % sensor 1

        temp = S1{trial,1}(:,1);   
        temp2 = dynWindFilt(windowSize,temp);
        
        P = 101;
        Q = size(temp2,1);
        S1_resamp(:,trial) = resample(temp2,P,Q,0);
        
        temp = S1{trial,2}(:,1);   
        temp2 = dynWindFilt(windowSize,temp);
        
        P = 101;
        Q = size(temp2,1);
        S1_maxResamp(:,trial) = resample(temp2,P,Q,0);
        
        % sensor 2
        temp = S2{trial,1}(:,1);
        temp2 = dynWindFilt(windowSize,temp);
        
        P = 101;
        Q = size(temp2,1);
        S2_resamp(:,trial) = resample(temp2,P,Q,0);
        
        temp = S2{trial,2}(:,1);   
        temp2 = dynWindFilt(windowSize,temp);
        
        P = 101;
        Q = size(temp2,1);
        S2_maxResamp(:,trial) = resample(temp2,P,Q,0);
        

        if options.outputLevel >= 4
            figure
            subplot(2,1,1)
            hold on
            plot(S1_resamp(:,trial),'b')
            plot(S1_maxResamp(:,trial),'r')
            title([label ', trial ' num2str(trial) ' filtered and normalized']) 
            ylabel('sensor 1')
            legend('average pressure (kPa)','peak pressure (kPa)')
            subplot(2,1,2)
            hold on
            plot(S2_resamp(:,trial),'b')
            plot(S2_maxResamp(:,trial),'r')
            ylabel('sensor 2')
        end

    end
    
    pressure{set+1,2} = S1_resamp;
    pressure{set+1,3} = S2_resamp;


    S1_avg = zeros(101,2);
    S2_avg = zeros(101,2);
    S1_max = zeros(101,2);
    S2_max = zeros(101,2);
    
    for frame = 1:101
        S1_avg(frame,1) = mean(nonzeros(S1_resamp(frame,:)));
        S1_avg(frame,2) = std(nonzeros(S1_resamp(frame,:)));
        S2_avg(frame,1) = mean(nonzeros(S2_resamp(frame,:)));
        S2_avg(frame,2) = std(nonzeros(S2_resamp(frame,:)));
        
        
        S1_max(frame,1) = mean(nonzeros(S1_maxResamp(frame,:)));
        S1_max(frame,2) = std(nonzeros(S1_maxResamp(frame,:)));
        S2_max(frame,1) = mean(nonzeros(S2_maxResamp(frame,:)));
        S2_max(frame,2) = std(nonzeros(S2_maxResamp(frame,:)));

    end
    
    
    
    S1_avg(isnan(S1_avg))=0;
    S2_avg(isnan(S2_avg))=0;
    S1_max(isnan(S1_max))=0;
    S2_max(isnan(S2_max))=0;
    
    pressure{set+1,4} = S1_avg;
    pressure{set+1,5} = S2_avg;
    pressure{set+1,6} = S1_max;
    pressure{set+1,7} = S2_max;
    
    

    

    if options.outputLevel >= 3
        stance = 0:1:100;
        figure
        subplot(2,1,1)
        boundedline(stance,S1_avg(:,1),S1_avg(:,2),'r','alpha');
        title([label ' Sensor 1 Avg Pressure (kPa)'])
        subplot(2,1,2)
        boundedline(stance,S2_avg(:,1),S2_avg(:,2),'r','alpha');
        title([label ' Sensor 2 Avg Pressure (kPa)'])
    end
    
    % get offset and set with lowest offset
    if S1_avg(end-100,1) < S1_offset
        S1_offset = S1_avg(end,1);
    end
    if S2_avg(end,1) < S2_offset
        S2_offset = S1_avg(end,1);
    end
    
    dataLabel{set} = label;
    
end

% match the swing offset if option is chosen
for set = 1:nSets
    try 
        if strcmp(options.matchOffset, 'Yes')
            pressure{set+1,4}(:,1) = pressure{set+1,4}(:,1)-(pressure{set+1,4}(end,1)-S1_offset);
            pressure{set+1,5}(:,1) = pressure{set+1,5}(:,1)-(pressure{set+1,5}(end,1)-S1_offset);
            pressure{set+1,6}(:,1) = pressure{set+1,6}(:,1)-(pressure{set+1,6}(end,1)-S1_offset);
            pressure{set+1,7}(:,1) = pressure{set+1,7}(:,1)-(pressure{set+1,7}(end,1)-S1_offset);
        else
%             pressure{set+1,4}(:,1) = pressure{set+1,4}(:,1);
%             pressure{set+1,5}(:,1) = pressure{set+1,5}(:,1);
        end
    catch
%         pressure{set+1,4}(:,1) = pressure{set+1,4}(:,1);
%         pressure{set+1,5}(:,1) = pressure{set+1,5}(:,1);
    end
end


% plot the combined data
if options.outputLevel >= 1
    figure
    hold on
    for set = 1:nSets;
        stance = 0:1:100;
        if set == 1; color = 'r'; end
        if set == 2; color = 'b'; end
        if set == 3; color = 'k'; end
        if set == 4; color = 'g'; end
        
        subplot(2,1,1)
        boundedline(stance,pressure{set+1,4}(:,1),pressure{set+1,4}(:,2),color,'alpha');
        title('Sensor 1 Avg Pressure (kPa)')
        warning('off','all')
        if nSets == 1; legend(dataLabel{1},'');end
        if nSets == 2; legend(dataLabel{1},'',dataLabel{2},'');end
        if nSets == 3; legend(dataLabel{1},'',dataLabel{2},'',dataLabel{3},'');end
        if nSets == 4; legend(dataLabel{1},'',dataLabel{2},'',dataLabel{3},'',dataLabel{4},'');end
        warning('on','all')
        subplot(2,1,2)
        boundedline(stance,pressure{set+1,5}(:,1),pressure{set+1,5}(:,2),color,'alpha');
        title('Sensor 2 Avg Pressure (kPa)')
        
    end
end

if options.outputLevel >= 2
    
    figure
    hold on
    for set = 1:nSets;
        stance = 0:1:100;
        if set == 1; color = 'r'; end
        if set == 2; color = 'b'; end
        if set == 3; color = 'k'; end
        if set == 4; color = 'g'; end
        
        subplot(2,1,1)
        boundedline(stance,pressure{set+1,6}(:,1),pressure{set+1,6}(:,2),color,'alpha');
        title('Sensor 1 Max Pressure (kPa)')
        warning('off','all')
        if nSets == 1; legend(dataLabel{1},'');end
        if nSets == 2; legend(dataLabel{1},'',dataLabel{2},'');end
        if nSets == 3; legend(dataLabel{1},'',dataLabel{2},'',dataLabel{3},'');end
        if nSets == 4; legend(dataLabel{1},'',dataLabel{2},'',dataLabel{3},'',dataLabel{4},'');end
        warning('on','all')
        subplot(2,1,2)
        boundedline(stance,pressure{set+1,7}(:,1),pressure{set+1,7}(:,2),color,'alpha');
        title('Sensor 2 Max Pressure (kPa)')
        
    end
end

save pressureData.mat pressure