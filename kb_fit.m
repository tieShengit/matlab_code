function [k_opt, beta_opt, k_interval] = kb_fit(time_label, ka)
% kb_fit - Fit kb and beta parameters based on time_label and known ka.
%
% Inputs:
%   time_label - Array of measured labeled fractions at specific times.
%   ka         - Known parameter (ka) for the model.
%
% Outputs:
%   k_opt      - Fitted value for kb.
%   beta_opt   - Fitted value for beta.
%   k_interval - 95% confidence interval for kb.

% Define time points (hours)
t = [0.083, 0.5, 1, 2, 3, 5];

% Calculate unlabeled values (assuming total = 1)
unlabeled_values = ones(1, length(time_label)) - time_label;

% Define the model function
modelB = @(x, t) (x(2) + (1 - x(2)) * (ka * exp(-x(1) * t) - x(1) * exp(-ka * t)) / (ka - x(1)));

% Initial guess and bounds
kb_init = 0.01;    % Initial guess for kb
beta_init = 0.01;  % Initial guess for beta
x0 = [kb_init, beta_init];
lb = [0.0001, 0];  % Lower bounds for [kb, beta]
ub = [20, 1];      % Upper bounds for [kb, beta]

% Perform nonlinear least squares curve fitting
[params_opt, ~, resi, ~, ~, ~, J] = lsqcurvefit(modelB, x0, t, unlabeled_values, lb, ub);

% Calculate 95% confidence intervals
ci = nlparci(params_opt, resi, 'jacobian', J);

% Extract results
k_interval = ci(1,:);     % Confidence interval for kb
k_opt = params_opt(1);    % Optimal kb
beta_opt = params_opt(2); % Optimal beta
end
