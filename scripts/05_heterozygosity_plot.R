# Calculate and plot individual heterozygosity rates
# Input: heterozygosity.het

# Read PLINK heterozygosity output
het <- read.table(
  "data/processed/heterozygosity.het",
  header = TRUE,
  stringsAsFactors = FALSE
)

# Calculate observed heterozygosity rate
het$heterozygosity_rate <-
  (het$N.NM. - het$O.HOM.) / het$N.NM.

# Calculate mean and standard deviation
het_mean <- mean(het$heterozygosity_rate, na.rm = TRUE)
het_sd <- sd(het$heterozygosity_rate, na.rm = TRUE)

# Define ±3 SD thresholds
lower_cutoff <- het_mean - 3 * het_sd
upper_cutoff <- het_mean + 3 * het_sd

# Create output directory if needed
dir.create(
  "results/figures/qc",
  recursive = TRUE,
  showWarnings = FALSE
)

# Plot
png(
  "results/figures/qc/heterozygosity_distribution.png",
  width = 1200,
  height = 900,
  res = 150
)

hist(
  het$heterozygosity_rate,
  breaks = 30,
  main = "Distribution of Individual Heterozygosity",
  xlab = "Heterozygosity rate",
  ylab = "Number of individuals"
)

abline(v = lower_cutoff, lty = 2)
abline(v = upper_cutoff, lty = 2)
abline(v = het_mean, lty = 1)

dev.off()

# Print summary
cat("Number of individuals:", nrow(het), "\n")
cat("Mean heterozygosity:", het_mean, "\n")
cat("SD:", het_sd, "\n")
cat("Lower 3-SD cutoff:", lower_cutoff, "\n")
cat("Upper 3-SD cutoff:", upper_cutoff, "\n")
