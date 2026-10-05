# QC Step 3: Minor Allele Frequency (MAF) visualization
#
# Input:
#   MAF_check.frq
#
# Output:
#   results/figures/qc/maf_distribution.png

# -----------------------------
# 1. Set directories
# -----------------------------

input_dir <- "data/processed"

output_dir <- "~/Bioinformatics/Mini-GWAS-analysis/results/figures/qc"

dir.create(
  output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# -----------------------------
# 2. Read PLINK frequency data
# -----------------------------

maf_data <- read.table(
  file.path(input_dir, "MAF_check.frq"),
  header = TRUE
)


# -----------------------------
# 3. Calculate summary statistics
# -----------------------------

n_variants <- nrow(maf_data)

n_below_05 <- sum(maf_data$MAF < 0.05)

n_at_least_05 <- sum(maf_data$MAF >= 0.05)

proportion_below_05 <- n_below_05 / n_variants


# -----------------------------
# 4. Print summary
# -----------------------------

cat("Total variants:", n_variants, "\n")
cat("Variants with MAF < 0.05:", n_below_05, "\n")
cat("Variants with MAF >= 0.05:", n_at_least_05, "\n")
cat(
  "Proportion with MAF < 0.05:",
  round(proportion_below_05 * 100, 2),
  "%\n"
)


# -----------------------------
# 5. Plot MAF distribution
# -----------------------------

png(
  filename = file.path(
    output_dir,
    "maf_distribution.png"
  ),
  width = 1800,
  height = 1200,
  res = 200
)

hist(
  maf_data$MAF,
  breaks = 50,
  xlim = c(0, 0.5),
  main = "Autosomal Minor Allele Frequency Distribution",
  xlab = "Minor Allele Frequency (MAF)",
  ylab = "Number of Variants"
)

abline(
  v = 0.05,
  lty = 2,
  lwd = 2
)

text(
  x = 0.05,
  y = max(
    hist(
      maf_data$MAF,
      breaks = 50,
      plot = FALSE
    )$counts
  ) * 0.95,
  labels = paste0(
    "MAF = 0.05 threshold\n",
    format(n_below_05, big.mark = ","),
    " variants below threshold"
  ),
  pos = 4
)

dev.off()


# -----------------------------
# 6. Completion message
# -----------------------------

cat(
  "Plot saved to:",
  file.path(output_dir, "maf_distribution.png"),
  "\n"
)
