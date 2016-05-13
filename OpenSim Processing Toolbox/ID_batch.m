%-------------------------------------------------------------------------% 
% AmpModel_ID_Batch.m
% 
% This function performs batch ID for the UMass transtibial amputee model
%
% 
% Written by Andrew LaPre 2/2016
% Last modified 5/4/2016
%
%-------------------------------------------------------------------------%

% close all
% clear all
% clc


function ID_batch(ID_options)

% load options
model_dir = ID_options.model_pth;
modelFile = ID_options.model;
IK_results_dir = ID_options.IKresults_pth;
grf_data_dir = ID_options.grfData_pth;
genericSetupPath = ID_options.setup_pth;
genericSetupForID = ID_options.genericSetupForID;
results_dir = ID_options.results_pth;
xForces = ID_options.extForces;

if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end



% set up paths
trialsForID = dir(fullfile(IK_results_dir, '*.mot'));
grfData = dir(fullfile(grf_data_dir, '*.mot'));


nTrials = size(trialsForID);

% Loop through the trials
for trial= 1:nTrials;
    
    % pull in the OpenSim modeling classes
    import org.opensim.modeling.*
    

    % load the model
    model = Model([model_dir modelFile]);

    % get coordinates and set defaults 
    coords = model.getCoordinateSet();

    if strcmp(ID_options.amputated_side,'left')
        coords.get('mtp_angle_r').setDefaultLocked(false);
    end
    if strcmp(ID_options.amputated_side,'right')
        coords.get('mtp_angle_l').setDefaultLocked(false);
    end

    coords.get('foot_flex').setDefaultLocked(false);
    coords.get('socket_tx').setDefaultLocked(true);
    coords.get('socket_ty').setDefaultLocked(false);
    coords.get('socket_tz').setDefaultLocked(true);
    coords.get('socket_flexion').setDefaultLocked(false);
    coords.get('socket_adduction').setDefaultLocked(false);
    coords.get('socket_rotation').setDefaultLocked(false);

    if strcmp(ID_options.activeAlignment,'Yes')
        coords.get('AAP_Proximal').setDefaultLocked(false);
        coords.get('AAP_Posterior').setDefaultLocked(false);
        coords.get('AAP_Anterior').setDefaultLocked(false);
        coords.get('Actuator_Rear').setDefaultLocked(false);
        coords.get('Ballscrew').setDefaultLocked(false);
    end
    
    model.initSystem();
    
    % Get the name of the motion file for this trial
    motionFile = trialsForID(trial).name;
    
    % Get the name of the grf file for this trial
%     grfFile = ([grf_data_dir grfData(trial).name]);
    grfFile = ([grf_data_dir grfData(trial).name]);
    
    % Create name of trial from .mot file name
    name = regexprep(motionFile,'_ik.mot','');
    fullpath = ([IK_results_dir motionFile]);
    
    % get motion data to determine time range
    motData = Storage(fullpath);
    
    % get first and last times
    initial_time = motData.getFirstTime();
    final_time = motData.getLastTime();
       
    % create external loads object and modify
    extLoads = ExternalLoads(model,([genericSetupPath xForces]));
    extLoads.setDataFileName(grfFile);
    extLoads.setExternalLoadsModelKinematicsFileName([IK_results_dir motionFile]);
    extLoads.print([genericSetupPath 'temp.xml']);
%     name2 = extLoads.getName

    % set up idTool for this trial
    idTool = InverseDynamicsTool([genericSetupPath genericSetupForID]);
    idTool.setModel(model);
    idTool.setStartTime(initial_time);
    idTool.setEndTime(final_time);
    idTool.setCoordinatesFileName([IK_results_dir motionFile]);
    idTool.setExternalLoadsFileName([genericSetupPath 'temp.xml']);
    idTool.setLowpassCutoffFrequency(6);
    idTool.setOutputGenForceFileName([name '_id.sto']);
    idTool.setResultsDir(results_dir);
        
    fprintf(['Calculating inverse dynamics for trial ' num2str(trial) ' of ' num2str(nTrials(1)) '\n'])
    
    
%     idTool.getCoordinatesFileName();
%     extLoads.getDataFileName();
    
    % Run ID
    idTool.run();
    
    
end

fprintf('ID processing complete!\n');

% clear all



