#!/bin/bash
#SBATCH --time=5:00:00
#SBATCH --mem=100G
#SBATCH --output=run_%A_%a.out
#SBATCH --error=run_%A_%a.err

module unload gcc/cray/8.1.0
module load gcc/8.1.0
module load r/3.3.2

# Run R script performing the analysis of the collected data

input_dir="PATH TO THE FOLDER WITH ALL THE PIPELINE OUTPUT DATA"
output_dir="PATH TO THE DESIRED OUTPUT DIRECTORY"
code_dir="PATH TO CODE DIRECTORY"

R --no-save $input_dir $output_dir < $code_dir/data_analysis_nuclei.r
 
