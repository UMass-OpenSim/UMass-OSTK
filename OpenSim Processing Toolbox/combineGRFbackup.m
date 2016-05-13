function GRFavg = combineGRF(data_folder)
% this data calculates the average and standard deviation of trimmed grf
% .tsv files



trials = dir(fullfile(data_folder, '*f_2.tsv'));
nTrials = size(trials,1);
pathname = data_folder;


vx = zeros(101,nTrials);
vy = zeros(101,nTrials);
for trial = 1:nTrials;

    % get filename for this trial
    file_input = trials(trial).name;
    
    data = dlmread(strcat(pathname,file_input),'',23,0);
    
    temp = data(:,2);
    P = 101;
    Q = size(temp,1);
    vx(:,trial) = resample(temp,P,Q);
    
    temp = data(:,3);
    P = 101;
    Q = size(temp,1);
    vy(:,trial) = resample(temp,P,Q);
    
end

GRFavg.Vx = zeros(101,2);
GRFavg.Vy = zeros(101,2);

for frame = 1:101
    GRFavg.Vx(frame,1) = mean(vx(frame,:));
    GRFavg.Vx(frame,2) = std(vx(frame,:));
    GRFavg.Vy(frame,1) = mean(vy(frame,:));
    GRFavg.Vy(frame,2) = std(vy(frame,:));
end

stance = 0:1:100;
figure
subplot(2,1,1)
boundedline(stance,GRFavg.Vy(:,1),GRFavg.Vy(:,2),'r','alpha');
title('Vertical GRF (N)')
xlabel('% Gait')
subplot(2,1,2)
boundedline(stance,GRFavg.Vx(:,1),GRFavg.Vx(:,2),'r','alpha');
title('Horizontal GRF (N)')  
xlabel('% Gait')



