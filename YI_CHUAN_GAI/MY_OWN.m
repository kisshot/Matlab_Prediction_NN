%{
_train:训练
_test:测试
_norm:归一化，数据位于(0,1)
tic和toc用来记录matlab命令执行的时间
%}

% 初始化
tic 
clear;
clc;

% 数据
input = load('input.txt');
output = load('output.txt');
save data input output

% 数据初始化
input_train = input(1:150,:)';
output_train = output(1:150,:)';
input_test = input(151:186,:)';
output_test = output(151:186,:)';

% 训练数据归一化
[input_norm, is] = mapminmax(input_train);    %is:输入数据归一化参数
[output_norm, os] = mapminmax(output_train);  %os:输出数据归一化参数

% BP初始化
input_num = 3;
hidden_num = 6;
output_num = 1;

% 建立网络
TF1 = 'tansig'; TF2 = 'purelin';
net = newff(input_norm, output_norm, hidden_num, {TF1 TF2}, 'trainlm');


% 遗传参数初始化
iteration_num = 10; %进化次数，即迭代次数
popsize = 30; %种群规模，自定义
pc = 0.3; %交叉概率
pm = 0.1; %变异概率


numsum=input_num*hidden_num+hidden_num+hidden_num*output_num+output_num;
lenchrom=ones(1,numsum);       
bound=[-3*ones(numsum,1) 3*ones(numsum,1)];    %数据范围
individuals=struct('fitness',zeros(1,popsize), 'chrom',[]);  %将种群信息定义为一个结构体


%各种群适应度计算 
for i=1:popsize
	individuals.chrom(i,:) = Code(lenchrom, bound);  %编码
	x = individuals.chrom(i,:);
	%计算适应度
	individuals.fitness(i) = fun(x,input_num,hidden_num,output_num,net,input_norm,output_norm);
end

[bestfitness, bestindex] = min(individuals.fitness);
bestchrom = individuals.chrom(bestindex,:);  %最好的染色体
%-------以上：完成第一次的适应度计算即存储，接下来选择交叉变异从而获得更好的个体，迭代十次---------%


% 选择，交叉，变异
for i=1:iteration_num
	% 选择  
    individuals=select(individuals,popsize);
    % 交叉  
    individuals.chrom=Cross(pc,lenchrom,individuals,popsize,bound);  
    % 变异  
    individuals.chrom=Mutation(pm,lenchrom,individuals,popsize,i,iteration_num,bound);
    
    % 计算适应度
    for j=1:popsize
		x = individuals.chrom(j,:); %个体，本段与上面一样，但无需编码，要做的是计算选择/交叉/变异之后的适应度值
		%计算适应度
		individuals.fitness(j) = fun(x,input_num,hidden_num,output_num,net,input_norm,output_norm);
    end	
	%找到最小适应度的染色体及它们在种群中的位置
    [newbestfitness,newbestindex] = min(individuals.fitness);
    [worestfitness,worestindex] = max(individuals.fitness);
    % 代替上一次进化中最好的染色体
	if newbestfitness < bestfitness
       bestfitness = newbestfitness;
       bestchrom = individuals.chrom(newbestindex,:);
    end
    individuals.chrom(worestindex,:) = bestchrom;
    individuals.fitness(worestindex) = bestfitness;   %把最糟糕的用最好的替换
end


% 判断是否达标，已达标，进入下一步

% 获得最佳初始阀值权值

x = bestchrom;
w1 = x(1:input_num*hidden_num);
B1 = x(input_num*hidden_num+1:input_num*hidden_num+hidden_num);
w2 = x(input_num*hidden_num+hidden_num+1:input_num*hidden_num+hidden_num+hidden_num*output_num);
B2 = x(input_num*hidden_num+hidden_num+hidden_num*output_num+1:input_num*hidden_num+hidden_num+hidden_num*output_num+output_num);

net.iw{1,1} = reshape(w1,hidden_num,input_num);
net.lw{2,1} = reshape(w2,output_num,hidden_num);
net.b{1} = reshape(B1,hidden_num,1);
net.b{2} = reshape(B2,output_num,1);

% BP网络训练
% 网络参数
net.trainParam.epochs=1000;
net.trainParam.lr=0.1;
net.trainParam.goal=0.0001;

net.divideFcn = ''; % 为和书本一致，对于样本极少的情况，不要再三分了

%网络训练
[net,tr]=train(net,input_norm,output_norm);

%数据归一化
input_test_norm = mapminmax('apply',input_test,is);
an = sim(net,input_test_norm); %归一化的预测结果
output_test_BP = mapminmax('reverse',an,os); %预测结果
error = output_test_BP-output_test;

% 画图
figure(1)
plot(output_test_BP,':og','LineWidth',1.5)
hold on
plot(output_test,'-*','LineWidth',1.5);
legend('预测输出','期望输出')
grid on
set(gca,'linewidth',1.0);
xlabel('样本','FontSize',15);
ylabel('函数输出','FontSize',15);
set(gcf,'color','w')
title('GA-BP 网络','Color','k','FontSize',15);

toc









