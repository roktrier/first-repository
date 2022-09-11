function new_MP=t_MP(MP,Oslps)
%new_MP=t_MP(MP,Oslps)
%输入的MP不能为空，不能为全为零
%根据不连续的MP序列值、算出MP时间序列
new_MP=zeros(length(MP),1);
stop=find(MP==0);
if isempty(stop)
    average=sum(MP)/length(MP);
    new_MP=MP-average;
else
    i=0;
    while i<=length(stop)
        if i==0
            m=1;n=stop(1);
        elseif i<length(stop)
            m=stop(i);n=stop(i+1);
        else
            m=stop(end);n=length(MP);
        end
        if n-m>sqrt(Oslps)
            average=sum(MP(m:n))/(n-m);
            new_MP(m:n)=MP(m:n)-average;
        end
        i=i+1;%循环变量
    end
end
%超限出1.5的MP值视为粗差，不使用
new_MP(abs(new_MP)>1.5)=0;