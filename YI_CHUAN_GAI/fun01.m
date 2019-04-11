% fun函数（BP神经网络预测，记录预测误差）

function error = fun01(x,input_num,hidden_num,output_num,net,input_norm,output_norm)
%该函数用来计算适应度值
%x          input     个体
%inputnum   input     输入层节点数
%outputnum  input     隐含层节点数
%net        input     网络
%net使用主函数中定义的网络，不需要再次创建
%inputn     input     训练输入数据
%outputn    input     训练输出数据
%error      output    个体适应度值
%提取
w1=x(1:input_num*hidden_num);
B1=x(input_num*hidden_num+1:input_num*hidden_num+hidden_num);
w2=x(input_num*hidden_num+hidden_num+1:input_num*hidden_num+hidden_num+hidden_num*output_num);
B2=x(input_num*hidden_num+hidden_num+hidden_num*output_num+1:input_num*hidden_num+hidden_num+hidden_num*output_num+output_num);
% net=newff(input_norm,output_norm,hidden_num);
%网络进化参数
net.trainParam.epochs=20;
net.trainParam.lr=0.1;
net.trainParam.goal=0.0001;
net.trainParam.show=100;
net.trainParam.showWindow=0;
%网络权值赋值
net.iw{1,1}=reshape(w1,hidden_num,input_num);
net.lw{2,1}=reshape(w2,output_num,hidden_num);
net.b{1}=reshape(B1,hidden_num,1);
net.b{2}=reshape(B2,output_num,1);

%网络训练
net=train(net,input_norm,output_norm);
an=sim(net,input_norm);
% error=sum(abs(an-output_norm));
error=sum(abs(an-output_norm)/output_norm);







