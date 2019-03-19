
% main（遗传算法主程序）
tic
clear;
clc;
load data.mat
inputnum=3;      % 注意网络的结构要和数据一致，否则会报错
hiddennum=6;
outputnum=1;
% input_train=input(1:1500,:)';
% input_test=input(1501:2000,:)';
% output_train=output(1:1500)';
% output_test=output(1501:2000)';
input_train = input((1:150),:)';
input_test=input((151:185),:)';
output_train = output(1:150)';
output_test=output(151:185)';
[inputn,inputps]=mapminmax(input_train);
[outputn,outputps]=mapminmax(output_train);
net=newff(inputn,outputn,hiddennum,{'tansig','purelin'},'trainlm'); 
%%{'tansig','purelin'}为默认的激活函数（trainlm为默认的训练算法，Levenberg-Marquart算法)
% 遗传算法参数初始化
maxgen=10;                         %进化代数，即迭代次数
sizepop=30;                        %种群规模
pcross=0.3;                       %交叉概率选择，0和1之间

pmutation=0.1;                    %变异概率选择，0和1之间

numsum=inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum;
lenchrom=ones(1,numsum);       
bound=[-3*ones(numsum,1) 3*ones(numsum,1)];    %数据范围
individuals=struct('fitness',zeros(1,sizepop), 'chrom',[]);  %将种群信息定义为一个结构体
avgfitness=[];                      %每一代种群的平均适应度
bestfitness=[];                     %每一代种群的最佳适应度
bestchrom=[];                       %适应度最好的染色体

for i=1:sizepop                                  %随机产生一个种群
    individuals.chrom(i,:)=Code(lenchrom,bound);    %编码
    x=individuals.chrom(i,:);                     %计算适应度
    individuals.fitness(i)=fun(x,inputnum,hiddennum,outputnum,net,inputn,outputn);   %染色体的适应度
end

[bestfitness bestindex]=min(individuals.fitness);
bestchrom=individuals.chrom(bestindex,:);  %最好的染色体
avgfitness=sum(individuals.fitness)/sizepop; %染色体的平均适应度                              
trace=[avgfitness bestfitness]; % 记录每一代进化中最好的适应度和平均适应度

 for num=1:maxgen
    % 选择  
     individuals=select(individuals,sizepop);   
    avgfitness=sum(individuals.fitness)/sizepop; 
    %交叉  
    individuals.chrom=Cross(pcross,lenchrom,individuals,sizepop,bound);  
    % 变异  
    individuals.chrom=Mutation(pmutation,lenchrom,individuals,sizepop,num,maxgen,bound);      
    % 计算适应度   
   
    for j=1:sizepop  
        x=individuals.chrom(j,:); %个体 
        individuals.fitness(j)=fun(x,inputnum,hiddennum,outputnum,net,inputn,outputn);     
    end  
    %找到最小和最大适应度的染色体及它们在种群中的位置
    [newbestfitness,newbestindex]=min(individuals.fitness);
    [worestfitness,worestindex]=max(individuals.fitness);
    % 代替上一次进化中最好的染色体
if bestfitness>newbestfitness
        bestfitness=newbestfitness;
        bestchrom=individuals.chrom(newbestindex,:);
    end
    individuals.chrom(worestindex,:)=bestchrom;
    individuals.fitness(worestindex)=bestfitness;
    avgfitness=sum(individuals.fitness)/sizepop;
    trace=[trace;avgfitness bestfitness]; %记录每一代进化中最好的适应度和平均适应度
 end
 
 figure(1)
[r c]=size(trace);
plot([1:r]',trace(:,2),'b--');
title(['适应度曲线  ' '终止代数＝' num2str(maxgen)]);
xlabel('进化代数');ylabel('适应度');
legend('平均适应度','最佳适应度');
disp('适应度                   变量');
  

% 把最优初始阀值权值赋予网络预测

%用遗传算法优化的BP网络进行值预测

x=bestchrom;
w1=x(1:inputnum*hiddennum);
B1=x(inputnum*hiddennum+1:inputnum*hiddennum+hiddennum);
w2=x(inputnum*hiddennum+hiddennum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum);
B2=x(inputnum*hiddennum+hiddennum+hiddennum*outputnum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum);

net.iw{1,1}=reshape(w1,hiddennum,inputnum);
net.lw{2,1}=reshape(w2,outputnum,hiddennum);
net.b{1}=reshape(B1,hiddennum,1);
net.b{2}=reshape(B2,outputnum,1);

% BP网络训练
%网络参数
net.trainParam.epochs=100;
net.trainParam.lr=0.1;
net.trainParam.goal=0.00001;

net.divideParam.trainRatio = 75/100;   %默认训练集占比
net.divideParam.valRatio = 15/100;      %默认验证集占比
net.divideParam.testRatio = 15/100;     %默认测试集占比

%网络训练
[net,per2]=train(net,inputn,outputn);

% BP网络预测
%数据归一化
inputn_test=mapminmax('apply',input_test,inputps);
an=sim(net,inputn_test);
test_simu=mapminmax('reverse',an,outputps);
error=test_simu-output_test;

figure(2)
plot(test_simu,':og','LineWidth',1.5)
hold on
plot(output_test,'-*','LineWidth',1.5);
legend('预测输出','期望输出')
grid on
set(gca,'linewidth',1.0);
xlabel('X 样本','FontSize',15);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ylabel('Y 输出','FontSize',15);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gcf,'color','w')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title('GA-BP Network','Color','k','FontSize',15);

toc

