#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --mem=100G
#SBATCH --job-name=cell_profiler_slide
#SBATCH --output=cell_profiler_slide_%j.out
#SBATCH --error=cell_profiler_slide_%j.err

pipeline="/gpfs/data/tsirigoslab/home/sn2289/BRAF_project_revisions/cellprofiler/nuclei_annotation.cppipe"

# The file changes based on the image being processed each time
file_text="$1"

# Run cell profiler
cellprofiler -c -r -p "$pipeline" --file-list "$file_text"
