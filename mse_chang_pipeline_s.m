function [error, predict_result] = mse_chang_pipeline_s(individual, input, output, number_rules, num_scales, uscale)
    size_input = size(input);
    error = 0;

    for i = 1:size_input(1, 1)
        % Determine the activated rules
        [rules_activated, weights_activated] = determine_rule_pipeline(input(i,:), individual(1:(size_input(1, 2)) * number_rules), individual(((size_input(1, 2)) * number_rules + 1):(size_input(1, 2) + 1) * number_rules));
        
        % Determine the scales_activated
        scales_activated = zeros(length(rules_activated), num_scales);
        for j = 1:length(rules_activated)
            scales_activated(j, :) = individual((size_input(1, 2) + 1) * number_rules + num_scales * rules_activated(j) - (num_scales - 1):(size_input(1, 2) + 1) * number_rules + num_scales * rules_activated(j));
        end

        gt(i, :) = return_gt(weights_activated, scales_activated);

        % 分类误差计算
        [max_val, max_idx] = max(gt(i, :));  % 找出最大值及其索引
        single_error(i) = uscale(max_idx);
    end
    
    predict_result = single_error;
    num_errors = sum(predict_result ~= output');

    total_samples = length(output);
    error = num_errors / total_samples;  % 基础错误率
    
    % 统计类别数量
    num_samples_minority = sum(output == 1);  % 少数类数量
    num_samples_majority = sum(output == 0);  % 多数类数量

    % 分类错误统计
    TP = sum((predict_result == 1) & (output' == 1));  % True Positives
    FP = sum((predict_result == 1) & (output' == 0));  % False Positives
    FN = sum((predict_result == 0) & (output' == 1));  % False Negatives
    TN = sum((predict_result == 0) & (output' == 0));  % True Negatives

    % 计算少数类的召回率、精确度和F1分数
    recall_1 = TP / (TP + FN + eps);  % 召回率
    precision_1 = TP / (TP + FP + eps);  % 精确度
    recall_0 = TN / (TN + FN + eps);  % 召回率
    precision_0 = TN / (TN + FP + eps);  % 精确度

    F1_minority = 2 * recall_1 * precision_1 / (recall_1 + precision_1 + eps);  % F1 分数
    F0_majority = 2 * recall_0 * precision_0 / (recall_0 + precision_0 + eps); 

    
    % 计算错误率
    error_majority = FP / (num_samples_majority + eps);  % 多数类错误率
    error_minority= FN / (num_samples_minority + eps);
    
    % 动态权重
    w_m = num_samples_minority / total_samples;  % 少数类权重
    w_M = num_samples_majority / total_samples;  % 多数类权重
    %% 使用平方根调整权重 顺序全数据
      %  w_m_adjusted = sqrt(1 / (w_m + eps));%5\8 
      % w_M_adjusted = sqrt(1 / w_M); % 5 8 
   %  %   w_M_adjusted = sqrt(1 / w_M)*2; % 1 2 3 4 6
   % % w_M_adjusted = sqrt(1 / w_M)*1.7; % 调整5
   % w_M_adjusted = sqrt(1 / w_M)*1.15; %调整8



   %  % % 
  %   w_m_adjusted = log(1 + 1/(w_m + eps));
  %   w_M_adjusted = log(1 + 1/(w_M + eps))*2;
  % % w_M_adjusted = log(1 + 1/(w_M + eps));%8 (sqrt)
  %  % w_M_adjusted = log(1 + 1/(w_M + eps))*1.4;% 5
  %  % w_M_adjusted = log(1 + 1/(w_M + eps))*1.8;% 1
  %  %  % %  
  %  %  % % %   %综合错误率
  %   error = error + w_m_adjusted*error_minority + w_M_adjusted *error_majority; 
   %  %   % error = error + w_m_adjusted*(1-F1_minority) + w_M_adjusted*(1-F1_majority);


    %%  调整权重 随机8:2
    w_m = log(1+(1-w_m)); %2 3 4 5 6 7 10 12
   % w_m = log(1+(1-w_m))*0.5;

   %% 加上限
   % w_m = min(log(1+(1-w_m)), 0.5);
  
    %   %综合错误率
       error = error +  w_m *error_minority ;%+ w_M  *error_majority; 
      
      
    

end


