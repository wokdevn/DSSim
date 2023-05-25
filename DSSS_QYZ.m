%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name：DSSS_QYZ
% Description：直接序列扩频，信源速率10kbps，扩频因子64，调制方式BPSK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;clear;close all
%%
us=1e-6;MHz=1e+6;KHz=1e+3;c=3e+8;GHz=1e+9;
%% 仿真参数
Rb=10e+3;%信源速率10kbps
t=10;%仿真时间1s
SF=64;%扩频因子
M=2;%调制阶数：2，采用BPSK调制

fs=SF*10*KHz;%设置采样率和信源速率的64倍相同，即每个比特进行一次采样.SF=64时，载频为640KHz
fc=0.5*fs;%满足采样间隔
Ts=1/fs;
bitNum=Rb*t;
t_seq=linspace(Ts,t,SF*bitNum);

channel='AWGN';%'AWGN'or'Inteference'
SNR=-15:1:-10;
%SNR=0;
Iterf=[80,160,320]*KHz;
%% 消息生成
data=randi([0,1],1,bitNum);
message=qammod(data,M);
%% 扩频序列
m_temp=m_sequence([1,0,0,0,0,1,1]);%固定的本源多项式
%m序列只能生成2^n-1长度的扩频码，但题目要求64，故补一个0
dsss_seq=2*[0,m_temp]-1;%扩频序列映射为+-1
%a=sum(dsss_seq);
rho=xcorr(dsss_seq,'coeff');
figure(1)
plot(rho)
xlabel('相关位置')
xlim([1,SF*2]);
ylabel('相关系数')
title('（1）扩频码的自相关性能')
%% 扩频
data_map=dsss_seq.'*message;
signal=reshape(data_map,1,SF*length(message)).*exp(1i*2*pi*fc*t_seq);
%power_signal=mean(abs(signal).^2);
%% 过高斯信道
if strcmp(channel,'AWGN')
    BER=zeros(1,length(SNR));
    for i=1:length(SNR)
        receive=awgn(signal,SNR(i));%添加高斯白噪声
        down_carrier=receive.*exp(-2*1i*pi*fc*t_seq);
        receive_map=reshape(down_carrier,SF,length(message));
        receive_message=dsss_seq*receive_map/SF;%解扩频
        receive_data=qamdemod(receive_message,M);
        BER(i)=sum((receive_data-data)~=0)/bitNum;
    end
    figure(2)
    semilogy(SNR,BER);
    xlabel('信噪比SNR（dB）')
    ylabel('误比特率')
    title('（2）在高斯信道下的误码率性能')
elseif strcmp(channel,'Inteference')
    figure(3)
    for j=1:length(Iterf)
        BER=zeros(1,length(SNR));
        for i=1:length(SNR)
            receive=awgn(signal,SNR(i))+exp(1i*2*pi*Iterf(j)*t_seq);%添加高斯白噪声和干扰
            down_carrier=receive.*exp(-2*1i*pi*fc*t_seq);
            receive_map=reshape(down_carrier,SF,length(message));
            receive_message=dsss_seq*receive_map/SF;%解扩频
            receive_data=qamdemod(receive_message,M);
            BER(i)=sum((receive_data-data)~=0)/bitNum;
        end
        semilogy(SNR,BER);
        hold on
    end
    legend('80KHz单音干扰','160KHz单音干扰','320KHz单音干扰')
    xlabel('信噪比SNR（dB）')
    ylabel('误比特率')
    title('（3）各种干扰信道下的误码率性能（单音）')
end




