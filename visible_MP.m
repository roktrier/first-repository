function visible_MP(Data,statis,Identity)
%展示多个卫星的MP值、或者展示某个卫星的MP值时间序列图
%visible_MP(Data,statis,Identity)
clf;cla;
if length(Identity)==1
    %多卫星只展示每个卫星的MP1、MP2
    fields=fieldnames(Data.(Identity));
    MPS=[];SIS={};
    for i=1:length(fields)
        SI=fields{i};
        [res,Error,Slip,MP]=Obs_slps_MP(Data,statis,SI);
        %对于MP值大于1.5或者无法计算的波段，将其MP值设为1.5,表示无参考意义
        if isnan(res)
            res(2)=1.5;
            res(3)=1.5;
        elseif length(res)==1
            res=[res(1) 1.5 1.5];
        end
        if res(2)>=1.5
            res(2)=1.5;
        end
        if res(3)>1.5
            res(3)=1.5;
        end
        MPS=[MPS;res(2) res(3)];
        SIS{length(SIS)+1}=SI;
    end
    bar(MPS);
    xticklabels(SIS);
    title('SI-MP1/MP2(m)');
else
    %单卫星展示每个载波的MP序列图
    %加载时间信息
    %确定文件头信息
    interval=Data.Header.Interval/(24*3600);
    t1=Data.Header.TimeOfFirstObs(4:6);
    t2=Data.Header.TimeOfLastObs(4:6);
    %str格式
    t1=[num2str(t1(1)),':',num2str(t1(2)),':',num2str(t1(3))];
    t2=[num2str(t2(1)),':',num2str(t2(2)),':',num2str(t2(3))];
    %datenum
    t1=datenum(t1);t2=datenum(t2);
    Epoch=Data.(Identity(1)).(Identity).Epoch;
    %把相应观测历元改为时间
    for j=1:length(Epoch)
        Epoch(j)=t1+Epoch(j)*interval;
    end
    [res,Error,Slip,MP]=Obs_slps_MP(Data,statis,Identity);
    if isnan(MP) %全为无效观测
        y=zeros(length(Epoch),1);
        plot(Epoch,y,'--oblack');
        legend('无效观测,无法计算MP值');
        str=[Identity '   t(s)-MP(m)'];
        title(str);
        %改变x轴刻度标签，和x、y轴范围
        datetick('x','HH:MM:SS');
        xlim 'tight'
        ylim([-1.5 1.5]);
    elseif isempty(MP)
        y=zeros(length(Epoch),1);
        plot(Epoch,y,'--oblack');
        legend('无效观测,无法计算MP值');
        str=[Identity '   t(s)-MP(m)'];
        title(str);
        %改变x轴刻度标签，和x、y轴范围
        datetick('x','HH:MM:SS');
        xlim 'tight'
        ylim([-1.5 1.5]);
    else
        %有有效观测时段的卫星，MP1和MP2都要做出时间序列图
        L1=MP(:,1);L2=MP(:,2);Oslps=res(1);
        L1=t_MP(L1,Oslps);L2=t_MP(L2,Oslps);
        epoch=Epoch;
        epoch(L2==0)=[];
        reliable_t2=epoch;%L2有效观测时段时间序列
        epoch=Epoch;
        epoch(L1==0)=[];
        reliable_t1=epoch;%L1有效观测时段时间序列
        L1(L1==0)=[];L2(L2==0)=[];%有效观测MP值
        
        subplot(1,2,1)
        if ~isempty(reliable_t1)
            plot(reliable_t1,L1,'-red');
            legend('有效观测');
            str=[Identity '   t(s)-MP1(m)'];
            title(str);
            datetick('x','HH:MM:SS');
            xlim 'tight';
            ylim([-1.5 1.5]);
        else
            plot(Epoch,zeros(length(Epoch),1),'--oblack');
            legend('无效观测,无法计算MP值');
            str=[Identity '   t(s)-MP1(m)'];
            title(str);
            %改变x轴刻度标签，和x、y轴范围
            datetick('x','HH:MM:SS');
            xlim 'tight';
            ylim([-1.5 1.5]);
        end
        
        subplot(1,2,2)
        if ~isempty(reliable_t2)
            plot(reliable_t2,L2,'-red');
            legend('有效观测');
            str=[Identity '   t(s)-MP2(m)'];
            title(str);
            datetick('x','HH:MM:SS');
            xlim 'tight';
            ylim([-1.5 1.5]);
        else
            plot(Epoch,zeros(length(Epoch),1),'--oblack');
            legend('无效观测,无法计算MP值');
            str=[Identity '   t(s)-MP2(m)'];
            title(str);
            %改变x轴刻度标签，和x、y轴范围
            datetick('x','HH:MM:SS');
            xlim 'tight';
            ylim([-1.5 1.5]);
        end
    end 
end
hold off


