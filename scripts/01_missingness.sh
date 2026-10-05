#!/bin/bash

# QC Step 1: genotype missingness
#
# This script documents the missingness-filtering workflow used in the Mini-GWAS analysis project.
#

DATA_DIR="$HOME/Bioinformatics/Mini-GWAS-analysis/data/processed"
INPUT="$HOME/Bioinformatics/Mini-GWAS-analysis/data/raw/HapMap_3_r3_1"

# ------------------------------------------------------------
# Step 1: Measure baseline missingness
# ------------------------------------------------------------

plink \
  --bfile "$INPUT" \
  --missing \
  --out "$DATA_DIR/missingness_baseline"

# ------------------------------------------------------------
# Step 2: Apply SNP missingness threshold of 20%
# ------------------------------------------------------------

plink \
  --bfile "$INPUT" \
  --geno 0.20 \
  --make-bed \
  --out "$DATA_DIR/HapMap_3_r3_1_geno20"

# ------------------------------------------------------------
# Step 3: Apply SNP missingness threshold of 2%
# ------------------------------------------------------------

plink \
  --bfile "$DATA_DIR/HapMap_3_r3_1_geno20" \
  --geno 0.02 \
  --make-bed \
  --out "$DATA_DIR/HapMap_3_r3_1_geno02"

# ------------------------------------------------------------
# Step 4: Apply individual missingness threshold of 2%
# ------------------------------------------------------------

plink \
  --bfile "$DATA_DIR/HapMap_3_r3_1_geno02" \
  --mind 0.02 \
  --make-bed \
  --out "$DATA_DIR/HapMap_3_r3_1_geno02_mind02"
