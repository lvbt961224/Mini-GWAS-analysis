# Dataset Baseline

## Overview

This project uses the genotype dataset distributed with the GWAS tutorial by Marees et al. (2018). The tutorial provides a simulated GWAS dataset based on HapMap CEU data. The dataset is used here as a training dataset for building a reproducible GWAS quality-control and analysis workflow.

---

## Dataset files

The PLINK binary dataset is represented by three files:
- HapMap_3_r3_1.bed - genotype information
- HapMap_3_r3_1.bim - variant/ marker information
- HapMap_3_r3_1.fam - individual-level information

The dataset prefix used throughout the analysis is: HapMap_3_r3_1

---

## Baseline PLINK analysis

The initial dataset was inspected using PLINK:
```plink --bfile HapMap_3_r3_1 --freq --out dataset_baseline```

This command calculates allele frequencies and provides an initial summary of the dataset.

---

## Baseline dataset characteristics

PLINK reported:
- **1,457,897 variants**
- **165 people**
- **80 males**
- **85 females**
- **112 phenotype values**
- **112 founders**
- **53 nonfounders**

The baseline total genotyping rate was: 0.997378

The phenotype distribution was:
- **56 cases**
- **56 controls**
- **53 individuals with missing phenotype information**

The .fam file contains 165 rows, corresponding to the 165 individuals included in the genotype dataset.

---

## FAM file structure

The PLINK .fam file contains six columns:

| Column | Description |
|--------|-------------|
| FID | Family ID |
| IID | Individual ID |
| PID | Paternal ID |
| MID | Maternal ID |
| SEX | Biological sex coded by PLINK |
| PHENO | Phenotype |

The .fam file does not contain a header row.

An example of the data structure is: 1328 NA06989 0 0 2 2, where the final two columns represent sex and phenotype, respectively.

---

## Initial PLINK warning

During the baseline analysis, PLINK reported:
> 225 het. haploid genotypes present (see dataset_baseline.hh); many commands treat these as missing.

This warning was documented but no individuals or variants were removed on the basis of this warning during the baseline analysis. The issue will be considered during subsequent quality-control steps as appropriate.

---

## Allele-frequency output

The `--freq` command generated: dataset_baseline.frq

The main columns in this file are:

| Column | Description |
|--=-----|-------------|
| CHR | Chromosome |
| SNP | Variant identifier |
| A1 | Minor allele |
| A2 | Major/reference allele |
| MAF | Minor allele frequency |
| NCHROBS | Number of observed allele calls |

For example, the first variant in the output was: rs2185539 with a reported MAF of: 0 and NCHROBS = 224.

---

## Relationship to the original tutorial

Marees et al. describe their tutorial dataset as a simulated GWAS dataset based on HapMap CEU data. The authors state that the simulation included 207 individuals and that effect sizes were increased because of the relatively small sample size.

However, the supplied PLINK dataset examined in this project contains **165 individuals** in its .fam file.

Therefore, this project records the characteristics of the actual dataset files used in the analysis rather than assuming that the dataset size described elsewhere in the tutorial necessarily corresponds to the currently examined files.

---

## Baseline summary

| Characteristic | Value |
|----------------|-------|
| Individuals | 165 |
| Males | 80 |
| Females | 85 |
| Variants | 1,457,897 |
| Phenotype values | 112 |
| Cases | 56 |
| Controls | 56 |
| Missing phenotypes | 53 |
| Founders | 112 |
| Nonfounders | 53 |
| Genotyping rate | 0.997378 |

---

## Baseline conclusion

The dataset contains a large number of variants relative to the number of individuals, with a high overall genotyping rate of 99.7378%.

The dataset is suitable for progressing through the tutorial's GWAS quality-control workflow. Subsequent analyses will evaluate genotype missingness, sex discrepancies, minor allele frequency, Hardy-Weinberg equilibrium, relatedness, and population stratification before association testing.

The baseline dataset used for the project is:HapMap_3_r3_1. The results documented here represent the state of the dataset before applying the project's subsequent QC filters.
