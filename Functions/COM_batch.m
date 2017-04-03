%-------------------------------------------------------------------------% 
% COM_batch.m
% 
% This function performs batch center of mass analysis for the UMass 
% transtibial amputee model
%
% Written by Andrew LaPre 2/2016
% Last modified 3/2017
%
% example function call:
% options.model_pth = ([pwd '\Models\']);
% options.model = 'A07_passive.osim';
% options.results_pth = ([pwd '\Analyses\Results\Passive\']);
% options.setup_pth = ([pwd '\Analyses\']);
% options.IKresults_pth = ([pwd '\IK\Results\Passive\']);
% COM_batch(options)
%-------------------------------------------------------------------------%

function COM_batch(options)


% Pull in the modeling classes straight from the OpenSim distribution

import org.opensim.modeling.*

% Go to the folder in the subject's folder where IK Results are
ik_results_folder = options.IKresults_pth;

% specify where setup files will be printed.
setupfiles_folder = options.setup_pth;

% specify where results will be printed.
results_folder = options.results_pth;
if ~exist(results_folder, 'dir')
    mkdir(results_folder);
end

model_dir = options.model_pth;
modelFile = options.model;

model = Model([model_dir modelFile]);

% Get and operate on the files

genericSetupForAn = [setupfiles_folder 'COM_analysisSetup.xml'];
analyzeTool = AnalyzeTool(genericSetupForAn);
analyzeTool.setModel(model);

% get the file names that match the ik_reults convention
% this is where consistent naming conventions pay off
trialsForAn = dir([ik_results_folder '*_ik.mot']);
nTrials =length(trialsForAn);

for trial= 1:nTrials;
    % get the name of the file for this trial
    motIKCoordsFile = trialsForAn(trial).name;
    
    % create name of trial from .trc file name
    name = regexprep(motIKCoordsFile,'_ik.mot','');
    
    % get .mot data to determine time range
    motCoordsData = Storage([ik_results_folder motIKCoordsFile]);
    
    % for this example, column is time
    initial_time = motCoordsData.getFirstTime();
    final_time = motCoordsData.getLastTime();
    
    analyzeTool.setName(name);
    analyzeTool.setResultsDir(results_folder);
    analyzeTool.setCoordinatesFileName([ik_results_folder motIKCoordsFile]);
    analyzeTool.setInitialTime(initial_time);
    analyzeTool.setFinalTime(final_time);   
    
    outfile = ['Setup_Analyze_' name '.xml'];
    analyzeTool.print([setupfiles_folder outfile]);
    
    fprintf(['Calculating COM Trajectory on trial # ' num2str(trial) '\n']);
    
    analyzeTool.run();
    
    % rename the out.log so that it doesn't get overwritten
%     copyfile('out.log',[results_folder name '_out.log'])
    
end
disp('batch COM analysis complete')