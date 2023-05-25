%%% Step 1: Simulation parameters set up %%%
numSim = 20;
SNR = 10;
upSample = 128;
syncSF = 128;   %% Spread factor of pilot symbols always is 128
chipRate = 2.5e6;

%% data gen
messageLen = 27*4;    %%% Message size. 
messageBlock = randi([0 1],messageLen,1);  %%% Random message data 

%% CRC
CRCPoly = [16 12 5 0];  %%% The generate polynomial for CRC-16
hCRC = comm.CRCGenerator('Polynomial',CRCPoly);  %%% The object to generate CRC
dataBlockCRC = step(hCRC,messageBlock);    %%% Excute CRC coding

%% Turbo
s = RandStream('mt19937ar','Seed',11);  %%% Define the random stream
intrlvrIndices = randperm(s,messageLen);   %%% Define the interleaver pattern in Turbo coder
%%% Define the Turbo encoder and decoder object
hTEnc = comm.TurboEncoder('TrellisStructure',poly2trellis(4,...
        [13 15],13),'InterleaverIndices',intrlvrIndices);
encodedData = step(hTEnc,dataBlockCRC);   %% Turbo Encoder
    
%% QPSK
hQPSKMod = comm.QPSKModulator('BitInput',true);
modSignal = step(hQPSKMod,encodedData);

%% Upsample
upSampleSignal = zeros(1,length(modSignal)*upSample);
for m = 1:length(modSignal)
    upSampleSignal((m-1)*upSample+1:m*upSample) = modSignal(m);
end;

%%% Construct Frame
%% pilot
pilot = [0 1];

upSamplePilot = zeros(1,length(pilot)*syncSF);
for m = 1:length(pilot)
   upSamplePilot((m-1)*syncSF+1 : m*syncSF) = pilot(m); 
end



%% 1.1 Set up the modulation and spreading parameters
numSyncSymbol = 7;
syncWord = (sqrt(1/2)+sqrt(-1/2)).*ones(numSyncSymbol,1);  %%% Define the synchronization symbol

% Generate 128 PN sequence
h1 = commsrc.pn('GenPloy',[1 0 0 0 1 1 1 1],'InitialStates',[0 0 0 0 0 1 0],'NumBitsOut',127);
m1 = generate(h1);
m1 = (0.5 - m1)*2;
DSPN = [m1;1];  %% zero pading to extend the 127-bit m sequence to a 128-bit PN sequence 


