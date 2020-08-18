#!/bin/bash
#SBATCH --time=72:00:00
#SBATCH --mem=100G
#SBATCH --job-name=cell_profiler
#SBATCH --output=run_%A_%a.out
#SBATCH --error=run_%A_%a.err


# RUN on headnode before submitting job
#module add miniconda2/4.5.4 jbig/2.1
#conda activate cellprofiler

# for over the image tile files
# and sbatch the job for each image

# It seems that i cannot change the output folder based on the image name that I want
# the -o command is not working. The output folder is the one determined in the pipeline.
# I altered the pipeline to identify the image name internally and create an output folder accordingly.

# Move to the directory with all the slide tile files
input_folder="YOUR PATH TO THE DIRECTORY WITH THE TILE LISTS FOR EACH SLIDE/"
script_folder="YOUR PATH TO THE SCRIPT DIRECTORY"

for image_tile_list in $input_forder/*_path.txt ; do
	sbatch $script_folder/cellprofiler.sh "$image_tile_list"
done
