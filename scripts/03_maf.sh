#!/bin/bash

# QC Step 3: Minor Allele Frequency (MAF)
#
# This script:
#   1. Selects autosomal SNPs (chromosomes 1-22).
#   2. Calculates allele frequencies.
#   3. Generates the MAF distribution plot using R.
#   4. Filters variants with MAF < 0.05.
#   5. Recalculates MAF after filtering.
#   6. Verifies that no variants with MAF < 0.05 remain.
#
# Input:
#   HapMap_3_r3_1_geno02_mind02_sex
#
# Main outputs:
#   snp_1_22.txt
#   HapMap_3_r3_1_geno02_mind02_sex_auto
#   MAF_check.frq
#   HapMap_3_r3_1_geno02_mind02_sex_auto_maf05
#   MAF_check_filtered.frq
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

INPUT="$DATA_DIR/HapMap_3_r3_1_geno02_mind02_sex"

AUTOSOMAL_SNP_LIST="$DATA_DIR/snp_1_22.txt"

AUTOSOMAL_DATASET="$DATA_DIR/HapMap_3_r3_1_geno02_mind02_sex_auto"

MAF_OUT="$DATA_DIR/MAF_check"

MAF_FILTERED="$DATA_DIR/HapMap_3_r3_1_geno02_mind02_sex_auto_maf05"

MAF_FILTERED_FREQ="$DATA_DIR/MAF_check_filtered"


# --------------------------------------------------
# 2. Check software
# --------------------------------------------------

echo "Using PLINK:"
"$PLINK" --version

echo


# --------------------------------------------------
# 3. Create autosomal SNP list
# --------------------------------------------------

echo "Creating autosomal SNP list..."

awk '$1 >= 1 && $1 <= 22 {print $2}' \
  "${INPUT}.bim" \
  > "$AUTOSOMAL_SNP_LIST"


echo "Number of autosomal SNPs:"
wc -l "$AUTOSOMAL_SNP_LIST"

echo


# --------------------------------------------------
# 4. Generate autosomal-only dataset
# --------------------------------------------------

echo "Creating autosomal-only dataset..."

"$PLINK" \
  --bfile "$INPUT" \
  --extract "$AUTOSOMAL_SNP_LIST" \
  --make-bed \
  --out "$AUTOSOMAL_DATASET"

echo


# --------------------------------------------------
# 5. Verify that only autosomal variants remain
# --------------------------------------------------

echo "Checking for non-autosomal variants..."

NON_AUTOSOMAL_COUNT=$(
  awk '$1 == 23 || $1 == 24 || $1 == 25 {count++} END {print count+0}' \
    "${AUTOSOMAL_DATASET}.bim"
)

echo "Non-autosomal variants remaining: $NON_AUTOSOMAL_COUNT"

if [ "$NON_AUTOSOMAL_COUNT" -ne 0 ]; then
    echo "ERROR: Non-autosomal variants remain in the dataset."
    exit 1
fi

echo


# --------------------------------------------------
# 6. Calculate baseline MAF
# --------------------------------------------------

echo "Calculating MAF..."

"$PLINK" \
  --bfile "$AUTOSOMAL_DATASET" \
  --freq \
  --out "$MAF_OUT"

echo


# --------------------------------------------------
# 7. Generate MAF visualization
# --------------------------------------------------

echo "Generating MAF distribution plot..."

Rscript "$PROJECT_DIR/scripts/03_maf_plot.R"

echo


# --------------------------------------------------
# 8. Apply MAF >= 0.05 filter
# --------------------------------------------------

echo "Applying MAF threshold of 0.05..."

"$PLINK" \
  --bfile "$AUTOSOMAL_DATASET" \
  --maf 0.05 \
  --make-bed \
  --out "$MAF_FILTERED"

echo


# --------------------------------------------------
# 9. Recalculate MAF after filtering
# --------------------------------------------------

echo "Recalculating MAF after filtering..."

"$PLINK" \
  --bfile "$MAF_FILTERED" \
  --freq \
  --out "$MAF_FILTERED_FREQ"

echo


# --------------------------------------------------
# 10. Verify no variants with MAF < 0.05 remain
# --------------------------------------------------

echo "Checking for variants with MAF < 0.05..."

LOW_MAF_COUNT=$(
  awk 'NR > 1 && $5 < 0.05 {count++} END {print count+0}' \
    "${MAF_FILTERED_FREQ}.frq"
)

echo "Variants with MAF < 0.05 remaining: $LOW_MAF_COUNT"

if [ "$LOW_MAF_COUNT" -ne 0 ]; then
    echo "ERROR: Variants with MAF < 0.05 remain after filtering."
    exit 1
fi

echo


# --------------------------------------------------
# 11. Final dataset summary
# --------------------------------------------------

echo "Final MAF-filtered dataset:"

echo "Individuals:"
wc -l "${MAF_FILTERED}.fam"

echo "Variants:"
wc -l "${MAF_FILTERED}.bim"

echo
echo "QC Step 3 complete."
