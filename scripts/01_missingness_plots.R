# QC Step 1: Missingness visualization
#
# Creates histograms of baseline genotype missingness at:
#   1. Individual level
#   2. SNP level
#
# Input:
#   missingness_baseline.imiss
#   missingness_baseline.lmiss
#
# Output:
#   results/figures/qc/missingness_individual.png
#   results/figures/qc/missingness_snp.png

# -----------------------------
# 1. Set directories
# -----------------------------

input_dir <- "~/Bioinformatics/Marees-GWA_tutorial/1_QC_GWAS"

output_dir <- "~/Bioinformatics/Mini-GWAS-analysis/results/figures/qc"

dir.create(
  output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# -----------------------------
# 2. Read PLINK missingness files
# -----------------------------

imiss <- read.table(
  file.path(input_dir, "missingness_baseline.imiss"),
  header = TRUE
)

lmiss <- read.table(
  file.path(input_dir, "missingness_baseline.lmiss"),
  header = TRUE
)


# -----------------------------
# 3. Calculate QC summaries
# -----------------------------

n_individuals <- nrow(imiss)
n_snps <- nrow(lmiss)

max_individual_missingness <- max(imiss$F_MISS)
max_snp_missingness <- max(lmiss$F_MISS)

n_individuals_gt02 <- sum(imiss$F_MISS > 0.02)
n_snps_gt02 <- sum(lmiss$F_MISS > 0.02)


# -----------------------------
# 4. Print summary to terminal
# -----------------------------

cat("Number of individuals:", n_individuals, "\n")
cat("Number of SNPs:", n_snps, "\n")

cat(
  "Maximum individual missingness:",
  max_individual_missingness,
  "\n"
)

cat(
  "Maximum SNP missingness:",
  max_snp_missingness,
  "\n"
)

cat(
  "Individuals with >2% missingness:",
  n_individuals_gt02,
  "\n"
)

cat(
  "SNPs with >2% missingness:",
  n_snps_gt02,
  "\n"
)


# -----------------------------
# 5. Plot individual missingness
# -----------------------------

png(
  filename = file.path(
    output_dir,
    "missingness_individual.png"
  ),
  width = 1800,
  height = 1200,
  res = 200
)

hist(
  imiss$F_MISS,
  breaks = 50,
  main = "Individual Genotype Missingness",
  xlab = "Fraction of Missing Genotypes",
  ylab = "Number of Individuals"
)

abline(
  v = 0.02,
  lty = 2,
  lwd = 2
)

text(
  x = 0.0195,
  y = max(hist(
    imiss$F_MISS,
    breaks = 50,
    plot = FALSE
  )$counts) * 0.95,
  labels = "2% QC threshold",
  pos = 2
)

dev.off()


# -----------------------------
# 6. Plot SNP missingness
# -----------------------------

png(
  filename = file.path(
    output_dir,
    "missingness_snp.png"
  ),
  width = 1800,
  height = 1200,
  res = 200
)

hist(
  lmiss$F_MISS,
  breaks = 50,
  main = "SNP Genotype Missingness",
  xlab = "Fraction of Missing Genotypes",
  ylab = "Number of SNPs"
)

abline(
  v = 0.02,
  lty = 2,
  lwd = 2
)

text(
  x = 0.02,
  y = max(hist(
    lmiss$F_MISS,
    breaks = 50,
    plot = FALSE
  )$counts) * 0.95,
  labels = paste0(
    "2% QC threshold (",
    format(n_snps_gt02, big.mark = ","),
    " SNPs > threshold)"
  ),
  pos = 4
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
