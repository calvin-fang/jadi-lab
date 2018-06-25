iterations=500;
dur=300;
layer='all';
fineScale=0;
forest_size=300;

%load the indices
durFold = ['~/project/ML_spontaneous_activity/output/duration_' num2str(dur) 'ms/'];
IDfn = [durFold 'state_classifier_duration_' num2str(dur) 'ms_with_' num2str(iterations) '_iterations_setup.mat']; 
if exist(IDfn,'file')
    load(IDfn)
else
    fprintf(1,'File %s does not exist !!!\n',IDfn);
    return;
end

%not scrambled
scramble=0;
for i=1:iterations
    spontaneous_lfp_state_classifier_parallel(dur,layer,fineScale,scramble,i,forest_size,trnMBPID,tstMBPID,sampleSz);
end

%scrambled
scramble=1;
for i=1:iterations
    spontaneous_lfp_state_classifier_parallel(dur,layer,fineScale,scramble,i,forest_size,trnMBPID,tstMBPID,sampleSz);
end



% outFile = ['~/project/ML_spontaneous_activity/output/duration_' num2str(dur) 'ms/layer_' num2str(layer) '/'];
% fn = [outFile 'mean_sqrd_error_output.mat'];
% save(fn, 'miscalcError', 'miscalcErrorScrambled', 'oobErr', 'oobErrScrambled');