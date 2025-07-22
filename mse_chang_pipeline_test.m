function [error,predict_result,gt, T1, F1, T0, F0] = mse_chang_pipeline_test(individual, input, output,  number_rules, num_scales, uscale)

% the situation would be more complicated since there are two attributes
% which means that there could be as many as four rules activated and need
% to be integrated
size_input = size(input);
output_test = output';
error = 0;

for i = 1: size_input(1,1)  %800
     
    % determine the activated rules
    [rules_activated, weights_activated] = determine_rule_pipeline(input(i,:), individual(1: (size_input(1,2))*number_rules), individual(((size_input(1,2))*number_rules +1):(size_input(1,2) +1)*number_rules));
    
    % determine the scales_activated
    scales_activated = zeros(length(rules_activated),num_scales);
    
    for j =1: length(rules_activated)
         scales_activated(j,:) = individual((size_input(1,2)+1)*number_rules +num_scales*rules_activated(j)-(num_scales-1) :(size_input(1,2)+1)*number_rules +num_scales*rules_activated(j)); 
    end
    
    gt(i,:) = return_gt(weights_activated, scales_activated);
   

    %%分类误差计算
    % 找出 gt(i, :) 的最大值及其索引
    [max_val, max_idx] = max(gt(i, :)); 

  % 根据最大值的索引，在 uscale 中找到对应值，赋给 single_error
   single_error(i) = uscale(max_idx);
 
end
predict_result = single_error';
num_errors = sum(predict_result ~= output);

% 计算总样本数
total_samples = length(output);

% 计算错误率
error = num_errors / total_samples;

T1 = sum((predict_result == 1) & (output == 1));
F1 = sum((predict_result == 0) & (output == 1));
F0 = sum((predict_result == 1) & (output == 0));
T0 = sum((predict_result == 0) & (output == 0));

%predict_result = single_error;
%error = error / i;
