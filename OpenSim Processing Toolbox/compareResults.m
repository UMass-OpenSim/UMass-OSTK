% compare the results of 2 folders with common datatypes
function compareResults(CR_options)



    
nSets = size(CR_options.datasets,2);
tag = CR_options.tag;
compResults{1,1} = 'dataset';
compResults{1,2} = 'trials';
compResults{1,3} = 'mean,std';

for set = 1:nSets

    dataFolder = CR_options.datasets{set};
    if strcmp(CR_options.dataType,'IK')
        trials = dir(fullfile(dataFolder, '*.mot'));
    end
    if strcmp(CR_options.dataType,'ID')
        trials = dir(fullfile(dataFolder, '*.sto'));
    end
    if strcmp(CR_options.dataType,'grf')
        trials = dir(fullfile(dataFolder, '*.mot'));
    end

    nTrials = size(trials,1);
    TAG = 0;
    
    if nTrials == 0 
        warning(['no ' CR_options.dataType ' datasets found in ' dataFolder])
    end
    
    % Loop through the trials
    for trial= 1:nTrials;
        dataFile = trials(trial).name;
        fullPath = ([dataFolder '\' dataFile]);
        if strcmp(CR_options.dataType,'IK')
            headerlinesIn = 11;
        end
        if strcmp(CR_options.dataType,'ID')
            headerlinesIn = 7;
        end
        if strcmp(CR_options.dataType,'grf') % doesn't work right now
            headerlinesIn = 7;
        end
        delimiterIn = '\t';
        data = importdata(fullPath,delimiterIn,headerlinesIn);
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
        
        windowSize = CR_options.filter;
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        temp2 = filter(b,a,temp);
        
        P = 101;
        Q = size(temp2,1);
        compResults{set+1,1} = set;
        compResults{set+1,2}(:,trial) = resample(temp2,P,Q,0);
        
        if CR_options.outputLevel >= 3
            figure(set + 20)
            hold on
            plot(temp)
            figure(set + 40)
            hold on
            stance = 0:1:100;
            plot(stance,compResults{set+1,2}(:,trial))
        end
        
        clear temp temp2
    end

    if nTrials >= 1 && TAG >= 1
        for samp = 1:101
            compResults{set+1,3}(samp,1) = mean(compResults{set+1,2}(samp,:));
            compResults{set+1,3}(samp,2) = std(compResults{set+1,2}(samp,:));
        end
    end

end

if CR_options.outputLevel >= 2 && TAG >= 1
    figure
    hold on
    stance = 0:100;
    for f = 1:nSets
        color = 'r';
        if f == 2; color = 'b';end
        if f == 3; color = 'k';end
        boundedline(stance,compResults{f+1,3}(:,1),compResults{f+1,3}(:,2),color,'alpha');
    end
end







save compResults.mat compResults