function mseq = m_sequence(fbconnection) 
%fbconnection 反馈线系数，1为开0为关，第一位和最后一位始终为1
%reginit寄存器初始值，始终设置为[1,zeros(1,n-1)]
%在时钟触发下，每次移位后各级寄存器会发生变化，其中任何一级寄存器的输出，
%随着时钟节拍的推移都会产生一个序列，该序列称为移位寄存器序列
n = length(fbconnection)-1;
N = 2^n - 1;
%register = reginit;%寄存器内容
register = [1,zeros(1,n-1)];
newregister=zeros(1,n);
mseq=zeros(1,n);     
mseq(1) = register(n);
for i = 2:N
    newregister(1) = mod(sum(fbconnection(2:end) .* register), 2);%新寄存器的第一位由计算得出，根据反馈系数
    for j = 2:n
        newregister(j) = register(j-1);%新寄存器继承上一个寄存器的状态
    end
    register = newregister;
    mseq(i) = register(n);%序列最后一位存入m序列，进入下一次循环
end

