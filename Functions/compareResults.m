%-------------------------------------------------------------------------% 
% compareResults.m
% 
% compare the results of 2 or more folders with common datatypes
% this calculates statistics of different trial sets for comparison
% 
% Written by Andrew LaPre 2/2016
% Last modified 3/2017
%
% example function call:
% clear options
% % add as many datasets as you want
% options.datasets{1} = 'Analyses\Results\Passive\';
% options.datasets{2} = 'Analyses\Results\Active2\';
% options.label{1} = 'Passive Pref AutoScaled';
% options.label{2} = 'Active Pref AutoScaled';
% options.filter = 5;  % filter window size
% options.outputLevel = 2;
% options.dataType = 'COM';         % IK ,ID, or COM
% options.stitchData = 'n';       % stitch heel strike to heel strike if the contralateral limb. 
% options.norm2mass = 'no';
% options.zeroCOM = 'yes';
% % enter the coordinate to compare
% options.tag = 'center_of_mass_Y'; 
% compareResults(options)
%-------------------------------------------------------------------------%

function compareResults(options)

try
    options.dataType;
catch
    warning('specify options.dataType ( = IK, ID, POW), terminating process')
    return
end

    
nSets = size(options.datasets,2);
tag = options.tag;

% setup data header
compResults{1,1} = 'dataset';
compResults{1,2} = 'data trials';
compResults{1,3} = 'data mean,std';
compResults{1,4} = 'max trials';
compResults{1,5} = 'max mean,std';
compResults{1,6} = 'min trials';
compResults{1,7} = 'min mean,std';

if strcmp(options.dataType,'POW')
    compResults{1,8} = 'NetPosWrk trials';
    compResults{1,9} = 'NetPosWrk mean,std';
    compResults{1,10} = 'NetWrk trials';
    compResults{1,11} = 'NetWrk mean,std';
end

    




try 
    outLevel = options.outputLevel;
catch
    outLevel = 1;
end

try 
    stitch = options.stitchData;
catch
    stitch = 'no';
    disp('options.stitchData not specified, setting default to NO')
end

try 
    rmvofst = options.removeOffset;
catch
    rmvofst = 'no';
end
% check for norm2mass
try 
    norm2mass = options.norm2mass;
catch
    norm2mass = 'no';
end
% check for mirroring 
try 
    mirror = options.mirror;
catch
    mirror = 'no';
end
% check for zeroing 
try 
    zeroCOM = options.zeroCOM;
catch
    zeroCOM = 'no';
end

tagName = regexprep(tag,'_',' ');

dataLabel = cell(nSets);

for set = 1:nSets

    dataFolder = options.datasets{set};
    
    % get trials
    if strcmp(options.dataType,'IK')
        trials = dir(fullfile(dataFolder, '*.mot'));
    end
    if strcmp(options.dataType,'ID') 
        trials = dir(fullfile(dataFolder, '*.sto'));
    end
    if strcmp(options.dataType,'grf')
        trials = dir(fullfile(dataFolder, '*.mot'));
    end
    if strcmp(options.dataType,'COM')
        trials = dir(fullfile(dataFolder, '*_pos_global.sto'));
    end
    if strcmp(options.dataType,'POW')
        trials = dir(fullfile(dataFolder, '*_pow.sto'));
    end
    
    % get dataset label
    try
        label = options.label{set};
    catch
        label = ['dataset ' num2str(set)];
    end
    
    try
        subjectMass = options.subjectMass{set};
    catch
        subjectMass = 1;
    end
    if strmatch(options.dataType, {'IK' 'COM'})
        subjectMass = 1;
    end
    

    nTrials = size(trials,1);
    TAG = 0;
    
    if nTrials == 0 
        warning(['no ' options.dataType ' datasets found in ' dataFolder])
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Loop through the trials
    for trial= 1:nTrials;
        
        %%%%%%%%%%%%%%%%%%%
        % import trial data
        dataFile = trials(trial).name;
        fullPath = ([dataFolder '\' dataFile]);
        if strcmp(options.dataType,'IK')
            headerlinesIn = 11;
        end
        if strcmp(options.dataType,'ID')
            headerlinesIn = 7;
        end
        if strcmp(options.dataType,'COM')
            headerlinesIn = 19;
        end
        if strcmp(options.dataType,'POW')
            headerlinesIn = 10;
        end
        if strcmp(options.dataType,'grf') % doesn't work right now
            headerlinesIn = 7;
        end
        delimiterIn = '\t';
        data = importdata(fullPath,delimiterIn,headerlinesIn);
        
        %%%%%%%%%%%%%%%%%%%%%
        % search for data tag
        tags = data.colheaders;
        for ind = 1:size(tags,2)
            TAG = 0;
            if strcmp(tag,tags(1,ind))
                TAG = ind;
                fprintf([tag ' tag found \n'])
                break
            end
        end
        if TAG == 0
            warning(['tag not found in datafile ' dataFile])
            warning('check for correct directory and datafiles')
            continue
        end
        temp = data.data(:,TAG);
        tempSize = size(temp,1);
        time = data.data(:,1);
        timeStep = time(2);
        
        %%%%%%%%%%%%%%%%%%%%%%%
        % stitch data if called
        if strmatch(stitch,{'yes' 'Yes' 'Y' 'y' 'YES'})
            frameData = options.frames{set}(trial,:);
            splitFrame = round((frameData(4)-frameData(2))/10);
            temp1 = temp(1:splitFrame+1);
            temp2 = temp(splitFrame+1:end-10);
            temp = [temp2; temp1];
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%
        % remove offset if called
        if strmatch(rmvofst, {'yes' 'Yes' 'Y' 'y' 'YES'})
            temp = temp - mean([temp(1);temp(end)]);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%
        % mirror raw if called
        if strmatch(mirror, {'yes' 'Yes' 'Y' 'y' 'YES'})
%             compResults{set+1,2}(:,trial) = -compResults{set+1,2}(:,trial);
            temp = -temp;
        end
          
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % normalize to mass if called
        if strmatch(norm2mass,{'yes' 'Yes' 'Y' 'y' 'YES'})
            temp = temp./subjectMass;
        end
    
        %%%%%%%%%%%%%%%%%%%%%%%
        % filter and downsample
        windowSize = options.filter;
        temp2 = dynWindFilt(windowSize,temp);
%         temp2 = temp;
        P = 101;
        Q = size(temp2,1);
        tempRsmpl = resample(temp2,P,Q,0);
        compResults{set+1,1} = set;
        compResults{set+1,2}(:,trial) = tempRsmpl;
      
        %%%%%%%%%%%%%%%%%%%%%%%
        % find data max and min
        compResults{set+1,4}(1,trial) = max(temp);
        compResults{set+1,6}(1,trial) = min(temp);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % work calculations for power data
        if strcmp(options.dataType, 'POW')
            netPosWrk = 0;
            tempSize = size(temp,1);
            for n = 1:tempSize
                if temp(n) >= 0
                    netPosWrk = netPosWrk + temp(n)*timeStep;
                end
            end
            netWrk = sum(temp.*timeStep);
%             netAbsWork = sum(abs(temp).*timeStep);
            compResults{set+1,8}(1,trial) = netPosWrk;
            compResults{set+1,10}(1,trial) = netWrk;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % output each data trial if called
%         if outLevel >= 5
%             warning('off','all')
%             color = 'r';
%             if trial == 2; color = 'b';end
%             if trial == 3; color = 'k';end
%             if trial == 4; color = 'g';end
%             if trial == 5; color = 'c';end
%             figure(set + 20)
%             hold on
%             plot(temp,color)
%             title([tagName ' raw data'])
%             legend('trial 1','trial 2','trial 3','trial 4')
%             figure(set + 40)
%             hold on
%             stance = 0:1:100;
%             plot(stance,compResults{set+1,2}(:,trial),color)
%             title([label ' ' tagName ' filtered and normalized'])
%             legend('trial 1','trial 2','trial 3','trial 4','trial 5')
%             warning('on','all')
%         end        
        
        % plot
        if outLevel >= 3
            warning('off','all')
            color = 'r';
            if trial == 2; color = 'b';end
            if trial == 3; color = 'k';end
            if trial == 4; color = 'g';end
            if trial == 5; color = 'c';end
            figure(set + 20)
            hold on
            plot(temp,color)
            title([label ' ' tagName ' raw data'])
            legend('trial 1','trial 2','trial 3','trial 4','trial 5')
            figure(set + 40)
            hold on
            stance = 0:1:100;
            plot(stance,compResults{set+1,2}(:,trial),color)
            title([label ' ' tagName ' filtered and normalized'])
            legend('trial 1','trial 2','trial 3','trial 4','trial 5')
            warning('on','all')
        end
        
        clear temp temp2
    end
    
    
    %%%%%%%%%%%%%%%%%%%%
    % dataset statistics 
    if nTrials >= 1 && TAG >= 1
        for samp = 1:101
            compResults{set+1,3}(samp,1) = mean(compResults{set+1,2}(samp,:));
            compResults{set+1,3}(samp,2) = std(compResults{set+1,2}(samp,:));
        end
        
        %%%%%%%%%%%%%%%%%%%%
        % max/min statistics
        compResults{set+1,5}(1,1) = mean(compResults{set+1,4}(1,:));
        compResults{set+1,5}(1,2) = std(compResults{set+1,4}(1,:));
        compResults{set+1,7}(1,1) = mean(compResults{set+1,6}(1,:));
        compResults{set+1,7}(1,2) = std(compResults{set+1,6}(1,:));
        
        %%%%%%%%%%%%%%%%%
        % work statistics
        if strcmp(options.dataType, 'POW')
            compResults{set+1,9}(1,1) = mean(compResults{set+1,8}(1,:));
            compResults{set+1,9}(1,2) = std(compResults{set+1,8}(1,:));
            compResults{set+1,11}(1,1) = mean(compResults{set+1,10}(1,:));
            compResults{set+1,11}(1,2) = std(compResults{set+1,10}(1,:));
        end
    end
    

    %%%%%%%%%%
    % zero COM
    if strmatch(zeroCOM,{'yes' 'Yes' 'Y' 'y' 'YES'})
        if strcmp(options.dataType,'COM')
%         compResults{set+1,3}(:,1) = compResults{set+1,3}(:,1)-min(compResults{set+1,3}(1:30,1));
%         compResults{set+1,3}(:,1) = compResults{set+1,3}(:,1)-min(compResults{set+1,3}(30:80,1));
        compResults{set+1,3}(:,1) = compResults{set+1,3}(:,1)-max(compResults{set+1,3}(70:100,1));
%         compResults{set+1,3}(:,1) = compResults{set+1,3}(:,1)-min(compResults{set+1,3}(:,1));
%         compResults{set+1,3}(:,1) = compResults{set+1,3}(:,1)-min(compResults{set+1,3}(1,1));
        end
    end

    dataLabel{set} = label;
end

%%%%%%%%%%%%%%%%%%%
% plot average data
if outLevel >= 2 && TAG >= 1
    figure
    hold on
    stance = 0:100;
    for f = 1:nSets
        color = 'r';
        if f == 2; color = 'b';end
        if f == 3; color = 'k';end
        if f == 4; color = 'g';end
        if f == 5; color = 'c';end
        boundedline(stance,compResults{f+1,3}(:,1),compResults{f+1,3}(:,2),color,'alpha');
        title ([tagName ' ' options.dataType ' data'])
        warning('off','all')
        if nSets == 1; legend(dataLabel{1},'');end
        if nSets == 2; legend(dataLabel{1},'',dataLabel{2},'');end
        if nSets == 3; legend(dataLabel{1},'',dataLabel{2},'',dataLabel{3},'');end
        if nSets == 4; legend(dataLabel{1},'',dataLabel{2},'',dataLabel{3},'',dataLabel{4},'');end
        if nSets == 5; legend(dataLabel{1},'',dataLabel{2},'',dataLabel{3},'',dataLabel{4},'',dataLabel{5},'');end
        warning('on','all')
    end
end

save compResults.mat compResults