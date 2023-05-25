%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%参数列表
%turbo码率:1/2 size:3360bit
%crc:16
%扩频因子:4,128
%data rate:625kbps 19.5kbps
%qpsk
%上采率4
%chip rate:2.5M
%RRC滚降系数:0.3
%带宽:3.25M
%采样率:10M = 上采*chip rate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 1: Simulation parameters set up %%%
Rb=6.25*10e3;%信源速率
t=10;%仿真时间10s
numSim = 20;%仿真次数,暂时不用
SNR=-15:1:-10;
SF=4;%扩频因子
M=4;%QPSK调制

bitNum=Rb*t;

upSample = 4;
syncSF = 128;   %% Spread factor of pilot symbols always is 128
chipRate = 2.5e6;
lengthZeroPad = 40*syncSF;  %% zero padding to the synchronization signal to isolate two synchronization headers.
%% data gen
data = randi([0 1],bitNum,1);  %%% Random message data
%% CRC
CRCPoly = [16 12 5 0];  %%% The generate polynomial for CRC-16
hCRC = comm.CRCGenerator('Polynomial',CRCPoly);  %%% The object to generate CRC
dataBlockCRC = step(hCRC,data);    %%% Excute CRC coding
%% Turbo
s = RandStream('mt19937ar','Seed',11);  %%% Define the random stream
intrlvrIndices = randperm(s,messageLen);   %%% Define the interleaver pattern in Turbo coder
%%% Define the Turbo encoder and decoder object
hTEnc = comm.TurboEncoder('TrellisStructure',poly2trellis(4,...
    [13 15],13),'InterleaverIndices',intrlvrIndices);
dataTurbo = step(hTEnc,dataBlockCRC);   %% Turbo Encoder
%% QPSK
dataMod=qammod(dataTurbo,M);
%% Spread spectrum
% Generate 128 PN sequence
h1 = commsrc.pn('GenPloy',[1 0 0 0 1 1 1 1],'InitialStates',[0 0 0 0 0 1 0],'NumBitsOut',127);
m1 = generate(h1);
m1 = (0.5 - m1)*2;
PN = [m1;1];  %% zero pading to extend the 127-bit m sequence to a 128-bit PN sequence
spreadedDataMatrix = dataMod*PN;  %% spreading of data symbols
spreadedData = reshape(spreadedDataMatrix.',[1,length(modSignal)*SF]);
%% Upsample
upSampleSignal = zeros(1,length(spreadedData)*upSample);
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

spreadedSyncMatrix = syncWord * DSPN.';
spreadedSync = reshape(spreadedSyncMatrix.',[1,length(syncWord)*syncSF]);

upSampleSync = zeros(1,length(spreadedSync)*upSample);
index = 0;
for k = 1:length(spreadedSync)
    upSampleChip = [spreadedSync(k) zeros(1,upSample-1)];
    upSampleSync(index+1:index+length(upSampleChip)) = upSampleChip;
    index = index+length(upSampleChip);
end;
upSampleSync = [upSampleSync zeros(1,lengthZeroPad)];  %%% zero padding

