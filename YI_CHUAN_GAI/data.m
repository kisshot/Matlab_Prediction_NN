
%下载输入输出数据
input = load('input.txt');
output = load('output.txt');
save data input output
iitrain = input(1:150,:)';
ootrain = output(1:150,:)';
iitest = input(151:186,:)';
ootest = output(151:186,:)';

% 数据
train = load('wind_power_train.txt');
test = load('wind_power_test.txt');
save data train test

input_train = train(:,1:13)';
output_train = train(:,14)';
input_test = test(:,1:13)';
output_test = test(:,14)';