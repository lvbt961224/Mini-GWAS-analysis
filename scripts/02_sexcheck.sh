#!/bin/bash

# QC Step 2: Sex discrepancy
#
# This script:
#   1. Checks recorded sex against genotype-inferred sex using X-chromosome homozygosity.
#   2. Generates an R visualization.
#   3. Creates a list of individuals flagged as PROBLEM.
#   4. Removes discrepant individuals from the dataset.
#
# Input:
#   HapMap_3_r3_1_geno02_mind02
#
# Output:
#   sexcheck_baseline.sexcheck
#   sex_discrepancy.txt
#   HapMap_3_r3_1_geno02_mind02_sex
#
# The tutorial uses 0.2 and 0.8 as the female and male classification thresholds, respectively.

set -euo pipefail


# --------------------------------------------------
# 1. Define directories and software
# --------------------------------------------------

DATA_DIR="$HOME/Bioinformatics/Marees-GWA_tutorial/1_QC_GWAS"
PROJECT_DIR="$HOME/Bioinformatics/Mini-GWAS-analysis"

PLINK="$HOME/Bioinformatics-tools/PLINK1.9/plink"

INPUT="$DATA_DIR/HapMap_3_r3_1_geno02_mind02"
SEXCHECK_OUT="$DATA_DIR/sexcheck_baseline"
DISCREPANCY_FILE="$DATA_DIR/sex_discrepancy.txt"
OUTPUT="$DATA_DIR/HapMap_3_r3_1_geno02_mind02_sex"


# --------------------------------------------------
# 2. Check software
# --------------------------------------------------

echo "Using PLINK:"
"$PLINK" --version


# --------------------------------------------------
# 3. Check sex discrepancy
# --------------------------------------------------

echo
echo "Running sex discrepancy check..."

"$PLINK" \
  --bfile "$INPUT" \
  --check-sex 0.2 0.8 \
  --out "$SEXCHECK_OUT"


# --------------------------------------------------
# 4. Generate sex-check visualization
# --------------------------------------------------

echo
echo "Generating sex-check plot..."

Rscript "$PROJECT_DIR/scripts/02_sexcheck_plot.R"


# --------------------------------------------------
# 5. Create list of discrepant individuals
# --------------------------------------------------

echo
echo "Creating sex discrepancy list..."

awk '$5 == "PROBLEM" {print $1, $2}' \
  "${SEXCHECK_OUT}.sexcheck" \
  > "$DISCREPANCY_FILE"


echo "Individuals flagged as PROBLEM:"
cat "$DISCREPANCY_FILE"

echo
echo "Number of discrepant individuals:"
wc -l "$DISCREPANCY_FILE"


# --------------------------------------------------
# 6. Remove discrepant individuals
# --------------------------------------------------

if [ -s "$DISCREPANCY_FILE" ]; then

    echo
    echo "Removing discrepant individuals..."

    "$PLINK" \
      --bfile "$INPUT" \
      --remove "$DISCREPANCY_FILE" \
      --make-bed \
      --out "$OUTPUT"

else

    echo
    echo "No sex discrepancies detected."
    echo "No individuals were removed."

fi


# --------------------------------------------------
# 7. Final verification
# --------------------------------------------------

echo
echo "Final dataset summary:"

if [ -f "${OUTPUT}.fam" ]; then
    echo "Individuals:"
    wc -l "${OUTPUT}.fam"

    echo "Variants:"
    wc -l "${OUTPUT}.bim"
fi

echo
echo "QC Step 2 complete."
