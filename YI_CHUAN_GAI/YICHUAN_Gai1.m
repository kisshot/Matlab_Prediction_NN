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

% input = load('wind_power_input_1.txt');
% output = load('wind_power_output_1.txt');
input = load('scadaWindPower_input.txt');
output = load('scadaWindPower_output.txt');
save data input output

% 数据初始化

% input_train = input(1:149,:)';
% output_train = output(1:149,:)';
% input_test = input(150:178,:)';
% output_test = output(150:178,:)';

input_train = input(1:400,:)';
output_train = output(1:400,:)';
input_test = input(401:450,:)';
output_test = output(401:450,:)';

% 训练数据归一化
[input_norm, is] = mapminmax(input_train);    %is:输入数据归一化参数
[output_norm, os] = mapminmax(output_train);  %os:输出数据归一化参数

% BP初始化
% input_num = 13;
% hidden_num = 26;
% output_num = 1;
input_num = 2;
hidden_num = 5;
output_num = 1;

% 建立网络
TF1 = 'tansig'; TF2 = 'purelin';
net = newff(input_norm, output_norm, hidden_num, {TF1 TF2}, 'trainlm');


% 遗传参数初始化
iteration_num = 10; %进化次数，即迭代次数
popsize = 50; %种群规模，自定义
pc = 0.3; %交叉概率
pm = 0.1; %变异概率


numsum=input_num*hidden_num+hidden_num+hidden_num*output_num+output_num;
lenchrom=ones(1,numsum);       
bound=[-3*ones(numsum,1) 3*ones(numsum,1)];    %数据范围
individuals=struct('fitness',zeros(1,popsize), 'chrom',[]);  %将种群信息定义为一个结构体


%各种群适应度计算 
for i=1:popsize
	individuals.chrom(i,:) = Code01(lenchrom);  %编码
	x = individuals.chrom(i,:);
	%计算适应度
	individuals.fitness(i) = fun01(x,input_num,hidden_num,output_num,net,input_norm,output_norm);
end

[bestfitness, bestindex] = min(individuals.fitness);
bestchrom = individuals.chrom(bestindex,:);  %最好的染色体
%-------以上：完成第一次的适应度计算即存储，接下来选择交叉变异从而获得更好的个体，迭代十次---------%


% 选择，交叉，变异
bestfitnessindex = []; % 用来记录最佳个体在第几行
for num=1:iteration_num
	% 选择  
    individuals=select01(individuals,popsize);
    % 交叉  
    individuals.chrom=Cross01(pc,lenchrom,individuals,popsize);  
    % 变异  
    individuals.chrom=Mutation01(pm,individuals,popsize,lenchrom,num,iteration_num); 
    % individuals.chrom=Mutation(pm,lenchrom,individuals,popsize,num,iteration_num,bound); 
    
    % 计算适应度
    for j=1:popsize
		x = individuals.chrom(j,:); %个体，本段与上面一样，但无需编码，要做的是计算选择/交叉/变异之后的适应度值
		%计算适应度
		individuals.fitness(j) = fun01(x,input_num,hidden_num,output_num,net,input_norm,output_norm);
        
    end	
	%找到最小适应度和最大适应度的染色体及它们在种群中的位置
    [newbestfitness,newbestindex] = min(individuals.fitness);
    [worestfitness,worestindex] = max(individuals.fitness);
    % 代替上一次进化中最好的染色体
	if newbestfitness < bestfitness
       bestfitness = newbestfitness;
       bestindex = newbestindex;
       bestchrom = individuals.chrom(bestindex,:);
    end
    
    
    %如果将历史最佳替代当代最差，可能会容易陷入局部最优。
    %因此多加一个判断，如果连续三次迭代的历史最佳都是同一行的个体，就再进行一次突变。
    bestfitnessindex = [bestfitnessindex bestindex];
    if num >= 3
        if bestfitnessindex(num) == bestfitnessindex(num-1) == bestfitnessindex(num-2)
            individuals.chrom=Mutation01(pm,individuals,popsize,lenchrom,num,iteration_num);
        end
    end
    
    individuals.chrom(worestindex,:) = bestchrom;
    individuals.fitness(worestindex) = bestfitness;   %把最糟糕的用最好的替换   
    
    
end


% 判断是否达标，已达标，进入下一步
% 个人的想法是，设定一个计数器，如果连续N代出现的最优个体的适应度都一样时，
% 严格的说应该是，连续N代子代种群的最优个体适应度都<=父代最优个性的适应度）可以终止运算。
% 也可以简单的根据经验固定进化的代数。
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
net.trainParam.epochs = 1000;%设置训练次数
net.trainParam.goal=0.0001;%设置收敛误差
net.trainParam.show=20;% 显示频率，这里设置为没训练20次显示一次
net.trainParam.mc=0.95;% 附加动量因子
net.trainParam.lr=0.01;% 学习率设置0.01
net.trainParam.min_grad=2e-6;%最小性能梯度
% net.trainParam.min_fail=5;% 最大确认失败次数

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









