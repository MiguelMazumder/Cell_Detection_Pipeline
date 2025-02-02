% Author: Miguel Mazumder -> mfmmazumder@gwmail.gwu.edu
% Date: 11/29/2023 FIX QUADRANT COUNTER
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
    prompt1 = {'Enter step size: '};
    dlgtitle1 = 'Frequency Step Size';
    fieldsize1 = [1 50];
    definput1 = {'20'};
    answer = inputdlg(prompt1,dlgtitle1,fieldsize1,definput1);
    step = str2double(answer);
    % Create a dialog box with two input fields
    prompt = {'Enter x dimension of images:', 'Enter y dimension of images:'};
    dlgtitle = 'Image dimensions required for average frequency of cells across images';
    dims = [1 50]; % Dimensions of the input fields
    % Default values
    definput = {'2818', '2698'};
    % Show the dialog box and wait for user input
    answer2 = inputdlg(prompt, dlgtitle, dims, definput);
    num1 = str2double(answer2{1});x_bins=1:step:num1;
    num2 = str2double(answer2{2});y_bins=1:step:num2;
    x_bin_count = zeros(1,length(x_bins)-1);
    y_bin_count = zeros(1,length(y_bins)-1);
    for i=1:length(csv_files)
        % Get current data to load
        data = readmatrix(csv_files{i});
        xdata = sort(data(:,1));
        [cell_count_x]=get_freq(xdata,csv_files{i},'X Coordinate of image',x_bins);
        x_bin_count = x_bin_count + cell_count_x;
        ydata = sort(data(:,2));
        [cell_count_y]=get_freq(ydata,csv_files{i},'Y Coordinate of image',y_bins);
        y_bin_count = y_bin_count + cell_count_y;
    end
    overallfolder_frequnecy_per_bin_count(x_bin_count,y_bin_count,x_bins,y_bins)
end

%% Function to get frequency of numbers
function [cell_counter] = get_freq(locations,title_,x_or_y,bin_dim)
    %edges = min(locations):step:max(locations)+step;
    cell_counter = histcounts(locations, bin_dim);
    percent_freq = cell_counter/length(locations);
    disp("end")
    disp(percent_freq(end))
    disp("minus 1")
    disp(percent_freq(end-1))
    % Plot the graph
    figure;
    plot(bin_dim(1:end-1), percent_freq);
    % Find the position of the first underscore
    underscoreIndex = strfind(title_, '_');
    title_ = title_(1:underscoreIndex(1)-1);
    title(title_)
    xlabel(x_or_y);
    ylabel('Frequency');
end
function overallfolder_frequnecy_per_bin_count(x_bin_count,y_bin_count,x_bins,y_bins)
%X bin plot
    x_percent_freq = x_bin_count/sum(x_bin_count);
    % Plot the graph
    figure;
    plot(x_bins(1:end-1), x_percent_freq);
    title('Average cell count frequency across X bins');
    xlabel('X Coordinate of image');
    ylabel('Frequency');
%Y bin plot
    y_percent_freq = y_bin_count/sum(y_bin_count);
    % Plot the graph
    figure;
    plot(y_bins(1:end-1), y_percent_freq);
    title('Average cell count frequency across Y bins');
    xlabel('Y Coordinate of image');
    ylabel('Frequency');
end