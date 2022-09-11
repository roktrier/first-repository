function OutStruct=read_R_O(input1,input2)
%本函数用于读取Rinex格式的O文件，输出一个嵌套结构体
%input1为文件路径或者文件名称
%input2为选取系统，如input2='GC',则输出的结构体中只含GPS、BDS中的数据信息，不含其他卫星系统数据
%G=GPS R=GLONASS C=COMPASS S=SBAS J=QZSS E=GALILEO -----------注
%input3为选取观测值类型，如input3='CL',则输出的结构体中只含伪距和载波相位观测值
%C=码伪距观测值 L=载波相位观测值 D=多普勒观测值 S=信噪比观测值 --------注

%OutStruct: {Header:[1*1 struct] G:[1*1 struct] R:[1*1 struct] C:[1*1 struct]}
%OutStruct中包括Header结构体和包括每个GNSS系统观测值的结构体
%对于每个GNSS系统 以C为例(有C01、C02、C03等多颗卫星）
%C: {C01: [1*1 struct] C02: {1*1 struct} ......}
%对于BDS中每颗特定的卫星，以C01为例(有B1、B2、B3三个频率的载波,和相应的观测历元）
%C01: {B1:[1*1 struct] B2:[1*1 struct] B3:[1*1 struct] Epoch:[n*1 int]}
%对于每个载波，以B1载波为例(总共有4种类型的观测量，每种类型的观测量还包括强度)
%B1:{C: [n*1 double] L: [n*1 double] D: [n*1 double] S: [n*1 double]}
%n为历元数，4行数据分别为伪距、载波、多普勒、信噪比(也可根据input3的内容缩减，但顺序不变）

%目前只支持读取GPS、GLONASS、BDS系统的伪距和载波相位观测值(可添加）
%end of header
%OutStruct=read_R_O('4_1_WG017_1.22O','GRC')

%为输出结构体添加GNSS系统信息
OutStruct=struct('Header',struct);
for i=1:length(input2)
    OutStruct.(input2(i))=struct;
end

%略过文件头部分（后续可添加读取文件头信息内容）
file=fopen(input1);
k=1;
while(k)
    line=fgetl(file);
    %添加采样间隔信息
    if contains(splitstrbynum(line,[61 length(line)]),'INTERVAL')
        OutStruct.Header.Interval=str2num(splitstrbynum(line,[1 60]));
    end
    %添加起始观测、结束观测时间信息
    if contains(splitstrbynum(line,[61 length(line)]),'TIME OF FIRST OBS')
        time_start=str2num(splitstrbynum(line,[1 48]));
        OutStruct.Header.TimeOfFirstObs=time_start;
    end
    if contains(splitstrbynum(line,[61 length(line)]),'TIME OF LAST OBS')
        time_end=str2num(splitstrbynum(line,[1 48]));
        OutStruct.Header.TimeOfLastObs=time_end;
    end
    %判断文件头是否结束
    if contains(line,'END OF HEADER')
        k=0;
    end
end
%读取文件主体
Epoch=0;%历元计数
while(~feof(file))
    line=fgetl(file);
    if contains(line,'>')
        Epoch=Epoch+1;%每读取到一个'>'，表示历元数加一
        line=fgetl(file);
    end
    Sys=line(1);SI=line(1:3);%卫星系统标识信息
    if contains(input2,Sys)
        OutStruct=read_R_O_line(OutStruct,line);%更新卫星观测值信息
        if ~isfield(OutStruct.(Sys).(SI),'Epoch')%如果该卫星未添加历元信息，则为它添加
        OutStruct.(Sys).(SI)=setfield(OutStruct.(Sys).(SI),'Epoch',[]);
        end
        %更新卫星历元信息
        OutStruct.(Sys).(SI).Epoch=[OutStruct.(Sys).(SI).Epoch;Epoch];
    end
end
        
        


    
