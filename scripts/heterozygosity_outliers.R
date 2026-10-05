data/processed/heterozygosity.het# Identify heterozygosity outliers
# Input: heterozygosity.het

het <- read.table(
  "data/processed/heterozygosity.het",
  header = TRUE,
  stringsAsFactors = FALSE
)

# Calculate heterozygosity rate
het$heterozygosity_rate <-
  (het$N.NM. - het$O.HOM.) / het$N.NM.

# Calculate mean and SD
het_mean <- mean(het$heterozygosity_rate, na.rm = TRUE)
het_sd <- sd(het$heterozygosity_rate, na.rm = TRUE)

# Define ±3 SD cutoffs
lower_cutoff <- het_mean - 3 * het_sd
upper_cutoff <- het_mean + 3 * het_sd

# Identify outliers
outliers <- het[
  het$heterozygosity_rate < lower_cutoff |
  het$heterozygosity_rate > upper_cutoff,
  c("FID", "IID", "heterozygosity_rate")
]

# Write outlier list
write.table(
  outliers,
  "data/processed/heterozygosity_outliers.txt",
  quote = FALSE,
  row.names = FALSE,
  sep = "\t"
)

# Print summary
cat("Mean heterozygosity:", het_mean, "\n")
cat("SD:", het_sd, "\n")
cat("Lower cutoff:", lower_cutoff, "\n")
cat("Upper cutoff:", upper_cutoff, "\n")
cat("Number of outliers:", nrow(outliers), "\n\n")

if (nrow(outliers) > 0) {
  print(outliers)
}
