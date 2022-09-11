function [res,Error,Slip,MP]=Cycleslips(Obs,F,Epoch)
%[res,Error,Slip]=Cycleslips(Obs,F,Epoch)
%基于MW组合和GF组合对双频伪距、载波相位观测值进行周跳的探测与修复,F为双频频率
%Epoch为有效观测历元
%输入观测值矩阵，输出双频模糊度
%输出res为：[o_slps MP1 MP2]
%输出Error为 有粗差的历元 输出Slip为发生周跳的历元 MP为有效、无粗差、无周跳历元的多路径值

%[res,Slip]=Cycleslips(Obs,F);
load('constant.mat')
f1=F(1);f2=F(2);g=f1/f2;
P1=Obs(:,1);L1=Obs(:,2);P2=Obs(:,3);L2=Obs(:,4);
MW=(f1-f2)/c*(f1*P1+f2*P2)/(f1+f2)-(L1-L2);%MW=N1-N2
MW=MW.*Epoch;
GF=c/f1*L1-c/f2*L2;%电离层残差组合
GF=GF.*Epoch;

Error=zeros(length(Epoch),1);%记录发生粗差的历元
Slip=zeros(length(Epoch),1);%记录发生周跳的历元
MP=zeros(length(Epoch),2);%有效、无粗差、无周跳历元的多路径值
%控制参数
n=3;dmax1=1;dmax2=0.05;

k=0;
if sum(Epoch)==0
    res=NaN;
    Error=zeros(length(Epoch),1);
    Slip=zeros(length(Epoch),1);
    MP=NaN;
else
%避免一开始就是无效观测历元，无法初始化
while k<=length(Epoch)
    if Epoch(k+1)==0
        k=k+1;
    else
        break;
    end
end
i=k+1;%从不是无效观测的第一个历元开始平滑
while i<=length(MW)-2
    %MW组合平滑处理
    %如果平滑过程中遇到无效观测值，直接令这个MW值为前一历元的平滑值
    if MW(i)==0
        MW(i)=Average_MW(i-1);
    end
    if i==(k+1)
        Average_MW(i)=MW(i);
        sigma02(i)=dmax1;%MW组合初始阈值设为1
    else
        Average_MW(i)=(i-1)/i*Average_MW(i-1)+1/i*MW(i);
        sigma02(i)=(i-1)/i*sigma02(i-1)+1/i*(MW(i)-Average_MW(i-1))^2;
        
    end
    %判断粗差、周跳
    if abs(MW(i+1)-Average_MW(i))>n*sqrt(sigma02(i)) && Epoch(i+1)~=0%i+1历元无效观测时，不需判断
        if abs(MW(i+2)-Average_MW(i))>n*sqrt(sigma02(i)) && abs(MW(i+2)-MW(i+1))<n*sqrt(sigma02(i)) &&Epoch(i+2)~=0
            Slip(i+1)=1;
            %有周跳，则下一历元的MW值不参与平滑
            MW(i+1)=Average_MW(i);
        elseif abs(MW(i+2)-Average_MW(i))<n*sqrt(sigma02(i)) && abs(MW(i+2)-MW(i+1))>n*sqrt(sigma02(i)) && Epoch(i+2)~=0
            Error(i+1)=1;
            MW(i+1)=Average_MW(i);%将有粗差的MW值直接调为前面i个历元MW值的平滑值
        elseif abs(MW(i+2)-Average_MW(i))>n*sqrt(sigma02(i)) && abs(MW(i+2)-MW(i+1))>n*sqrt(sigma02(i)) && Epoch(i+2)~=0
            %如果连续两个历元都和前面的平滑值相差很远，且不是周跳，则认定这两个历元都为粗差
            Error(i+1)=1;Error(i+2)=1;
            %将有粗差的MW值直接调为前面i个历元MW值的平滑值
            MW(i+1)=Average_MW(i);
            MW(i+2)=Average_MW(i);
        end
    elseif Epoch(i+2)==0%如果i+1历元超限，且i+2历元为无效观测，直接认定i+1历元为周跳
        Slip(i+1)=1;
        MW(i+1)=Average_MW(i);
    end
    i=i+1;
end
%使用GF组合对周跳进行进一步探测
if sum(Slip)==0%如果MW组合未检测到周跳
    i=1;
    while i<=length(Epoch)-1
        if GF(i)~=0 && GF(i+1)~=0 && abs(GF(i+1)-GF(i))>dmax2
            if Error(i)==0 && Error(i+1)==0  %若果无粗差，则认定为周跳
                Slip(i+1)=1;
            end
        elseif GF(i)~=0 && GF(i+1)~=0 && abs(GF(i+1)-GF(i))<dmax2
            %如果不超限，反而有粗差，则去除粗差标记
            if Error(i)~=0 || Error(i+1)~=0
                Error(i)=0;
                Error(i+1)=0;
            end
                
        end
        %循环变量加一
        i=i+1;
    end
else
    %如果MW组合检测到周跳
    Stop=find(Slip);%在MW组合探测到周跳的地方停止
for k=0:length(Stop)
    %判断GF组合历元段
    if k==0
        i=1;j=Stop(1);
    elseif k>0 && k<length(Stop)
        i=Stop(k);j=Stop(k+1);
    else
        i=Stop(end);j=Epoch(end);
    end
    while i<=j-2
        if GF(i)~=0 && GF(i+1)~=0 && abs(GF(i+1)-GF(i))>dmax2
            if Error(i)==0 && Error(i+1)==0  %若果无粗差，则认定为周跳
                Slip(i+1)=1;
            end
        elseif GF(i)~=0 && GF(i+1)~=0 && abs(GF(i+1)-GF(i))<dmax2
            %如果不超限，反而有粗差，则去除粗差标记
            if Error(i)~=0 || Error(i+1)~=0
                Error(i)=0;
                Error(i+1)=0;
            end
                
        end
        %循环变量加一
        i=i+1;
    end
end  
end

%%每周跳观测量
if sum(Slip)~=0
    Oslps=sum(Epoch)/sum(Slip);
else
    Oslps=9999999;
end

MP1=[];MP2=[];%伪距多路径影响值
if sum(Slip)==0%如果无周跳
    i=1;
    while i<=length(Epoch)
         if Error(i)==0 && Epoch(i)~=0%无粗差历元和有效历元
           m1=P1(i)-(g^2+1)/(g^2-1)*c/f1*L1(i)+2/(g^2-1)*c/f2*L2(i);
           MP1=[MP1;m1];
           m2=P2(i)-2*g^2/(g^2-1)*c/f1*L1(i)+(g^2+1)/(g^2-1)*c/f2*L2(i);
           MP2=[MP2;m2];
           MP(i,:)=[m1 m2];
         end
         i=i+1;
    end
    MP1=MP_hard(MP1,Oslps);
    MP2=MP_hard(MP2,Oslps);
    res=[Oslps MP1 MP2];
else
    %如果有周跳
Stop=find(Slip);%在探测到周跳的地方停止
for k=0:length(Stop)
    %判断无周跳历元段
    if k==0
        i=1;j=Stop(1)-1;
    elseif k>0 && k<length(Stop)
        i=Stop(k);j=Stop(k+1)-1;
    elseif k==length(Stop)
        i=Stop(end);j=length(Epoch);
    end
    mp1=[];mp2=[];
    while i<=j-1
         if Error(i)==0 && Epoch(i)~=0%无粗差历元、和有效历元
           m1=P1(i)-(g^2+1)/(g^2-1)*c/f1*L1(i)+2/(g^2-1)*c/f2*L2(i);
           mp1=[mp1;m1];
           m2=P2(i)-2*g^2/(g^2-1)*c/f1*L1(i)+(g^2+1)/(g^2-1)*c/f2*L2(i);
           mp2=[mp2;m2];
           MP(i,:)=[m1 m2];
         end
         i=i+1;
    end
    MP1=[MP1;MP_hard(mp1,Oslps)];
    MP2=[MP2;MP_hard(mp2,Oslps)];
    
end
MP1=sum(MP1)/length(MP1);
MP2=sum(MP2)/length(MP2);
res=[Oslps MP1 MP2];
end
end

%**********************************************************************
function res=MP_hard(input,Oslps)
%res=MP(input,Oslps)
%根据各个历元的MP值，计算多路径误差评估值
%对于长度小于Oslps的观测时段，不用，输出为空

if isempty(input)
    res=[];
else
    %剔除粗差
    
    
N=length(input);
if N<=sqrt(Oslps) && Oslps<9999999
    res=[];
else 
    MP=0;
    for i=1:N
        MP=(input(i)-sum(input)/N)^2+MP;
    end
    res=sqrt(MP/(N-1));
end
end



%*************************************************************************
function res=MP_easy(input)
%res=MP(input,Oslps)
%根据各个历元的MP值，计算多路径误差评估值
%对于长度小于Oslps的观测时段,也使用,避免没有计算结果
N=length(input);
if N==0
    res=[];
elseif N==1
    res=input(1);
else 
    MP=0;
    for i=1:N
        MP=(input(i)-sum(input)/N)^2+MP;
    end
    res=sqrt(MP/(N-1));
end



    




