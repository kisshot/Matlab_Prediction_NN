
% select函数（选择）

function ret =select01(individuals,popsize)
% 该函数用于进行选择操作
% individuals input    种群信息
% sizepop     input    种群规模
% ret         output   选择后的新种群

k = 10;  % 系数
fitness = k./individuals.fitness;
% probability = fitness./sum(fitness);

P=[];%个体概率按顺序存入数组P中
for i=1:popsize
    P = [P fitness(i)/sum(fitness)]; 
end
%对P中各个个体做计算累加概率Q
%Q对应模拟各个体概率的一条直线，在直线上根据个体概率分成段，段的宽度越长，随机被选中的概率就越大
Q=[];
Q(1)=P(1);
for j=2:length(P)
    Q(j)=P(j)+Q(j-1);
end

% 大循环：得到新的种群，每次循环都选出一行种群，新的种群也是popsize组(行)
% 中循环：100次循环，得到每一行的种群被选中的次数
% 小循环：轮盘赌法，只是为了找出在100次循环中的每一次：r位于哪个区间，在哪个区间，后面的Z(k)就+1
% Z对应每一个种群(总共popsize个种群)在100次循环中被选中的次数
index = [];
for i=1:popsize %大循环
    
    Z = zeros(1,popsize);       %Z[0,0,0,....0]共popsize和元素，分别对应popsize个种群，初始值为0，存储的是被选中的次数
    for j=1:100 %中循环
        r = rand;
        % 轮盘赌
        if r < Q(1)
            Z(1) = Z(1) + 1;
        end
        for k=2:popsize %小循环
            if Q(k-1) < r <= Q(k)
                Z(k) = Z(k) + 1;
            end   
        end       
    end                   %100次循环，Z(k)里有每一组被选中的次数
    [~, t] = max(Z);                 
    index = [index t];    %在100次循环中：被选中次数最多的那一组
end                       %popsize次循环，每一次找出一个被选中最多的加到index中，到时新的种群就对应index


    
%新种群
individuals.chrom=individuals.chrom(index,:);   %individuals.chrom为种群中个体
individuals.fitness=individuals.fitness(index);

ret=individuals;
     
            
    