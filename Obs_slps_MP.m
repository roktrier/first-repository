function [res,Error,Slip,MP]=Obs_slps_MP(Data,statis,SI)
%[res,new_data]=Obs_slps_MP(Data,statis,SI)
%计算每周跳观测量函数
%输入Data为读入的观测数据结构体，statis为关于观测数据完整率统计信息结构体
%SI为卫星系统和卫星号如PRN='G01'
%输出res包括O/slps值、和多路径误差MP值
%Error表示有粗差的历元、Slip表示有周跳的历元（用1标记）


%导入频率、光速等常量
load('constant.mat');
if isequal(SI,'All')
    %添加计算所有卫星O/slps值和MP值的代码
    
elseif ~isfield(Data.(SI(1)),SI) || ~isfield(Data,SI(1))
    error('该卫星或该卫星系统不在观测数据内');
elseif isequal(SI(1),'G') || isequal((SI(1)),'R')
    %添加计算GPS或者GLONASS单颗卫星O/slps值和MP值的代码
    Epoch=statis.(SI(1)).(SI).Total;%有效观测历元
    Obs_1=[Data.(SI(1)).(SI).L1.C(:,1) Data.(SI(1)).(SI).L1.L(:,1)];%L1观测值
    Obs_2=[Data.(SI(1)).(SI).L2.C(:,1) Data.(SI(1)).(SI).L2.L(:,1)];%L2观测值
    %载波L1,L2频率
    if isequal(SI(1),'G')
        f1=fL1;f2=fL2;
    else
        f=slot2frq(SI);
        f1=f(1);f2=f(2);
    end
    %计算Oslps值、MP值
    Obs=[Obs_1 Obs_2];F=[f1 f2];
    [res,Error,Slip,MP]=Cycleslips(Obs,F,Epoch);
else
    %添加计算BDS单颗卫星O/slps值和MP值的代码
    Epoch=statis.(SI(1)).(SI).Total;%有效观测历元
    Obs_1=[Data.(SI(1)).(SI).B1.C(:,1) Data.(SI(1)).(SI).B1.L(:,1)];%B1观测值
    Obs_2=[Data.(SI(1)).(SI).B2.C(:,1) Data.(SI(1)).(SI).B2.L(:,1)];%B2观测值
    f1=fB1l;f2=fB2l;
    Obs=[Obs_1 Obs_2];F=[f1 f2];
    [res,Error,Slip,MP]=Cycleslips(Obs,F,Epoch);
end


    
    
    


