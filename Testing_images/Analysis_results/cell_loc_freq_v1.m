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
    for i=1:length(csv_files)
        % Get current data to load
        data = readmatrix(csv_files{i});
        xdata = sort(data(:,1));
        get_freq(xdata,csv_files{i},'X Coordinate Frequency',step)
        ydata = sort(data(:,2));
        get_freq(ydata,csv_files{i},'Y Coordinate Frequency',step);
        
    end
end

%% Function to get frequency of numbers
function get_freq(locations,title_,x_or_y,step)
    %if step == 1
        %edges = unique(locations);
    %end
    edges = min(locations):step:max(locations)+step;
    frequency = histcounts(locations, edges);
    percent_freq = frequency/length(locations);
    % Plot the graph
    figure;
    plot(edges(1:end-1), percent_freq);
    % Find the position of the first underscore
    underscoreIndex = strfind(title_, '_');
    title_ = title_(1:underscoreIndex(1)-1);
    title(title_)
    xlabel(x_or_y);
    ylabel('Occurrences');
end