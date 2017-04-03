% -------------------------------------------------------------------------
% trimMarkerData.m
%
% this script trims .tsv marker data files in the given folder, according 
% to frames and writes a trimmed file in a write folder
% 
% use frammeFinder.m to generate frames first
% 
% written by Andrew LaPre
% last modified 3/2017
% 
% example function call:
% Frames = frames.passive;
% data_folder = 'TSV\Passive\MarkerData\';
% trimMarkerData(data_folder, Frames)
% -------------------------------------------------------------------------

function trimMarkerData(data_folder, frames)

write_folder = [data_folder(1,1:end-1) '_Trimmed\'];

if ~exist(write_folder,'dir')
    mkdir(write_folder)
end


Trials = dir(fullfile(data_folder, '*.tsv'));
nTrials = size(Trials,1);
pathname = data_folder;

maxMarkers = 100;

for trial = 1:nTrials
    disp(['working on trial ' num2str(trial) ' marker data'])
    % get first and last frame
    first = round(frames(trial,2)/10);
    last = round(frames(trial,6)/10);
    
    % Get the name of the file for this trial
    file_input = Trials(trial).name;
    
    %Get the header information
    fileID = fopen([pathname file_input]);
    n = 1;
    strTemp = '%s';
    while n<maxMarkers+1
        strTemp = strcat(strTemp, ' %s');
        n = n+1;
    end
    clear header
    header = textscan(fileID,strTemp, 10,'Delimiter','\t');
    
    
    %extract the data
    data = dlmread(strcat(pathname,file_input),'',10,0); %all are data
    fclose(fileID);
    
    % create new files in write_folder and write headers
    fileID = fopen([write_folder file_input], 'w');
    filename = [write_folder file_input];    
    for indx = 1:10
        n = 1;
        while n<maxMarkers+1
            temp{n} = char(header{1,n}(indx));
            n=n+1;
        end
        if indx == 1
            temp{2} = num2str(last-first+1);
        end
        n=1;
        strTemp = '%s';
        while n<maxMarkers+1
            n = n+1;
            if n<maxMarkers+1
                strTemp = strcat(strTemp, '\t%s');
            else
                strTemp = strcat(strTemp, '\n');
            end
            
        end
        fprintf(fileID, strTemp, temp{1:end});
        
    end
    clear temp
    temp = data(first:last,:);
    
    dlmwrite(filename,temp,'-append','delimiter','\t', 'precision','%.3f')
    fclose(fileID);
    clear temp
end

disp('marker data successfuly trimmed')