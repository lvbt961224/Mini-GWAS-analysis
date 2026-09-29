#!/bin/bash

# Baseline allele-frequency analysis
# Dataset: Marees et al. GWAS tutorial
#
# This script performs an initial PLINK analysis of the HapMap-based tutorial dataset before applying QC filters.

# Input dataset
DATASET="HapMap_3_r3_1"

# Run baseline allele-frequency analysis
plink \
  --bfile "$DATASET" \
  --freq \
  --out dataset_baseline
