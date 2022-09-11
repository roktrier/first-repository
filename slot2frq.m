function frq=slot2frq(SI)
%根据GLONASS卫星的SI号，来计算相应L1、L2载波的频率
%输入例如R10,输出频率(以Hz为单位）
slot=0;%插槽
number=str2num(SI(2:3));%卫星号
switch number
    case 1
        slot=1;
    case 2
        slot=-4;
    case 3
        slot=5;
    case 4
        slot=6;
    case 5
        slot=1;
    case 6
        slot=-4;
    case 7
        slot=5;
    case 8
        slot=6;
    case 9
        slot=-2;
    case 10
        slot=-7;
    case 11
        slot=-5;
    case 12
        slot=-1;
    case 13
        slot=-2;
    case 14
        slot=-7;
    case 15
        slot=0;
    case 16
        slot=-1;
    case 17
        slot=4;
    case 18
        slot=-3;
    case 19
        slot=3;
    case 20
        slot=2;
    case 21
        slot=4;
    case 22
        slot=-3;
    case 23
        slot=3;
    case 24
        slot=2;
end
f1=1602.5625e6+(slot-1)*0.5625e6;
f2=1246.4375e6+(slot-1)*0.4375e6;
frq=[f1;f2];
        
