function [file,path]=getObsfile()
%专门用于读取RENIX格式的O文件
%[file path]=getObsfile()
%年份暂时限定为05-25
str='*.05O;*.06O;*.07O;*.08O;*.09O;*.10O;*.11O;*.12O;*.13O;*.14O;*.15O;*.16O;*.17O;*.18O;*.19O;*.20O;*.21O;*.22O;*.23O;*.24O;*.25O';
[file,path]=uigetfile(str,'选取O文件');