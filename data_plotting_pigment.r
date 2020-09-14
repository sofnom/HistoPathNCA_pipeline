# This script creates boxplots with the nuclear feature
# distributions based on mutational status. 

# Input data
args <- commandArgs()

pigment_file <- args[3]
mutation_file <- args[4]
output_folder <- args[5]

# Load data
pigment_data <- read.table(pigment_file, header = TRUE, sep = "\t")
mutation <- read.table(mutation_file, header = TRUE, sep = "\t")

# Merge mutation info with object data
all_pigment <- merge(pigment_data, mutation, by = "Patient.ID")
all_pigment$mutation <- factor(all_pigment$mutation, levels = c("WT", "BRAF"))

# Plot together

pdf(paste(output_folder,"boxplots_pigment.pdf", sep = ""), width = 7, height = 5)
  myplot <- ggplot(all_pigment, aes(x=mutation, y=log(mean_pigmented_area_per_patient))) +
    geom_boxplot(aes(fill=mutation),width=0.5) +
    geom_jitter(position=position_jitter(0.2))+ theme_bw() +
    ylab("log(average pigment per patient)") + theme(text = element_text(size=20)) +
    scale_fill_manual(values=c("dark grey","orange")) + facet_wrap(~ location)
  print(myplot)
  dev.off()


# Calculate p-value
BRAF_patients <- subset(all_pigment, all_pigment$mutation == "BRAF")
WT_patients <- subset(all_pigment, all_pigment$mutation == "WT")

w_BRAF_WT <- wilcox.test(log(BRAF_patients$mean_pigmented_area_per_patient), log(WT_patients$mean_pigmented_area_per_patient), alternative = "two.sided",paired = FALSE)

write.table(w_BRAF_WT$p.value, paste(output_folder,"p_values_pigment.txt"), col.names = TRUE, row.names = FALSE, sep = "\t", quote = FALSE)
