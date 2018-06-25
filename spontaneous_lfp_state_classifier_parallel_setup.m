function []=spontaneous_lfp_state_classifier_parallel_setup(dur,iterations)

%For spontaneous_lfp_state_classifier_parallel
%will both set up input file names and indices


dataFile = ['MBP_' num2str(dur) '.mat'];
% load the data file
fn = ['/gpfs/ysm/pi/jadi/V4-Laminar-Spont-Clustering/Data/' dataFile];

if exist(fn,'file')
    load(fn)
else
    fprintf(1,'File %s does not exist !!!\n',fn);
    return;
end


% allDataID = 1:length(data);
% alltstDataID=setdiff(allDataID, usedTstDataID); %dropping used test data
% tstDataIDIndx = randperm(length(allTstDataID), floor(0.1*length(data)));
% tstDataID = allTstDataID(tstDataIDIndx);
% trnDataID = setdiff(allDataID, tstDataID);
% sampleSz=length(tstDataID);
% tstSmplSz=length(trnDataID);

percentTest = 0.1;
%10% used for test, 90% for training

%initiate matrices
tstMBPID = zeros(iterations,floor(percentTest*length(MBP_ALL))); 
trnMBPID = zeros(iterations,ceil((1-percentTest)*length(MBP_ALL)));

%create new indices, avoiding overlap
allMBPID = 1:length(MBP_ALL);
for l = 1:iterations
        
    if l==1
        allTstMBPID = allMBPID;
        tstMBPIDIndx = randperm(length(allTstMBPID), floor(percentTest*length(MBP_ALL))); %initiate first row of indices
    else
        allTstMBPID = setdiff(allMBPID, tstMBPID(l-1,:)); %drop the previously used test indices
        tstMBPIDIndx = randperm(length(setdiff(allMBPID, tstMBPID(l-1,:))), floor(percentTest*length(MBP_ALL)));
    end
    
    tstMBPID(l,:) = allTstMBPID(tstMBPIDIndx);
    trnMBPID(l,:) = setdiff(allMBPID,tstMBPID(l,:));
end

%check for repeated rows of indices
[uniqueTstMBPID,uniqueInd]=unique(sort(tstMBPID,2),'rows','stable');
while size(uniqueTstMBPID,1)~=size(tstMBPID,1)
    repeatedIndices=setdiff([1:iterations],uniqueInd);
    %repeat creating indices for repeated segments
    for l = repeatedIndices        
        if l==1
            allTstMBPID = allMBPID;
            tstMBPIDIndx = randperm(length(allTstMBPID), round(percentTest*length(MBP_ALL))); %initiate first row of indices
        else
            allTstMBPID = setdiff(allMBPID, tstMBPID(l-1,:)); %drop the previously used test indices
            tstMBPIDIndx = randperm(length(setdiff(allMBPID, tstMBPID(l-1,:))), round(percentTest*length(MBP_ALL)));
        end

        tstMBPID(l,:) = allTstMBPID(tstMBPIDIndx);
        trnMBPID(l,:) = setdiff(allMBPID,tstMBPID(l,:));
    end
    [uniqueTstMBPID,uniqueInd]=unique(sort(tstMBPID,2),'rows','stable');
end

sampleSz=length(tstMBPID);
tstSmplSz=length(trnMBPID);

%saving file
outFile = ['~/project/ML_spontaneous_activity/output/duration_' num2str(dur) 'ms/'];
if exist(outFile,'dir')~=7
    mkdir(outFile);
end

outfn = [outFile 'state_classifier_duration_' num2str(dur) 'ms_with_' num2str(iterations) '_iterations_setup.mat'];

if (exist(outfn,'file'))
    fprintf(1,'File %s already exists !!!\n',outfn);
    return
end

save(outfn,'tstMBPID','trnMBPID','sampleSz','tstSmplSz');

% wwhere tst and trnMBPID have to go into remember
% EX=transpose(MBP_ALL(layerInd,firstTrnMBPID)); %training data
% LABEL=transpose(MBP_ALL(16,firstTrnMBPID)); %training labels
% TEST=transpose(MBP_ALL(layerInd,firstTstMBPID)); %test data
% LABELhat=transpose((MBP_ALL(16,firstTstMBPID))); %test labels
