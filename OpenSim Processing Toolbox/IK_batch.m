%-------------------------------------------------------------------------% 
% IK_Batch.m
% 
% This function performs batch IK for models with transtibial amputation
% 
% 
% Written by Andrew LaPre 12/2015
% Last modified 5/4/2016
%
%-------------------------------------------------------------------------%

% close all
% clear all
% clc


function IK_batch(IK_options)

% load options
model_dir = IK_options.model_pth;
modelFile = IK_options.model;
trc_data_dir = IK_options.trcData_pth;
genericSetupPath = IK_options.setup_pth;
genericSetupForIK = IK_options.genericSetupForIK;
results_dir = IK_options.results_pth;

if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

% pull in the OpenSim modeling classes
import org.opensim.modeling.*


% set up paths
trialsForIK = dir(fullfile(trc_data_dir, '*.trc'));
     
% load the model
model = Model([model_dir modelFile]);

% get coordinates and set defaults that may be altered from scaling
coords = model.getCoordinateSet();

if strcmp(IK_options.amputated_side,'left')
    coords.get('mtp_angle_r').setDefaultLocked(false);
end
if strcmp(IK_options.amputated_side,'right')
    coords.get('mtp_angle_l').setDefaultLocked(false);
end
coords.get('foot_flex').setDefaultLocked(false);

% socket coordinates
coords.get('socket_tx').setDefaultLocked(true);
coords.get('socket_ty').setDefaultLocked(false);
coords.get('socket_tz').setDefaultLocked(true);
coords.get('socket_flexion').setDefaultLocked(false);
coords.get('socket_adduction').setDefaultLocked(false);
coords.get('socket_rotation').setDefaultLocked(false);

if strcmp(IK_options.activeAlignment,'Yes')
    coords.get('AAP_Proximal').setDefaultLocked(false);
    coords.get('AAP_Posterior').setDefaultLocked(false);
    coords.get('AAP_Anterior').setDefaultLocked(false);
    coords.get('Actuator_Rear').setDefaultLocked(false);
    coords.get('Ballscrew').setDefaultLocked(false);
end

model.initSystem();

ikTool = InverseKinematicsTool([genericSetupPath genericSetupForIK]);
ikTool.setModel(model);


nTrials = size(trialsForIK);

% Loop through the trials
for trial= 1:nTrials;

    % Get the name of the file for this trial
    markerFile = trialsForIK(trial).name;

    % Create name of trial from .trc file name
    name = regexprep(markerFile,'.trc','');
    fullpath = ([trc_data_dir markerFile]);

    % Get trc data to determine time range
    markerData = MarkerData(fullpath);

    % Get initial and intial time 
    initial_time = markerData.getStartFrameTime();
    final_time = markerData.getLastFrameTime();

    % Setup ikTool for this trial
    ikTool.setName(name);
    ikTool.setMarkerDataFileName(fullpath);
    ikTool.setStartTime(initial_time);
    ikTool.setEndTime(final_time);
    ikTool.setOutputMotionFileName([results_dir '\' name '_ik.mot']);

    % Save the settings in a setup file
    outfile = ['Setup_IK_' name '.xml'];
    ikTool.print([genericSetupPath outfile]);

    % print progress to command window
    fprintf(['Performing IK on trial # ' num2str(trial) '\n']);

    % Run IK
    ikTool.run();   

end
        

fprintf('IK processing complete!\n');

% clear all


