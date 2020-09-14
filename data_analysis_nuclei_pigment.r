# Read arguments

args <- commandArgs()

input_folder <- args[3]
output_folder <- args[4]

library(dplyr)
library(ggplot2)
library(ggfortify)
library(tidyr)
library(corrplot)

## Read all per slide files for annotated objects
## after removing the ones overlapping the pigmented areas


# Use this code to do the analysis for NUCLEI.
filenames <- list.files(path=input_folder,
                        pattern="Nuclei_out_of_pigment+.*txt")

##Create list of data frame names without the ".txt" part 
data_frame_names <-substr(filenames,1,nchar(filenames)-4)

###Load all files
for(i in data_frame_names){
  filepath <- file.path(input_folder,paste(i,".txt",sep=""))
  assign(i, read.delim(filepath,
                       colClasses=c(rep("numeric",2), rep("character",7),rep("numeric", 23)),
                       sep = "\t"))
}

# OBJECT PROCESSING
#Add patient and slide information to slide dataframes to facilitate merging later
# This way each object has the patient and the slide information
for(i in data_frame_names){
	current_slide_data <- get(i)
	# Add Patient.ID - use one of the two following lines based on the id lenght for your patients.
	# For our NYU cohort is 6 characters, and 12 for the TCGA.
		# NYU cohort 
		current_slide_data$Patient.ID <- substr(i,23,28)
		# TCGA cohort 
		current_slide_data$Patient.ID <- substr(i,23,34)

	# Add Slide.ID
	current_slide_data$Slide.ID <- gsub("Nuclei_out_of_pigment_", "", i)
	assign(i, current_slide_data)
}

# Merge all object data identified in all tiles together
# This process can take some time.
all_tiles <- data.frame()
for(current_tiles in data_frame_names){
	tile_data <- get(current_tiles)
	all_tiles <- rbind(all_tiles, tile_data)
}
write.table(all_tiles, paste(output_folder,"all_accepted_nuclei.txt", sep = "") , row.names = FALSE, col.names = TRUE, quote = FALSE, sep = "\t")

# Average all 18 CellProfiler features across all nuclei identified for each patient
per_patient_mean_nuclei_results <-  group_by(all_tiles,Patient.ID) %>% summarize(mean_Nuclear_Area = mean(AreaShape_Area),
                                                                                          sum_Nuclear_Area = sum(AreaShape_Area),
                                                                                          mean_Nuclear_Eccentricity = mean(AreaShape_Eccentricity),
                                                                                          mean_Nuclear_Compactness = mean(AreaShape_Compactness),
                                                                                          mean_Nuclear_MajorAxisLength = mean(AreaShape_MajorAxisLength),
                                                                                          mean_Nuclear_MinorAxisLength = mean(AreaShape_MinorAxisLength),
                                                                                          mean_Nuclear_Perimeter = mean(AreaShape_Perimeter),
                                                                                          mean_Nuclear_Orientation = mean(AreaShape_Orientation),
                                                                                          mean_Nuclear_Solidity = mean(AreaShape_Solidity),
                                                                                          mean_Nuclear_Extent = mean(AreaShape_Extent),
                                                                                          mean_Nuclear_EulerNumber = mean(AreaShape_EulerNumber),
                                                                                          mean_Nuclear_FormFactor = mean(AreaShape_FormFactor),
                                                                                          mean_Nuclear_MaxFeretDiameter = mean(AreaShape_MaxFeretDiameter),
                                                                                          mean_Nuclear_MaximumRadius = mean(AreaShape_MaximumRadius),
                                                                                          mean_Nuclear_MeanRadius = mean(AreaShape_MeanRadius),
                                                                                          mean_Nuclear_MedianRadius = mean(AreaShape_MedianRadius),
                                                                                          mean_Nuclear_MinFeretDiameter = mean(AreaShape_MinFeretDiameter))


total_number_of_nuclei_per_patient <- count(all_tiles, Patient.ID)
##Tiles per slide
tiles_per_slide <- all_tiles %>% group_by(Patient.ID,Slide.ID) %>% summarise(number_of_tiles = max(ImageNumber))
total_number_of_tiles_per_patient <- tiles_per_slide %>% group_by(Patient.ID) %>% summarise(total_tiles_per_patient = sum(number_of_tiles))
## Normalize number of nuclei per patient to the number of tiles
total_number_of_nuclei_per_patient$norm_number_of_nuclei_per_tile <- total_number_of_nuclei_per_patient$n / total_number_of_tiles_per_patient$total_tiles_per_patient

per_patient_data <- merge(per_patient_mean_nuclei_results, total_number_of_nuclei_per_patient, by = "Patient.ID")

# Normalize the sum of nuclear area per patient by the number of tiles for each patient
per_patient_data <- merge(per_patient_data, total_number_of_tiles_per_patient, by = "Patient.ID")
per_patient_data$sum_Nuclear_Area_norm <- per_patient_data$sum_Nuclear_Area / per_patient_data$total_tiles_per_patient

# Write data
write.table(per_patient_data, paste(output_folder, "per_patient_nuclei_data_normalized.txt", sep = "") ,row.names = FALSE, col.names = TRUE, sep = "\t",quote = FALSE)


# PIGMENT PROCESSING
## Read all per slide files for pigment
filenames_pigment <- list.files(path=input_folder,
                        pattern="pigmented_regions+.*txt")

##Create list of data frame names without the ".txt" part 
data_frame_names_pigment <-substr(filenames_pigment,1,nchar(filenames_pigment)-4)

###Load all files
for(i in data_frame_names_pigment){
  filepath <- file.path(input_folder,paste(i,".txt",sep=""))
  assign(i, read.delim(filepath,
                       colClasses=c(rep("numeric",2), rep("character",7),rep("numeric", 23)),
                       sep = "\t"))
}

# Add Patient.ID and Slide.ID information
for(i in data_frame_names_pigment){
                current_slide_data <- get(i)
                # NYU cohort
                if (nrow(current_slide_data) != 0){
                       current_slide_data$Patient.ID <- substr(i,19,24)
                       current_slide_data$Slide.ID <- gsub("pigmented_regions_","",i)
                       assign(i, current_slide_data)
                }
                # OR, for TCGA cohort
                if (nrow(current_slide_data) != 0){
                        current_slide_data$Patient.ID <- substr(i,19,30)
                        current_slide_data$Slide.ID <- gsub("pigmented_regions_","",i)
                        assign(i, current_slide_data)
                }
        }

# Merge pigment data from all slides/patients
all_pigmented_areas <- data.frame()
for(current_tiles in data_frame_names_pigment){
        # Obtain data frame data
        tile_data <- get(current_tiles)
        all_pigmented_areas <- rbind(all_pigmented_areas, tile_data)
}

# Calculate average pigment area for every patient, normalized by the number of tiles for each patient 
pigment_area_total_tile <- all_pigmented_areas %>% group_by(Patient.ID,Slide.ID,ImageNumber) %>% summarise(total_pigment_area = sum(AreaShape_Area))
pigment_area_total_slide <- pigment_area_total_tile %>% group_by(Patient.ID,Slide.ID) %>% summarise(total_pigment_area_slide = sum(total_pigment_area))
# Normalize pigmented area on all tiles of a slide and not only the ones that have pigment
pigment_area_total_slide_merged <- merge(pigment_area_total_slide, tiles_per_slide, by = c("Patient.ID", "Slide.ID"))
pigment_area_total_slide_merged$total_pigment_area_slide_norm <- pigment_area_total_slide_merged$total_pigment_area_slide / pigment_area_total_slide_merged$number_of_tiles

pigment_area_total_patient <- pigment_area_total_slide %>% group_by(Patient.ID) %>% summarise(mean_pigmented_area_per_patient = mean(total_pigment_area_slide_norm))

# Write data
write.table(per_patient_data, paste(output_folder, "per_patient_pigment_data.txt", sep = "") ,row.names = FALSE, col.names = TRUE, sep = "\t",quote = FALSE)

