# HistoPathNCA_pipeline
A nuclear and cell annotation pipeline for histopathology H&amp;E slides using CellProfiler. This pipeline was developed for our study Kim & Nomikou et al, "A Deep Learning Approach for Rapid Mutational Screening in Melanoma" in biorxiv: https://doi.org/10.1101/610311.

This pipeline was developed using the publicly available CellProfiler software (Carpenter AE et al. CellProfiler: image analysis software for identifying and 
quantifying cell phenotypes. Genome Biology, 2006) to perform nuclear and cell annotation on melanoma histopathology slides. 

CellProfiler 3.1.8 version is used (Documentation: http://cellprofiler-manual.s3.amazonaws.com/CellProfiler-3.0.0/index.html). 
All scripts are developed for the "bigpurple" computing cluster of the NYU Grossman School of Medicine and appropriate SLURM headers are used in the .sh scripts. 

## Data structure
The pipeline is designed to run for every tile of an H&E slide. For our study, tiling is performed using the "0b_tileLoop_deepzoom4.py" script from the DeepPATH pipeline (https://github.com/ncoudray/DeepPATH). The input data need to be organized in the following manner:
1. 299x299 pixel tiles are saved in folders named after the corresponding slide. Each tile is named according to the formula: slide_name_x_y.jpeg, where x and y are the tile coordinates. Files containing the paths to all tiles of the slides of interest are saved as well in a separate folder under the naming convention slide-name_path.txt. This file structure enables the CellProfiler pipeline to create an output folder for each slide.

## Pipeline
Our CellProfiler pipeline consists of the following steps:
1. UnmixColors: The pipeline starts by de-convolving the Hematoxylin, Eosin and Pigment signals and generating grayscale images indicating the location of each stain with white color. The deconvolution of Hematoxylin and Eosin is built-in the software and the pigment color was determined by choosing a custom color profile based on the pigmentation of our images (used image "pigment.png" in the same folder as the .cppipe file). 
2. IdentifyPrimaryObjects: Then, the Hematoxylin stain is used to annotate nuclei, and the pigment stain is used to annotate pigmented regions on the tile. To annotate nuclei, we decided to adopt the Otsu method with default parameters except for “threshold correction factor” for which we used value of 1.3 instead of the default 1.0 for more stringent annotation. “Typical diameter of objects” was set to 10 to 40 pixels, as by default. For pigment annotation, we used a manual thresholding method with a threshold of 0.8 and ‘typical diameter of objects” was set to 10 to 100 to reduce the number of objects identified. Our slides were not color normalized. We noticed that color normalization was interfering with the annotation of pigmented regions because it was reducing the contrast between the pigment color and the rest of the slide. Instead, we opted for the Otsu method which tests multiple thresholding values before performing nuclear annotation, therefore it automatically adapts to each tile’s color profile. For cell annotation, we changed the annotation method to Minimum Cross Entropy with the default thresholding smoothing value of 1.3488 and the default threshold correction factor of 1.0. The rest of pipeline stages are unchanged.
3. ConvertObjectsToImage: This step is used to convert the identified pigment objects to a mask image that can be used by the following step MaskObjects.
4. MaskObjects: Pigmented areas were excluded from our nuclear annotation because pigmented cells may represent melanophages rather than tumor cells. 
5. OverlayOutlines: This step is overlaying the tile image with the identified nuclei and pigmented regions for visualization and evaluation of our pipeline. The objects are overlayed using the default parameters. 
6. SaveImages: The overlay images of can be saved in a jpeg format.
7. MeasureObjectSizeShape: This module measures object size and shape features. In total, it measures 18 features: 
8. ExportToSpeadsheet: This step is used to save the outputs of the previous step into a text file for every slide.

The nuclear annotation pipeline is in the "nuclei_annotation.cppipe" script and the cell annotation pipeline is in the "cell_annotation.cppipe" script. These scripts can be opened and edited on CellProfiler.  

To run the pipeline, you can use the "run_cellprofiler.sh" script. This script is designed to loop over all tile lists for the slides of interest and submit a job to run the CellProfiler pipeline for each slide separately. This is achieved using the "cellprofiler.sh" script where the user can define the pipeline they wish to use. 

## Outputs
The pipeline creates one folder for each slide in a predetermined output folder called "test_output" by default, but can be changed by the user through the CellProfiler interface ("ExportToSpeadsheet" step). 
In the slide specific folder, the pipeline outputs:
1. A .txt file with all the object information for each tile of a slide. This file can be named "Nuclei_Slide_name.txt" or "Cells_Slide_name.txt" based on the annotated objects. 
2. A .txt file with all pigmented objects identified, called "pigmented_regions_slide_name.txt".
3. A .txt file with all the annotated objects that are not overlapping the pigment areas, named either "Nuclei_out_of_pigment_slide_name.txt" or "Cells_out_of_pipeline_slide_name.txt".
4. A series of .png files named "overlay_x_y.png" with the initial tile image overlayed with the nuclear/cellular and pigment annotations and a series of .png files named "overlay_out_of_pigment_x_y.png" for visualization of only the objects that do not overlap pigment areas along with the pigmented regions. These files are generated for every tile analyzed.  

## Data analysis
Analysis of the generated data is focusing on creating a visualization of the average feature values for the identified nuclei/cells at the patient level. The way the analysis is set, it can take care of multiple slides by patient by aggregating all the information from all the slides. Three scripts are developed:
  
  * data_analysis_nuclei_pigment.r 
    * Input: A folder with all the pipeline generated files for nuclei (Nuclei_out_of_pigment_slide_name.txt) and pigment (pigmented_regions_slide_name.txt) for your slides of interest.
    * Output: 
    1. A file with the average data for all annotated objects, named "all_accepted_nuclei.txt".
    2. A file including the averaged nuclear features for each patient normalized to the total number of tiles per patient when necessary, called "per_patient_nuclei_data_normalized.txt". The features that get normalized by the total number of tiles are the total number of objects and the total area occupied by the objects. 
    3. A file named "per_patient_pigment_data.txt". This file has two columns, one with the patient id and one with the total pigmented area for each patient normalized by the total number of tiles for each patient.
    The files have the following headers
  
  * data_analysis_cells.r
    * Input: A folder with all the pipeline generated files for cells (Cells_out_of_pigment_slide_name.txt) for your slides of interest.
    * Output: 
    1. A file with the average data for all annotated objects, named "all_accepted_cells.txt".
    2. A file including the averaged cellular features for each patient normalized to the total number of tiles per patient when necessary, called "per_patient_cell_data_normalized.txt". The features that get normalized by the total number of tiles are the total number of objects and the total area occupied by the objects. 
  
  * data_analysis_nuclei.r
    * This script has the same structure as the previous one can be used to analyze nuclear data alone. 

You can use the run_analysis.sh script to help you submit the analysis scripts on a cluster. 

Note: Please, make sure you update the scripts if the patient identifiers you are using have length different than 6 (our NYU cohort) or 12 (TCGA data).

## Data plotting
Finally, scripts are provided for data visualization:
1. data_plotting_objects.r
  * Input: The input to this script is the data file with the normalized data by patient, a file including the patient ids and their mutational status and a string indicating if the objects are "nuclei" or "cells" to determine the output files. 
  * Output: These scripts create a .png file with boxplots showing the feature distribution by mutation statification for each object feature. For our paper, we plotted the nuclear and cellular data by patient BRAF mutational status. The script also generates a file with p-values comparing the two distributions using a Wilcoxon rank sum test.

2. data_plotting_pigment.r
  * Input: 
  * Output: 
 
