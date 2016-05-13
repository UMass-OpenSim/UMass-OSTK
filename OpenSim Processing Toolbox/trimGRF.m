function trimGRF(data_folder, frames)
% This function trims .tsv force files in a given data folder according to 
% frames, and writes a trimmed file in write_folder


write_folder = [data_folder(1,1:end-1) '_Trimmed\'];

if ~exist(write_folder,'dir')
    mkdir(write_folder)
end

F1Trials = dir(fullfile(data_folder, '*f_1.tsv'));
F2Trials = dir(fullfile(data_folder, '*f_2.tsv'));
F3Trials = dir(fullfile(data_folder, '*f_3.tsv'));
F4Trials = dir(fullfile(data_folder, '*f_4.tsv'));
F5Trials = dir(fullfile(data_folder, '*f_5.tsv'));
nTrials = size(F1Trials,1);
pathname = data_folder;


for trial = 1:nTrials
    disp(['working on trial ' num2str(trial) ' GRF data'])
    % get first and last frame
    first = frames(trial,2);
    last = frames(trial,3);
    
    % Get the name of the file for this trial
    file_input_F1 = F1Trials(trial).name;
    file_input_F2 = F2Trials(trial).name;
    file_input_F3 = F3Trials(trial).name;
    file_input_F4 = F4Trials(trial).name;
    file_input_F5 = F5Trials(trial).name;

    %Get the header information
    fileID_F1 = fopen([pathname file_input_F1]);
    fileID_F2 = fopen([pathname file_input_F2]);
    fileID_F3 = fopen([pathname file_input_F3]);
    fileID_F4 = fopen([pathname file_input_F4]);
    fileID_F5 = fopen([pathname file_input_F5]);
    header1 = textscan(fileID_F1,'%s %s %s', 23,'Delimiter','\t');
    header2 = textscan(fileID_F2,'%s %s %s', 23,'Delimiter','\t');
    header3 = textscan(fileID_F3,'%s %s %s', 23,'Delimiter','\t');
    header4 = textscan(fileID_F4,'%s %s %s', 23,'Delimiter','\t');
    header5 = textscan(fileID_F5,'%s %s %s', 23,'Delimiter','\t');

    %extract the data
    data1 = dlmread(strcat(pathname,file_input_F1),'',23,0); %all are data
    data2 = dlmread(strcat(pathname,file_input_F2),'',23,0); %all are data
    data3 = dlmread(strcat(pathname,file_input_F3),'',23,0); %all are data
    data4 = dlmread(strcat(pathname,file_input_F4),'',23,0); %all are data
    data5 = dlmread(strcat(pathname,file_input_F5),'',23,0); %all are data
    fclose(fileID_F1);
    fclose(fileID_F2);
    fclose(fileID_F3);
    fclose(fileID_F4);
    fclose(fileID_F5);
    
    % create new files in write_folder and write headers
    fileID_F1 = fopen([write_folder file_input_F1], 'w');
    fileID_F2 = fopen([write_folder file_input_F2], 'w');
    fileID_F3 = fopen([write_folder file_input_F3], 'w');
    fileID_F4 = fopen([write_folder file_input_F4], 'w');
    fileID_F5 = fopen([write_folder file_input_F5], 'w');
    filename1 = [write_folder file_input_F1];
    filename2 = [write_folder file_input_F2];
    filename3 = [write_folder file_input_F3];
    filename4 = [write_folder file_input_F4];
    filename5 = [write_folder file_input_F5];
    for indx = 1:23
        temp1 = char(header1{1,1}(indx));
        temp2 = char(header1{1,2}(indx));
        temp3 = char(header1{1,3}(indx));
        temp4 = char(header2{1,1}(indx));
        temp5 = char(header2{1,2}(indx));
        temp6 = char(header2{1,3}(indx));
        temp7 = char(header3{1,1}(indx));
        temp8 = char(header3{1,2}(indx));
        temp9 = char(header3{1,3}(indx));
        temp10 = char(header4{1,1}(indx));
        temp11 = char(header4{1,2}(indx));
        temp12 = char(header4{1,3}(indx));
        temp13 = char(header5{1,1}(indx));
        temp14 = char(header5{1,2}(indx));
        temp15 = char(header5{1,3}(indx));
        if indx == 1
            temp2 = num2str(last-first+1);
            temp5 = num2str(last-first+1);
            temp8 = num2str(last-first+1);
            temp11 = num2str(last-first+1);
            temp14 = num2str(last-first+1);
        end
        fprintf(fileID_F1, '%s\t%s\t%s\n', temp1, temp2, temp3);
        fprintf(fileID_F2, '%s\t%s\t%s\n', temp4, temp5, temp6);
        fprintf(fileID_F3, '%s\t%s\t%s\n', temp7, temp8, temp9);
        fprintf(fileID_F4, '%s\t%s\t%s\n', temp10, temp11, temp12);
        fprintf(fileID_F5, '%s\t%s\t%s\n', temp13, temp14, temp15);
    end
    
    temp1 = data1(first:last,:);
    temp2 = data2(first:last,:);
    temp3 = data3(first:last,:);
    temp4 = data4(first:last,:);
    temp5 = data5(first:last,:);
    
    dlmwrite(filename1,temp1,'-append','delimiter','\t', 'precision','%.6f')
    dlmwrite(filename2,temp2,'-append','delimiter','\t', 'precision','%.6f')
    dlmwrite(filename3,temp3,'-append','delimiter','\t', 'precision','%.6f')
    dlmwrite(filename4,temp4,'-append','delimiter','\t', 'precision','%.6f')
    dlmwrite(filename5,temp5,'-append','delimiter','\t', 'precision','%.6f')
    fclose(fileID_F1);
    fclose(fileID_F2);
    fclose(fileID_F3);
    fclose(fileID_F4);
    fclose(fileID_F5);
    
    figure
    subplot(3,1,1)
    plot(temp1(:,3))
    ylabel('FP1 Trimmed Vertical GRF (N)')
    subplot(3,1,2)
    plot(temp2(:,3))
    ylabel('FP2 Trimmed Vertical GRF (N)')
    subplot(3,1,3)
    plot(temp3(:,3))
    ylabel('FP3 Trimmed Vertical GRF (N)')
    
end

disp('GRF data successfuly trimmed')

