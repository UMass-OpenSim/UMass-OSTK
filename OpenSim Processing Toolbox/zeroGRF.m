function zeroGRF(data_folder)
% This function removes the baseline offset from ground reaction forces in
% all .tsv files in a given folder.
%
%
% written by Andrew LaPre


if strcmp(data_folder(1,end-7:end),'-Analog\')
    write_folder = [data_folder(1,1:end-8) '_Zeroed\'];
else
    write_folder = [data_folder(1,1:end-1) '_Zeroed\'];
end

if ~exist(write_folder,'dir')
    mkdir(write_folder)
end

F1Trials = dir(fullfile(data_folder, '*f_1.tsv'));
F2Trials = dir(fullfile(data_folder, '*f_2.tsv'));
F3Trials = dir(fullfile(data_folder, '*f_3.tsv'));
F4Trials = dir(fullfile(data_folder, '*f_4.tsv'));
F5Trials = dir(fullfile(data_folder, '*f_5.tsv'));
nTrials = size(F1Trials);
pathname = data_folder;

disp('removing GRF zero offset, this will take a few seconds');

for trial = 1:nTrials;
    

    % Get the name of the file for this trial
    file_input_F1 = F1Trials(trial).name;
    file_input_F2 = F2Trials(trial).name;
    file_input_F3 = F3Trials(trial).name;
    file_input_F4 = F4Trials(trial).name;
    file_input_F5 = F5Trials(trial).name;
    
    hLines = 23;
    
    try
        test = dlmread(strcat(pathname,file_input_F1),'',hLines,0); 
    catch
        hLines = 24;
    end

    %Get the header information
    fileID_F1 = fopen([pathname file_input_F1]);
    fileID_F2 = fopen([pathname file_input_F2]);
    fileID_F3 = fopen([pathname file_input_F3]);
    fileID_F4 = fopen([pathname file_input_F4]);
    fileID_F5 = fopen([pathname file_input_F5]);
    header1 = textscan(fileID_F1,'%s %s %s', hLines,'Delimiter','\t');
    header2 = textscan(fileID_F2,'%s %s %s', hLines,'Delimiter','\t');
    header3 = textscan(fileID_F3,'%s %s %s', hLines,'Delimiter','\t');
    header4 = textscan(fileID_F4,'%s %s %s', hLines,'Delimiter','\t');
    header5 = textscan(fileID_F5,'%s %s %s', hLines,'Delimiter','\t');

    %extract the data
    data1 = dlmread(strcat(pathname,file_input_F1),'',hLines,0); %all are data
    data2 = dlmread(strcat(pathname,file_input_F2),'',hLines,0); %all are data
    data3 = dlmread(strcat(pathname,file_input_F3),'',hLines,0); %all are data
    data4 = dlmread(strcat(pathname,file_input_F4),'',hLines,0); %all are data
    data5 = dlmread(strcat(pathname,file_input_F5),'',23,0); %all are data
    fclose(fileID_F1);
    fclose(fileID_F2);
    fclose(fileID_F3);
    fclose(fileID_F4);
    fclose(fileID_F5);

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
        fprintf(fileID_F1, '%s\t%s\t%s\n', temp1, temp2, temp3);
        fprintf(fileID_F2, '%s\t%s\t%s\n', temp4, temp5, temp6);
        fprintf(fileID_F3, '%s\t%s\t%s\n', temp7, temp8, temp9);
        fprintf(fileID_F4, '%s\t%s\t%s\n', temp10, temp11, temp12);
        fprintf(fileID_F5, '%s\t%s\t%s\n', temp13, temp14, temp15);
    end

    % remove the offset
    for col = 1:6
        tare1 = data1(1,col);
        tare2 = data2(size(data2,1),col);
        tare3 = data3(size(data2,1),col);
        for row = 1:size(data1,1)
            sample1 = data1(row,col);
            sample2 = data2(row,col);
            sample3 = data3(row,col);
            data1(row,col) = sample1-tare1;
            data2(row,col) = sample2-tare2;
            data3(row,col) = sample3-tare3;
            
        end
    end    
    
    dlmwrite(filename1,data1,'-append','delimiter','\t', 'precision','%.6f')
    dlmwrite(filename2,data2,'-append','delimiter','\t', 'precision','%.6f')
    dlmwrite(filename3,data3,'-append','delimiter','\t', 'precision','%.6f')
    dlmwrite(filename4,data4,'-append','delimiter','\t', 'precision','%.6f')
    dlmwrite(filename5,data5,'-append','delimiter','\t', 'precision','%.6f')
    fclose(fileID_F1);
    fclose(fileID_F2);
    fclose(fileID_F3);
    fclose(fileID_F4);
    fclose(fileID_F5);
    
    figure
    subplot(3,1,1)
    plot(data1(:,3))
    ylabel('FP1 Zeroed Vertical GRF (N)')
    subplot(3,1,2)
    plot(data2(:,3))
    ylabel('FP2 Zeroed Vertical GRF (N)')
    subplot(3,1,3)
    plot(data3(:,3))
    ylabel('FP3 Zeroed Vertical GRF (N)')
    
end

disp('zero offset removed from GRF files'); 
