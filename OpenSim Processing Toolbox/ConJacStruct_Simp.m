%ConJacStruct_Simp
%
% This script constructs the Constraint Jacobian matrix structure for a 2D 
% transtibial amputee model, for a full gait cycle. 
% This can be modified for more options, to build for other models and
% constraints.
%
% Written by Andrew LaPre

close all 
clear all
% clc

%% setup

% modify this block to change the structure
nNodes = 101;
nCoord = 12;
nMusc = 16;
tFinal = 1; % 1 for yes 0 for no for a final time constraint
% prescribe correlation arrays 
pelvTiltG = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];   % all muscles and pelvis
pelvTxG = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];     % all muscles and pelvis
pelvTyG = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];     % all muscles and pelvis
rHipG = [1,2,3,4,5,6,7,8,9];        % muscles that affect right hip
rKneeG = [1,2,5,6,7,8,9];           % muscles that affect right knee
rAnkleG = [7,8,9];                  % muscles that affect right ankle
lHipG = [10,11,12,13,14,15,16];     % muscles that affect left hip
lKneeG = [10,11,14,15,16];          % muscles that affect left knee


%% first a setup routine

% preallocate constraint jacobian matrix
nSteps = nNodes - 1;
cols = nNodes*nCoord + nNodes*nCoord + 2*nMusc*nNodes + nMusc*nNodes + tFinal;
rows = nCoord*nSteps + nCoord*nSteps + 2*nMusc*nSteps;
Jtemp = zeros(rows,cols);

% construct matrix correlating muscle accelerations with coordinates
CoordMuscMat = zeros(nMusc,nCoord);
for musc = 1:nMusc
    for coord = 1:nMusc
        if ismember(musc,pelvTiltG)
            CoordMuscMat(musc,1) = 1;       % pelvis tilt
        end
        if ismember(musc,pelvTxG)
            CoordMuscMat(musc,2) = 1;       % pelvis tx
        end
        if ismember(musc,pelvTyG)
            CoordMuscMat(musc,3) = 1;       % pelvis ty
        end
        if ismember(musc,rHipG)
            CoordMuscMat(musc,4) = 1;       % right hip
        end
        if ismember(musc,rKneeG)
            CoordMuscMat(musc,5) = 1;       % right knee
        end
        if ismember(musc,rAnkleG)
            CoordMuscMat(musc,6) = 1;       % right ankle
        end
        if ismember(musc,lHipG)
            CoordMuscMat(musc,8) = 1;       % left hip
        end
        if ismember(musc,lKneeG)
            CoordMuscMat(musc,9) = 1;       % left knee
        end
    end
end

% this figure just shows quickly the sparsity of the sparsity matrix
figure 
spy(CoordMuscMat)
title('Muscle/Coordinate Correlation Matrix Structure')
ylabel('muscles: adot/ldot alternating')
xlabel('coordinate positions')

%% construct constraint jacobian

% build jacobian structure for: Con-vel,X-pos 
col = 0;
row = 0;
coord = 1;
while coord < nCoord+1
    col = col+1;
    inc = 1;
    while inc < nNodes
        row = row+1;    
        Jtemp(row,col) = 1;
        col = col+1;
        inc = inc+1;
        Jtemp(row,col) = 1;
    end
    coord = coord + 1;
end

% build jacobian structure for: Con-vel,X-vel 
row = 0;
coord = 1;
while coord < nCoord+1
    col = col+1;
    inc = 1;
    while inc < nNodes
        row = row+1;    
        col = col+1;
        inc = inc+1;
        Jtemp(row,col) = 1;
    end
    coord = coord + 1;
end
rowTemp2 = row;

% build jacobian structure for: Con-acc,X-pos
acc = 1;
while acc < nCoord+1
    rowTemp = row;
    col = 0;
    coord = 1;
    while coord < nCoord+1
        col = col+1;
        inc = 1;
        row = rowTemp;
        while inc < nNodes
            row = row+1;    
            col = col+1;
            inc = inc+1;
            Jtemp(row,col) = 1;
        end
        coord = coord + 1;
    end
    acc = acc+1;
end

% build jacobian structure for: Con-acc,X-vel 
acc = 1;
row = rowTemp2;
colTemp = col;
while acc < nCoord+1
    rowTemp = row;
    coord = 1;
    col = colTemp;
    while coord < nCoord+1
        col = col+1;
        inc = 1;
        row = rowTemp;
        while inc < nNodes
            row = row+1; 
            if acc == coord
                Jtemp(row,col) = 1;
            end
            col = col+1;
            inc = inc+1;
            Jtemp(row,col) = 1;
        end
        coord = coord + 1;
    end
    acc = acc+1;
end

% build jacobian structure for: Con-acc,X-musc 
acc = 1;
row = rowTemp2;
colTemp = col;
while acc < nCoord+1
    rowTemp = row;
    musc = 1;
    col = colTemp;
    while musc < nMusc+1
        col = col+nNodes+1;
        inc = 1;
        row = rowTemp;
        while inc < nNodes
            row = row+1;
            col = col+1;
            inc = inc+1;
            Jtemp(row,col) = 1;
        end
        musc = musc + 1;
    end
    
    acc = acc+1;
end


% build jacobian structure for: Con-musc_dot,X-pos 
muscDot = 1;
rowTemp2 = row;
col = 0;
while muscDot < nMusc + 1
    rowTemp = row;
    coord = 1;
    col = 0;
    while coord < nCoord + 1;
        inc = 1;
        row = rowTemp;
        row = row+nNodes-1;
        col = col+1;
        while inc < nNodes
            row = row+1;
            col = col+1;
            inc = inc+1;
            if CoordMuscMat(muscDot,coord) == 1 
                Jtemp(row,col) = 1;
            end
        end
        coord = coord + 1;
    end
    muscDot = muscDot + 1;
end

% build jacobian structure for: Con-musc_dot,X-musc
muscDot = 1;
row = rowTemp2;
col = col + nNodes*nCoord;
colTemp = col;
while muscDot < nMusc*2 + 1
    rowTemp = row;
    musc = 1;
    col = colTemp; 
    while musc < nMusc*2 + 1
        inc = 1;
        row = rowTemp;
        col = col+1;
        while inc < nNodes
            row = row+1;
            if musc == muscDot
                Jtemp(row,col) = 1;
            end
            col = col+1;
            inc = inc+1;
            if musc == muscDot
                Jtemp(row,col) = 1; 
                if mod(musc,2) == 0
                    Jtemp(row,col-nNodes) = 1;
                end
            end
        end
        musc = musc + 1;
    end
    muscDot = muscDot + 1;
end

% build jacobian structure for: Con-musc_dot,X-controls 
muscDot = 1;
row = rowTemp2;
colTemp = col;
while muscDot < nMusc + 1;
    rowTemp = row;
    cont = 1;
    col = colTemp;
    while cont < nMusc + 1
        inc = 1;
        row = rowTemp;
        col = col+1;
        while inc < nNodes
            row = row+1;
            col = col+1;
            if cont == muscDot
                Jtemp(row,col) = 1;
            end
            inc = inc + 1;
        end
        row = row + nNodes - 1;
        cont = cont + 1;
    end    
    muscDot = muscDot + 1;
end

% build final time constraint jacobian structure
if tFinal == 1
    c = size(Jtemp,2);
    r = 1;
    while r < row + 1;
        Jtemp(r,c) = 1;
        r = r + 1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% build jacobian structure for other constraints

% build periocidty constraint jacobian structure for: full gait cycle
col = 0;
nPerCon = 2*nCoord + 2*nMusc + nMusc;
PerCon = 1;
while PerCon < nPerCon + 1;
    row = row + 1;
    col = col + 1;
    Jtemp(row,col) = 1;
    col = col + nNodes-1;
    Jtemp(row,col) = 1;
    if PerCon == 2
        Jtemp(row,size(Jtemp,2)) = 1;
    end
    PerCon = PerCon + 1;
end

% build jacobian structure for: initial horizontal position
row = row + 1;
Jtemp(row,(nNodes+1)) = 1;


% work on initial heel constraint
col = 1;
row = row + 1;
coord = 1;
while coord <= nCoord
    if coord == 1 || coord == 3
        Jtemp(row,col) = 1;
    end
    if coord >= 4 && coord <= 12
        Jtemp(row,col) = 1;
    end
    col = col + nNodes+1;
    coord = coord + 1;
end

% build periocidy constraint jacobian structure to force reciprical hip motion 
col = 1;
row = row + 1;
coord = 1;
while coord <= nCoord
    if coord == 4 || coord == 8
        Jtemp(row,col) = 1;
    end
    col = col + nNodes+1;
    coord = coord + 1;
end
col = 1;
row = row + 1;
coord = 1;
midNode = round(nNodes/2);
while coord <= nCoord
    if coord == 4 || coord == 8
        Jtemp(row,col+midNode-1) = 1;
        Jtemp(row,col+midNode) = 1;
    end
    col = col + nNodes+1;
    coord = coord + 1;
end

%% plot the jacobian structure

figure
spy(Jtemp)
title(['Jacobian Sparsity Structure for ' num2str(nNodes) ' Nodes'])
xlabel('Variables (x)')
ylabel('Conastraints (c)')

%% cleanup and save

clear Jstruct
Jstruct = Jtemp;
save Jacobian_Structure Jstruct


