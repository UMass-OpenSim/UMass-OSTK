function getMass(datafolder)
% getMass retrieves the subjects mass from the force plate data

% note: this will not work if the force plates have not been zeroed out
% prior to collection

trials = dir(fullfile(datafolder, '*f_1.tsv'));


nTrials = size(trials,1);
pathname = datafolder;

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

subjectMass = mean(m);

disp('subject mass calculated successfully')

save subjectMass.mat subjectMass