#!/bin/bash

# QC Step 4: Hardy-Weinberg Equilibrium (HWE)
#
# This script:
#   1. Calculates HWE statistics.
#   2. Creates a low-p-value subset for visualization.
#   3. Generates HWE distribution plots using R.
#   4. Applies the control HWE threshold (P < 1e-6).
#   5. Applies the conservative case HWE threshold (P < 1e-10).
#   6. Verifies the final HWE-filtered dataset.
#
# Input:
#   HapMap_3_r3_1_geno02_mind02_sex_auto_maf05
#
# Output:
#   HWE_check.hwe
#   HWE_check_zoom.hwe
#   HapMap_hwe_filter_step1
#   HapMap_3_r3_1_geno02_mind02_sex_auto_maf05_hwe
#
# PLINK version:
#   PLINK 1.9.0-rc3 (23 Sep 2026)

set -euo pipefail


# --------------------------------------------------
# 1. Define directories and software
# --------------------------------------------------

DATA_DIR="$HOME/Bioinformatics/Marees-GWA_tutorial/1_QC_GWAS"
PROJECT_DIR="$HOME/Bioinformatics/Mini-GWAS-analysis"

PLINK="$HOME/Bioinformatics-tools/PLINK1.9/plink"

INPUT="$DATA_DIR/HapMap_3_r3_1_geno02_mind02_sex_auto_maf05"

HWE_OUT="$DATA_DIR/HWE_check"

HWE_ZOOM="$DATA_DIR/HWE_check_zoom"

CONTROL_FILTER="$DATA_DIR/HapMap_hwe_filter_step1"

FINAL="$DATA_DIR/HapMap_3_r3_1_geno02_mind02_sex_auto_maf05_hwe"


# --------------------------------------------------
# 2. Check software
# --------------------------------------------------

echo "Using PLINK:"
"$PLINK" --version
echo


# --------------------------------------------------
# 3. Calculate HWE statistics
# --------------------------------------------------

echo "Calculating HWE statistics..."

"$PLINK" \
  --bfile "$INPUT" \
  --hardy \
  --out "$HWE_OUT"

echo


# --------------------------------------------------
# 4. Create low-p-value HWE subset for visualization
# --------------------------------------------------

echo "Creating HWE subset with P < 1e-5..."

awk 'NR == 1 || $9 < 0.00001 {print}' \
  "${HWE_OUT}.hwe" \
  > "${HWE_ZOOM}.hwe"

echo "Rows in HWE zoom file:"
wc -l "${HWE_ZOOM}.hwe"

echo


# --------------------------------------------------
# 5. Generate HWE visualization
# --------------------------------------------------

echo "Generating HWE plots..."

Rscript "$PROJECT_DIR/scripts/04_hwe_plot.R"

echo


# --------------------------------------------------
# 6. Apply control HWE threshold
# --------------------------------------------------

echo "Applying control HWE threshold: P < 1e-6..."

"$PLINK" \
  --bfile "$INPUT" \
  --hwe 1e-6 \
  --make-bed \
  --out "$CONTROL_FILTER"

echo


# --------------------------------------------------
# 7. Apply case HWE threshold
#
# In the original Marees tutorial:
#   --hwe 1e-10 --hwe-all
#
# In current PLINK 1.9, --hwe-all is deprecated.
# "include-nonctrl" is used instead.
# --------------------------------------------------

echo "Applying case HWE threshold: P < 1e-10..."

"$PLINK" \
  --bfile "$CONTROL_FILTER" \
  --hwe 1e-10 include-nonctrl \
  --make-bed \
  --out "$FINAL"

echo


# --------------------------------------------------
# 8. Verify control threshold
# --------------------------------------------------

echo "Checking control HWE threshold..."

CONTROL_FAIL=$(
  awk 'NR > 1 && $3 == "UNAFF" && $9 < 1e-6 {count++} END {print count+0}' \
    "${HWE_OUT}.hwe"
)

echo "Control HWE tests with P < 1e-6: $CONTROL_FAIL"

if [ "$CONTROL_FAIL" -ne 0 ]; then
    echo "WARNING: Control HWE tests below threshold were detected."
fi

echo


# --------------------------------------------------
# 9. Verify case threshold
# --------------------------------------------------

echo "Checking case HWE threshold..."

CASE_FAIL=$(
  awk 'NR > 1 && $3 == "AFF" && $9 < 1e-10 {count++} END {print count+0}' \
    "${HWE_OUT}.hwe"
)

echo "Case HWE tests with P < 1e-10: $CASE_FAIL"

if [ "$CASE_FAIL" -ne 0 ]; then
    echo "WARNING: Case HWE tests below threshold were detected."
fi

echo


# --------------------------------------------------
# 10. Final dataset summary
# --------------------------------------------------

echo "Final HWE-filtered dataset:"

echo "Individuals:"
wc -l "${FINAL}.fam"

echo "Variants:"
wc -l "${FINAL}.bim"

echo
echo "QC Step 4 complete."
