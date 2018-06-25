figure(1);
plot(transpose(error));
figure(2);
plot(transpose(errorScrambled));

meanError=mean(error); %averaged error
meanErrSc=mean(errorScrambled); %average scrambled error

STEError=std(error)/sqrt(size(error,2));
STEErrSc=std(errorScrambled)/sqrt(size(errorScrambled,2));

figure(3);
hold on
%plot average mean square error of all the iterations of random forest with standard error
plot(transpose(meanError),'b');
plot(transpose(meanError)-transpose(STEError),'b--');
plot(transpose(meanError)+transpose(STEError),'b--');

%plot average mean square error of all the iterations of random forest with standard error with labels scrambled 
plot(transpose(meanErrSc),'r');
plot(transpose(meanErrSc)-transpose(STEErrSc),'r--');
plot(transpose(meanErrSc)+transpose(STEErrSc),'r--');