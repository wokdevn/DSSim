function mseq = m_sequence(fbconnection) 
%fbconnection ������ϵ����1Ϊ��0Ϊ�أ���һλ�����һλʼ��Ϊ1
%reginit�Ĵ�����ʼֵ��ʼ������Ϊ[1,zeros(1,n-1)]
%��ʱ�Ӵ����£�ÿ����λ������Ĵ����ᷢ���仯�������κ�һ���Ĵ����������
%����ʱ�ӽ��ĵ����ƶ������һ�����У������г�Ϊ��λ�Ĵ�������
n = length(fbconnection)-1;
N = 2^n - 1;
%register = reginit;%�Ĵ�������
register = [1,zeros(1,n-1)];
newregister=zeros(1,n);
mseq=zeros(1,n);     
mseq(1) = register(n);
for i = 2:N
    newregister(1) = mod(sum(fbconnection(2:end) .* register), 2);%�¼Ĵ����ĵ�һλ�ɼ���ó������ݷ���ϵ��
    for j = 2:n
        newregister(j) = register(j-1);%�¼Ĵ����̳���һ���Ĵ�����״̬
    end
    register = newregister;
    mseq(i) = register(n);%�������һλ����m���У�������һ��ѭ��
end

