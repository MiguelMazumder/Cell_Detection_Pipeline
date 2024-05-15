

# Cell Detection and Counting Pipeline
Typical cell detections systems such as qpath can often create excessive false positives or only be effective for certain cell types.
The goal of our this MATLAB cell detection pipeline is to create an accurate cell detection system as well as include user preferences for output cell analysis for the Shook Lab at GWU.
To avoid script dependency, which is often an issue with most cell detection software, all of the detection, counting, formatting, and functions are executed from a single script.
The pipeline of the script begins with a folder access and organization function to collect all cell image .tif and .tiff files from a user prompted folder, as well as desired quadrant dimensions for later cell grouping analysis.
The cell detection and counting function is then performed on the available files in the folder. The details of the cell detection includes: Takes a base image, separates it into channels, and detects cells based on the overlap of nucleus and cell stains.
The current threshold used for our images is 75%, but this is adjustable. The detection process utilizes thresholding, connected components labeling, and region properties to detect the overlap of nucleus and cell stains.
It then updates cell counts for each quadrant as well as additional features such as saving images of the cell detections and/or detected cell locations. The additional features are optional based on user inputs.

Author: Miguel Mazumder  
Email: mfmmazumder@gwmail.gwu.edu  
Date: 11/29/2023  

## Overview

This script, "blue_green_cell_detection_v3", is designed to detect and count cells based on a provided image set. It separates input images into their respective channels, identifying overlap between nucleus and cell stains to detect cells specifically. The script focuses on blue nucleus stain and green cell stain detection.

## Functionality

- **Image Segmentation and Detection**:
  - Segregates images into respective channels.
  - Detects cells based on blue nucleus and green cell stains.

- **Folder Access**:
  - Reads input .tif files from a specified folder.

- **Data Output**:
  - Generates .csv files containing:
    - Overall cell count.
    - Cell count per quadrant (distribution).

- **Additional Features**:
  - Provides options to save visualizations of cell detection.
  - Offers to save detected cell locations for each image.

## Usage

### Script Execution

1. Run `folder_access` to retrieve image file names and quadrant dimensions.
2. Execute `cell_detect` to perform cell detection and counting.
3. Utilize `create_headers` to format and save data to .csv files.

### Folder Access and Organization

The `folder_access` function reads .tif files from a specified folder and organizes results in a dedicated `Analysis_results` folder.

### Cell Detection and Counting

The `cell_detect` function:
- Extracts relevant channels (green cell stain, blue nucleus stain) from images.
- Performs thresholding and connected components labeling.
- Identifies overlap between stains to detect and count cells.
- Computes quadrant-specific cell counts.

### Formatting and Data Export

The `create_headers` function:
- Formats the extracted data into tables.
- Saves the formatted data to .csv files.

### Additional Features

- Users can opt to save visualizations of cell detection.
- Users can choose to save detected cell locations for each image.

## Instructions for Use

1. Ensure MATLAB is configured with required dependencies.
2. Update folder paths and parameters as needed.
3. Execute the script to process and analyze image data.

## Editing Instructions

- Modify folder names for specific groups (e.g., "Old", "Young").
- Adjust channel settings (`nucleus_stain`, `cell_stain`) for stain detection.
- Fine-tune overlap and edge handling parameters for accurate cell detection.

For any questions or issues, please contact Miguel Mazumder at mfmmazumder@gwmail.gwu.edu.
