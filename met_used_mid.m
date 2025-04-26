clear all;
clc;

% Unified table size
source_path_name = './2025_data_cal/0406/data/first/';

mets_name = {'Malic','Fumaric'}; 

% Get the unified table size values
sizex = 0; sizey = 0;
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

% Iterate over each substance
for met=1:length(mets_name)
    
    % Iterate over each time point
    for t=1:6
        % Read all MID for each substance at each time point
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
        
        % Write the unregistered data
        before_sheets = sheetnames(before_path);
        for b = 1:length(sheetnames(before_path))
            sheet_name = before_sheets{b};
            null_Mi = zeros(sizey,sizex);
            Mi = readmatrix(before_path,Sheet=sheet_name);
            Mi = Mi .* before_non_zero_values;
            null_Mi(1:size(Mi,1),1:size(Mi,2)) = Mi;
            before_sum = before_sum + null_Mi;

            % Write each MID
            writematrix(null_Mi,before_save_path,"Sheet",sheet_name);
        end

        % Write the sum
        writematrix(before_sum,before_save_path,"Sheet",'before_SUM');

        sheets = sheetnames(file_path);

        % Unified table size, read each MID
        for i = 1:sheet_num
            sheet_name = sheets{i};
            null_Mi = zeros(sizey,sizex);
            Mi = readmatrix(file_path,Sheet=sheet_name);
            Mi = Mi .* non_zero_values;
            null_Mi(1:size(Mi,1),1:size(Mi,2)) = Mi;

            % Accumulate
            mid_sum = mid_sum + null_Mi;
            % Write
            writematrix(null_Mi,save_path,"Sheet",['used_' sheet_name]);
        end

        writematrix(mid_sum,save_path,"Sheet",'MID_SUM');
        finiteIdx = isfinite(mid_sum(:));

        % Write the sum
        % Replace NaN values with 0
        mid_sum(isnan(mid_sum)) = 0;
        
        % Replace Inf values with 1
        mid_sum(mid_sum==Inf) = 1;
        
        % Replace -Inf values with 0
        mid_sum(mid_sum==-Inf) = 0;
        
        % Normalize the input data to the range [0,1]
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
