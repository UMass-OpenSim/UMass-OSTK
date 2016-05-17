% This function is written for raw .asc files that are saved in the Novel
% software without a mask. It will have to be modified if ascii data files
% are saved with a mask.

% written by Andrew LaPre

function getPressureAvgs(options)

nSets = size(options.dataSets,2);

windowSize = options.filter;

pressure{1,1} = 'dataset';
pressure{1,2} = 'S1 trials';
pressure{1,3} = 'S2 trials';
pressure{1,4} = 'S1 mean,std';
pressure{1,5} = 'S2 mean,std';

S1_offset = 1000; 
S2_offset = 1000;

for set = 1:nSets
    
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

    for trial = 1:nTrials;
        
        try
            omitFlag = options.omit{set}(trial);
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
        
        pressure{set+1,2}{trial} = S1{trial,1};
        pressure{set+1,3}{trial} = S2{trial,1};
        
        
        if options.outputLevel >= 3
            figure
            subplot(2,1,1)
            plot(S1{trial,1})
            subplot(2,1,2)
            plot(S2{trial,1})
        end
        
        % sensor 1

        temp = S1{trial,1}(:,1);   
        temp2 = dynWindFilt(windowSize,temp);
        
        P = 101;
        Q = size(temp2,1);
        S1_resamp(:,trial) = resample(temp2,P,Q,0);
        
        % sensor 2
        temp = S2{trial,1}(:,1);
        temp2 = dynWindFilt(windowSize,temp);
        
        P = 101;
        Q = size(temp2,1);
        S2_resamp(:,trial) = resample(temp2,P,Q,0);
        

        if options.outputLevel >= 3
            figure
            subplot(2,1,1)
            plot(S1_resamp(:,trial))
            subplot(2,1,2)
            plot(S2_resamp(:,trial))
        end

    end
    
    pressure{set+1,2} = S1_resamp;
    pressure{set+1,3} = S2_resamp;


    S1_avg = zeros(101,2);
    S2_avg = zeros(101,2);
    
    for frame = 1:101
        S1_avg(frame,1) = mean(nonzeros(S1_resamp(frame,:)));
        S1_avg(frame,2) = std(nonzeros(S1_resamp(frame,:)));
        S2_avg(frame,1) = mean(nonzeros(S2_resamp(frame,:)));
        S2_avg(frame,2) = std(nonzeros(S2_resamp(frame,:)));
        

    end
    
    
    
    S1_avg(isnan(S1_avg))=0;
    S2_avg(isnan(S2_avg))=0;
    
    pressure{set+1,4} = S1_avg;
    pressure{set+1,5} = S2_avg;
    
    

    

    if options.outputLevel >= 2
        stance = 0:1:100;
        figure
        subplot(2,1,1)
        boundedline(stance,S1_avg(:,1),S1_avg(:,2),'r','alpha');
        title('Sensor 1 Avg Pressure (kPa)')
        subplot(2,1,2)
        boundedline(stance,S2_avg(:,1),S2_avg(:,2),'r','alpha');
        title('Sensor 2 Avg Pressure (kPa)')
    end
    
    % get offset and set with lowest offset
    if S1_avg(end-100,1) < S1_offset
        S1_offset = S1_avg(end-100,1);
    end
    if S2_avg(end,1) < S2_offset
        S2_offset = S1_avg(end-100,1);
    end
    
end

% match the swing offset if option is chosen
for set = 1:nSets
    try 
        if strcmp(options.matchOffset, 'Yes')
            pressure{set+1,4}(:,1) = pressure{set+1,4}(:,1)-(pressure{set+1,4}(end,1)-S1_offset);
        else
            pressure{set+1,4}(:,1) = pressure{set+1,4}(:,1);
        end
    catch
        pressure{set+1,4}(:,1) = pressure{set+1,4}(:,1);
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
        
        subplot(2,1,1)
        boundedline(stance,pressure{set+1,4}(:,1),pressure{set+1,4}(:,2),color,'alpha');
        title('Sensor 1 Avg Pressure (kPa)')
        warning('off','all')
        legend('dataset 1',' ', 'dataset 2',' ')
        subplot(2,1,2)
        boundedline(stance,pressure{set+1,5}(:,1),pressure{set+1,5}(:,2),color,'alpha');
        title('Sensor 2 Avg Pressure (kPa)')
        
    end
end

save pressureData.mat pressure