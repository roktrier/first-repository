function OutStruct=read_R_O_line(instruct,line)
%读取观测文件主体中的一行数据
%
%三频信号，数据(每个数据包括观测值和强度，他们之间用空格隔开)排列顺序如下:
%  卫星号 载波L1观测值  C1      L1       D1       S1
%   1-3             5-19    21-35    37-51    53-67
%        载波L2观测值  C2      L2       D2       S2
%                   69-83   85-99    101-115  117-131
%        载波L3观测值  C3      L3       D3       S3
%                   133-147 149-163  165-179  181-195
%
%目前支持读取GPS、GLONASS、BDS中的观测量
%OutStruct=read_R_O_line(OutStruct,line)
Sys=line(1);SI=line(1:3);%卫星标识信息
if ~isfield(instruct.(Sys),SI)
   instruct.(Sys).(SI)=struct;%如果尚未添加这一卫星，则添加这颗卫星
   %为这颗卫星添加相应载波，及观测值
   switch Sys
       case {'G','R'}
           instruct.(Sys).(SI).L1=struct('C',[],'L',[],'D',[],'S',[]);
           instruct.(Sys).(SI).L2=struct('C',[],'L',[],'D',[],'S',[]);
       case 'C'
           instruct.(Sys).(SI).B1=struct('C',[],'L',[],'D',[],'S',[]);
           instruct.(Sys).(SI).B2=struct('C',[],'L',[],'D',[],'S',[]);
           instruct.(Sys).(SI).B3=struct('C',[],'L',[],'D',[],'S',[]);
   end
end
%为不同系统的卫星不同波段载波读入数据
order1=[5 19 21 35 37 51 53 67 69 83 85 99 101 115 117 131];%双频切割序列
order2=[order1 133 147 149 163 165 179 181 195];%三频切割序列
if length(line)<=131%双频情况
    Obs_str=splitstrbynum(line,order1);%分割数据
    %将Obs_str中没有的观测量标记，而后用0代替
    Obs=[];
    [m,n]=size(Obs_str);
    for i=1:m
        if isspace(Obs_str(i,:))
            %没有观测值时，将字符串首尾各加入一个0，表示没有观测值或者强度信息
            Obs_str(i,1)='0';
            Obs_str(i,end)='0';
        end
        Obs_str_=splitstrbynum(Obs_str(i,:),[1 13 14 15]);%将观测值与强度分开
        Obs=[Obs;double(str2num(Obs_str_))'];
    end
    instruct.(Sys).(SI).L1.C=[instruct.(Sys).(SI).L1.C;Obs(1,:)];
    instruct.(Sys).(SI).L1.L=[instruct.(Sys).(SI).L1.L;Obs(2,:)];
    instruct.(Sys).(SI).L1.D=[instruct.(Sys).(SI).L1.D;Obs(3,:)];
    instruct.(Sys).(SI).L1.S=[instruct.(Sys).(SI).L1.S;Obs(4,:)];
    instruct.(Sys).(SI).L2.C=[instruct.(Sys).(SI).L2.C;Obs(5,:)];
    instruct.(Sys).(SI).L2.L=[instruct.(Sys).(SI).L2.L;Obs(6,:)];
    instruct.(Sys).(SI).L2.D=[instruct.(Sys).(SI).L2.D;Obs(7,:)];
    instruct.(Sys).(SI).L2.S=[instruct.(Sys).(SI).L2.S;Obs(8,:)];
elseif length(line)<=195 && length(line)>131%三频情况
    Obs_str=splitstrbynum(line,order2);%分割数据
    [m,n]=size(Obs_str);
    Obs=[];
    %将Obs_str中没有的观测量标记，而后用0代替
    for i=1:m
        if isspace(Obs_str(i,:))
            %没有观测值时，将字符串首尾各加入一个0，表示没有观测值或者强度信息
            Obs_str(i,1)='0';
            Obs_str(i,end)='0';
        end
        Obs_str_=splitstrbynum(Obs_str(i,:),[1 13 15 15]);%将观测值与强度分开
        Obs=[Obs;double(str2num(Obs_str_))'];
    end
    instruct.(Sys).(SI).B1.C=[instruct.(Sys).(SI).B1.C;Obs(1,:)];
    instruct.(Sys).(SI).B1.L=[instruct.(Sys).(SI).B1.L;Obs(2,:)];
    instruct.(Sys).(SI).B1.D=[instruct.(Sys).(SI).B1.D;Obs(3,:)];
    instruct.(Sys).(SI).B1.S=[instruct.(Sys).(SI).B1.S;Obs(4,:)];
    instruct.(Sys).(SI).B2.C=[instruct.(Sys).(SI).B2.C;Obs(5,:)];
    instruct.(Sys).(SI).B2.L=[instruct.(Sys).(SI).B2.L;Obs(6,:)];
    instruct.(Sys).(SI).B2.D=[instruct.(Sys).(SI).B2.D;Obs(7,:)];
    instruct.(Sys).(SI).B2.S=[instruct.(Sys).(SI).B2.S;Obs(8,:)];
    instruct.(Sys).(SI).B3.C=[instruct.(Sys).(SI).B3.C;Obs(9,:)];
    instruct.(Sys).(SI).B3.L=[instruct.(Sys).(SI).B3.L;Obs(10,:)];
    instruct.(Sys).(SI).B3.D=[instruct.(Sys).(SI).B3.D;Obs(11,:)];
    instruct.(Sys).(SI).B3.S=[instruct.(Sys).(SI).B3.S;Obs(12,:)];  
end
OutStruct=instruct;
        