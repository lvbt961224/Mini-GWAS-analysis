# QC Step 3: Minor Allele Frequency (MAF)

## Purpose

The third quality-control step evaluates the minor allele frequency (MAF) of genetic variants and removes variants with very low MAF.

The Marees et al. tutorial performs this step using autosomal SNPs only, defined as variants on chromosomes 1–22. The tutorial then examines the MAF distribution and applies a MAF threshold of 0.05. The authors note that low-MAF variants provide limited statistical power in smaller samples and may be more prone to genotyping errors; the appropriate threshold depends on sample size. :contentReference[oaicite:1]{index=1}

---

## Input dataset

The MAF analysis was performed after completion of the missingness and sex-discrepancy QC steps.

Input dataset:

```text
HapMap_3_r3_1_geno02_mind02_sex
```

Input dataset characteristics:
- Individuals: 164
- Variants: 1,430,443
- Males: 80
- Females: 84
- Cases: 56
- Controls: 56
- Missing phenotypes: 52

---

## Step 3.1: Restrict to autosomal SNPs

The input dataset contained variants on chromosomes 1–22, chromosome 23 (X), and chromosome 25 (pseudo-autosomal region).

For the MAF analysis, only autosomal SNPs were retained.

The autosomal SNP list was generated with:

```bash
awk '$1 >= 1 && $1 <= 22 {print $2}' \
  HapMap_3_r3_1_geno02_mind02_sex.bim \
  > snp_1_22.txt
```

The autosomal-only dataset was then created with:

```bash
plink \
  --bfile HapMap_3_r3_1_geno02_mind02_sex \
  --extract snp_1_22.txt \
  --make-bed \
  --out HapMap_3_r3_1_geno02_mind02_sex_auto
```

### Result

The autosomal-only dataset contained:
- Individuals: 164
- Variants: 1,398,544

The number of variants removed during autosomal extraction was: 1,430,443 - 1,398,544 = 31,899

These excluded variants consisted of the X chromosome and chromosome 25 variants.

---

## Verification of autosomal extraction

The autosomal dataset was independently checked for variants coded as chromosomes 23, 24, or 25:

```bash
awk '$1 == 23 || $1 == 24 || $1 == 25 {count++} END {print count+0}' \
  HapMap_3_r3_1_geno02_mind02_sex_auto.bim
```

Result: 0

Therefore, no X-, Y-, or XY/PAR-coded variants remained in the autosomal dataset.

---

## Step 3.2: Calculate MAF

Allele frequencies were calculated using:

```bash
plink \
  --bfile HapMap_3_r3_1_geno02_mind02_sex_auto \
  --freq \
  --out MAF_check
```

PLINK reported:

```text
Allele frequencies (founders only)
```

The dataset contained:
- Founders: 112
- Nonfounders: 52

Therefore, the MAF values in `MAF_check.frq` were calculated using the founder subset.

The frequency output contained the following main columns:

| Column | Description |
|---|---|
| CHR | Chromosome |
| SNP | Variant identifier |
| A1 | Minor allele |
| A2 | Other allele |
| MAF | Minor allele frequency |
| NCHROBS | Number of observed allele calls |

For example:

```text
1   rs2185539    T    C       0      224
1  rs11240767    T    C       0      224
1   rs3131972    A    G   0.1652      224
1   rs3131969    A    G   0.1339      224
1   rs1048488    C    T   0.1667      222
```

For the 112 founders, the maximum number of allele observations per fully observed SNP is: 112 × 2 = 224

---

## Step 3.3: Baseline MAF distribution

An R script was used to visualize the autosomal MAF distribution.

The resulting figure is:

```text
results/figures/qc/maf_distribution.png
```

The distribution showed:
- A large spike at MAF = 0.
- A broad distribution of variants across the remaining range up to MAF = 0.5.
- A substantial number of variants below the proposed MAF = 0.05 threshold.

The MAF = 0 spike represents variants for which the minor allele was not observed in the founder subset used for the allele-frequency calculation.

---

## Number of variants below the MAF threshold

The number of variants with MAF <0.05 was calculated with:

```bash
awk 'NR > 1 && $5 < 0.05 {count++} END {print count+0}' MAF_check.frq
```

Result: 325,318

Therefore:
- Total autosomal variants: 1,398,544
- Variants with MAF <0.05: 325,318
- Variants with MAF ≥0.05: 1,073,226

The proportion of variants with MAF <0.05 was approximately: 23.25%

---

## Step 3.4: Apply MAF filter

Variants with MAF <0.05 were removed using:

```bash
plink \
  --bfile HapMap_3_r3_1_geno02_mind02_sex_auto \
  --maf 0.05 \
  --make-bed \
  --out HapMap_3_r3_1_geno02_mind02_sex_auto_maf05
```

PLINK reported:

> 325318 variants removed due to minor allele threshold(s)

and:

> 1073226 variants and 164 people pass filters and QC.

Thus: 1,398,544 - 325,318 = 1,073,226

The resulting number of variants is also identical to the number reported in the original Marees tutorial after applying its `--maf 0.05` filter. :contentReference[oaicite:2]{index=2}

---

## Step 3.5: Post-filter verification

The MAF distribution was recalculated for the filtered dataset:

```bash
plink \
  --bfile HapMap_3_r3_1_geno02_mind02_sex_auto_maf05 \
  --freq \
  --out MAF_check_filtered
```

The final MAF output was checked using:

```bash
awk 'NR > 1 && $5 < 0.05 {count++} END {print count+0}' MAF_check_filtered.frq
```

Result: 0

Therefore, no variants with MAF <0.05 remained after filtering.

---

## Final dataset

The final MAF-filtered dataset is:

```text
HapMap_3_r3_1_geno02_mind02_sex_auto_maf05
```

It contains:
- Individuals: 164
- Variants: 1,073,226
- Males: 80
- Females: 84
- Cases: 56
- Controls: 56
- Missing phenotypes: 52

The final total genotyping rate reported by PLINK during the MAF-filtered frequency calculation was approximately: 0.998039

---

## Summary of QC Step 3

| Stage | Individuals | Variants | Notes |
|---|---:|---:|---|
| After sex-discrepancy QC | 164 | 1,430,443 | Input for Step 3 |
| Autosomal extraction | 164 | 1,398,544 | Chromosomes 1–22 only |
| MAF calculation | 164 | 1,398,544 | Frequencies calculated using founders |
| `--maf 0.05` | 164 | 1,073,226 | 325,318 variants removed |
| Post-filter verification | 164 | 1,073,226 | 0 variants with MAF <0.05 |

---

## Interpretation

The majority of autosomal variants had low missingness and a broad range of allele frequencies, but 325,318 variants had MAF below 0.05 in the founder-based frequency calculation.

Following the Marees tutorial, variants with MAF <0.05 were excluded before proceeding to subsequent QC steps. The final dataset contained 1,073,226 autosomal variants and 164 individuals.

This MAF threshold is specific to the workflow used here and should not be interpreted as a universal cutoff for all GWAS datasets. MAF thresholds should be considered in relation to sample size and study design.
