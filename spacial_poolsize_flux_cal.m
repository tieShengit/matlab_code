clear all;
clc;

% 根据测量的浓度数据直接取平均算其他时间点的poolsize值,使用nmol/g为单位
% 文件路径 计算苜蓿的poolsize 
your_fold_path = './2025_data_cal/new_data/first/';
met_names = {'Malic', 'Fumaric' };

% 代谢物浓度 nmol/g
% 酢浆草浓度
malic_concentration = [1682.015, 2007.131, 2013.333, 2360.016];
fumaric_concentration = [104.214, 108.881, 111.980, 98.274];

% 苜蓿浓度
% malic_concentration = [1550, 1410, 1450, 1220,1410,1480,1230,1050,980,890,1010,1150];
% fumaric_concentration = [913.81,950.61,965.71,963.82,911.9,908.74,923.65,891.56,...
%     895.76,935.73,916.89,951.35,934.69,874.2,963.54,965.41];

asp_concentration = [1,1];
met_concentration = [mean(malic_concentration), mean(fumaric_concentration)];
met_con_map = containers.Map(met_names,met_concentration);

time_point = 6;

%  使用Malic t1 时间点m0不为0的位置计算sum_mid_sum
mal_t1_sum_mid = readmatrix([your_fold_path 'Malic/Malic_t1_used_data.xlsx'],Sheet='MID_SUM');

non_zero_bealoon = mal_t1_sum_mid ~=0;
for i=1:length(met_names)
    met_name = met_names{i};
    all_nor_sum = zeros(size(mal_t1_sum_mid));
    all_mid_sum = zeros(size(mal_t1_sum_mid));
    for t=1:6
        mid_sum = readmatrix([your_fold_path met_name '/' met_name '_t' num2str(t) '_used_data.xlsx'],Sheet='nor_mid_sum');
        MID_SUM = readmatrix([your_fold_path met_name '/' met_name '_t' num2str(t) '_used_data.xlsx'],Sheet='MID_SUM');
        used_data = mid_sum .* non_zero_bealoon;
        each_sum = MID_SUM .* non_zero_bealoon;
        all_nor_sum = all_nor_sum + used_data;
        all_mid_sum = all_mid_sum + each_sum;
    end

    time_sum_nor = all_nor_sum/time_point;
    writematrix(time_sum_nor,[your_fold_path met_name '_nor_mid_sum.xlsx'])
    sum_kai = time_sum_nor(non_zero_bealoon);
    average_kai = mean(sum_kai);

%     使用kfp参数和计算得到每个空间点的pool_size得到flux
    mid_sum_mean = all_mid_sum/time_point;
    mean_sum_kai = mid_sum_mean(non_zero_bealoon);
    mean_kai = mean(mean_sum_kai);
    spacial_points_pool = mid_sum_mean .* met_con_map(met_name)/mean_kai;

%    poolsize绝对值
    writematrix(spacial_points_pool,[your_fold_path met_name '_pool_abs.xlsx'])

%     读取kfp参数
    kfp_params = readmatrix([your_fold_path 'Malic_Fumaric_cons_20_kfp_alpha.xlsx'],Sheet=[met_name '_kfp']);
    alpha_params = readmatrix([your_fold_path 'Malic_Fumaric_cons_20_kfp_alpha.xlsx'],Sheet=[met_name '_alpha']);
    alpha_params(alpha_params == 0) = 1;
    alpha_copy1 = ones(size(alpha_params));
    alpha_copy2 = alpha_copy1 -alpha_params;

    spacial_point_flux = spacial_points_pool .* kfp_params .* alpha_copy2;


    % 写入该物质的空间点的flux
    writematrix(spacial_point_flux,[your_fold_path met_name '_20_flux.xlsx'])

end


