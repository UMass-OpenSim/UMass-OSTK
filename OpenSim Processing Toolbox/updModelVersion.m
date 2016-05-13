%-------------------------------------------------------------------------% 
% udpModelVersion.m
% 
% This file updates the amputee models prior to version 30505. In the
% latest version, the user cannot specify a joint to be reversed, and must
% redefine the joint to switch the parent and child frames. 
% 
% before running, ensure the following folders are in the working
% directory:
%     IKErrors        Where marker errors are written for each trial
%     IKResults       Where kinematic results are  written for each trial
%     IKSetup         Contains generic setup file and trial specific setup 
%                     files are written
%     MarkerData      Contains marker trajectory files for each trial
%     ModelsScaled    Contains the models used in IK
%
% before running, modify script options cell appropriately
% 
% Written by Andrew LaPre 12/2015
% Last modified 2/4/2016
%
%-------------------------------------------------------------------------%

close all
clear all
clc

%% script options

% socket model selection 1 = normal, 2 = ghost (use ghost if the joint
mPath = '\Models\Scaled\3.3Models\';

% models to convert
model1 = 'A01_SocRef1_scaled.osim';
model2 = 'A01_SocRef2_scaled.osim';
model3 = 'A01_SocRef3_scaled.osim';
% new model names
Model1 = 'A01_Left_TTAmp_SR1_scaled.osim';
Model2 = 'A01_Left_TTAmp_SR2_scaled.osim';
Model3 = 'A01_Left_TTAmp_SR3_scaled.osim';

%% Pull OpenSim modeling classes and define ikTool

% Pull in the modeling classes straight from the OpenSim distribution
import org.opensim.modeling.*

%% main loop for conversion 
% updates model to version 30505
for ModelNumber = 1:3;
    
    % Get the model
    if ModelNumber == 1
        modelFile = ([mPath model1]);
        newModel = (['\Models\Scaled\4.0Models\' Model1]);
    end
    if ModelNumber == 2
        modelFile = ([mPath model2]);
        newModel = (['\Models\Scaled\4.0Models\' Model2]);
    end
    if ModelNumber == 3
        modelFile = ([mPath model3]);
        newModel = (['\Models\Scaled\4.0Models\' Model3]);
    end
    
    model = Model([pwd modelFile]);
    
    % make joint convention standard (probably doesn't matter)
    socket = model.getJointSet.get('socket');
    socket.set_reverse(false);
    
    % redefine the socket joint
    parentOld = socket.getParentFrameName();
    childOld = socket.getChildFrameName();
    socket.setParentFrameName(childOld)
    socket.setChildFrameName(parentOld)
    
%     socket.getParentFrameName()
%     socket.getChildFrameName()
    
    % save a new model to be used in IK and ID
    model.print([pwd newModel]);
        
    clear model socket parentOld childOld modelFile...
         ans  
end

fprintf('models successfully converted to version 30505 for use with OpenSim 4.0 API \n');

clear all