function Output=splitstrbynum(str,order)
%按照位数截取字符串,用于截取信息全为数据的字符串
%order=[1 3 5 19]时，Output=[str(1:3);str(5:19)];
%order应升序排列,对于空字符段，用O表示
Output=[];
if rem(length(order),2)~=0
    error('order数组应含偶数个元素！');
end
for i=1:2:(length(order)-1)
    if order(i)>length(str)
        splitstr=0;
    else
        splitstr=str(order(i):order(i+1));
    end
    Output=strvcat(Output,splitstr);%将不同长度的splitstr按统一长度存入字符串组
end