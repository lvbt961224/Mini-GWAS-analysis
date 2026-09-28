#!/bin/bash

# Baseline allele-frequency analysis
# Dataset: Marees et al. GWAS tutorial

plink \
  --bfile HapMap_3_r3_1 \
  --freq \
  --out dataset_baseline
