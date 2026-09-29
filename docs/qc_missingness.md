# QC Step 1: Missingness

## Purpose

The first quality-control step is to evaluate missing genotype data at both the SNP and individual levels. Following Marees et al. (2018), SNP missingness was assessed first, followed by individual missingness. A relatively relaxed SNP missingness threshold of 20% was initially applied, followed by a stricter threshold of 2%. Individual missingness was then evaluated using a 2% threshold.

---

## Dataset at baseline

The dataset used in this project is the HapMap-based dataset provided with the Marees et al. GWAS tutorial.

Baseline dataset:
- Individuals: 165
- Variants: 1,457,897
- Phenotype values: 112
- Cases: 56
- Controls: 56
- Missing phenotypes: 53
- Males: 80
- Females: 85

Baseline total genotyping rate: 0.997378

PLINK also reported that:
> 225 het. haploid genotypes present (see dataset_baseline.hh); many commands treat these as missing.

These observations were retained for documentation and were not removed at this stage.

---

## Step 1.1: Baseline missingness assessment

Command:
```plink --bfile HapMap_3_r3_1 --missing --out missingness_baseline```

This generated:
- missingness_baseline.imiss - individual missingness
- missingness_baseline.lmiss — SNP missingness

### Baseline results

Maximum individual missingness: 0.02029
Individual with the highest missingness: NA12739
Maximum SNP missingness: 0.04848

Therefore, no individual or SNP exceeded the initial 20% missingness threshold.

At the stricter 2% threshold, however:
- 1 individual had missingness ≥2%
- 27,454 SNPs had missingness >2%

This motivated the subsequent SNP filtering step.

---

## Step 1.2: SNP missingness filtering at 20%

The first SNP-level filter used a 20% missingness threshold:
```plink --bfile HapMap_3_r3_1 --geno 0.20 --make-bed --out HapMap_3_r3_1_geno20```

### Result

No SNPs were removed because no SNP had missingness greater than 20%.

The filtered dataset therefore retained:
- Individuals: 165
- Variants: 1,457,897

---

## Step 1.3: SNP missingness filtering at 2%

A stricter SNP-level missingness threshold of 2% was then applied:
```plink --bfile HapMap_3_r3_1_geno20 --geno 0.02 --make-bed --out HapMap_3_r3_1_geno02```

### Result

After applying the 2% SNP missingness threshold:

- Variants retained: 1,430,443
- Variants removed: 27,454
- Individuals retained: 165

The number of retained variants was calculated as: 1,457,897 - 27,454 = 1,430,443

---

## Step 1.4: Reassess missingness after SNP filtering

Missingness was recalculated after SNP filtering:
```plink --bfile HapMap_3_r3_1_geno02 --missing --out missingness_geno02```

### Results

The filtered dataset contained:
- Variants: 1,430,443
- Individuals: 165

Total genotyping rate: 0.997899

No SNPs remained with missingness >2%.

The individual with the highest remaining missingness was still NA12739. However, its missingness decreased from 0.02029 at baseline to approximately 0.01952 after removal of SNPs with >2% missingness.

Thus, after SNP-level filtering, no individual had genotype missingness ≥2%.

---

## Step 1.5: Individual missingness filtering

Individual-level missingness was then evaluated using a 2% threshold:
```plink --bfile HapMap_3_r3_1_geno02 --mind 0.02 --make-bed --out HapMap_3_r3_1_geno02_mind02```

### Result

PLINK reported:

> 0 people removed due to missing genotype data (--mind)

Therefore:
- Individuals retained: 165
- Individuals removed: 0
- Variants retained: 1,430,443

The final dataset after Step 1 contains:
- **165 individuals**
- **1,430,443 variants**

Phenotype distribution remained:
- 56 cases
- 56 controls
- 53 missing phenotypes

---

## Step 1.6: Final verification

The number of individuals was verified using:
```wc -l HapMap_3_r3_1_geno02_mind02.fam```

Result: 165

The number of variants was verified using:
```wc -l HapMap_3_r3_1_geno02_mind02.bim```

Result: 1,430,443

---

## Summary of missingness QC

| Stage | Individuals | Variants | Notes |
|-------|-------------|----------|-------|
| Baseline | 165 | 1,457,897 | Genotyping rate = 0.997378 |
| --geno 0.20 | 165 | 1,457,897 | No SNPs removed |
| --geno 0.02 | 165 | 1,430,443 | 27,454 SNPs removed |
| Recalculated missingness | 165 | 1,430,443 | No SNPs >2% missing |
| --mind 0.02 | 165 | 1,430,443 | No individuals removed |

### Final QC status

The missingness QC step is complete.

The final dataset for subsequent QC analyses is: HapMap_3_r3_1_geno02_mind02

with:
- 165 individuals
- 1,430,443 variants
- no SNPs with >2% missingness
- no individuals removed by the 2% individual-missingness threshold

---

## Notes

The original Marees et al. tutorial describes missingness filtering as one of the core GWAS quality-control procedures. In this project, the workflow is reproduced while documenting the observed characteristics of the supplied tutorial dataset.

The phenotype contains 56 cases, 56 controls, and 53 individuals with missing phenotype information. These missing phenotype values are retained at this stage because Step 1 focuses specifically on genotype missingness rather than phenotype filtering.

PLINK also reported het. haploid genotypes during the analysis. This observation is documented here and will be considered during later QC steps rather than being treated as an individual-removal criterion at this stage.
