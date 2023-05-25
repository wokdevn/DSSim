%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name��DSSS_QYZ
% Description��ֱ��������Ƶ����Դ����10kbps����Ƶ����64�����Ʒ�ʽBPSK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;clear;close all
%%
us=1e-6;MHz=1e+6;KHz=1e+3;c=3e+8;GHz=1e+9;
%% �������
Rb=10e+3;%��Դ����10kbps
t=10;%����ʱ��1s
SF=64;%��Ƶ����
M=2;%���ƽ�����2������BPSK����

fs=SF*10*KHz;%���ò����ʺ���Դ���ʵ�64����ͬ����ÿ�����ؽ���һ�β���.SF=64ʱ����ƵΪ640KHz
fc=0.5*fs;%����������
Ts=1/fs;
bitNum=Rb*t;
t_seq=linspace(Ts,t,SF*bitNum);

channel='AWGN';%'AWGN'or'Inteference'
SNR=-15:1:-10;
%SNR=0;
Iterf=[80,160,320]*KHz;
%% ��Ϣ����
data=randi([0,1],1,bitNum);
message=qammod(data,M);
%% ��Ƶ����
m_temp=m_sequence([1,0,0,0,0,1,1]);%�̶��ı�Դ����ʽ
%m����ֻ������2^n-1���ȵ���Ƶ�룬����ĿҪ��64���ʲ�һ��0
dsss_seq=2*[0,m_temp]-1;%��Ƶ����ӳ��Ϊ+-1
%a=sum(dsss_seq);
rho=xcorr(dsss_seq,'coeff');
figure(1)
plot(rho)
xlabel('���λ��')
xlim([1,SF*2]);
ylabel('���ϵ��')
title('��1����Ƶ������������')
%% ��Ƶ
data_map=dsss_seq.'*message;
signal=reshape(data_map,1,SF*length(message)).*exp(1i*2*pi*fc*t_seq);
%power_signal=mean(abs(signal).^2);
%% ����˹�ŵ�
if strcmp(channel,'AWGN')
    BER=zeros(1,length(SNR));
    for i=1:length(SNR)
        receive=awgn(signal,SNR(i));%��Ӹ�˹������
        down_carrier=receive.*exp(-2*1i*pi*fc*t_seq);
        receive_map=reshape(down_carrier,SF,length(message));
        receive_message=dsss_seq*receive_map/SF;%����Ƶ
        receive_data=qamdemod(receive_message,M);
        BER(i)=sum((receive_data-data)~=0)/bitNum;
    end
    figure(2)
    semilogy(SNR,BER);
    xlabel('�����SNR��dB��')
    ylabel('�������')
    title('��2���ڸ�˹�ŵ��µ�����������')
elseif strcmp(channel,'Inteference')
    figure(3)
    for j=1:length(Iterf)
        BER=zeros(1,length(SNR));
        for i=1:length(SNR)
            receive=awgn(signal,SNR(i))+exp(1i*2*pi*Iterf(j)*t_seq);%��Ӹ�˹�������͸���
            down_carrier=receive.*exp(-2*1i*pi*fc*t_seq);
            receive_map=reshape(down_carrier,SF,length(message));
            receive_message=dsss_seq*receive_map/SF;%����Ƶ
            receive_data=qamdemod(receive_message,M);
            BER(i)=sum((receive_data-data)~=0)/bitNum;
        end
        semilogy(SNR,BER);
        hold on
    end
    legend('80KHz��������','160KHz��������','320KHz��������')
    xlabel('�����SNR��dB��')
    ylabel('�������')
    title('��3�����ָ����ŵ��µ����������ܣ�������')
end




