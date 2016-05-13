function combineGRF(combGRF_options)
% This function calculates the average and standard deviation of trimmed grf
% .tsv files

nSets = size(combGRF_options.datasets,2);


windowSize = combGRF_options.filter;

GRFdata{1,1} = 'dataset';
GRFdata{1,2} = 'vx all trials';
GRFdata{1,3} = 'vy all trials';
GRFdata{1,4} = 'vx mean,std';
GRFdata{1,5} = 'vy mean,std';




for set = 1:nSets
    
    GRFdata{set+1,1} = set;    
    data_folder = combGRF_options.datasets{set};
    trials = dir(fullfile(data_folder, '*f_2.tsv'));
    nTrials = size(trials,1);
    pathname = data_folder;
    
    
    
    GRFdata{set+1,2} = zeros(101,nTrials);
    GRFdata{set+1,3} = zeros(101,nTrials);
    for trial = 1:nTrials;

        % get filename for this trial
        file_input = trials(trial).name;

        data = dlmread(strcat(pathname,file_input),'',23,0);

        temp = data(:,2);
        
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        temp2 = filter(b,a,temp);
        
        P = 101;
        Q = size(temp2,1);
        GRFdata{set+1,2}(:,trial) = resample(temp2,P,Q,0);
        
        temp = data(:,3);
        
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        temp2 = filter(b,a,temp);
        
        P = 101;
        Q = size(temp2,1);
        GRFdata{set+1,3}(:,trial) = resample(temp2,P,Q,0);

    end

    GRFdata{set+1,4} = zeros(101,2);
    GRFdata{set+1,5} = zeros(101,2);

    for frame = 1:101
        GRFdata{set+1,4}(frame,1) = mean(GRFdata{set+1,2}(frame,:));
        GRFdata{set+1,4}(frame,2) = std(GRFdata{set+1,2}(frame,:));
        GRFdata{set+1,5}(frame,1) = mean(GRFdata{set+1,3}(frame,:));
        GRFdata{set+1,5}(frame,2) = std(GRFdata{set+1,3}(frame,:));
    end

    if combGRF_options.outputLevel >= 3
        stance = 0:1:100;
        figure
        subplot(2,1,1)
        boundedline(stance,GRFdata{set+1,5}(:,1),GRFdata{set+1,5}(:,2),'r','alpha');
        title('Vertical GRF (N)')
        xlabel('% Gait')
        subplot(2,1,2)
        boundedline(stance,GRFdata{set+1,4}(:,1),GRFdata{set+1,4}(:,2),'r','alpha');
        title('Horizontal GRF (N)')  
        xlabel('% Gait')
    end
    
    
end
if combGRF_options.outputLevel >= 2
    stance = 0:1:100;
    figure
    for set = 1:nSets
        if set == 1; color = 'r'; end
        if set == 2; color = 'b'; end
        if set == 3; color = 'k'; end
        if set == 4; color = 'g'; end
        subplot(2,1,1)
        boundedline(stance,GRFdata{set+1,5}(:,1),GRFdata{set+1,5}(:,2),color,'alpha');
        title('Vertical GRF (N)')
        xlabel('% Gait')
        subplot(2,1,2)
        boundedline(stance,GRFdata{set+1,4}(:,1),GRFdata{set+1,4}(:,2),color,'alpha');
        title('Horizontal GRF (N)')  
        xlabel('% Gait')
    end
    
    
end
save combinedGRF.mat GRFdata 



