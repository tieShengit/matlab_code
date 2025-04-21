clear all;
clc;

% 统一表大小
source_path_name = './2025_data_cal/0406/data/first/';

mets_name = {'Malic','Fumaric'}; 

% 获取统一表大小值
sizex = 0;sizey = 0;
for sz=1:6
    mal_path = [source_path_name 'Malic' '/' 'Malic' '_t' num2str(sz) '_tformed_data.xlsx'];    
    data_size = size(readmatrix(mal_path));
    if data_size(1) > sizey
        sizey = data_size(1);
    end
    if data_size(2) > sizex
        sizex = data_size(2);
    end 
end

% 遍历每个物质
for met=1:length(mets_name)
    
%     遍历每个时间点
    for t=1:6
    % 读取每个物质每个时间点的所有MID
    file_path = [source_path_name mets_name{met} '/' mets_name{met} '_t' num2str(t) '_tformed_data.xlsx'];
    save_path = [source_path_name mets_name{met} '/' mets_name{met} '_t' num2str(t) '_used_data.xlsx'];
    
    before_path = [source_path_name 'before/' mets_name{met} '/' mets_name{met} '_t' num2str(t) '_before.xlsx'];
    before_save_path = [source_path_name 'before/' mets_name{met} '/' mets_name{met} '_t' num2str(t) '_same_size_before.xlsx'];

    before_sum = zeros(sizey,sizex);
    before_m0 = readmatrix(before_path);
    m0_data = readmatrix(file_path);
    non_zero_values = m0_data ~= 0;
    before_non_zero_values = before_m0 ~= 0;
    mid_sum = zeros(sizey,sizex);
    sheet_num = length(sheetnames(file_path));
    
%     写入未配准数据
    before_sheets = sheetnames(before_path);
    for b = 1:length(sheetnames(before_path))
        sheet_name = before_sheets{b};
        null_Mi = zeros(sizey,sizex);
        Mi = readmatrix(before_path,Sheet=sheet_name);
        Mi = Mi.* before_non_zero_values;
        null_Mi(1:size(Mi,1),1:size(Mi,2)) = Mi;
        before_sum = before_sum + null_Mi;

        % 写入每个MID
        writematrix(null_Mi,before_save_path,"Sheet",sheet_name);
    end

%     写入总和
    writematrix(before_sum,before_save_path,"Sheet",'before_SUM');

    sheets = sheetnames(file_path);

%     统一表大小 读取每个mid
    for i = 1:sheet_num
        sheet_name = sheets{i};
        null_Mi = zeros(sizey,sizex);
        Mi = readmatrix(file_path,Sheet=sheet_name);
        Mi = Mi.* non_zero_values;
        null_Mi(1:size(Mi,1),1:size(Mi,2)) = Mi;

        % 累加
        mid_sum = mid_sum + null_Mi;
        % 写入
        writematrix(null_Mi,save_path,"Sheet",['used_' sheet_name]);
    end

    writematrix(mid_sum,save_path,"Sheet",'MID_SUM');
    finiteIdx = isfinite(mid_sum(:));

    % 写入总和
        % 将NaN值替换为0
    mid_sum(isnan(mid_sum)) = 0;
    
    % 将Inf值替换为1
    mid_sum(mid_sum==Inf) = 1;
    
    %将-Inf值替换为0
    mid_sum(mid_sum==-Inf) = 0;
    
    %将输入数据归一化到[0,1]范围内。
    FIXEDmin = min(mid_sum(:));
    FIXEDmax = max(mid_sum(:));
    if isequal(FIXEDmax,FIXEDmin)
        mid_sum = 0*mid_sum;
    else
        mid_sum(finiteIdx) = (mid_sum(finiteIdx) - FIXEDmin) ./ (FIXEDmax - FIXEDmin);
    end

    writematrix(mid_sum,save_path,"Sheet",'nor_mid_sum');

    end
    
end

