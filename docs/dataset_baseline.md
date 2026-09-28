# Baseline Dataset Description

## Dataset

The dataset used for this project is the HapMap-based educational dataset distributed with the Marees et al. GWAS tutorial.

The paper describes a simulated binary phenotype based on HapMap CEU genotype data and states that the simulated dataset had N = 207.

## Observed contents of the distributed PLINK dataset

The actual PLINK files analyzed in this project contain:

| Feature | Value |
|---|---:|
| Individuals | 165 |
| Males | 80 |
| Females | 85 |
| Individuals with phenotype values | 112 |
| Phenotype 1 | 56 |
| Phenotype 2 | 56 |
| Missing phenotype (-9) | 53 |
| Genetic variants | 1,457,897 |

## Baseline PLINK analysis

Command:

```bash
plink --bfile HapMap_3_r3_1 --freq --out dataset_baseline
