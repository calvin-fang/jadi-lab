function [err,oobErr, tstMBPID] = spontaneous_lfp_state_classifier(dur,layer,fineScale,scramble,usedTstMBPID,iter,forest_size)
%{
random forest classifier for average power in 5 oscillatory bands with attentional state labels

input
dur: window duration
layer: which cortical layer, 'supra', 'input', 'infra', or 'all'
fineScale: 1 for fine attention detail, 0 for course attention detail
usedTstMBPID: previously used test indices
iter: current iteration

output
err: cumulative mean squared error
tstMBPID: currently test indices
outFile: folder directory
%}

switch(layer)
    case 'supra'
        layerInd=1:5;
    case 'input'
        layerInd=6:10;
    case 'infra'
        layerInd=11:15;
    case 'all'
        layerInd=1:15;
end
    
%Create output file to save training and testing results
%outFile = ['~/project/ML_spontaneous_activity/output/' attnCon dataFile];
%old file name

dataFile = ['MBP_' num2str(dur) '.mat'];

outFile = ['~/project/ML_spontaneous_activity/output/duration_' num2str(dur) 'ms/layer_' num2str(layer) '/'];

if exist(outFile,'dir')~=7
    mkdir(outFile);
end

if fineScale
    scale='fine_scale';
else
    scale='course_scale';
end


outfnPre = [outFile 'state_classifier_layer_' num2str(layer) '_duration_' num2str(dur) 'ms_' scale '_iteration_' num2str(iter) '_output_MBP_' num2str(dur)];

if scramble
    outfnPre = ['scrambled_' outfnPre];
end

outfn = [outfnPre '.mat'];

%if (exist(outfn,'file'))
%     fprintf(1,'File %s already exists !!!\n',outfn);
%     return
% end

% attempt to create a lock on the file
% 
% lockfn = [outfnPre '_lock.mat'];
% 
% if ~exist(lockfn,'file')
%      save(lockfn,'lockfn');
% else
%      return; % some other process has the file locked
% end

% load the data file
fn = ['/gpfs/ysm/pi/jadi/V4-Laminar-Spont-Clustering/Data/' dataFile];

if exist(fn,'file')
    load(fn)
else
    fprintf(1,'File %s does not exist !!!\n',fn);
    return;
end

%fineScale flag
%if on
%1.1 = just before saccade
%1.2 = just after saccade
%3 = drowsy
%4.1 = beginning of eye closed period
%4.2 = middle of eye closed period
%4.3 = end of eye closed period
%
%if off
%1=open eye
%3=drowsy
%4=closed eye
if ~fineScale
    courseScale=round(MBP_ALL(16,:));
    MBP_ALL(16,:)=courseScale;
end

% Pick 90% for trainig and 10% for testing.
%{
Jadi has function give it used test samples, then gives back new tested
samples, take samples are all - used
10% for testing, 90% for training
10% = new test
90% include used, just want to make sure the new test sample does not
overlap with used)

this code is wrapped in another
initially usedsamples =[]
then will loop multiple times
%}
allMBPID = 1:length(MBP_ALL);
allTstMBPID = setdiff(allMBPID, usedTstMBPID); %drop the used  test data
tstMBPIDIndx = randperm(length(allTstMBPID), floor(0.1*length(MBP_ALL)));
tstMBPID = allTstMBPID(tstMBPIDIndx);
trnMBPID = setdiff(allMBPID, tstMBPID);
sampleSz=length(tstMBPID);
tstSmplSz=length(trnMBPID);


EX=transpose(MBP_ALL(layerInd,trnMBPID)); %training data
LABEL=transpose(MBP_ALL(16,trnMBPID)); %training labels
TEST=transpose(MBP_ALL(layerInd,tstMBPID)); %test data
LABELhat=transpose((MBP_ALL(16,tstMBPID))); %test labels

sampleInd=randperm(sampleSz);
myIn=EX(sampleInd,:);
myOut=LABEL(sampleInd);

if scramble
    myOut = myOut(randperm(length(myOut)));
end


%clean up Nans.
myInNew = [];
myOutNew = [];
for l = 1:length(myOut)
    if(~isnan(sum(myIn(l,:))))
        myInNew(end+1,:) = myIn(l,:);
        myOutNew(end+1,:) = myOut(l,:);
    end
end
myIn = myInNew;
myOut = myOutNew;

bagger = TreeBagger(forest_size,myIn,myOut,'oobpred','on');

% Get the misclassification probability (mean squared error)
err = error(bagger,TEST,LABELhat,'mode','cumulative');
oobErr=oobError(bagger);
%figure(2); plot(error(bagger,TEST,LABELhat,'mode','cumulative')); hold on
save(outfn,'bagger','layer', 'sampleSz', 'tstSmplSz');

% delete(lockfn);
