# This script creates boxplots with the nuclear feature
# distributions based on mutational status. 

# Input data
args <- commandArgs()

object_file <- args[3]
mutation_file <- args[4]
object <- args[5]
output_folder <- args[6]

# Load data
object_data <- read.table(object_file, header = TRUE, sep = "\t")
mutation <- read.table(mutation_file, header = TRUE, sep = "\t")

# Merge mutation info with object data
all_features <- merge(object_data, mutation, by = "Patient.ID")
all_features$mutation <- factor(all_features$mutation, levels = c("WT", "BRAF"))

# Plot together
features <- colnames(all_features)
# We do not wish to create a boxplot for some of the columns, and we remove them here.
remove_elements <- c("Patient.ID","mutation", "n", "total_tiles_per_patient")

for (i in features[!features %in% remove_elements]){
  pdf(paste(output_folder,"boxplots",object, "_", i, ".pdf", sep = ""), width = 7, height = 5)
  myplot <- ggplot(all_features, aes(x=mutation, y=get(i))) +
    geom_boxplot(aes(fill=mutation),width=0.5) +
    geom_jitter(position=position_jitter(0.2))+ theme_bw() +
    ylab(paste( i, "per patient")) + theme(text = element_text(size=20)) +
    scale_fill_manual(values=c("dark grey","orange")) + facet_wrap(~ location)
  print(myplot)
  dev.off()
}

# Calculate p-value
dataset <- all_features

p_value_dataframe <- data.frame("comparison" = c("all_data"))
BRAF_patients <- subset(dataset, dataset$final_mutation == "BRAF")
WT_patients <- subset(dataset, dataset$final_mutation == "WT")
for (i in features[!features %in% remove_elements]){
  temp <- c()
  w_BRAF_WT <- wilcox.test(BRAF_patients[[i]], WT_patients[[i]], alternative = "two.sided",paired = FALSE)

  # Build data frame entry
  temp <- c(temp, w_BRAF_WT$p.value)
  
  # Add column to dataframe
  p_value_dataframe[,i]<- temp
}

write.table(p_value_dataframe, paste(output_folder,"p_values_", object, ".txt"), col.names = TRUE, row.names = FALSE, sep = "\t", quote = FALSE)
