function [k_opt,beta_opt,k_interval] = kb_fit(time_label,ka)

% 定义时间点
t = [0.083, 0.5, 1, 2, 3, 5];

% 使用未标记度进行拟合
unlabeled_values = ones(1,length(time_label)) - time_label;

% 拟合函数
modelB = @(x, t) (x(2) + (1-x(2)) *(ka * exp(-x(1) * t) - x(1) * exp(-ka * t))/(ka-x(1)));

% 初始值和约束
kb = 0.01;
beta = 0.01;
x0 = [kb, beta];
lb = [0.0001,0];
ub = [20,1];

% kb_opt为拟合后的值
[params_opt,~,resi,~,~,~,J] = lsqcurvefit(modelB,x0, t, unlabeled_values,lb,ub);
ci = nlparci(params_opt,resi,'jacobian',J);
k_interval = ci(1,:);
k_opt = params_opt(1);
beta_opt = params_opt(2);
end