function [globalBestValue, globalBestIndividual, trace] = return_GA(btr_data, np, ng, number_rules, num_att, num_scales, ub_bound, lb_bound, uscale)

Nind = np; %% number of population 20个种群数

input = btr_data(:, 1:num_att);  %
output = btr_data(:, num_att+1);

%size_input(1,1) means the number of training/testing dataset
%size_input(1,2) means the number of input attributes
size_input = size(input);  % 800×4

% the number of variables means the sum of inputs and scales 输入与等级的总和
numVariables = number_rules *(size_input(1,2) +1 + num_scales); %50 变量数 我认为是基因数 及brb的参数 +1是规则权重

for i=1:size_input(1,2)
    
    lb(number_rules*(i-1) +1:number_rules * i) = lb_bound(i); %4×5
    ub(number_rules*(i-1) +1:number_rules * i) = ub_bound(i); 
    
end

lb(number_rules * size_input(1,2)+1 : numVariables) = 0;  % 21-50
ub(number_rules * size_input(1,2)+1 : numVariables) = 1;

% % %*** initial the population
pop = initializePop_pipeline(np, lb_bound, ub_bound, lb,ub,number_rules,numVariables,num_scales); %20×50

for i=1:Nind
    [objv(i),predict_result(i,:)] = mse_chang_pipeline_s(pop(i,:), input, output,  number_rules, num_scales, uscale);   
end
    
for gen =1:ng  %500
    
    if mod(gen,100) ==0
    
    gen
    
    end 
    
    %新的交叉变异
    % 动态调整交叉概率
    
       crossoverProb = 0.9;
  
   newPop = xovsp(pop, crossoverProb); % 动态交叉概率



    
    %newPop = xovsp(pop,0.9); % crossover
    newPop = mut(newPop); % mutation


     for k=1:np  
        for j=1:numVariables         %调整起点变量中违反约束的位
            if (newPop(k,j)<lb(1,j))&&(newPop(k,j)>=(2*lb(1,j)-ub(1,j)))
                newPop(k,j)=lb(1,j)+(lb(1,j)-newPop(k,j));
            end
            if (newPop(k,j)<=(2*ub(1,j)-lb(1,j)))&&(newPop(k,j)>ub(1,j))
                newPop(k,j)=ub(1,j)-(newPop(k,j)-ub(1,j));
            end
            if newPop(k,j)<(2*lb(1,j)-ub(1,j))
                newPop(k,j)=lb(1,j)+rand*(ub(1,j)-lb(1,j));
            end
            if newPop(k,j)>(2*ub(1,j)-lb(1,j))
                newPop(k,j)=lb(1,j)+rand*(ub(1,j)-lb(1,j));
            end    
        end
       
     end



   
        % reset and normalize the scales
    for ii=1:size_input(1,2) %4
    
        newPop(:,number_rules*(ii-1) +1) = lb_bound(ii);
        newPop(:,number_rules*ii ) = ub_bound(ii);

    
    end
        
    newPop(:,number_rules * (size_input(2) +1) +1:numVariables) = y_normalize(newPop(:,number_rules *(size_input(2) +1)+1:numVariables),num_scales);
        

   % new objective
    for i=1:Nind
        [newObjv(i),newpredict_result(i,:)] = mse_chang_pipeline_s(newPop(i,:), input, output,  number_rules, num_scales, uscale);   
    end
   
   allObjv = [objv, newObjv]; 
   allPop = [pop; newPop];
   [fitness, index] = sort(allObjv);
   pop = allPop(index(1:Nind),:);
   objv = allObjv(index(1:Nind));

   trace(gen) = min(objv);
   globalBestIndividual = pop(1,:);

   globalBestValue = trace(gen)
end
end
