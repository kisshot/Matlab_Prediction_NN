% Code函数（编码）

function ret=Code(lenchrom,bound)
%本函数将变量编码成染色体，用于随机初始化一个种群
% lenchrom   input : 染色体长度
% bound      input : 变量的取值范围
% ret        output: 染色体的编码值
    pick=rand(1,length(lenchrom));

    ret=bound(:,1)'+(bound(:,2)-bound(:,1))'.*pick; %线性插值，编码结果以实数向量存入ret中

