args <- commandArgs()

input_folder <- args[3]
output_folder <- args[4]

library(dplyr)
library(ggplot2)
library(ggfortify)

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
tiles_per_slide <- all_tiles_data_mut %>% group_by(Patient.ID,Slide.ID) %>% summarise(number_of_tiles = max(ImageNumber))

pigment_area_total_tile <- all_pigmented_areas %>% group_by(Patient.ID,Slide.ID,ImageNumber) %>% summarise(total_pigment_area = sum(AreaShape_Area))
pigment_area_total_slide <- pigment_area_total_tile %>% group_by(Patient.ID,Slide.ID) %>% summarise(total_pigment_area_slide = sum(total_pigment_area))
# Normalize pigmented area on all tiles of a slide and not only the ones that have pigment
pigment_area_total_slide_merged <- merge(pigment_area_total_slide, tiles_per_slide, by = c("Patient.ID", "Slide.ID"))
pigment_area_total_slide_merged$total_pigment_area_slide_norm <- pigment_area_total_slide_merged$total_pigment_area_slide / pigment_area_total_slide_merged$number_of_tiles
#pigment_area_total_slide$total_pigment_area_slide_norm <- pigment_area_total_slide$total_pigment_area_slide / tiles_per_slide$number_of_tiles

pigment_area_total_patient <- pigment_area_total_slide %>% group_by(Patient.ID) %>% summarise(mean_pigmented_area_per_patient = mean(total_pigment_area_slide_norm))

# Write data
write.table(per_patient_data, paste(output_folder, "per_patient_pigment_data.txt", sep = "") ,row.names = FALSE, col.names = TRUE, sep = "\t",quote = FALSE)

