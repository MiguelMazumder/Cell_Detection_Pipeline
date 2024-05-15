% Author: Miguel Mazumder -> mfmmazumder@gwmail.gwu.edu
% Date: 11/29/2023 FIX BIN SPACING
%% README
% This script produces graphs representing x or y cell location frequency
% for visualization of what is going on in each image

%% REQUIRMENTS: Place this script in the same folder as cell_location.csv files
%it will produce x and y frequency figures for each
%cell_location.csv file that exists in the folder.

%% BODY OF SCRIPT: Calling Folder Access, Read files, and Produce Figures
csvfiles = folder_access;
figure_visual(csvfiles)
%% FOLDER ACCESS
function [csvFileNames] = folder_access()
    csvFiles = dir('*cell_locations.csv');
    csvFileNames = {csvFiles.name};
    if isempty(csvFileNames)
        % Display an error message
        error('No cell_locations.csv files found. Cannot execute figure visualization.');
    end
end
%% CSV READ and Produce Figures
function figure_visual(csv_files)
    % Create a dialog box with two input fields
    prompt = {'Enter number of x bins:', 'Enter number of y bins:'};
    dlgtitle = 'User Input: Number of Bins';
    dims = [1 50]; % Dimensions of the input fields
    % Default values
    definput = {'20', '20'};
    % Show the dialog box and wait for user input
    answer = inputdlg(prompt, dlgtitle, dims, definput);
    
    xbin_num = str2double(answer{1});
    ybin_num = str2double(answer{2});
    
    % Create a dialog box with two input fields
    prompt = {'Enter x dimension of images:', 'Enter y dimension of images:'};
    dlgtitle = 'Image dimensions required for average frequency of cells across images';
    dims = [1 50]; % Dimensions of the input fields
    % Default values
    definput = {'2818', '2698'};
    % Show the dialog box and wait for user input
    answer2 = inputdlg(prompt, dlgtitle, dims, definput);
    num1 = str2double(answer2{1});y_bins=linspace(1,num1,xbin_num + 1);
    num2 = str2double(answer2{2});x_bins=linspace(1,num2,ybin_num + 1);
    xtotal_count = zeros(1,length(x_bins)-1);
    ytotal_count = zeros(1,length(x_bins)-1);
    for i=1:length(csv_files)
        % Get current data to load
        data = readmatrix(csv_files{i});

        % Get frequency for x and y coordinates
        [cell_count_x] = get_freq(data(:,1), csv_files{i}, 'X Coordinate of image', x_bins); %vertical bins (default 1:2698)
        xtotal_count = xtotal_count + cell_count_x;
        disp('x')
        disp(cell_count_x)
        [cell_count_y] = get_freq(data(:,2), csv_files{i}, 'Y Coordinate of image', y_bins); %horizontal bins (default 1:2818)
        disp('y')
        disp(cell_count_y)
        ytotal_count = ytotal_count + cell_count_y;
    end
    overallfolder_frequnecy_per_bin_count(xtotal_count,x_bins,'Average cell count frequency across X bins','X Coordinate of image')
    overallfolder_frequnecy_per_bin_count(cell_count_y,y_bins,'Average cell count frequency across Y bins','Y Coordinate of image')
end

%% Function to get frequency of numbers
function [cell_counter] = get_freq(locations, title_, x_or_y, bins)
    cell_counter = histcounts(locations, bins);
    percent_freq = cell_counter / sum(cell_counter);
    % Plot the graph
    figure;
    plot(bins(1:end-1), percent_freq);

    % Find the position of the first underscore
    underscoreIndex = strfind(title_, '_');
    title_ = title_(1:underscoreIndex(1)-1);
    title(title_);
    xlabel(x_or_y);
    ylabel('Frequency');
end

function overallfolder_frequnecy_per_bin_count(total_count,bins,x_or_y_title,x_or_y)
    % Get frequency
    percent_freq = total_count/sum(total_count);
    % Plot the graph
    figure;
    plot(bins(1:end-1), percent_freq);
    title(x_or_y_title);
    xlabel(x_or_y);
    ylabel('Frequency');
end
