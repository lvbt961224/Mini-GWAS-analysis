# QC Step 4: Hardy-Weinberg Equilibrium (HWE)

## Purpose

The fourth quality-control step evaluates whether genotype frequencies at each variant are consistent with Hardy-Weinberg equilibrium (HWE).

For a biallelic variant with allele frequencies p and q, the expected genotype frequencies under HWE are p², 2pq, and q². Strong deviations from HWE can indicate genotyping problems, although deviations can also arise from population structure, biological processes, or the ascertainment of affected individuals.

The Marees et al. tutorial treats HWE as an important genotype-level QC step. For binary traits, it applies a stringent HWE threshold to controls and a more conservative (less stringent) threshold to cases because genuine disease-associated variants can deviate from HWE in case samples.

---

## Input dataset

The HWE analysis was performed after missingness, sex-discrepancy, autosomal extraction, and MAF QC.

Input dataset:

```text
HapMap_3_r3_1_geno02_mind02_sex_auto_maf05
```

Input dataset characteristics:
- Individuals: 164
- Variants: 1,073,226
- Males: 80
- Females: 84
- Cases: 56
- Controls: 56
- Missing phenotypes: 52

The dataset contains autosomal variants only and has already passed the MAF >= 0.05 filter.

---

## Step 4.1: Calculate HWE statistics

HWE statistics were calculated using:

```bash
plink \
  --bfile HapMap_3_r3_1_geno02_mind02_sex_auto_maf05 \
  --hardy \
  --out HWE_check
```

PLINK generated:

```text
HWE_check.hwe
```

PLINK reported that the HWE analysis was performed using founders only: 112 founders and 52 nonfounders.

The case/control HWE report contains separate tests for:
- `ALL` — all analyzed founders
- `AFF` — affected/case founders
- `UNAFF` — unaffected/control founders

For the 112 founders, the overall genotype counts for a fully observed SNP sum to 112 individuals.

---

## HWE output structure

The `HWE_check.hwe` file contains:

| Column | Meaning |
|---|---|
| CHR | Chromosome |
| SNP | Variant identifier |
| TEST | HWE test population |
| A1 | Allele 1 |
| A2 | Allele 2 |
| GENO | Genotype counts |
| O(HET) | Observed heterozygote frequency |
| E(HET) | Expected heterozygote frequency |
| P | HWE p-value |

For case/control data, each variant can therefore contribute up to three HWE test rows.

---

## Step 4.2: Identify strongly deviating HWE results for visualization

Following the Marees tutorial, HWE results with: P < 1e-5 were selected for a zoomed visualization. The tutorial uses this subset only to display strongly deviating HWE results more clearly; it is not the final QC filtering threshold. :contentReference[oaicite:2]{index=2}

The subset was generated with:

```bash
awk 'NR == 1 || $9 < 0.00001 {print}' \
  HWE_check.hwe \
  > HWE_check_zoom.hwe
```

### Results

There were 13 HWE test rows with P < 1e-5. These represented 10 ALL, 1 AFF, and 2 UNAFF.
The 13 rows corresponded to: 12 unique SNPs. The difference between 13 test rows and 12 unique SNPs was caused by `rs10990625`, which had both an `ALL` and an `AFF` result below 1e-5.

---

## Low-p-value HWE results

The 13 rows with P < 1e-5 were:

| SNP | Test | HWE P-value |
|---|---|---:|
| rs7623291 | ALL | 8.938e-06 |
| rs34238522 | ALL | 3.515e-06 |
| rs3102841 | ALL | 1.899e-06 |
| rs354831 | ALL | 6.339e-06 |
| rs10990625 | ALL | 9.391e-06 |
| rs10990625 | AFF | 3.574e-07 |
| rs2918624 | ALL | 8.540e-06 |
| rs4934139 | ALL | 1.722e-06 |
| rs2303632 | UNAFF | 4.934e-06 |
| rs7963063 | UNAFF | 4.934e-06 |
| rs17080881 | ALL | 6.863e-06 |
| rs10507731 | ALL | 6.863e-06 |
| rs12608717 | ALL | 1.410e-06 |

---

## Step 4.3: HWE visualization

Two R-based visualizations were generated:

```text
results/figures/qc/hwe_distribution.png
results/figures/qc/hwe_distribution_zoom.png
```

The first plot displays the distribution of all HWE p-values.

The second plot focuses on HWE p-values below 1e-5.

The full distribution contains a very large concentration of p-values close to 1, with only a small number of HWE tests in the extreme lower tail.

The zoomed plot shows the 13 HWE test rows with P < 1e-5 identified above.

---

## Step 4.4: Control HWE filtering

For the binary trait, the Marees tutorial first applies P < 1e-6 to the control data. The tutorial uses this as the stringent control QC threshold. :contentReference[oaicite:3]{index=3}

The command used was:

```bash
plink \
  --bfile HapMap_3_r3_1_geno02_mind02_sex_auto_maf05 \
  --hwe 1e-6 \
  --make-bed \
  --out HapMap_hwe_filter_step1
```

### Result

PLINK reported 0 variants removed due to Hardy-Weinberg exact test.

The resulting dataset contained:
- Individuals: 164
- Variants: 1,073,226

An independent check of the control HWE results confirmed:

```bash
awk 'NR > 1 && $3 == "UNAFF" && $9 < 1e-6 {count++} END {print count+0}' \
  HWE_check.hwe
```

Result: 0

Thus, no control HWE test fell below the specified threshold.

---

## Step 4.5: Case HWE filtering

The tutorial next applies a much more conservative threshold to the case data: P < 1e-10.

The original tutorial uses:

```text
--hwe 1e-10 --hwe-all
```

and describes the case threshold as less stringent than the control threshold because only extremely strong deviations are excluded in cases. :contentReference[oaicite:4]{index=4}

In current PLINK 1.9, `--hwe-all` is deprecated. The equivalent current syntax is:

```text
--hwe 1e-10 include-nonctrl
```

The command used in this project was therefore:

```bash
plink \
  --bfile HapMap_hwe_filter_step1 \
  --hwe 1e-10 include-nonctrl \
  --make-bed \
  --out HapMap_3_r3_1_geno02_mind02_sex_auto_maf05_hwe
```

### Result

PLINK reported 0 variants removed due to Hardy-Weinberg exact test.

The final dataset contained:
- Individuals: 164
- Variants: 1,073,226

An independent check of the case HWE results confirmed:

```bash
awk 'NR > 1 && $3 == "AFF" && $9 < 1e-10 {count++} END {print count+0}' \
  HWE_check.hwe
```

Result: 0

Thus, no case HWE test fell below the specified threshold.

---

## Final dataset

The final HWE-filtered dataset is:

```text
HapMap_3_r3_1_geno02_mind02_sex_auto_maf05_hwe
```

It contains:
- Individuals: 164
- Variants: 1,073,226
- Males: 80
- Females: 84
- Cases: 56
- Controls: 56
- Missing phenotypes: 52

No variants were removed during either stage of the HWE filtering.

---

## Summary of QC Step 4

| Stage | Individuals | Variants | Notes |
|---|---:|---:|---|
| After MAF QC | 164 | 1,073,226 | Input for HWE |
| HWE test | 164 | 1,073,226 | 112 founders used for HWE calculations |
| Control HWE filter | 164 | 1,073,226 | P < 1e-6; 0 variants removed |
| Case HWE filter | 164 | 1,073,226 | P < 1e-10; 0 variants removed |

---

## Interpretation

The HWE p-value distribution was concentrated toward high p-values, with only a small number of strongly deviating HWE test results.

Thirteen HWE test rows had P < 1e-5, corresponding to 12 unique SNPs. However, none of the control tests met the exclusion criterion of P < 1e-6, and none of the case tests met the more conservative exclusion criterion of P < 1e-10.

Consequently, HWE filtering removed no variants, and all 1,073,226 variants passing the previous MAF step were retained for subsequent QC.
