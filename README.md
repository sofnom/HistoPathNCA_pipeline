# HistoPathNCA_pipeline
A nuclear and cell annotation pipeline for histopathology H&amp;E slides using CellProfiler.

This pipeline was developed using the publicly available CellProfiler (Carpenter AE et al. CellProfiler: image analysis software for identifying and 
quantifying cell phenotypes. Genome Biology, 2006) software to perform nuclear and cell annotation from melanoma histopathology slides. 

CellProfiler 3.1.8 version is used. The pipeline is developed for the bigpurple computing cluster of the NYU School of Medicine and appropriate SLURMP headers are used in the .sh scripts. 

## Data structure
The pipeline is designed to run for every tile of an H&E slide. For our study, tiling is performed using the "0b_tileLoop_deepzoom4.py" script from the DeepPATH pipeline (https://github.com/ncoudray/DeepPATH). 
Tiles are saved in folders named after the corresponding slide. Each tile is named according to the formula: slide_name_x_y.jpeg, where x and y are the tile coordinates. Files containing the paths to all tiles of the slides of interest are saved as well, in a separate folder. This file structure enables the CellProfiler pipeline to create an output folder for each slide, and inside this folder one output .txt file with the object measurements for all the tiles together. 

## Pipeline
Our CellProfiler pipeline consists of the following steps:
### UnmixColors: The pipeline starts by de-convolving the Hematoxylin, Eosin and Pigment signals and generating grayscale images indicating the location of each stain with white color. The deconvolution of Hematoxylin and Eosin is built-in the software and the pigment color was determined by choosing a custom color profile based on the pigmentation of our images. 
### IdentifyPrimaryObjects: Then, the Hematoxylin stain is used to annotate nuclei, and the pigment stain is used to annotate pigmented regions on the tile. To annotate nuclei, we decided to adopt the Otsu method with default parameters except for “threshold correction factor” for which we used value of 1.3 instead of the default 1.0 for more stringent annotation. “Typical diameter of objects” was set to 10 to 40 pixels, as by default. For pigment annotation, we used a manual thresholding method with a threshold of 0.8 and ‘typical diameter of objects” was set to 10 to 100 to reduce the number of objects identified. Our slides were not color normalized. We noticed that color normalization was interfering with the annotation of pigmented regions because it was reducing the contrast between the pigment color and the rest of the slide. Instead, we opted for the Otsu method which tests multiple thresholding values before performing nuclear annotation, therefore it automatically adapts to each tile’s color profile. For cell annotation, we changed the annotation method to Minimum Cross Entropy with the default thresholding smoothing value of 1.3488 and the default threshold correction factor of 1.0. The rest of pipeline stages are unchanged.
### ConvertObjectsToImage: This step is used to convert the identified pigment objects to a mask image that can be used by the following step MaskObjects.
### MaskObjects: Pigmented areas were excluded from our nuclear annotation because pigmented cells may represent melanophages rather than tumor cells. 
### OverlayOutlines: This step is overlaying the tile image with the identified nuclei and pigmented regions for visualization and evaluation of our pipeline. The objects are overlayed using the default parameters. 
### SaveImages: The overlay images of can be saved in a jpeg format.
### MeasureObjectSizeShape: This module measures object size and shape features. In total, it measures 18 features: 
## ExportToSpeadsheet: This step is used to save the outputs of the previous step into a text file for every slide.

The nuclear annotation pipeline is saved in the file:
The cell annotation pipeline is saved in the file: 

To run the pipeline, you can use the "run_cellprofiler.sh" script. 

## Outputs

## Data analysis
