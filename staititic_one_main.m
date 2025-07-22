clc;
clear;
%load outdata.txt;
%load new_out.txt;
data = dlmread('new_out.txt', '\t');

%data = outdata;

% 子特征数与权重
subfeature_counts = [1, 6, 5, 7, 10, 7, 9, 10, 9];
% subfeature_counts = [4, 6, 5, 7, 10, 7, 9, 10, 9];
weights = [1/3, 1/5, 1/4, 1/6, 1/9, 1/6, 1/8, 1/9, 1/8];

num_samples = size(data, 1);
num_features = length(subfeature_counts);

% 初始化统计结果
feature_occurrence_count = zeros(num_samples, num_features);

% 子特征统计和处理
start_idx = 1;
for i = 1:num_features
    subfeature_count = subfeature_counts(i);
    end_idx = start_idx + subfeature_count - 1;
    
    % 特殊处理第一个特征
    if i == 1
        % 对第一个特征，仅取原始输入数据，并乘以权重
        feature_occurrence_count(:, i) = data(:, start_idx:end_idx) ;
    else
        % 其他特征按统计逻辑处理
        feature_data = data(:, start_idx:end_idx);
        first_subfeature_active = feature_data(:, 1) == 1;
        feature_occurrence_count(:, i) = first_subfeature_active * 0.1 + (~first_subfeature_active) .* sum(feature_data, 2);
    end
    
    start_idx = end_idx + 1;
end

% 加权特征
weighted_features = feature_occurrence_count .* weights;
row_sums = sum(weighted_features, 2);

% 归一化
min_val = min(row_sums);
max_val = max(row_sums);
normalized_column = (row_sums - min_val) / (max_val - min_val);

% 整合新数据集
new_data = [weighted_features, normalized_column];

% 分级
grading_method = 'equal_interval'; % 修改为 'equal_frequency' 切换分级方式
if strcmp(grading_method, 'equal_interval')
    edges = linspace(min(normalized_column), max(normalized_column), 6);
    levels = discretize(normalized_column, edges, 'IncludedEdge', 'right');
elseif strcmp(grading_method, 'equal_frequency')
    [sorted_values, indices] = sort(normalized_column);
    n = length(normalized_column);
    num_per_group = ceil(n / 5);
    levels = zeros(n, 1);
    for i = 1:5
        start_idx = (i-1) * num_per_group + 1;
        end_idx = min(i * num_per_group, n);
        levels(indices(start_idx:end_idx)) = i;
    end
end

% 整合分级结果
final_data = [new_data, levels];
disp('处理完成的最终数据:');
disp(final_data);

% 保存结果（可选）
% writematrix(final_data, 'processed_data.csv');
