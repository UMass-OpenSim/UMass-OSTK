% -------------------------------------------------------------------------
% getMass.m
%
% getMass retrieves the subjects mass from the force plate data
%
% note: this will not work if the force plates have not been zeroed out
% prior to collection
% 
% written by Andrew LaPre
% last modified 3/2017
%
% example function call:
% % point to folders containing calibration data for each subject
% datafolder{1} = [pwd '\TSV\Calibration\GRF_Passive\'];
% datafolder{2} = [pwd '\TSV\Calibration\GRF_Active\'];
% getMass(datafolder);
% -------------------------------------------------------------------------

function getMass(datafolder)

nSets = size(datafolder,2);

subjectMass = zeros(nSets,1);

for set = 1:nSets
    
    dataFolder = datafolder{set};
    trials = dir(fullfile(dataFolder, '*f_1.tsv'));


    nTrials = size(trials,1);
    pathname = dataFolder;

    m = zeros(nTrials,1);

    for trial = 1:nTrials
        file_input = trials(trial).name;
        try
            data = dlmread(strcat(pathname,file_input),'',23,0);
        catch
            data = dlmread(strcat(pathname,file_input),'',24,0);
        end
        temp = data(:,3);

        m(trial) = mean(temp)/9.81;


    end

    subjectMass(set) = mean(m);

end

disp('subject mass calculated successfully')

save subjectMass.mat subjectMass