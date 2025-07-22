function [error, predict_result] = mse_mohu(individual, input, output, number_rules, num_scales, uscale)

% 初始化变量
size_input = size(input);
error = 0;
sigma = 0.2; % 隶属度函数的宽度
alpha = 1.0; % 决策边界调整因子

% 获取标签列
labels = output;  

% 计算类别1和类别0的样本比例
num_1 = sum(labels == 1);  % 类别1的样本数量
num_0 = sum(labels == 0);  % 类别0的样本数量
total_samples = num_1 + num_0;  % 总样本数量

p_1 = num_1 / total_samples;  % 类别1的比例
p_0 = num_0 / total_samples;  % 类别0的比例
% 动态调整 C_1 和 C_0


for i = 1:size_input(1,1)  % 遍历所有样本
   
    [rules_activated, weights_activated] = determine_rule_pipeline(input(i,:), individual(1:(size_input(1,2)) * number_rules), individual(((size_input(1,2)) * number_rules + 1):(size_input(1,2) + 1) * number_rules));
    scales_activated = zeros(length(rules_activated), num_scales);
    
    for j = 1:length(rules_activated)
        scales_activated(j,:) = individual((size_input(1,2) + 1) * number_rules + num_scales * rules_activated(j) - (num_scales - 1):(size_input(1,2) + 1) * number_rules + num_scales * rules_activated(j)); 
    end
    
    gt(i,:) = return_gt(weights_activated, scales_activated);
    
    % 基于类别的隶属度计算错误
    %[max_val, max_idx] = max(gt(i,:));  % 获取最大概率的类别

    %% 获取类别0和类别1的概率值
    belief_0 = gt(i, 1); % 类别0的概率
    belief_1 = gt(i, 2); % 类别1的概率
     % 计算类别1和类别0的隶属度
    mu_0 = gaussian_membership(belief_0, 1, sigma);  % 类别0的隶属度
    mu_1 = gaussian_membership(belief_1, 1, sigma);  % 类别1的隶属度

   %% 反模糊化
    if  mu_1 >  mu_0
        % 预测为类别1
        single_error(i) = 1;  % 根据类别1的隶属度加权错误
    else
        % 预测为类别0
        single_error(i) = 0;  % 根据类别0的隶属度加权错误
    end

end

% 根据最终的错误计算总误差
% 计算加权错误：根据类别比例调整惩罚
predict_result = single_error;
num_errors = sum(predict_result ~= output');
% 计算总样本数
total_samples = length(output);
% 计算错误率
error = num_errors / total_samples; %基础错误率
% 每个类别数据的个数
num_minority = sum(output == 1); % 少数类样本数
num_majority = total_samples - num_minority; % 多数类样本数

% 分类错误统计
fp_minority = sum((predict_result ~= output') & (output' == 1)); % 少数类误分类数
fp_majority = sum((predict_result ~= output') & (output' == 0)); % 多数类误分类数

% 分类错误率
error_minority = fp_minority / num_minority; % 少数类错误率
error_majority = fp_majority / num_majority; % 多数类错误率

C_1 = 1-p_1;  
C_0 =  1-p_0;  
penalty =  0.8*C_1*error_minority +  C_0*error_majority ;
% 总误差
error = error + penalty ; 



% predict_result = single_error;
% num_errors = sum(predict_result ~= output');
% error = num_errors / total_samples;  % 基础错误率

end

% 高斯隶属度函数
function mu = gaussian_membership(x, c, sigma)
    % x：输入样本，c：类别中心（0或1），sigma：宽度
    mu = exp(-(x - c).^2 / (2 * sigma^2));
end
