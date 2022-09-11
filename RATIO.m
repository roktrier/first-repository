function [statis,Ratio]=RATIO(Data)
%计算数据完整率RATIO值函数
%输入Data为读入的含有观测信息的结构体，输出含数据完整率信息的结构体
%res为储存数据量、Ratio储存完整率
%[statis,Ratio]=RATIO(OutStruct)

%去掉Header字段
Data=rmfield(Data,'Header');
fields1=fieldnames(Data);

%循环统计数据
for i=1:length(fields1)
    statis.(fields1{i})=struct;%添加卫星系统
    
    fields2=fieldnames(Data.(fields1{i}));
    Total=[];%理论观测数据量统计
    Effective=[];%有效观测量统计
    for j=1:length(fields2)%具体到某个卫星
        statis.(fields1{i}).(fields2{j})=struct;%添加卫星
        Total_epoch=length(Data.(fields1{i}).(fields2{j}).Epoch);%该卫星所有观测历元数
        %去除每个卫星的Epoch字段后，便于遍历
        Data.(fields1{i}).(fields2{j})=rmfield(Data.(fields1{i}).(fields2{j}),'Epoch');
        fields3=fieldnames(Data.(fields1{i}).(fields2{j}));
        Total=[Total;Total_epoch];%记录该卫星系统所有卫星的理论观测值总数
        statis.(fields1{i}).(fields2{j}).Epoch=Total_epoch;%记录该卫星理论历元数
        Real=zeros(Total_epoch,length(fields3));%统计有效观测数
        for k=1:length(fields3)
            for m=1:Total_epoch
                if Data.(fields1{i}).(fields2{j}).(fields3{k}).C(m,1)~=0 && Data.(fields1{i}).(fields2{j}).(fields3{k}).L(m,1)~=0
                    Real(m,k)=1;
                end
            end
            statis.(fields1{i}).(fields2{j}).(fields3{k})=sum(Real(:,k));
            %统计该卫星系统在每个单频点下的总有效观测量
            if ~isfield(statis.(fields1{i}),fields3{k})
                statis.(fields1{i}).(fields3{k})=0;
            end
            statis.(fields1{i}).(fields3{k})=statis.(fields1{i}).(fields3{k})+sum(Real(:,k));
        end
        %统计单个卫星有效观测数据(每个频率都需完整观测）
        single_s=[];%记录每个完整观测的历元数
        for t=1:Total_epoch
            if Real(t,:)==ones(1,length(fields3))
                single_s=[single_s;1];
            else
                single_s=[single_s;0];
            end
        end
        Effective=[Effective;sum(single_s)];
        statis.(fields1{i}).(fields2{j}).Total=single_s;
    end
    statis.(fields1{i}).Epoch=sum(Total);
    statis.(fields1{i}).Total=sum(Effective);
end
%计算数据完整率
Ratio.Total=(statis.G.Total+statis.R.Total+statis.C.Total)/(statis.G.Epoch+statis.R.Epoch+statis.C.Epoch);
for i=1:length(fields1)
    if isequal(fields1{i},'G') || isequal(fields1{i},'R')
        Ratio.(fields1{i}).L1=statis.(fields1{i}).L1/statis.(fields1{i}).Epoch;
        Ratio.(fields1{i}).L2=statis.(fields1{i}).L2/statis.(fields1{i}).Epoch;
    else
        Ratio.(fields1{i}).B1=statis.(fields1{i}).B1/statis.(fields1{i}).Epoch;
        Ratio.(fields1{i}).B2=statis.(fields1{i}).B2/statis.(fields1{i}).Epoch;
        Ratio.(fields1{i}).B3=statis.(fields1{i}).B3/statis.(fields1{i}).Epoch;
    end
    Ratio.(fields1{i}).Total=statis.(fields1{i}).Total/statis.(fields1{i}).Epoch;
end
    
    
    
