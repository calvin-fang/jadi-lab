dur=[300 400 500 600];
iterations=500;

for i=1:length(dur)
    spontaneous_lfp_state_classifier_parallel_setup(dur(i),iterations)
end