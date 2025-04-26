clear all;
clc;

% Co-fitting, first calculate ka, then fit kb
% Malic is the upstream metabolite, Fumaric is the downstream metabolite

data_sequence_number = 'first';
path_str = ['./2025_data_cal/new_data/' data_sequence_number '/'];
upstream_met = 'Malic'; 
downstream_met = 'Fumaric';   

save_name = [path_str upstream_met '_' downstream_met '_cons_20_kfp_alpha.xlsx'];

% Parameter fitting
up_met_time_label_matrixes = cell(1, 6);
down_met_time_label_matrixes = cell(1, 6);

for i = 1:6
    filename1 = [path_str upstream_met '/' upstream_met '_t' num2str(i) '_caled_MID.xlsx'];
    filename2 = [path_str downstream_met '/' downstream_met '_t' num2str(i) '_caled_MID.xlsx'];
    current_m0 = readmatrix(filename1, Sheet='percent_M0');
    matrix_size = size(current_m0);

    % space_point_label
    up_met_time_label = readmatrix(filename1, Sheet='space_point_label');
    down_met_time_label = readmatrix(filename2, Sheet='space_point_label');
    up_met_time_label_matrixes{i} = up_met_time_label;
    down_met_time_label_matrixes{i} = down_met_time_label;
end
    
% Kfp parameter matrices for upstream and downstream metabolites
up_met_kfp_matrix = zeros(matrix_size);
down_met_kfp_matrix = zeros(matrix_size);
up_met_alpha_matrix = zeros(matrix_size);
down_met_alpha_matrix = zeros(matrix_size);
ka_l = zeros(size(up_met_kfp_matrix)); ka_u = zeros(size(up_met_kfp_matrix));
kb_l = zeros(size(up_met_kfp_matrix)); kb_u = zeros(size(up_met_kfp_matrix));

for x = 1:matrix_size(2)
    for y = 1:matrix_size(1)
            up_met_time_label = [];
            down_met_time_label = [];
            % Get the label data for the six time points for this spatial point
            for i = 1:6
                up_met_label_array = up_met_time_label_matrixes{i};
                down_met_label_array = down_met_time_label_matrixes{i};
                up_met_time_label = [up_met_time_label, up_met_label_array(y, x)];
                down_met_time_label = [down_met_time_label, down_met_label_array(y, x)];
            end
            u = all(up_met_time_label(:) == 0);
            d = all(down_met_time_label(:) == 0);

            % Check if all labels are zero
            if sum(up_met_time_label(:) == 0) <= 4 && sum(down_met_time_label(:) == 0) <= 4

                % Fit parameters and save to matrix Ka
                [ka, alpha, Ka_interval] = kfp_fit(up_met_time_label);
                ka_l(y, x) = Ka_interval(1); ka_u(y, x) = Ka_interval(2);
                up_met_kfp_matrix(y, x)  = ka;

                % Kb
                [kb, beta, Kb_interval] = kb_fit(down_met_time_label, ka);
                kb_l(y, x) = Kb_interval(1); kb_u(y, x) = Kb_interval(2);
                down_met_kfp_matrix(y, x) = kb;

                up_met_alpha_matrix(y, x) = alpha;
                down_met_alpha_matrix(y, x) = beta;
            end
    end
end

% Save kfp parameters
writematrix(up_met_kfp_matrix, save_name, Sheet=[upstream_met '_kfp']);
writematrix(down_met_kfp_matrix, save_name, Sheet=[downstream_met '_kfp']);

writematrix(ka_l, save_name, Sheet=[upstream_met '_lb']);
writematrix(ka_u, save_name, Sheet=[upstream_met '_ub']);

writematrix(kb_l, save_name, Sheet=[downstream_met '_lb']);
writematrix(kb_u, save_name, Sheet=[downstream_met '_ub']);

% Save alpha parameters
writematrix(up_met_alpha_matrix, save_name, Sheet=[upstream_met '_alpha']);
writematrix(down_met_alpha_matrix, save_name, Sheet=[downstream_met '_alpha']);
