clear all;
clc;

% Calculate the poolsize value for other time points directly based on the measured concentration data, using nmol/g as the unit
% File path to calculate the poolsize of alfalfa
your_fold_path = './2025_data_cal/new_data/first/';
met_names = {'Malic', 'Fumaric'};

% Metabolite concentrations in nmol/g
% Oxalis concentration
malic_concentration = [1682.015, 2007.131, 2013.333, 2360.016];
fumaric_concentration = [104.214, 108.881, 111.980, 98.274];

% Alfalfa concentration
% malic_concentration = [1550, 1410, 1450, 1220,1410,1480,1230,1050,980,890,1010,1150];
% fumaric_concentration = [913.81,950.61,965.71,963.82,911.9,908.74,923.65,891.56,...
%     895.76,935.73,916.89,951.35,934.69,874.2,963.54,965.41];

asp_concentration = [1,1];
met_concentration = [mean(malic_concentration), mean(fumaric_concentration)];
met_con_map = containers.Map(met_names,met_concentration);

time_point = 6;

% Use the positions where Malic t1 time point m0 is non-zero to calculate sum_mid_sum
mal_t1_sum_mid = readmatrix([your_fold_path 'Malic/Malic_t1_used_data.xlsx'],Sheet='MID_SUM');

non_zero_bealoon = mal_t1_sum_mid ~= 0;
for i = 1:length(met_names)
    met_name = met_names{i};
    all_nor_sum = zeros(size(mal_t1_sum_mid));
    all_mid_sum = zeros(size(mal_t1_sum_mid));
    for t = 1:6
        mid_sum = readmatrix([your_fold_path met_name '/' met_name '_t' num2str(t) '_used_data.xlsx'],Sheet='nor_mid_sum');
        MID_SUM = readmatrix([your_fold_path met_name '/' met_name '_t' num2str(t) '_used_data.xlsx'],Sheet='MID_SUM');
        used_data = mid_sum .* non_zero_bealoon;
        each_sum = MID_SUM .* non_zero_bealoon;
        all_nor_sum = all_nor_sum + used_data;
        all_mid_sum = all_mid_sum + each_sum;
    end

    time_sum_nor = all_nor_sum / time_point;
    writematrix(time_sum_nor, [your_fold_path met_name '_nor_mid_sum.xlsx'])
    sum_kai = time_sum_nor(non_zero_bealoon);
    average_kai = mean(sum_kai);

    % Use kfp parameters and calculate the pool_size at each spatial point to get flux
    mid_sum_mean = all_mid_sum / time_point;
    mean_sum_kai = mid_sum_mean(non_zero_bealoon);
    mean_kai = mean(mean_sum_kai);
    spacial_points_pool = mid_sum_mean .* met_con_map(met_name) / mean_kai;

    % Absolute value of poolsize
    writematrix(spacial_points_pool, [your_fold_path met_name '_pool_abs.xlsx'])

    % Read kfp parameters
    kfp_params = readmatrix([your_fold_path 'Malic_Fumaric_cons_20_kfp_alpha.xlsx'],Sheet=[met_name '_kfp']);
    alpha_params = readmatrix([your_fold_path 'Malic_Fumaric_cons_20_kfp_alpha.xlsx'],Sheet=[met_name '_alpha']);
    alpha_params(alpha_params == 0) = 1;
    alpha_copy1 = ones(size(alpha_params));
    alpha_copy2 = alpha_copy1 - alpha_params;

    spacial_point_flux = spacial_points_pool .* kfp_params .* alpha_copy2;

    % Write the flux of spatial points for this metabolite
    writematrix(spacial_point_flux, [your_fold_path met_name '_20_flux.xlsx'])
end
