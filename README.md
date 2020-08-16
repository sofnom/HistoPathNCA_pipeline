# HistoPathNCA_pipeline
A nuclear and cell annotation pipeline for histopathology H&amp;E slides using CellProfiler.

This pipeline was developed using the publicly available CellProfiler (Carpenter AE et al. CellProfiler: image analysis software for identifying and 
quantifying cell phenotypes. Genome Biology, 2006) software to perform nuclear and cell annotation from melanoma histopathology slides. 

CellProfiler 3.1.8 version is used. The pipeline is developed for the bigpurple computing cluster of the NYU School of Medicine and appropriate SLURMP headers are used in the .sh scripts. 

## Data structure
The pipeline is designed to run for every tile of an H&E slide. For our study, tiling is performed using the "0b_tileLoop_deepzoom4.py" script from the DeepPATH pipeline (https://github.com/ncoudray/DeepPATH). 
Tiles are saved in folders named after the corresponding slide. Each tile is named according to the formula: slide_name_x_y.jpeg, where x and y are the tile coordinates. Files containing the paths to all tiles of the slides of interest are saved as well. This file structure enables the CellProfiler pipeline to create an output folder for each slide, and one output .txt file with the object measurements for all the tiles together. 

## Pipeline
To run the pipeline, you can use the "run_cellprofiler.sh" script. 

## Outputs

## Data analysis
