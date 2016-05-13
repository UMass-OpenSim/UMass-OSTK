% modelPreScale.m 

% Use this function to prescale an amputee model residual limb for a
% specific subject prior to scaling with the scale tool. The resulting
% model will have residual limb length, mass and inertial properties
% prescaled appropriately. When scaling with the scale tool using marker
% data, make sure to scale the residual limb with the scale factor
% calculated from the markers on the residual limb. Prosthesis mass/inertia
% will still need to be modified appropriately to reflect the subjects
% prosthesis
%
% see modelPreScaleExample.m 
%
% Need to modify to work with OpenSim 4.0
%
% Written by Andrew LaPre 3/29/2016
% Last Modified 4/5/2016

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
    p = Vec3(); % create empty OpenSim vector for intact ankle
    sc = Vec3(); % create empty OpenSim vector for socket loc in child 
    sp = Vec3(); % create empty OpenSim vector for socket loc in parent  
    
    if strcmp(char(socketParent),'tibia_l_amputated')
        
        joints.get('ankle_r').getLocationInParent(p);
        joints.get('socket').getLocationInParent(sp);
        
        pval(1) = p.get(0);
        pval(2) = p.get(1);
        pval(3) = p.get(2);
        spval(1) = sp.get(0);
        spval(2) = sp.get(1);
        spval(3) = sp.get(2);
        
        spMod = pval(2)*limbRatio-pval(2)*limbRatio*socketRefPlacement;
        ldiff = spMod - spval(2);
        scMod = ldiff;
        
        socketNewP = Vec3();
        socketNewP.set(0,spval(1))
        socketNewP.set(1,spMod)
        socketNewP.set(2,spval(3))
        socketNewC = Vec3();
        socketNewC.set(0,0)
        socketNewC.set(1,scMod)
        socketNewC.set(2,0)
        
        
        joints.get('socket').setLocationInParent(socketNewP)
        joints.get('socket').setLocationInChild(socketNewC)
        
        rMass = bodies.get('tibia_r').getMass();
        mass = rMass*limbRatio;
        
        mCenter = Vec3();
        bodies.get('tibia_r').getMassCenter(mCenter)
        massCenter = Vec3(mCenter.get(0),mCenter.get(1)*limbRatio,mCenter.get(2));
        inertiaMat = ArrayDouble(0.0,6);
        bodies.get('tibia_r').getInertia(inertiaMat)
        inertiaMat.set(0,inertiaMat.get(0)*limbRatio)
        inertiaMat.set(1,inertiaMat.get(1))
        inertiaMat.set(2,inertiaMat.get(2)*limbRatio)
        bodies.get('tibia_l_amputated').setMass(mass);
        bodies.get('tibia_l_amputated').setMassCenter(massCenter);
        bodies.get('tibia_l_amputated').setInertia(inertiaMat);
        
        name = regexprep(preScaleOptions.newName,'.osim','');
        modelNew.setName(name);
        modelNew.print([preScaleOptions.modelFolder preScaleOptions.newName]);
        
        disp('left transtibial amputee model prescaled for subject')

    elseif strcmp(char(socketParent),'tibia_r_amputated')

        joints.get('ankle_l').getLocationInParent(p);
        joints.get('socket').getLocationInParent(sp);
        
        pval(1) = p.get(0);
        pval(2) = p.get(1);
        pval(3) = p.get(2);
        spval(1) = sp.get(0);
        spval(2) = sp.get(1);
        spval(3) = sp.get(2);
        
        spMod = pval(2)*limbRatio-pval(2)*limbRatio*socketRefPlacement;
        ldiff = spMod - spval(2);
        scMod = ldiff;
        
        socketNewP = Vec3();
        socketNewP.set(0,spval(1))
        socketNewP.set(1,spMod)
        socketNewP.set(2,spval(3))
        socketNewC = Vec3();
        socketNewC.set(0,0)
        socketNewC.set(1,scMod)
        socketNewC.set(2,0)
        
        
        joints.get('socket').setLocationInParent(socketNewP)
        joints.get('socket').setLocationInChild(socketNewC)
        
        rMass = bodies.get('tibia_l').getMass();
        mass = rMass*limbRatio;
        
        mCenter = Vec3();
        bodies.get('tibia_l').getMassCenter(mCenter)
        massCenter = Vec3(mCenter.get(0),mCenter.get(1)*limbRatio,mCenter.get(2));
        inertiaMat = ArrayDouble(0.0,6);
        bodies.get('tibia_l').getInertia(inertiaMat)
        inertiaMat.set(0,inertiaMat.get(0)*limbRatio)
        inertiaMat.set(1,inertiaMat.get(1))
        inertiaMat.set(2,inertiaMat.get(2)*limbRatio)
        bodies.get('tibia_r_amputated').setMass(mass);
        bodies.get('tibia_r_amputated').setMassCenter(massCenter);
        bodies.get('tibia_r_amputated').setInertia(inertiaMat);

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
    disp('version not compatible with function')
end
