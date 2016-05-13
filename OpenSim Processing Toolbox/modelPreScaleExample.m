% modelPreScaleExample.m
%
% This is an example of how to use the function modelPreScale.m to properly
% modify the residual limb length, socket reference frame, mass and inertia
% to be subject specific, dependent on the limb length ratio and socket
% reference ratio
%
% function depends on body and joint names in model, must have body 
% 'tibia_l_amputated' or "tibia_r_amputated', and joints 'ankle_r' or 
% 'ankle_l', 'pros_ankle' and 'socket'
%
% The modelPreScale.m function doesn't modify the mass or inertial 
% properties of the prosthesis
%
% Written by Andrew LaPre 4/3/2016
% Last modified 4/5/2016

clc
clear all
close all

% name of model and location in parent working directory
modelFolder = 'Models\Generic\';
% model = [modelFolder 'TTAmp_Left.osim'];
model = [modelFolder 'TTAmp_Right.osim'];

% amputated/intact-limb length ratio
lratio = .4;   
% socket reference percent (percent of residual limb length from distal
% point of limb to be used as reference frame location. 
% (0 equates to a reference at the distal end of the residual limb, 
%  1 equates to a reference at the proximal end of the residual limb)
SR = .25;

% OpenSim version: 3.3 or 4.0 (currently only works for 3.3)
ver = '3.3';

% run the function
newModel = modelPreScale(model,lratio,SR,ver);


% get model name and save new model file (or you can continue to work on
% the model
modelName = newModel.getName();
newModel.print([char(modelName) '_preScaled.osim']);