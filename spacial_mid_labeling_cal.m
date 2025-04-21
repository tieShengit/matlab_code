clear all;
clc;

% 计算每个物质每个时间点配准后的MID(比值形式)

data_sequence_number = 'first';

your_path = './';
path_str = [your_path data_sequence_number '/'];

mets_name = {'Malic','Fumaric',}; 
mets_cnum = {4,4};

time_label = cell(1,length(mets_name));

mids = {'M0','M1','M2','M3','M4'};

for met=1:length(mets_name)
    file1_path = [path_str 'Malic' '/' 'Malic' '_t' '1' '_used_data.xlsx'];
    mid0_matrix = readmatrix(file1_path,Sheet="used_M0");
    met_mean_label = [];
    
    % 读取数据
    for t=1:6
    fprintf(fp,'时间点 %d \n',t);
    file_path = [path_str mets_name{met} '/' mets_name{met} '_t' num2str(t) '_used_data.xlsx'];
    save_path = [path_str mets_name{met} '/' mets_name{met} '_t' num2str(t) '_caled_MID.xlsx'];

    before_path = [path_str 'before/' mets_name{met} '/' mets_name{met} '_t' num2str(t) '_same_size_before.xlsx'];
    before_save_path = [path_str 'before/' mets_name{met} '/' mets_name{met} '_t' num2str(t) '_mids_before.xlsx'];
    before_m0_matrix = readmatrix(before_path,Sheet='M0');
    before_sum_matrix = readmatrix(before_path,Sheet='before_SUM');
    before_mid_sheet_num = length(sheetnames(before_path))-1;
    before_non_zero_position = before_m0_matrix ~= 0;
    before_sheets = sheetnames(before_path);
    
    %   读取每个mid,计算比值
    for i = 1:length(mids)
        sheet_name =  mids{i};
        if ismember(sheet_name,before_sheets)
            Mi = readmatrix(before_path,Sheet=sheet_name);
            Mi(before_non_zero_position) = Mi(before_non_zero_position) ./ before_sum_matrix(before_non_zero_position);
            writematrix(Mi,before_save_path,"Sheet",sheet_name);
        end
    end

    m0_matrix = readmatrix(file_path,Sheet='used_M0');
    sum_matrix = readmatrix(file_path,Sheet='MID_SUM');
    mid_sheet_num = length(sheetnames(file_path))-1;
    non_zero_position = m0_matrix ~= 0;
    space_point_label = zeros(size(m0_matrix,1),size(m0_matrix,2));
    lower = zeros(size(m0_matrix,1),size(m0_matrix,2));
    upper = zeros(size(m0_matrix,1),size(m0_matrix,2));
    
    sheets = sheetnames(file_path);

    %   读取每个mid,计算比值
    for i = 1:length(mids)
        sheet_name = ['used_' mids{i}];
        if ismember(sheet_name,sheets)
            Mi = readmatrix(file_path,Sheet=sheet_name);
            Mi(non_zero_position) = Mi(non_zero_position) ./ sum_matrix(non_zero_position);
            writematrix(Mi,save_path,"Sheet",['percent_' mids{i}]);
            upper = upper + Mi * (i-1);
            lower = lower + Mi;
        end
    end
    
    lower = lower * mets_cnum{met};

    % 保存每个空间点的标记度
    space_point_label(non_zero_position) = upper(non_zero_position) ./ lower(non_zero_position);
    writematrix(space_point_label,save_path,"Sheet",'space_point_label');
    
    end

end



