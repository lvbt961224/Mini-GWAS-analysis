# QC Step 2: Sex Discrepancy

## Purpose

The second quality-control step evaluates whether the sex recorded in the PLINK dataset is consistent with sex inferred from genotype data.

Marees et al. (2018) recommend using X-chromosome heterozygosity/homozygosity to identify discrepancies between recorded and genotype-inferred sex. In their workflow, individuals with an X-chromosome homozygosity estimate (`F`) below 0.2 are classified as female, whereas individuals with `F` above 0.8 are classified as male. Samples that do not meet the expected range are flagged by PLINK as `PROBLEM`.

---

## Input dataset

The sex-discrepancy analysis was performed after completion of genotype missingness QC.

Input dataset:

```text
HapMap_3_r3_1_geno02_mind02
```

Input dataset characteristics:
- Individuals: 165
- Variants: 1,430,443
- Cases: 56
- Controls: 56
- Missing phenotypes: 53

---

## Preliminary chromosome inspection

Before running the sex check, the chromosome composition of the filtered dataset was examined.

The dataset contained:
- Chromosomes 1–22: autosomal variants
- Chromosome 23: 31,490 variants
- Chromosome 25: 409 variants
- Chromosome 24: no variants

Under the PLINK chromosome convention used here:
- 23 = X chromosome
- 24 = Y chromosome
- 25 = XY/pseudo-autosomal region

The presence of X-chromosome variants permits genotype-based sex checking.

The chromosome 25 variants were already separated from chromosome 23 in the dataset, so no additional X-chromosome splitting step was applied.

---

## Heterozygous haploid genotype warning

During the analysis, PLINK reported:

```text
179 het. haploid genotypes present
```

The associated `.hh` file was:

```text
HapMap_3_r3_1_geno02_mind02.hh
```

The 179 flagged genotype calls were mapped back to the `.bim` file and all were found to be associated with chromosome 23 (X).

The `.hh` file was also inspected at the individual level. The largest numbers of flagged calls were observed for:

```text
1355 NA12413    73
1340 NA07022    37
1340 NA06994    22
1420 NA12003    15
```

The individual ultimately flagged by the sex-discrepancy check, NA10854, did not appear in the `.hh` file.

Therefore, the 179 heterozygous-haploid calls and the single sex discrepancy were treated as separate QC findings.

---

## Step 2.1: Sex discrepancy check

The PLINK sex-check command was:

```bash
plink \
  --bfile HapMap_3_r3_1_geno02_mind02 \
  --check-sex 0.2 0.8 \
  --out sexcheck_baseline
```

PLINK reported:

```text
--check-sex: 23424 Xchr and 0 Ychr variant(s) scanned, 1 problem detected.
```

The output file was:

```text
sexcheck_baseline.sexcheck
```

---

## Sex-check results

The `.sexcheck` file contained 165 individuals.

Summary:

| Status | Number of individuals |
|---|---:|
| OK | 164 |
| PROBLEM | 1 |

The single discrepant individual was:

```text
FID       IID       PEDSEX       SNPSEX       STATUS       F
1349      NA10854   2            1            PROBLEM      0.99
```

Interpretation:

- `PEDSEX = 2` indicates that the individual was recorded as female in the `.fam` file.
- `SNPSEX = 1` indicates that the genotype-based sex inference classified the sample as male.
- `F = 0.99` is strongly within the male range defined for this sex check.
- PLINK therefore classified the sample as `PROBLEM`.

The individual was independently confirmed to be recorded as female in the `.fam` file:

```text
1349 NA10854 NA11839 NA11840 2 -9
```

NA10854 did not occur in the `.hh` file, indicating that the sample was not one of the 179 individual genotype calls responsible for the heterozygous-haploid warning.

---

## Step 2.2: Sex-check visualization

The X-chromosome homozygosity estimates were visualized in R.

The resulting figure is:

```text
results/figures/qc/sex_check.png
```

The plot displays:

- the expected female range (`F < 0.2`)
- the ambiguous range (`0.2 ≤ F ≤ 0.8`)
- the expected male range (`F > 0.8`)
- the X-chromosome `F` value of each individual
- NA10854 highlighted as the single discrepant individual

The visualization shows two clear clusters corresponding to the recorded female and male groups, with NA10854 positioned in the male range despite its recorded female sex.

---

## Step 2.3: Investigate the discrepant individual

The discrepant individual was first verified against the `.fam` file:

```bash
grep -w 'NA10854' HapMap_3_r3_1_geno02_mind02.fam
```

Result:

```text
1349 NA10854 NA11839 NA11840 2 -9
```

The individual was also checked against the `.hh` file:

```bash
grep -w 'NA10854' HapMap_3_r3_1_geno02_mind02.hh
```

No output was returned.

Thus, no heterozygous-haploid genotype calls were listed for NA10854.

---

## Step 2.4: Create the removal list

Following the removal option in the Marees tutorial, a two-column file containing FID and IID was created for individuals with `PROBLEM` status.

The file was:

```text
sex_discrepancy.txt
```

Contents:

```text
1349 NA10854
```

The file was verified to contain one individual:

```bash
wc -l sex_discrepancy.txt
```

Result:

```text
1 sex_discrepancy.txt
```

---

## Step 2.5: Remove the discrepant individual

The discrepant individual was removed using:

```bash
plink \
  --bfile HapMap_3_r3_1_geno02_mind02 \
  --remove sex_discrepancy.txt \
  --make-bed \
  --out HapMap_3_r3_1_geno02_mind02_sex
```

PLINK reported:

```text
--remove: 164 people remaining.
```

The resulting dataset was:

```text
HapMap_3_r3_1_geno02_mind02_sex
```

---

## Final verification

The number of individuals was verified using:

```bash
wc -l HapMap_3_r3_1_geno02_mind02_sex.fam
```

Result:

```text
164
```

The number of variants was verified using:

```bash
wc -l HapMap_3_r3_1_geno02_mind02_sex.bim
```

Result:

```text
1430443
```

The removed individual was confirmed to be absent:

```bash
grep -w 'NA10854' HapMap_3_r3_1_geno02_mind02_sex.fam
```

No output was returned.

The phenotype distribution after removal was:
- Cases: 56
- Controls: 56
- Missing phenotypes: 52

---

## Summary of QC Step 2

| Stage | Individuals | Variants | Notes |
|---|---:|---:|---|
| After missingness QC | 165 | 1,430,443 | Input for sex check |
| Sex check | 165 | 1,430,443 | 164 OK, 1 PROBLEM |
| After removing NA10854 | 164 | 1,430,443 | Final Step 2 dataset |

### Final dataset

The dataset carried forward to the next QC step is:

```text
HapMap_3_r3_1_geno02_mind02_sex
```

with:
- 164 individuals
- 1,430,443 variants
- 56 cases
- 56 controls
- 52 missing phenotypes

---

## Interpretation

One individual, NA10854, showed a discrepancy between recorded sex and genotype-inferred sex. The sample was recorded as female but had an X-chromosome homozygosity estimate of `F = 0.99` and was classified by PLINK as male based on the sex-check thresholds.

Because the recorded and genotype-inferred sex were inconsistent, the sample was excluded from the downstream GWAS QC dataset.

The original Marees tutorial similarly presents deletion of individuals flagged as `PROBLEM` as one option for handling sex discrepancies. The tutorial's example dataset also identifies one woman with a sex discrepancy and an `F` value of 0.99. 
