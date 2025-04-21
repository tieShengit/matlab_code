clear all;
clc;

% 使用已经获取的参数对每个物质每个时间点的所有MID进行配准
% 'Malic', 'Fumaric', 'SUC' 

% 修改样本序号
sampler_num = 'first';
params_floder = ['./2025_data_cal/0406/params/' sampler_num '/'];

% 修改文件路径
source_floder = 'C:\Users\Administrator\Desktop\2025计算\20250406/20250417/';

save_path_folder = ['./2025_data_cal/0406/data/' sampler_num '/'];

% 加载fixed图像的轮廓闭包
load([params_floder 'fixed_boundray.mat']);
mets_name = {'Malic','Fumaric'}; 

para_name = {'mal','fum'};
time_points = {'5min','30min','1h','2h','3h','5h'};
mids = {'M0','M1','M2','M3','M4'};
befor_data_save_fold = ['./2025_data_cal/0406/data/' sampler_num '/before/'];

if ~exist(befor_data_save_fold,'dir')
    mkdir(befor_data_save_fold)
    disp('创建before文件夹')
else
    disp('----')
end

for m=1:length(mets_name)
    met_name = mets_name{m};
    p_name = para_name{m};
    start = 1;
    fixed_matrix = readmatrix('C:\Users\Administrator\Desktop\2025计算\20250406\0330\30min-new-5ppm\MAL\MAL_m0_(4288483)_N_sum.xlsx');
    for t=start:length(time_points)
        save_path = [save_path_folder met_name '/'];
        before_save_path = [befor_data_save_fold met_name '/'];
        if ~exist(save_path,'dir')
            mkdir(save_path)
        else
            disp('---')
        end
        if ~exist(before_save_path,'dir')
            mkdir(before_save_path)
        else
            disp('---')
        end
        file_save_path = [save_path met_name '_t' num2str(t) '_tformed_data.xlsx'];
        before_file_save_path =[before_save_path met_name '_t' num2str(t) '_before.xlsx'];
        params_name = [para_name{m} '_t' num2str(t) '.mat'];

        %  加载对应参数
        load([params_floder params_name])
        current_t = time_points{t};
        current_folder = [source_floder current_t '/'  met_name '/'];

        % 找到对应文件
        for mid=1:length(mids)
            sheet_name = mids{mid};
            f_str = ['*m' num2str(mid-1) '*N_sum.xlsx'];
            files_name_list = dir(fullfile(current_folder, f_str));
            files_name = {files_name_list.name};

            % 存在该文件
            if ~isempty(files_name)
                full_path = fullfile(current_folder, files_name{1});
                movimg_matrix = readmatrix(full_path);
                fixed_matrix = im2gray(fixed_matrix);
                movimg_matrix = im2gray(movimg_matrix);
                
                fixed_matrix = maskMatrixWithPolygon(fixed_matrix,fix_img_boundary);

                % 将两张图像填充成同样分辨率
                [fixed_matrix,movimg_matrix] = convert2same(fixed_matrix, movimg_matrix);
                
                % 提取需要用到的部分
                movimg_matrix = maskMatrixWithPolygon(movimg_matrix,moving_img_boundary);
                
%                 写入预处理但是未变换的数据
                writematrix(movimg_matrix, before_file_save_path,'Sheet',sheet_name);
 
                % 获取参考
                movingRefObj = imref2d(size(movimg_matrix));
                fixedRefObj = imref2d(size(fixed_matrix));
                
                % 应用已有的参数配准,并显示配准结果
                tform = R1.Transformation;
                displace_fild = R1.DisplacementField;
                registered_1 = imwarp(movimg_matrix, movingRefObj, tform, 'OutputView', fixedRefObj, 'SmoothEdges', true,'interp','nearest');
                
                figure();
                subplot(121);h1 = heatmap(fixed_matrix,"Colormap",jet);
                h1.GridVisible = 'off';
                h1.XDisplayLabels = repmat({''},size(fixed_matrix,2),1);
                h1.YDisplayLabels = repmat({''},size(fixed_matrix,1),1);
                h1.ColorbarVisible = 'off';
                title('fixed');
                
                final_matrix = imwarp(registered_1,displace_fild,'SmoothEdges', true,'interp','nearest');
                subplot(122);
                h2 = heatmap(final_matrix,"Colormap",jet);
                h2.GridVisible = 'off';
                h2.XDisplayLabels = repmat({''},size(final_matrix,2),1);
                h2.YDisplayLabels = repmat({''},size(final_matrix,1),1);
                h2.ColorbarVisible = 'off';
                % set(gca,'position', [0 0 1 1]);
                title(sheet_name);
                
                
                %保存配准后的结果
                writematrix(final_matrix, file_save_path,'Sheet',sheet_name);
            end
            
            
        end
    end
end




