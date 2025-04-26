clear all;
clc;

% Register all MID for each substance and each time point with the obtained parameters
% 'Malic', 'Fumaric', 'SUC'

% Modify sample number
sampler_num = 'first';
params_floder = ['./2025_data_cal/0406/params/' sampler_num '/'];

% Modify file paths
source_floder = 'C:\Users\Administrator\Desktop\2025计算\20250406/20250417/';

save_path_folder = ['./2025_data_cal/0406/data/' sampler_num '/'];

% Load the boundary closure of the fixed image
load([params_floder 'fixed_boundray.mat']);
mets_name = {'Malic','Fumaric'}; 

para_name = {'mal','fum'};
time_points = {'5min','30min','1h','2h','3h','5h'};
mids = {'M0','M1','M2','M3','M4'};
befor_data_save_fold = ['./2025_data_cal/0406/data/' sampler_num '/before/'];

if ~exist(befor_data_save_fold,'dir')
    mkdir(befor_data_save_fold)
    disp('Creating before folder')
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

        % Load corresponding parameters
        load([params_floder params_name])
        current_t = time_points{t};
        current_folder = [source_floder current_t '/'  met_name '/'];

        % Find the corresponding files
        for mid=1:length(mids)
            sheet_name = mids{mid};
            f_str = ['*m' num2str(mid-1) '*N_sum.xlsx'];
            files_name_list = dir(fullfile(current_folder, f_str));
            files_name = {files_name_list.name};

            % The file exists
            if ~isempty(files_name)
                full_path = fullfile(current_folder, files_name{1});
                movimg_matrix = readmatrix(full_path);
                fixed_matrix = im2gray(fixed_matrix);
                movimg_matrix = im2gray(movimg_matrix);
                
                fixed_matrix = maskMatrixWithPolygon(fixed_matrix,fix_img_boundary);

                % Resize both images to the same resolution
                [fixed_matrix,movimg_matrix] = convert2same(fixed_matrix, movimg_matrix);
                
                % Extract the required part
                movimg_matrix = maskMatrixWithPolygon(movimg_matrix,moving_img_boundary);
                
%                 Write the preprocessed but untransformed data
                writematrix(movimg_matrix, before_file_save_path,'Sheet',sheet_name);
 
                % Get reference
                movingRefObj = imref2d(size(movimg_matrix));
                fixedRefObj = imref2d(size(fixed_matrix));
                
                % Apply the existing registration parameters and display the registration result
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
                
                % Save the registered results
                writematrix(final_matrix, file_save_path,'Sheet',sheet_name);
            end
        end
    end
end
