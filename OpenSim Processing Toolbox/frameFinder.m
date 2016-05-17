function frames = frameFinder(data_folder)
% This function returns the frame of the first pressure sample, first heel 
% strike, and second heel strike of all data sets, given a folder
% containing both analog and force .tsv files exported from QTM.

% resultant array frames: [novel pulse, HS1, HS2, TO1, TO2]

analog_files = dir(fullfile(data_folder, '*a.tsv'));
f1_files = dir(fullfile(data_folder, '*f_1.tsv'));
f2_files = dir(fullfile(data_folder, '*f_2.tsv'));
f3_files = dir(fullfile(data_folder, '*f_3.tsv'));

nTrials = size(analog_files,1);
pathname = data_folder;

frames = zeros(nTrials,3);


for trial = 1:nTrials;

%     errorFlag = 0;
    % get frame pressure starts recording
    % Get the name of the file for this trial
    file_input = analog_files(trial).name;
    name1 = regexprep(file_input,'_a.tsv','');
    % load analog data
    data = dlmread(strcat(pathname,file_input),'',13,0);
    analog64 = data(:,64);
    % search for pulse in channel 64
    for t = 1:size(analog64,1)
       if analog64(t)>.2 
           break
       end
    end
    x=t;
    if t>1
        x=t-2;
    end

    frames(trial,1) = x;

    % get first heel strike frame
    % load forceplate 2 data
    file_input = f2_files(trial).name;
    name2 = regexprep(file_input,'_f_2.tsv','');
    try
        data = dlmread(strcat(pathname,file_input),'',23,0);
    catch
        data = dlmread(strcat(pathname,file_input),'',24,0);
    end
    fp2_data = data(:,3);
    % zero data
    fp2_data = fp2_data-fp2_data(1);
    % filter the data
    windowSize = 10;
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    fp2_data = filter(b,a,fp2_data);
    for t = 1:size(data,1)
        if fp2_data(t)>2 
            break
        end
    end
    x=t;
    if t>1
        x=t-10;
    end
    frames(trial,2) = x;
%     plot(temp)

    % get second heel strike frame
    % load forceplate 1 data
    file_input = f1_files(trial).name;
    name3 = regexprep(file_input,'_f_1.tsv','');    
    try
        data = dlmread(strcat(pathname,file_input),'',23,0);
    catch
        data = dlmread(strcat(pathname,file_input),'',24,0);
    end
    fp1_data = data(:,3);
    fp1_data = fp1_data-fp1_data(1);
    cop_sag = data(:,8);
    cop_sag_dot = diff(cop_sag);
    % filter the data
    windowSize = 10;
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    temp = filter(b,a,cop_sag_dot);
%     contact_flag = 0;
%     HS_flag = 0;
    for t = 1:size(temp,1) 
        if fp1_data(t,1)>500 && temp(t)>2.5
            break
        end
    end
    if t == size(temp,1)
        warning([file_input ' 2nd heel strike needs manual input, inspect plot. You may need to inspect the original data in QTM.'])
%         errorFlag = 1;
    end
    x=t;
    if t>1 && t<(size(temp,1)-10) % search untill the last ten frames
        x=t+10;
    end   
    frames(trial,3) = x;
    
    % get first toe off frame
    % load forceplate 3 data
    file_input = f3_files(trial).name;
    name4 = regexprep(file_input,'_f_3.tsv','');
    try
        data = dlmread(strcat(pathname,file_input),'',23,0);
    catch
        data = dlmread(strcat(pathname,file_input),'',24,0);
    end
    fp3_data = data(:,3);
    % zero data
    fp3_data = fp3_data-fp3_data(end);
    % filter the data
    windowSize = 10;
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    fp3_data = filter(b,a,fp3_data);
    for t = frames(trial,2):size(data,1)
        if fp3_data(t)<2 
            break
        end
    end
    x=t;
    if t>1
        x=t+10;
    end
    frames(trial,4) = x;
    
    % get second toe off frame
    % load forceplate 2 data
    file_input = f2_files(trial).name;
    name5 = regexprep(file_input,'_f_2.tsv','');
    try
        data = dlmread(strcat(pathname,file_input),'',23,0);
    catch
        data = dlmread(strcat(pathname,file_input),'',24,0);
    end
    fp2_data = data(:,3);
    % zero data
    fp2_data = fp2_data-fp2_data(end);
    % filter the data
    windowSize = 10;
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    fp2_data = filter(b,a,fp2_data);
    for t = frames(trial,2)+100:size(data,1)
        if fp2_data(t)<2 
            break
        end
    end
    x=t;
    if t>1
        x=t+10;
    end
    frames(trial,5) = x;   
    
    
    
    
    
    
    
    figure
    subplot(4,1,1)
    hold on
    plot(analog64)
    plot(frames(trial,1),analog64(frames(trial,1)),'*r')
%     xlim([frames(trial,1)-100 frames(trial,1)+100])
    title(name1 )
    ylabel('ch64 pulse')
    
    subplot(4,1,2)
    hold on
    plot(fp3_data)
    plot(frames(trial,4),fp3_data(frames(trial,4)),'*r')
    xlim([frames(trial,2)-10 frames(trial,3)+10])
    ylim([-10 max(fp3_data)+100])
    ylabel(' FP3 ')
    
    subplot(4,1,3)
    hold on
    plot(fp2_data)
    plot(frames(trial,2),fp2_data(frames(trial,2)),'*r')
    plot(frames(trial,5),fp2_data(frames(trial,5)),'*r')
    xlim([frames(trial,2)-10 frames(trial,3)+10])
    ylim([-10 max(fp2_data)+100])
    ylabel(' FP2 ')
    
    subplot(4,1,4)
    hold on
    plot(fp1_data)
    plot(frames(trial,3),fp1_data(frames(trial,3)),'*r')
    xlim([frames(trial,2)-10 frames(trial,3)+10])
    ylim([-10 max(fp1_data)+100])
%     ylabel([name3 ' FP1 '])
    ylabel(' FP1 ')
    
end