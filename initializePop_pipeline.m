function y=initializePop_pipeline(np,lb_bound, ub_bound, lb,ub,number_rules,numVariables,num_scales)  %lq为起点中变量位的个数
y=zeros(np,numVariables);   
for i=1:length(lb)
    
    y(:,i)=lb(i)+(ub(i)-lb(i))*rand(np,1);  
end
for i=1:length(lb_bound)  %1-4
    
    y(:,number_rules*(i-1) +1) = lb_bound(i);
    y(:,number_rules*i) = ub_bound(i);
end
y(:,(number_rules * (length(lb_bound) +1)+1):numVariables) = y_normalize(y(:, (number_rules * (length(lb_bound) +1) +1):numVariables),num_scales);

  