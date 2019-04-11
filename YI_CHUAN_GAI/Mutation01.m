
function ret = Mutation01(pm, individuals, popsize, lenchrom, num, iteration_num)

for i=1:100
    pick = rand;
    row = ceil(rand*popsize);
    if pick < pm
        column = ceil(rand*length(lenchrom));
        vk = individuals.chrom(row, column);
        % 尝试：非一致性变异和自适应性变异https://www.cnblogs.com/liyuwang/p/6012712.html
        % vk1 = vk + h(t,bk-vk) 
        % vk2 = vk - h(t,vk-ak)
        % h(t,y) = y * (1-r^(1-t/T)^p)
        % 接下来要考虑边界条件，及变异后的vk是否超过了权值、阈值的(-3,-3)范围
        bk = 3;
        ak = -3;
        pick = rand;
        vk1 = vk + (bk-vk) * (1 - pick^(1-num/iteration_num)^3 );
        vk2 = vk - (vk-ak) * (1 - pick^(1-num/iteration_num)^3 );
        pick = rand;
        individuals.chrom(row, column) = vk1 + (vk2-vk1).*pick;  %产生(vk1,vk2)范围内的随机数
    end
end

ret = individuals.chrom;
        