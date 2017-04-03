%-------------------------------------------------------------------------% 
% POW_batch.m
% 
% This function performs batch power analysis for the UMass transtibial amputee model
%
% Written by Andrew LaPre 2/2016
% Last modified 3/2017
%
% example function call:
% options.IKdatasets{1} = 'IK\Results\Passive\';
% options.IKdatasets{2} = 'IK\Results\Active2\';
% options.IDdatasets{1} = 'ID\Results\Passive\';
% options.IDdatasets{2} = 'ID\Results\Active2\';
% options.results_pth{1} = ([pwd '\POW\Passive\']);
% options.results_pth{2} = ([pwd '\POW\Active2\']);
% options.filter = 15;
% options.linearcoordinates = [4, 5, 6, 22];
% POW_batch(options)
%-------------------------------------------------------------------------%

function POW_batch(options)

filt = options.filter;

nSets = size(options.IKdatasets,2);

for dataset = 1:nSets
    
    results_dir = options.results_pth{dataset};
    
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
    end
    
    
    ikDataset = dir(fullfile(options.IKdatasets{dataset}, '*.mot'));
    idDataset = dir(fullfile(options.IDdatasets{dataset}, '*.sto'));
    
    nTrials = size(ikDataset,1);
    
    if nTrials == 0 
        warning('check datasets')
    end
%     figure
    for trial = 1:nTrials
        
        disp(['calculating power for trial ' num2str(trial) ' of dataset ' num2str(dataset)])
        ikFile = ikDataset(trial).name;
        ikPath = [options.IKdatasets{dataset} ikFile];
        idFile = idDataset(trial).name;
        idPath = [options.IDdatasets{dataset} idFile];
        
        ikData = importdata(ikPath,'\t',11);
        ikColHeaders = ikData.colheaders;
        idData = importdata(idPath,'\t',7);
        idColHeaders = idData.colheaders;
        
        nCol = length(ikColHeaders);
        nRows = size(ikData.data,1);
        powData = zeros(nRows-1,nCol);
        ikDot = zeros(nRows-1,nCol);
        powData(:,1) = ikData.data(1:end-1,1);
        ikDot(:,1) = diff(ikData.data(:,1));
        
        for col = 1:nCol
            idCoord = idData.data(1:end-1,col);
            if col>1
                c = col-1;
                % filter kinematics
                ikData.data(:,col) = dynWindFilt(filt,ikData.data(:,col));
                % if it is a linear coordinate specified
                if ismember(c,options.linearcoordinates)
%                     ikDot(:,col) = diff(ikData.data(:,col))./ikDot(:,1);
                    ikDot(:,col) = diff(ikData.data(:,col))./(1/240);
                else 
%                     ikDot(:,col) = (diff(ikData.data(:,col).*(pi/180)))./ikDot(:,1);
                    ikDot(:,col) = (diff(ikData.data(:,col).*(pi/180)))./(1/240);
                end
                ikDot(:,col) = dynWindFilt(filt,ikDot(:,col));
                powData(:,col) = ikDot(:,col).*idCoord(:);
            end
        end
%         hold on
%         plot(ikDot(:,8))
        
        POWname = regexprep(ikFile,'_ik.mot','');
        pow_filename = [POWname '_pow.sto'];
        
        % create the header
        header{1} = [POWname '_pow'];
        header{2} = 'version=1';
        header{3} = ['nRows=' num2str(size(powData,1))];
        header{4} = ['nColumns=' num2str(size(powData,2))];
        header{5} = '';
        header{6} = 'Units are S.I. units (second, meters, Newtons, ...)';
        header{7} = 'Power is in Watts';
        header{8} = '';
        header{9} = 'endheader';
        
        % create file
        fid = fopen(pow_filename,'w');
        
        % print the header
        for i = 1:length(header)
            fprintf(fid,'%s\n',header{i});
        end
        
        for i = 1:size(ikColHeaders,2)
            if i>1
                label = [ikColHeaders{i} '_power'];
            else
                label = ikColHeaders{i};
            end
            if i == size(ikColHeaders,2)
                fprintf(fid,'%s',char(label));
            else
                fprintf(fid,'%s\t',char(label));
            end
        end
        fprintf(fid,'\n');
        
%         dlmwrite(pow_filename, powData,'-append','delimiter','\t','precision','%.6f','newline','pc');
        dlmwrite(pow_filename, powData,'-append','delimiter','\t','precision','%.6f');
%         dlmwrite(pow_filename, powData,'-append','delimiter','\t','newline','pc');
        
        fclose(fid);
        
        movefile(pow_filename,results_dir,'f');
        
        
    end
end

disp ('batch power calculations complete')
