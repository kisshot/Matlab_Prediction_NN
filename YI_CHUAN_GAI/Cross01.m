% cross函数（交叉）
function ret=Cross01(pc,lenchrom,individuals,popsize)
%本函数完成交叉操作
% pcorss                input  : 交叉概率
% lenchrom              input  : 染色体的长度
% individuals.chrom     input  : 染色体群
% sizepop               input  : 种群规模
% ret                   output : 交叉后的染色体

% 实数编码，在进行交叉时，考虑模型二进制交叉SBX

 for i=1:100  %每一轮for循环中，可能会进行一次交叉操作，染色体是随机选择的，交叉位置也是随机选择的，
                  %但该轮for循环中是否进行交叉操作则由交叉概率决定（continue控制）        
    pick=rand(1,2);   % 随机选择两个染色体进行交叉
    row=ceil(pick.*popsize);  
    pick=rand;
    if pick < pc
         % 随机选择交叉位
         pick=rand;       
         column=ceil(pick*length(lenchrom)); %随机选择进行交叉的位置，即选择第几个变量进行交叉，注意：两个染色体交叉的位置相同
         pick=rand; %交叉开始
         v1=individuals.chrom(row(1),column);                                                         %index(1)行,pos列
         v2=individuals.chrom(row(2),column);
         individuals.chrom(row(1),column)=pick*v2+(1-pick)*v1;
         individuals.chrom(row(2),column)=pick*v1+(1-pick)*v2; %交叉结束
    end
 end

ret=individuals.chrom;

