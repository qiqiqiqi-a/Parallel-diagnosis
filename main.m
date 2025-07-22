% load data
clc
clear
load origin_data.txt
data_out = origin_data(:,10:end);
new_data = zeros(size(data_out));

% 遍历每一行
for i = 1:size(data_out, 1)
    % 找到当前行的最大值及其索引
    [~, idx] = max(data_out(i, :));  % idx 为最大值的位置
    
    % 将该位置赋值为 1
    new_data(i, idx) = 1;
end
Newdata_out = new_data ;
count_ones = sum(new_data, 1);

 load data1.txt;
  data = data1;

% 读取第十列 选择疾病类型
column_10 = Newdata_out(:, 10);

% 将修改后的列重新赋值回原数据集
data(:, 10) = column_10;
sum1 = sum(data(:,10) ==1 );
sum0 = length(data(:,10)) - sum1;



%% 上下限
lb_bound = [0 0 0 0 0 0 0 0 0];
ub_bound = [1 1 1 1 1 1 1 1 1];



%% parameter settings

num_rules = 8;
num_att = 9;
num_scales = 2;
uscale = [0 1];

length = num_rules * (num_att + 1 + num_scales); %50 变量数
num_indi = 50; % 种群中个体的数量
gen_all = 200;
% gt_all_runs = zeros(30, 172, 2);
gt_all_runs = zeros(10,172, 2);

%%
for run =1:10

    % 
    shuffledData = data(randperm(size(data,1)),:); % 1000×5 size(training_Hu,1) 的作用是返回 training_Hu 这个矩阵的第一维的大小，也就是行数

    train_set = shuffledData(1:172,:);  
    test_set = shuffledData(1:172,:); 

     % 
    [error_GA(run) brb_GA(run,1:length) best_GA(run, 1:gen_all)] = return_GA(train_set, num_indi, gen_all, num_rules, num_att, num_scales, ub_bound, lb_bound, uscale);

    [error_test_GA(run), predict_result(run,:),gt_all_runs(run,:, :),T1(run,:), F1(run,:), T0(run,:), F0(run,:)] = mse_chang_pipeline_test(brb_GA(run,1:length), test_set(:,1:num_att), test_set(:, num_att + 1),  num_rules, num_scales, uscale); 
   %% 输出
   num_1(run) = sum(test_set(:,end)' == 1);
   num_0(run)= sum(test_set(:,end)' == 0);
   total_samples(run) = num_0(run)+ num_1(run);
   % 计算错误率
   acc(run)= 1- error_test_GA(run); %基础错误率
   TP_acc(run) = T1(run,:)/num_1(run);
   FP_acc(run) = F1(run,:)/num_1(run);
   TN_acc(run) = T0(run,:)/num_0(run);
   FN_acc(run) = F0(run,:)/num_0(run);
  % save error8_p0_p1_a_rule8.mat;
end




acc = acc';
TP_acc = TP_acc';
FP_acc = FP_acc';
TN_acc = TN_acc';
figure(1);
plot(test_set(:,end), 'bo');
hold on
plot(predict_result(1,:), 'r*');
title('第一种疾病');
legend('测试数据', '预测数据');


save illness8_rule10.mat;


