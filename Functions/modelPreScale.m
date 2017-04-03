%-------------------------------------------------------------------------% 
% modelPreScale.m
%
% Use this function to prescale an amputee model residual limb for a
% specific subject prior to scaling with the scale tool. The resulting
% model will have residual limb length, mass and inertial properties
% prescaled appropriately. When scaling with the scale tool using marker
% data, make sure to scale the residual limb with the scale factor
% calculated from the markers on the residual limb. Prosthesis mass/inertia
% will still need to be modified appropriately to reflect the subjects
% prosthesis
%
% will not yet work with OpenSim 4.0
%
% Written by Andrew LaPre 3/29/2016
% Last Modified 3/2017
%
% example function call:
% options.modelFolder = 'Models\';
% options.limbRatio = .45;                            % amputated/intact-limb length ratio
% options.SocketRefPlacement = .25;                   % from distal tip
% options.version = '3.3';                            % OpenSim version: 3.3 or 4.0
% options.model = 'TTAmp_Left_passive.osim';          % generic model name
% options.newName = 'A03_passive_prescaled2.osim';    % new model name 
% modelPreScale(options);  
%-------------------------------------------------------------------------% 

function modelPreScale(preScaleOptions)



preScaleOptions.modelFolder;
modelFile = [preScaleOptions.modelFolder preScaleOptions.model];
limbRatio = preScaleOptions.limbRatio;
socketRefPlacement = preScaleOptions.SocketRefPlacement;
version = preScaleOptions.version;

import org.opensim.modeling.*

modelNew = Model(modelFile);

state = modelNew.initSystem();

% ver = modelNew.getVersion()
bodies = modelNew.getBodySet();
joints = modelNew.getJointSet();

% code for 3.3
if strcmp(version,'3.3')
    socketParent = joints.get('socket').getParentBody();
    ankleParentOrig = Vec3();  % create empty OpenSim vector for intact ankle in parent
    socketParentOrig = Vec3();    % create empty OpenSim vector for socket loc in parent  
    
    if strcmp(char(socketParent),'tibia_l_amputated')
        
        % get intact ankle location in its parent frame
        joints.get('ankle_r').getLocationInParent(ankleParentOrig);
        % get socket joint in its parent frame
        joints.get('socket').getLocationInParent(socketParentOrig);
        % get joint components and store in array
        ankleParOrigComp(1) = ankleParentOrig.get(0);     % original ankle joint x
        ankleParOrigComp(2) = ankleParentOrig.get(1);     % original ankle joint y
        ankleParOrigComp(3) = ankleParentOrig.get(2);     % original ankle joint z
        socketParOrigComp(1) = socketParentOrig.get(0);   % original socket joint x
        socketParOrigComp(2) = socketParentOrig.get(1);   % original socket joint y
        socketParOrigComp(3) = socketParentOrig.get(2);   % original socket joint z
        
        % calculate modified joint y components
        socketParMod = ankleParOrigComp(2)*limbRatio-ankleParOrigComp(2)*limbRatio*socketRefPlacement;
        socketChildMod = socketParMod - socketParOrigComp(2);
        
        % create vector and store new components
        socketNewP = Vec3();
        socketNewP.set(0,socketParOrigComp(1))
        socketNewP.set(1,socketParMod)
        socketNewP.set(2,socketParOrigComp(3))
        socketNewC = Vec3();
        socketNewC.set(0,0)
        socketNewC.set(1,socketChildMod)
        socketNewC.set(2,0)
        
        % set new components for model joints
        joints.get('socket').setLocationInParent(socketNewP)
        joints.get('socket').setLocationInChild(socketNewC)
        
        %-----------------------MASS AND INERTIA--------------------------%
        massIntact = bodies.get('tibia_r').getMass();
        massAmp = massIntact*limbRatio;
        massCenterIntact = Vec3();
        bodies.get('tibia_r').getMassCenter(massCenterIntact)
        massCenterAmp = Vec3(massCenterIntact.get(0),massCenterIntact.get(1)*limbRatio,massCenterIntact.get(2));
        inertiaMat = ArrayDouble(0.0,6);
        bodies.get('tibia_r').getInertia(inertiaMat)
        inertiaMat.set(0,inertiaMat.get(0)*(limbRatio^3))
        inertiaMat.set(1,inertiaMat.get(1)*(limbRatio^3))
        inertiaMat.set(2,inertiaMat.get(2)*(limbRatio^3))
        bodies.get('tibia_l_amputated').setMass(massAmp);
        bodies.get('tibia_l_amputated').setMassCenter(massCenterAmp);
        bodies.get('tibia_l_amputated').setInertia(inertiaMat);
        
        % rename the modified model
        name = regexprep(preScaleOptions.newName,'.osim','');
        modelNew.setName(name);
        modelNew.print([preScaleOptions.modelFolder preScaleOptions.newName]);
        
        disp('left transtibial amputee model prescaled for subject')

    elseif strcmp(char(socketParent),'tibia_r_amputated')

        % get intact ankle location in its parent frame
        joints.get('ankle_l').getLocationInParent(ankleParentOrig);
        % get socket joint in its parent frame
        joints.get('socket').getLocationInParent(socketParentOrig);
        
        % get joint components and store in array
        ankleParOrigComp(1) = ankleParentOrig.get(0);
        ankleParOrigComp(2) = ankleParentOrig.get(1);
        ankleParOrigComp(3) = ankleParentOrig.get(2);
        socketParOrigComp(1) = socketParentOrig.get(0);
        socketParOrigComp(2) = socketParentOrig.get(1);
        socketParOrigComp(3) = socketParentOrig.get(2);
        
        % calculate modified joint y components
        socketParMod = ankleParOrigComp(2)*limbRatio-ankleParOrigComp(2)*limbRatio*socketRefPlacement;
        socketChildMod = socketParMod - socketParOrigComp(2);
        
        % create vector and store new components
        socketNewP = Vec3();
        socketNewP.set(0,socketParOrigComp(1))
        socketNewP.set(1,socketParMod)
        socketNewP.set(2,socketParOrigComp(3))
        socketNewC = Vec3();
        socketNewC.set(0,0)
        socketNewC.set(1,socketChildMod)
        socketNewC.set(2,0)
        
        
        % set new components for model joints
        joints.get('socket').setLocationInParent(socketNewP)
        joints.get('socket').setLocationInChild(socketNewC)
        
        %-----------------------MASS AND INERTIA--------------------------%
        massIntact = bodies.get('tibia_l').getMass();
        massAmp = massIntact*limbRatio;
        massCenterIntact = Vec3();
        bodies.get('tibia_l').getMassCenter(massCenterIntact)
        massCenterAmp = Vec3(massCenterIntact.get(0),massCenterIntact.get(1)*limbRatio,massCenterIntact.get(2));
        inertiaMat = ArrayDouble(0.0,6);
        bodies.get('tibia_l').getInertia(inertiaMat)
        inertiaMat.set(0,inertiaMat.get(0)*(limbRatio^3))
        inertiaMat.set(1,inertiaMat.get(1)*(limbRatio^3))
        inertiaMat.set(2,inertiaMat.get(2)*(limbRatio^3))
        bodies.get('tibia_r_amputated').setMass(massAmp);
        bodies.get('tibia_r_amputated').setMassCenter(massCenterAmp);
        bodies.get('tibia_r_amputated').setInertia(inertiaMat);

        % rename the modified model
        modelNew.setName(preScaleOptions.newName);
        modelNew.print([preScaleOptions.modelFolder preScaleOptions.newName]);
        
        disp('right transtibial amputee model prescaled for subject')
        
        

    else
        disp('model not compatible with function')
    end

% code for 4.0
elseif strcmp(version,'4.0')
    socketParentFrame = joints.get('socket').getParentFrame();
    if strcmp(char(socketParentFrame),'tibia_l_amputated_offset')

        base = socketParentFrame.findBaseFrame();
%         socketParentFrame.findLocationInAnotherFrame(state, [0,0,0],base)
        X = socketParentFrame.findTransformInBaseFrame()
%         y = X(2)

        disp('left transtibial amputee model prescaled for subject')

    elseif strcmp(char(socketParentFrame),'tibia_r_amputated_offset')


        disp('right transtibial amputee model prescaled for subject')

    else
        disp('model not compatible with function')
    end
    
else
    disp('opensim version not compatible with function')
end
