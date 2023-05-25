syncSF = 128;

numSyncSymbol = 7;
syncWord = (sqrt(1/2)+sqrt(-1/2)).*ones(numSyncSymbol,1);  %%% Define the synchronization symbol

% Generate 128 PN sequence
h1 = commsrc.pn('GenPloy',[1 0 0 0 1 1 1 1],'InitialStates',[0 0 0 0 0 1 0],'NumBitsOut',127);
m1 = generate(h1);
m1 = (0.5 - m1)*2;
DSPN = [m1;1];  %% zero pading to extend the 127-bit m sequence to a 128-bit PN sequence

spreadedSyncMatrix = syncWord * DSPN.';
spreadedSync = reshape(spreadedSyncMatrix.',[1,length(syncWord)*syncSF]);
spreadedSync