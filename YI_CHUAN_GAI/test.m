

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test函数（判断阈值和权值是否超界）

function flag=test(chrom)
%此函数用来判断individuals.chrom里数值是否超过边界bound
%bound在main里定义为（-3:3）
%flag       output     染色体可行（未超界）output为1 ，不可行为0
f1=isempty(find(chrom>3, 1));
f2=isempty(find(chrom<-3, 1));
if f1*f2==0
    flag=0;
else
    flag=1;
end
