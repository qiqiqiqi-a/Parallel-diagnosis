function y_new = y_normalize(y,num_scales)

    size_y = size(y);
    
for i = 1: size_y(1,2)/num_scales
    
    total(:,1) = zeros(size_y(1,1),1);
    
   for j =1: num_scales
    
       total = total + y(:,(i-1) *num_scales + j);
    
   end    
    
   
   for j =1: num_scales
    
       y_new(:, (i-1) *num_scales + j) = y(:,(i-1) *num_scales + j)./total;
    
   end
       
end