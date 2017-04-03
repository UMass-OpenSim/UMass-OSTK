function getStrideTimes(options)

nSets = size(options.Frames,2);


stanceTimes{1,1} = 'dataset';
stanceTimes{1,2} = 'trial ';
stanceTimes{1,3} = 'mean,std';
cycleTimes{1,1} = 'dataset';
cycleTimes{1,2} = 'trial ';
cycleTimes{1,3} = 'mean,std';

data1 = zeros(nSets,2);
data2 = zeros(nSets,2);
for set = 1:nSets
    stanceTimes{set+1,1} = set;
    cycleTimes{set+1,1} = set;
    frameData = options.Frames{set};
    nTrials = size(frameData,1);
    for trial = 1:nTrials
        
        stanceTimes{set+1,2}(1,trial) = (frameData(trial,5) - frameData(trial,2))/2400;
        cycleTimes{set+1,2}(1,trial) = (frameData(trial,6) - frameData(trial,2))/2400;
        
        
    end
    
    stanceTimes{set+1,3}(1,1) = mean(stanceTimes{set+1,2}(1,:));
    stanceTimes{set+1,3}(1,2) = std(stanceTimes{set+1,2}(1,:));
    
    
    cycleTimes{set+1,3}(1,1) = mean(cycleTimes{set+1,2}(1,:));
    cycleTimes{set+1,3}(1,2) = std(cycleTimes{set+1,2}(1,:));
    
    data1(set,1) = stanceTimes{set+1,3}(1,1);
    data1(set,2) = stanceTimes{set+1,3}(1,2);
    data2(set,1) = cycleTimes{set+1,3}(1,1);
    data2(set,2) = cycleTimes{set+1,3}(1,2);
    
end
figure
hold on
data(:,1) = data1(:,1);
data(:,2) = data2(:,1);
bar(data)
legend('stance', 'cycle')
ylabel('time (s)')
xlabel('datasets')




save gaitTimes.mat stanceTimes cycleTimes