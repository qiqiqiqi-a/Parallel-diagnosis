function gt = return_gt(weights_activated, scales_activated)

if length(weights_activated) == 1
   
    gt = scales_activated;
    
else
    
    size_scales = size(scales_activated);
    
    m = zeros(length(weights_activated), size_scales(1,2));
    m_R = zeros(length(weights_activated));
    m_R_ = zeros(length(weights_activated));

    % cal m_k,l, m_R,l
    for i =1:length(weights_activated)
         
        m(i,:) = weights_activated(i) * scales_activated(i,:);
    end

    m_R = - (weights_activated-1); 
    m_R_ = - (weights_activated-1); 

    % calc miu
    miu = 1;
    miu_1 = ones(1,length(weights_activated));
    miu_2 = 1;

    for i =1:length(weights_activated)
       
        an(i,:) = m(i,:) + m_R_(i);
    end

    miu_1 = cumprod(an);

    miu_1(1:(length(weights_activated) -1),:) = [];

    miu_2 = cumprod(m_R_);
    
    miu = 1/ ( sum(miu_1) - (size_scales(1,2) -1)* miu_2(length(miu_2)));

    % calc m
    m_k =  miu .* ( miu_1 - miu_2(length(miu_2)) );

    m_H_ = miu * miu_2(length(miu_2)) ;

    gt = m_k ./ (1-m_H_);
    
end

end