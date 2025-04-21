function [k_opt,alpha_opt,k_interval] = kfp_fit(time_label)

% 定义时间点
t = [0.083, 0.5, 1, 2, 3, 5];

% 使用未标记度进行拟合
unlabeled_values = ones(1,length(time_label)) - time_label;

% kfp函数方程
model = @(x, t) (x(2) + (1-x(2)) * exp(-x(1) * t));

% 拟合 k_value，ka_opt为拟合后的值
k_value = 0.01; 
alpha = 0.01;
x0 = [k_value,alpha];
x1 = k_value;

% 约束
lb = [0.0001,0];
ub = [20,1];

[paras_opt,~,resi,~,~,~,J] = lsqcurvefit(model, x0,t, unlabeled_values,lb,ub);
ci = nlparci(paras_opt,resi,'jacobian',J);
k_interval = ci(1,:);
k_opt = paras_opt(1);
alpha_opt = paras_opt(2);
end