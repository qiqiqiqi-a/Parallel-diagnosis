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

        % ����������
        [max_val, max_idx] = max(gt(i, :));  % �ҳ����ֵ��������
        single_error(i) = uscale(max_idx);
    end
    
    predict_result = single_error;
    num_errors = sum(predict_result ~= output');

    total_samples = length(output);
    error = num_errors / total_samples;  % ����������
    
    % ͳ���������
    num_samples_minority = sum(output == 1);  % ����������
    num_samples_majority = sum(output == 0);  % ����������

    % �������ͳ��
    TP = sum((predict_result == 1) & (output' == 1));  % True Positives
    FP = sum((predict_result == 1) & (output' == 0));  % False Positives
    FN = sum((predict_result == 0) & (output' == 1));  % False Negatives
    TN = sum((predict_result == 0) & (output' == 0));  % True Negatives

    % ������������ٻ��ʡ���ȷ�Ⱥ�F1����
    recall_1 = TP / (TP + FN + eps);  % �ٻ���
    precision_1 = TP / (TP + FP + eps);  % ��ȷ��
    recall_0 = TN / (TN + FN + eps);  % �ٻ���
    precision_0 = TN / (TN + FP + eps);  % ��ȷ��

    F1_minority = 2 * recall_1 * precision_1 / (recall_1 + precision_1 + eps);  % F1 ����
    F0_majority = 2 * recall_0 * precision_0 / (recall_0 + precision_0 + eps); 

    
    % ���������
    error_majority = FP / (num_samples_majority + eps);  % �����������
    error_minority= FN / (num_samples_minority + eps);
    
    % ��̬Ȩ��
    w_m = num_samples_minority / total_samples;  % ������Ȩ��
    w_M = num_samples_majority / total_samples;  % ������Ȩ��
    %% ʹ��ƽ��������Ȩ�� ˳��ȫ����
      %  w_m_adjusted = sqrt(1 / (w_m + eps));%5\8 
      % w_M_adjusted = sqrt(1 / w_M); % 5 8 
   %  %   w_M_adjusted = sqrt(1 / w_M)*2; % 1 2 3 4 6
   % % w_M_adjusted = sqrt(1 / w_M)*1.7; % ����5
   % w_M_adjusted = sqrt(1 / w_M)*1.15; %����8



   %  % % 
  %   w_m_adjusted = log(1 + 1/(w_m + eps));
  %   w_M_adjusted = log(1 + 1/(w_M + eps))*2;
  % % w_M_adjusted = log(1 + 1/(w_M + eps));%8 (sqrt)
  %  % w_M_adjusted = log(1 + 1/(w_M + eps))*1.4;% 5
  %  % w_M_adjusted = log(1 + 1/(w_M + eps))*1.8;% 1
  %  %  % %  
  %  %  % % %   %�ۺϴ�����
  %   error = error + w_m_adjusted*error_minority + w_M_adjusted *error_majority; 
   %  %   % error = error + w_m_adjusted*(1-F1_minority) + w_M_adjusted*(1-F1_majority);


    %%  ����Ȩ�� ���8:2
    w_m = log(1+(1-w_m)); %2 3 4 5 6 7 10 12
   % w_m = log(1+(1-w_m))*0.5;

   %% ������
   % w_m = min(log(1+(1-w_m)), 0.5);
  
    %   %�ۺϴ�����
       error = error +  w_m *error_minority ;%+ w_M  *error_majority; 
      
      
    

end


