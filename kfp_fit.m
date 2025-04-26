function [k_opt, alpha_opt, k_interval] = kfp_fit(time_label)
% kfp_fit - Fit k and alpha parameters based on time_label data.
%
% Inputs:
%   time_label - Array of measured labeled fractions at specific times.
%
% Outputs:
%   k_opt      - Fitted value for k.
%   alpha_opt  - Fitted value for alpha.
%   k_interval - 95% confidence interval for k.

% Define time points (hours)
t = [0.083, 0.5, 1, 2, 3, 5];

% Calculate unlabeled values (assuming total = 1)
unlabeled_values = ones(1, length(time_label)) - time_label;

% Define the model function
model = @(x, t) (x(2) + (1 - x(2)) * exp(-x(1) * t));

% Initial guess for [k, alpha]
k_value = 0.01; 
alpha = 0.01;
x0 = [k_value, alpha];

% Constraints
lb = [0.0001, 0];  % Lower bounds for [k, alpha]
ub = [20, 1];      % Upper bounds for [k, alpha]

% Perform nonlinear least squares curve fitting
[paras_opt, ~, resi, ~, ~, ~, J] = lsqcurvefit(model, x0, t, unlabeled_values, lb, ub);

% Calculate 95% confidence intervals
ci = nlparci(paras_opt, resi, 'jacobian', J);

% Extract results
k_interval = ci(1,:);      % Confidence interval for k
k_opt = paras_opt(1);      % Optimal k
alpha_opt = paras_opt(2);  % Optimal alpha
end
