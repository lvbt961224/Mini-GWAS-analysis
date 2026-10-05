# QC Step 4: Hardy-Weinberg Equilibrium (HWE) visualization
#
# Input:
#   HWE_check.hwe
#   HWE_check_zoom.hwe
#
# Output:
#   results/figures/qc/hwe_distribution.png
#   results/figures/qc/hwe_distribution_zoom.png
#
# The full HWE distribution is plotted first.
# A second plot focuses on HWE p-values below 1e-5.

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
# 2. Read HWE data
# -----------------------------

hwe <- read.table(
  file.path(input_dir, "HWE_check.hwe"),
  header = TRUE
)

hwe_zoom <- read.table(
  file.path(input_dir, "HWE_check_zoom.hwe"),
  header = TRUE
)


# -----------------------------
# 3. Calculate summary values
# -----------------------------

n_hwe_rows <- nrow(hwe)

n_low_p <- sum(hwe$P < 1e-5)

n_unique_low_p_snps <- length(
  unique(
    hwe$SNP[hwe$P < 1e-5]
  )
)


# -----------------------------
# 4. Print summary
# -----------------------------

cat("Total HWE test rows:", n_hwe_rows, "\n")

cat(
  "HWE test rows with P < 1e-5:",
  n_low_p,
  "\n"
)

cat(
  "Unique SNPs with P < 1e-5:",
  n_unique_low_p_snps,
  "\n"
)

cat(
  "ALL rows with P < 1e-5:",
  sum(hwe$TEST == "ALL" & hwe$P < 1e-5),
  "\n"
)

cat(
  "AFF rows with P < 1e-5:",
  sum(hwe$TEST == "AFF" & hwe$P < 1e-5),
  "\n"
)

cat(
  "UNAFF rows with P < 1e-5:",
  sum(hwe$TEST == "UNAFF" & hwe$P < 1e-5),
  "\n"
)


# -----------------------------
# 5. Plot full HWE distribution
# -----------------------------

png(
  filename = file.path(
    output_dir,
    "hwe_distribution.png"
  ),
  width = 1800,
  height = 1200,
  res = 200
)

hist(
  hwe$P,
  breaks = 50,
  xlim = c(0, 1),
  main = "Hardy-Weinberg Equilibrium P-value Distribution",
  xlab = "HWE P-value",
  ylab = "Number of HWE tests"
)

abline(
  v = 1e-5,
  lty = 2,
  lwd = 2
)

dev.off()


# -----------------------------
# 6. Plot zoomed low P-values
# -----------------------------

png(
  filename = file.path(
    output_dir,
    "hwe_distribution_zoom.png"
  ),
  width = 1800,
  height = 1200,
  res = 200
)

hist(
  hwe_zoom$P,
  breaks = 20,
  xlim = c(0, 1e-5),
  main = "HWE P-values Below 1e-5",
  xlab = "HWE P-value",
  ylab = "Number of HWE tests"
)

# Reference lines for the actual QC thresholds
abline(
  v = 1e-6,
  lty = 2,
  lwd = 2
)

abline(
  v = 1e-10,
  lty = 3,
  lwd = 2
)

dev.off()


# -----------------------------
# 7. Completion message
# -----------------------------

cat(
  "Plots saved to:",
  output_dir,
  "\n"
)
