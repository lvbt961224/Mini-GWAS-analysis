# QC Step 2: Sex discrepancy visualization
#
# Input:
#   sexcheck_baseline.sexcheck
#
# Output:
#   results/qc/step02_sex_discrepancy/sex_check.png

# -----------------------------
# 1. Set directories
# -----------------------------

input_dir <- "data/processed"

output_dir <- "~/Bioinformatics/Mini-GWAS-analysis/results/qc/step02_sex_discrepancy"

dir.create(
  output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# -----------------------------
# 2. Read PLINK sex-check data
# -----------------------------

sexcheck <- read.table(
  file.path(input_dir, "sexcheck_baseline.sexcheck"),
  header = TRUE
)


# -----------------------------
# 3. Summarize results
# -----------------------------

n_total <- nrow(sexcheck)
n_problem <- sum(sexcheck$STATUS == "PROBLEM")
n_ok <- sum(sexcheck$STATUS == "OK")

cat("Total individuals:", n_total, "\n")
cat("OK:", n_ok, "\n")
cat("PROBLEM:", n_problem, "\n")


# -----------------------------
# 4. Create a plotting variable
# -----------------------------

sexcheck$RecordedSex <- ifelse(
  sexcheck$PEDSEX == 1,
  "Male",
  ifelse(sexcheck$PEDSEX == 2, "Female", "Unknown")
)

# -----------------------------
# 5. Plot X-chromosome F
# -----------------------------

png(
  filename = file.path(output_dir, "sex_check.png"),
  width = 1800,
  height = 1200,
  res = 200
)

plot(
  sexcheck$F,
  seq_len(nrow(sexcheck)),
  xlim = c(-0.1, 1.1),
  pch = 16,
  cex = 0.7,
  yaxt = "n",
  xlab = "X-chromosome homozygosity estimate (F)",
  ylab = "Individuals",
  main = "Sex Discrepancy Check",
  type = "n"
)

# Shade the ambiguous region first
rect(
  0.2,
  0,
  0.8,
  nrow(sexcheck) + 1,
  border = NA
)

# Classification thresholds
abline(
  v = 0.2,
  lty = 2,
  lwd = 2
)

abline(
  v = 0.8,
  lty = 2,
  lwd = 2
)

# Plot all individuals
points(
  sexcheck$F,
  seq_len(nrow(sexcheck)),
  pch = 16,
  cex = 0.7
)

# Highlight problematic individual(s)
problem_idx <- which(sexcheck$STATUS == "PROBLEM")

if (length(problem_idx) > 0) {

  points(
    sexcheck$F[problem_idx],
    problem_idx,
    pch = 19,
    cex = 1.3
  )

  text(
    x = sexcheck$F[problem_idx],
    y = problem_idx,
    labels = sexcheck$IID[problem_idx],
    pos = 4,
    cex = 0.8
  )
}

# Region labels
text(
  x = 0.05,
  y = nrow(sexcheck) + 2,
  labels = "Female",
  pos = 4
)

text(
  x = 0.5,
  y = nrow(sexcheck) + 2,
  labels = "Ambiguous",
  pos = 4
)

text(
  x = 0.85,
  y = nrow(sexcheck) + 2,
  labels = "Male",
  pos = 4
)

dev.off()


# -----------------------------
# 6. Completion message
# -----------------------------

cat(
  "Plot saved to:",
  file.path(output_dir, "sex_check.png"),
  "\n"
)
