function visible_Ratio(Data,statis,Identity,bool)
%visble_Ratio(OutStruct,statis,'C',1)
%根据Data、statis中的数据、Identiy标识
%bool等于1时，加上周跳、粗差等信息
clf;cla;
if length(Identity)==1
    %确定文件头信息
    interval=Data.Header.Interval/(24*3600);
    t1=Data.Header.TimeOfFirstObs(4:6);
    t2=Data.Header.TimeOfLastObs(4:6);
    %str格式
    t1=[num2str(t1(1)),':',num2str(t1(2)),':',num2str(t1(3))];
    t2=[num2str(t2(1)),':',num2str(t2(2)),':',num2str(t2(3))];
    %datenum
    t1=datenum(t1);t2=datenum(t2);
    %做出整个系统的图
    fields=fieldnames(Data.(Identity));
    for i=1:length(fields)
        Epoch=Data.(Identity).(fields{i}).Epoch;
        %把相应观测历元改为时间
        for j=1:length(Epoch)
            Epoch(j)=t1+Epoch(j)*interval;
        end
        %令无效观测历元时间等于零
        reliable=statis.(Identity).(fields{i}).Total;
        ti=Epoch.*reliable;
        %删除零元素
        ti(ti==0)=[];
        y=i*ones(length(ti),1);
        scatter(ti,y,25,'filled','yellow');
        hold on;
    end
    %添加周跳、粗差等信息
    if bool==1
        for i=1:length(fields)
            %获取粗差、周跳等信息
            [res,Error,Slip,MP]=Obs_slps_MP(Data,statis,fields{i});
            Epoch=Data.(Identity).(fields{i}).Epoch;
            %把相应观测历元改为时间
            for j=1:length(Epoch)
               Epoch(j)=t1+Epoch(j)*interval;
            end
            %删除零元素
            Error=Epoch.*Error;Error(Error==0)=[];
            Slip=Epoch.*Slip;Slip(Slip==0)=[];
            y1=i*ones(length(Error),1);
            y2=i*ones(length(Slip),1);
            scatter(Error,y1,'*','red');
            scatter(Slip,y2,'+','black');
        end
    end
    %改变x、y轴的刻度显示
    yticks(1:length(fields));
    yticklabels(fields);
    datetick('x','HH:MM:SS');
    title('卫星有效观测时段图(*表示粗差,+表示周跳)');
    %要先画图，然后再限制坐标范围
    xlim([t1 t2]);
else
    %单卫星图,画出L1、L2载波完整率和卫星完整率
    Epoch=Data.(Identity(1)).(Identity).Epoch;
    reliable=statis.(Identity(1)).(Identity).Total;
    if isequal(Identity(1),'G') || isequal(Identity(1),'R')
        L1=statis.(Identity(1)).(Identity).L1;
        L2=statis.(Identity(1)).(Identity).L1;
    else
        L1=statis.(Identity(1)).(Identity).B1;
        L2=statis.(Identity(1)).(Identity).B2;
    end
    y=[L1/length(Epoch) L2/length(Epoch) sum(reliable)/length(Epoch)];
    x=[1 3 5];
    xticklabel={'L1','L2','RATIO'};
    str='卫星完整率(L1/L2/总)';
    %添加粗差率、周跳率
    if bool==1
        [res,Error,Slip,MP]=Obs_slps_MP(Data,statis,Identity);
        if isempty(reliable)
            y=[y 0 0];
        else
            y4=sum(Error)/length(reliable);
            if isempty(Slip)
                y5=1;
            else
                y5=1/res(1);
            end
            y=[y y4 y5];
        end
        x=[x 7 9];
        xticklabel={'L1','L2','RATIO','Error' 'Slip'};
        str='卫星完整率(L1/L2/总) 粗差率/周跳率';
    end
    labels=string(y);
    
    bar(x,y,0.2)
    %添加条形的值
    text(x,y,labels,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')
    title(str);
    %添加x轴刻度标签
    xticks(x);
    xticklabels(xticklabel);
    ylim([0 1.3])
end
hold off

