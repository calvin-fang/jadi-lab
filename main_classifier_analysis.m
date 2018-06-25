iterations=500;
dur=300;
layer='all';
fineScale=0;
usedTstMBPID=[];
forest_size=300;


miscalcError=zeros(iterations,forest_size);
miscalcErrorScrambled=zeros(iterations,forest_size);

oobErr=zeros(iterations,forest_size);
oobErrScrambled=zeros(iterations,forest_size);


%not scrambled
scramble=0;
for i=1:iterations
    [err,oob,tstMBPID] = spontaneous_lfp_state_classifier(dur,layer,fineScale,scramble,usedTstMBPID,i,forest_size);
    usedTstMBPID=tstMBPID;
    miscalcError(i,:)=err;
    oobErr(i,:)=oob;
end

%scrambled
scramble=1;
for i=1:iterations
    [err,oob,tstMBPID] = spontaneous_lfp_state_classifier(dur,layer,fineScale,scramble,usedTstMBPID,i,forest_size);
    usedTstMBPID=tstMBPID;
    miscalcErrorScrambled(i,:)=err;
    oobErrScrambled(i,:)=oob;
end

outFile = ['~/project/ML_spontaneous_activity/output/duration_' num2str(dur) 'ms/layer_' num2str(layer) '/'];
fn = [outFile 'mean_sqrd_error_output.mat'];
save(fn, 'miscalcError', 'miscalcErrorScrambled', 'oobErr', 'oobErrScrambled');