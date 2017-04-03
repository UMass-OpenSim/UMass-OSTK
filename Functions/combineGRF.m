%-------------------------------------------------------------------------% 
% combineGRF.m
% 
% This function calculates the average and standard deviation of trimmed grf
% .tsv files
%
% Written by Andrew LaPre 2/2016
% Last modified 3/2017
%
% example function call:
% clear options
% load frames.mat
% % add as many folders as you want
% options.datasets{1} = [pwd '\GRFdata\Passive\'];
% options.datasets{2} = [pwd '\GRFdata\Active2\'];
% options.label{1} = 'Passive Pref';
% options.label{2} = 'Active Pref';
% options.Frames{1} = frames.passive;
% options.Frames{2} = frames.active2;
% options.outputLevel = 2;
% options.filter = 5;
% options.subjectMass{1} = 73.16;
% options.subjectMass{2} = 74.28;
% options.norm2mass = 'yes';
% combineGRF(options);
%-------------------------------------------------------------------------%


function combineGRF(options)

nSets = size(options.datasets,2);

try
    norm2mass = options.norm2mass;
catch
    norm2mass = 'no';
end


windowSize = options.filter;

GRFdata{1,1} = 'dataset';
GRFdata{1,2} = 'left vx all trials';
GRFdata{1,3} = 'left vy all trials';
GRFdata{1,4} = 'left vx mean,std';
GRFdata{1,5} = 'left vy mean,std';
GRFdata{1,6} = 'right vx all trials';
GRFdata{1,7} = 'right vy all trials';
GRFdata{1,8} = 'right vx mean,std';
GRFdata{1,9} = 'right vy mean,std';


dataLabel = cell(nSets);

for set = 1:nSets
    
    try
        mass = options.subjectMass{set};
    catch
        mass = 1;
    end
    
    frames = options.Frames{set};
    GRFdata{set+1,1} = set;    
    data_folder = options.datasets{set};
%     trials = dir(fullfile(data_folder, '*f_2.tsv'));
    trials = dir(fullfile(data_folder, '*.mot'));
    nTrials = size(trials,1);
    pathname = data_folder;
    
    try
        label = options.label{set};
    catch
        label = ['dataset ' num2str(set)];
    end
   
    
    GRFdata{set+1,2} = zeros(101,nTrials);
    GRFdata{set+1,3} = zeros(101,nTrials);
    GRFdata{set+1,6} = zeros(101,nTrials);
    GRFdata{set+1,7} = zeros(101,nTrials);
    for trial = 1:nTrials;
        
        % get second heel strike frame
        HS2 = frames(trial,4)-frames(trial,2)-10;

        % get filename for this trial
        file_input = trials(trial).name;

%         data = dlmread(strcat(pathname,file_input),'',23,0);
        data = dlmread(strcat(pathname,file_input),'\t',7,0);

        % norm2mass
        if strmatch(norm2mass,{'yes' 'Yes' 'Y' 'y' 'YES'})
            data = data./mass;
        end
        % left horizontal
        temp = data(:,2);
        temp2 = dynWindFilt(windowSize,temp);      
        P = 101;
        Q = size(temp2,1);
        GRFdata{set+1,2}(:,trial) = resample(temp2,P,Q,0);
        
        % left vertical
        temp = data(:,3);
        temp2 = dynWindFilt(windowSize,temp);
        P = 101;
        Q = size(temp2,1);
        GRFdata{set+1,3}(:,trial) = resample(temp2,P,Q,0);
        
        % right vertical
        temp = data(:,8);
        temp = cat(1,temp(HS2:end),temp(1:HS2));
        temp2 = dynWindFilt(windowSize,temp);
        P = 101;
        Q = size(temp2,1);
        GRFdata{set+1,6}(:,trial) = resample(temp2,P,Q,0);
        
        % right vertical
        temp = data(:,9);
        temp = cat(1,temp(HS2:end),temp(1:HS2));
        temp2 = dynWindFilt(windowSize,temp);
        P = 101;
        Q = size(temp2,1);
        GRFdata{set+1,7}(:,trial) = resample(temp2,P,Q,0);

    end

    GRFdata{set+1,4} = zeros(101,2);
    GRFdata{set+1,5} = zeros(101,2);
    GRFdata{set+1,8} = zeros(101,2);
    GRFdata{set+1,9} = zeros(101,2);

    for frame = 1:101
        % left 
        GRFdata{set+1,4}(frame,1) = mean(GRFdata{set+1,2}(frame,:));
        GRFdata{set+1,4}(frame,2) = std(GRFdata{set+1,2}(frame,:));
        GRFdata{set+1,5}(frame,1) = mean(GRFdata{set+1,3}(frame,:));
        GRFdata{set+1,5}(frame,2) = std(GRFdata{set+1,3}(frame,:));
        %right
        GRFdata{set+1,8}(frame,1) = mean(GRFdata{set+1,6}(frame,:));
        GRFdata{set+1,8}(frame,2) = std(GRFdata{set+1,6}(frame,:));
        GRFdata{set+1,9}(frame,1) = mean(GRFdata{set+1,7}(frame,:));
        GRFdata{set+1,9}(frame,2) = std(GRFdata{set+1,7}(frame,:));
    end

    if options.outputLevel >= 3
        stance = 0:1:100;
        % left
        figure
        subplot(2,1,1)
        boundedline(stance,GRFdata{set+1,5}(:,1),GRFdata{set+1,5}(:,2),'r','alpha');
        title('Left Vertical GRF (N)')
        xlabel('% Gait')
        subplot(2,1,2)
        boundedline(stance,GRFdata{set+1,4}(:,1),GRFdata{set+1,4}(:,2),'r','alpha');
        title('Left Horizontal GRF (N)')  
        xlabel('% Gait')
        % right
        figure
        subplot(2,1,1)
        boundedline(stance,GRFdata{set+1,9}(:,1),GRFdata{set+1,9}(:,2),'r','alpha');
        title('Right Vertical GRF (N)')
        xlabel('% Gait')
        subplot(2,1,2)
        boundedline(stance,GRFdata{set+1,8}(:,1),GRFdata{set+1,8}(:,2),'r','alpha');
        title('Reft Horizontal GRF (N)')  
        xlabel('% Gait')
    end
    
    dataLabel{set} = label;
end


if options.outputLevel >= 2
    stance = 0:1:100;
    % left
    figure
    for set = 1:nSets
        disp(set)
        if set == 1; color = 'r'; end
        if set == 2; color = 'b'; end
        if set == 3; color = 'k'; end
        if set == 4; color = 'g'; end
        subplot(2,2,1)
        boundedline(stance,GRFdata{set+1,5}(:,1),GRFdata{set+1,5}(:,2),color,'alpha');
        title('Left')
%         xlabel('% Gait')
        ylabel('Vertical GRF (N/kg)')
        if strmatch(norm2mass,{'yes' 'Yes' 'Y' 'y' 'YES'})
            ylim([-1 13])
        else
            ylim([-50 1000])
        end
        warning('off','all')
        if nSets == 1; legend(dataLabel{1},'');end
        if nSets == 2; legend(dataLabel{1},'',dataLabel{2},'');end
        if nSets == 3; legend(dataLabel{1},'',dataLabel{2},'',dataLabel{3},'');end
        if nSets == 4; legend(dataLabel{1},'',dataLabel{2},'',dataLabel{3},'',dataLabel{4},'');end
        warning('on','all')
        
        subplot(2,2,3)
        boundedline(stance,GRFdata{set+1,4}(:,1),GRFdata{set+1,4}(:,2),color,'alpha');
%         title('Left')  
        xlabel('% Gait')
        ylabel('Horizontal GRF (N/kg)')
        if strmatch(norm2mass,{'yes' 'Yes' 'Y' 'y' 'YES'})
            ylim([-3 3])
        else
            ylim([-200 220])
        end

        subplot(2,2,2)
        boundedline(stance,GRFdata{set+1,9}(:,1),GRFdata{set+1,9}(:,2),color,'alpha');
        title('Right')
%         xlabel('% Gait')
        if strmatch(norm2mass,{'yes' 'Yes' 'Y' 'y' 'YES'})
            ylim([-1 13])
        else
            ylim([-50 1000])
        end
        
        subplot(2,2,4)
        boundedline(stance,GRFdata{set+1,8}(:,1),GRFdata{set+1,8}(:,2),color,'alpha');
%         title('Right Horizontal GRF (N)')  
        xlabel('% Gait')
        if strmatch(norm2mass,{'yes' 'Yes' 'Y' 'y' 'YES'})
            ylim([-3 3])
        else
            ylim([-200 220])
        end
    end
end
save combinedGRF.mat GRFdata 



