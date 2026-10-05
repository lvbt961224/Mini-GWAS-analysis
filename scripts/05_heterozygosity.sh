#!/bin/bash

# Step 5: Individual heterozygosity QC

# Input dataset
INPUT="data/processed/HapMap_3_r3_1_geno02_mind02_sex_auto_maf05_hwe"

# 1. Exclude predefined high-LD/inversion regions and LD-prune SNPs
plink --bfile "$INPUT" \
      --exclude range data/processed/inversion.txt \
      --indep-pairwise 50 5 0.2 \
      --out data/processed/indepSNP

# 2. Calculate heterozygosity using the pruned SNP set
plink --bfile "$INPUT" \
      --extract data/processed/indepSNP.prune.in \
      --het \
      --out data/processed/heterozygosity

# 3. Identify individuals with heterozygosity >3 SD from the mean
Rscript scripts/heterozygosity_outliers.R

# 4. Remove heterozygosity outliers from the full dataset
plink --bfile "$INPUT" \
      --remove data/processed/heterozygosity_fail_ind.txt \
      --make-bed \
      --out "${INPUT}_het"
