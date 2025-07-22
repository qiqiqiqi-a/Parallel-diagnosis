function [rules ,weights] = determine_rule_pipeline(input, individual,weights_original)

% input
% individual

size_input = size(input);

abstract = zeros(length(input), length(individual)/length(input));

% determine the activated rules for x

for i = 1:length(input)  %%算每个属性 只要有一个属性沾边就算一个激活权重 最后合成 这就是并集 而交集只有都沾边才算激活权重
    
   abstract(i,:) = input(i) - individual((length(individual)/length(input)* (i-1) + 1): (length(individual)/length(input)* i));
    
   if i ==1
       
       if max(abstract(i,:)) ==0 || min(abstract(i,:)) ==0
       
           rule_activated(1) = find(abstract(i,:) == 0);
           weights_activated(1) = 1;
   
       else  %%没有等于其中某一个 那必然是在两个中间 会激活两个
       
           rule_activated(1) = find(abstract(i,:) == min(abstract(i,(find(abstract(i,:)>=0))))); %离左边最近 的索引 正的最小
           rule_activated(2) = find(abstract(i,:) == max(abstract(i,(find(abstract(i,:)< 0)))));%离右边边最近 的索引 负的最大
       %计算两个激活规则对应的 individual 矩阵中元素的绝对差距。
           gap = abs(individual (rule_activated(length(rule_activated) -1) + length(individual)/length(input) *(i-1)) - individual (rule_activated(length(rule_activated) ) + length(individual)/length(input) *(i-1)));
       %计算两个激活规则的权重。权重是输入值与 individual 矩阵中相应元素的差的绝对值除以 gap。
           weights_activated(length(rule_activated)- 1) = abs(input(i) - individual( rule_activated( length(rule_activated) )+length(individual)/length(input) *(i-1)) )/gap;

           weights_activated(length(rule_activated)) = abs(input(i) - individual( rule_activated( length(rule_activated) -1 )+length(individual)/length(input) *(i-1)) )/gap;
      
       end
       
   else
   
       if max(abstract(i,:)) ==0 || min(abstract(i,:)) ==0
       
           rule_activated(length(rule_activated) +1) = find(abstract(i,:) == 0);
           weights_activated(length(rule_activated) ) = 1;
   
       else
       
           
           
           
           rule_activated(length(rule_activated) + 1) = find(abstract(i,:) == min(abstract(i, (find(abstract(i,:)>=0)))));
           rule_activated(length(rule_activated) + 1) = find(abstract(i,:) == max(abstract(i, (find(abstract(i,:)< 0)))));
   
           gap = abs(individual (rule_activated(length(rule_activated) -1) + length(individual)/length(input) *(i-1)) - individual (rule_activated(length(rule_activated) ) + length(individual)/length(input) *(i-1)));
   
           weights_activated(length(rule_activated)- 1) = abs(input(i) - individual( rule_activated( length(rule_activated) )+length(individual)/length(input) *(i-1)) )/gap;

           weights_activated(length(rule_activated)) = abs(input(i) - individual( rule_activated( length(rule_activated) -1 )+length(individual)/length(input) *(i-1)) )/gap;
      
       end
   
   end
  
     
end


%eliminate the repeated rules

weights = zeros(length(individual)/length(input),1); %5条规则 5×1

for i=1:length(rule_activated)
    
    for j=1:length(individual)/length(input)  %1-5  在rule_activated中叠加相同 weights
        
        if rule_activated(i) == j
            
           weights(j) = weights(j) + weights_activated(i);
            
           break
        end            
    end
end

% normalize and delete the unnecessary weights 归一化权重并删除不必要的权重

for i =1: length(weights)
       
    rules(i) = i;
    weights(i) = weights(i) * weights_original(i);
    
end

total_weight = sum(weights);

weights = weights./total_weight;

weight_count = length(individual)/length(input);

count =0;

for i = 1: weight_count
    
    if weights(i - count) ==0

        rules(i - count) = [];
        weights(i - count) = [];  
        
        count = count +1;
        
    end

end
