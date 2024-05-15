% Author: Miguel Mazumder -> mfmmazumder@gwmail.gwu.edu
% Date: 11/29/2023 CORRECT QUADRANTS, but counting seems fucked? Check
% indexing it seems to only going in first rows of each column
%% README
% Cell Detection and Counting function is responsible for seperating the
% input images into its respective channels, and finding the overlap of
% nucleus stain and cell stain to detect cells. This script accounts for
% blue nucleus stain and green cell stain

% Folder access function to read input tif files will look for specified
% folder

% Writing function will write .csv files with the name of their image
% and contain: overall cell count, and cell count per quadrant
% (distribution)

% Additional Functions not mentioned here are for formatting and saving
% purposes
%% BODY OF SCRIPT: Calling Folder Access, Cell Detection, and File Writing Functions
% retrieve tif file names and user requested dimensions of quadrants
[image_names, quadrant_dimensions] = folder_access;
% receive user input to save visuals of cell detection and cell locations
[merge_response] = additionalfeaturesprompt();
% initialize cell counter for quadrants
store_data = zeros(length(image_names),quadrant_dimensions(1)*quadrant_dimensions(2)+1);

for i=1:length(image_names)
    % Get current image to load
    current_image = imread(image_names{i});
    % Perform cell detection/count
    [cell_count,nucleus_loc,quadrant_cellcount] = cell_detect(current_image,quadrant_dimensions,image_names{i});
    % Update cell count by quadrant
    store_data(i,1) = cell_count;store_data(i,2:end) = quadrant_cellcount;
    %store additional features if desired
    executeoptions(merge_response, nucleus_loc,image_names{i})
    %cd into analysis folder, add figures, and optional cell locations
end
% save quadrant cell counter to csv file with column and row labels
[data_formatted] = create_headers(image_names, quadrant_dimensions, store_data);
%% Folder Access and Organization Function
function [tifFileNames, quad_dim] = folder_access()
    prompt = {'Enter full path of folder of .tif files'};
    dlgtitle = 'Directory Input';
    fieldsize = [1 50];
    definput = {pwd};
    dir_answer = inputdlg(prompt,dlgtitle,fieldsize,definput);
    cd(char(dir_answer));
    tifFiles = dir('*.tif*');
    tifFileNames = {tifFiles.name};
    if isempty(tifFileNames)
        % Display an error message
        error('No TIFF files found. Cannot execute cell detection analysis.');
    end

    prompt1 = {'Enter desired quadrant dimensions'};
    dlgtitle1 = 'Quadrant Dimensions';
    fieldsize1 = [1 50];
    definput1 = {'10x2'};
    quad_answer = inputdlg(prompt1,dlgtitle1,fieldsize1,definput1);
    xyquadrants = split(quad_answer,'x');
    quad_dim = str2double(xyquadrants);

    % Specify the folder name for results
    folderName = 'Analysis_results';

    % Check if the folder already exists
    if ~exist(folderName, 'dir')
        % Create the folder if it doesn't exist
        mkdir(folderName);
        disp(['Folder named "' folderName '" created successfully.']);
    else
        % Display a message if the folder already exists
        disp(['Folder named "' folderName '" already exists.']);
    end
end
%% Cell Detection and Counting Function
function [cell_counter, cell_loc_store, quadrant_count_vectorform] = cell_detect(base_image,quad_dim,current_image_name)
    %red = base_image(:,:,1); % red channel is not used but for future projects it may
    cell_stain = base_image(:,:,2); % green channel contains cell stain
    nucleus_stain = base_image(:,:,3); % blue channel contains nucleus stain
    % Initialize variables to store cell count 
    % Step 1: Thresholding
    threshold_cell = graythresh(cell_stain);
    binary_cell = imbinarize(cell_stain, threshold_cell);
    
    threshold_nucleus = graythresh(nucleus_stain);
    binary_nucleus = imbinarize(nucleus_stain, threshold_nucleus);
    
    % Step 2: Connected Components Labeling
    %labeled_cell = logical(binary_cell);
    labeled_nucleus = logical(binary_nucleus);
    
    % Step 3: Region Properties
    %props_cell = regionprops(labeled_cell, 'Centroid', 'Area');
    props_nucleus = regionprops(labeled_nucleus, 'Centroid', 'Area');
    
    % Step 4: Check for Overlap
    thresholdOverlap = 0.75; % 75% overlap threshold
    figure
    imshow(base_image); % Display original image for reference
    title(current_image_name);
    hold on;
    % Initialize variables to hold overall cell count and quadrant cell
    % count
    cell_counter = 0;
    quadrant_cellcount = zeros(quad_dim');
    quadrant_xboundries = linspace(0,size(base_image,2),quad_dim(2)+1);
    quadrant_yboundries = linspace(0,size(base_image,1),quad_dim(1)+1);
    cell_loc_store = [];
    %% Remove LATER
        % Plot vertical lines at quadrant_xboundries positions
    for i = 1:length(quadrant_xboundries)
        x_line = quadrant_xboundries(i);
        line([x_line, x_line], [0, size(base_image, 1)], 'Color', 'w','LineStyle', '--', 'LineWidth', 0.5);
    end
    
    % Plot horizontal lines at quadrant_yboundries positions
    for i = 1:length(quadrant_yboundries)
        y_line = quadrant_yboundries(i);
        line([0, size(base_image, 2)], [y_line, y_line], 'Color', 'w','LineStyle', '--', 'LineWidth', 0.5);
    end
    %%
    for i = 1:numel(props_nucleus)
        centroid_nucleus = props_nucleus(i).Centroid;
        x = round(centroid_nucleus(1));quadrant_xindex = 1;
        y = round(centroid_nucleus(2));quadrant_yindex = 1;
        
        % Check if the region around the centroid is within image bounds
        % (ignoring edges with the -50 from the size(cell_stain)
        if x > 1 && x < size(cell_stain, 2)-50 && y > 1 && y < size(cell_stain, 1)-50
            % Check the surrounding area in CD26
            area_cell = sum(sum(binary_cell(y-1:y+1, x-1:x+1)));
            
            % Calculate the overlap ratio
            overlapRatio = area_cell / (3 * 3); % Assuming a 3x3 region around the centroid
            
            % Check if overlap is above the threshold
            if overlapRatio >= thresholdOverlap
                rectangle('Position', [x-1, y-1, 3, 3], 'EdgeColor', 'r', 'LineWidth', 2);
                cell_loc_store = [cell_loc_store;x y];
                cell_counter = cell_counter + 1;
                % Determine quadrant location
                while x >= quadrant_xboundries(quadrant_xindex+1)
                    quadrant_xindex = quadrant_xindex + 1;
                    if quadrant_xindex == quad_dim(2)
                        break
                    end
                end
                while y >= quadrant_yboundries(quadrant_yindex+1)
                    quadrant_yindex = quadrant_yindex + 1;
                    if quadrant_yindex == quad_dim(1)
                        break
                    end
                end
                quadrant_cellcount(quadrant_yindex,quadrant_xindex) = quadrant_cellcount(quadrant_yindex,quadrant_xindex) + 1;
            end
        end
    end
    quadrant_count_vectorform = reshape(quadrant_cellcount, 1, []);
    hold off;
end
%% Formatting quadrant and overall cell count to a table to save as an xlsx file
function [data_formatted] = create_headers(image_names, quad_dim,data)
    columnLabels = cell(1, quad_dim(1)*quad_dim(2)+1);
    columnLabels{1} = 'Total Cell Count';
    for i = 2:length(columnLabels)
        columnLabels{i} = ['Q:' num2str(i-1)];
    end
    RowLabels = image_names';
    % Now make it neat and save as excel file
    data_formatted = array2table(data,'VariableNames', columnLabels, 'RowNames', RowLabels);
    cur_dir = pwd;cd('Analysis_results')
    writetable(data_formatted,'Cell_Count.csv','WriteRowNames', true);
    cd(cur_dir)
end
%% Function for additional features if prompted
function [merged_response] = additionalfeaturesprompt()
    answer = questdlg('Would you like to save the images of cell detection?', ...
	    'Visual Cell Detection Features', ...
	    'Yes','No','No');
    answer1 = questdlg('Would you like to save detected cells locations of each image?', ...
	    'Cell Location Features', ...
	    'Yes','No','No');
    % Handle response
    switch answer
        case 'Yes'
            visual_response = 1;
        case 'No'
            visual_response = 2;
    end
    switch answer1
        case 'Yes'
            data_response = 1;
        case 'No'
            data_response = 2;
    end
    merged_response = strcat(num2str(visual_response),num2str(data_response));
end
%% Function to execute additional features
function executeoptions(vis_dat_response, nucleus_loc,current_image)%current_image is image_names{i}
    currentDir = pwd;
    switch vis_dat_response
        case '11'
            [~, baseName, ~] = fileparts(current_image);
            imgName = [baseName, '_visual_cell_count.tif'];
            dataName = [baseName, '_cell_locations.csv'];
            %cd into Analysis_results folder
            cd('Analysis_results')
            % save image
            saveas(gcf,imgName)
            close(gcf)
            % save cell locations
            writematrix(nucleus_loc,dataName)
            %cd .. back out for next image
            cd(currentDir)
        case '12'
            [~, baseName, ~] = fileparts(current_image);
            imgName = [baseName, '_visual_cell_count.tif'];
            %cd into Analysis_results folder
            cd('Analysis_results')
            % save image
            saveas(gcf,imgName)
            close(gcf)
            %cd .. back out for next image
            cd(currentDir)
        case '21'
            [~, baseName, ~] = fileparts(current_image);
            dataName = [baseName, '_cell_locations.csv'];
            %cd into Analysis_results folder
            cd('Analysis_results')
            % save cell locations
            writematrix(nucleus_loc,dataName)
            %cd .. back out for next image
            cd(currentDir)
        case '22'
            disp("Did not save visuals or cell locations")  
    end
end
%% EDITING Folder access and file writing functions
% Change folder names (Old, Young): crtl - f "group1" or "group2"
%% EDITING Cell detection function
% Change channel overlap to detect cell : ctrl-f "thresholdOverlap"

% Change which channel contains the nucleus: crtl-f "nucleus = "

% Change which channel contains the cell stain: crtl-f "cell = "

% Change overlap region for detection: crtl-f "overlapRatio = "

% Change how much of the image edge to crop: crtl-f "ignoring edges"
