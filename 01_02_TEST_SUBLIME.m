%{
1. 初始化
2. 读取输入输出数据
3. 输入输出数据归一化

3.5	将已知数据利用dividevec函数划分为训练数据、变化数据、测试数据

4. 创建神经网络
5. 设置训练参数：
6. 开始训练

7. 仿真
8. 输入数据进行预测
9. 计算误差
10.绘图
%}

% -----参考文件中有FOR I = 0 : 200这样的循环??????????????????????????????，要再看一下

clear;

clc;

%{
输入数据input，共15组数据，每组3个数据
对应电压、电流等输入量
%}
input = [493 372 445;372 445 176;445 176 235;176 235 378;235 378 429;
		378 429 561;429 561 651;561 651 467;651 467 527;467 527 668;
   		527 668 841; 668 841 526;841 526 480;526 480 567;480 567 685]';  %注意转置符号不能少

%{
输出数据output，共15组数据，每组1个数据
对应风电输出功率，即我们要求得的预测值
%}
output = [176 235 378 429 561 651 467 527 668 841 526 480 567 685 507];

%{
数据归一化	
%}
[normInput, is] = mapminmax(input);
[normOutput, os] = mapminmax(output);
%[p1,minp,maxp,t1,mint,maxt]=premnmx(input,output);
% 归一化用premnmx函数，反归一化用postmnmx函数

%{
数据乱序及分类处理
将数据划分为训练数据、变化数据、测试数据	
%}

%--------------这里将输入数据和输出数据分别加以划分，会打乱它们的一一对应关系吗？????????????????????
[trainSample.i,valideSample.i,testSample.i] =dividerand(normInput,0.7,0.15,0.15);

[trainSample.o,valideSample.o,testSample.o] =dividerand(normOutput,0.7,0.15,0.15);


%{
创建神经网络
使用newff函数
改进：将参数提取出来设置为变量
http://blog.sina.com.cn/s/blog_5f853eb10100zyib.html
%}
net = newff(minmax(normInput), [10,1], {'tansig','tansig','purelin'}, 'trainlm');

%{
神经网络参数配置
%}
net.trainParam.epochs = 5000;%设置训练次数
net.trainParam.goal=0.0000001;%设置收敛误差
net.trainParam.show=20;% 显示频率，这里设置为没训练20次显示一次
net.trainParam.mc=0.95;% 附加动量因子
net.trainParam.lr=0.05;% 学习速率，这里设置为0.05
net.trainParam.min_grad=1e-6;%最小性能梯度
net.trainParam.min_fail=5;% 最大确认失败次数

%{
开始训练神经网络	
%}
net.trainFcn='trainlm';
[net,tr]=train(net,trainSample.i,trainSample.o);
% [net,tr]=train(net,normInput,normOutput);


%{
训练完成后开始仿真
使用sim函数	
%}
[normTrainOutput,trainPerf]=sim(net,trainSample.i,[],[],trainSample.o);%训练的数据，根据BP得到的结果
[normValidateOutput,validatePerf]=sim(net,valideSample.i,[],[],valideSample.o);%验证的数据，经BP得到的结果
[normTestOutput,testPerf]=sim(net,testSample.i,[],[],testSample.o);%测试数据，经BP得到的结果
% [normTestOutput,testPerf]=sim(net,normInput,[],[],normOutput);%测试数据，经BP得到的结果

%{
仿真后结果数据反归一化，如果需要预测，只需将预测的数据input填入
将获得预测结果output
%}
trainOutput = mapminmax('reverse',normTrainOutput,os);%训练数据：BP得到的归一化后的结果output
trainInsect = mapminmax('reverse',trainSample.o,os);%训练数据已知的输出output
validateOutput = mapminmax('reverse',normValidateOutput,os);%变量数据：BP得到的归一化的结果output
validateInsect = mapminmax('reverse',valideSample.o,os);%变量的数据已知的输出output
testOutput = mapminmax('reverse',normTestOutput,os);%测试数据：BP得到的归一化的结果output
testInsect = mapminmax('reverse',testSample.o,os);%测试数据已知的输出output
% testOutput = mapminmax('reverse',normTestOutput,os);%测试数据：BP得到的归一化的结果output
% testInsect = mapminmax('reverse',normOutput,os);%测试数据已知的输出output

%{
做预测，输入要预测的数据pnew
%}
pnew=[313,256,239]'; %输入待预测数据
pnewn=mapminmax(pnew); %归一化
anewn=sim(net,pnewn); %仿真
anew=mapminmax('reverse',anewn,os); %反归一化得到预测结果


%{
%绝对误差计算
absTrainError = trainOutput-trainInsect;
absTestError = testOutput-testInsect;
error_sum=sqrt(absTestError(1).^2+absTestError(2).^2+absTestError(3).^2);
All_error=[All_error error_sum];
eps=90;%其为3组测试数据的标准差，或者每个数据偏差在一定范围内而判别
if ((abs(absTestError(1))<=30)&(abs(absTestError(2))<=30)&(abs(absTestError(3))<=30)|(error_sum<=eps))
save mynetdata net
     break
end
j
end
j
Min_error_sqrt=min(All_error)

testOutput
testInsect
%}

%{
数据分析和绘图

figure
plot(1:12,[trainOutput validateOutput],'b-',1:12,[trainInsect validateInsect],
'g--',13:15,testOutput,'m*',13:15,testInsect,'ro');

title('o为真实值，*为预测值')

xlabel('年份');
ylabel('交通量（辆次/昼夜）');

figure
xx=1:length(All_error);
plot(xx,All_error)
title('误差变化图')

%}
