# QC Step 5: Individual Heterozygosity

## 1. Overview

The purpose of this quality-control step is to identify individuals with unusually high or low heterozygosity.

Heterozygosity refers to the proportion of non-missing genotype calls that are heterozygous. Individuals with extreme heterozygosity values may indicate potential sample-quality problems and are therefore screened as part of the GWAS quality-control workflow.

Following the Marees et al. GWAS tutorial, heterozygosity is calculated using a set of SNPs that are approximately independent. Before LD pruning, predefined high-LD/inversion regions are excluded. Individuals whose heterozygosity rate deviates by more than 3 standard deviations (SD) from the mean are flagged as outliers and removed from the final QC dataset.

---

## 2. Input dataset

The input dataset for this step is the output of the previous HWE filtering step:

```text
HapMap_3_r3_1_geno02_mind02_sex_auto_maf05_hwe
```

Dataset characteristics before heterozygosity QC:
- Individuals: 164
- Males: 80
- Females: 84
- Cases: 56
- Controls: 56
- Missing phenotypes: 52
- Variants: 1,073,226
- Genome regions: autosomes only (chromosomes 1–22)
- MAF threshold: 0.05
- HWE filtering: completed in Step 4

The HWE step did not remove any variants, so the dataset entering Step 5 contained 1,073,226 variants.

---

## 3. Why LD pruning is required

Heterozygosity is calculated from genotype calls. However, many SNPs across the genome are correlated because of linkage disequilibrium (LD).

Highly correlated SNPs contain overlapping genetic information. Therefore, using a very large number of correlated SNPs in a heterozygosity calculation can cause some genomic regions to contribute disproportionately to the estimate.

For this reason, the Marees tutorial recommends calculating heterozygosity using a set of SNPs that are not highly correlated.

The workflow is:

```text
1,073,226 SNPs
      |
      v
Exclude predefined high-LD/inversion regions
      |
      v
LD pruning
      |
      v
Approximately independent SNP set
      |
      v
Calculate individual heterozygosity
```

The resulting LD-pruned SNP list is also retained for later QC analyses, particularly the relatedness analysis in Step 6.

---

## 4. Exclusion of predefined high-LD/inversion regions

The tutorial provides an `inversion.txt` file containing predefined genomic regions considered to have high LD.

The version used in this project contains:

```text
6  25500000  33500000  8 HLA
8  8135000   12000000  Inversion8
17 40900000  45000000  Inversion17
```

These regions are excluded before LD pruning because extended high LD can produce many correlated SNPs within a single genomic region.

Importantly, these regions are excluded only for the SNP-selection procedure used in this heterozygosity analysis. They are not permanently removed from the main GWAS dataset at this stage.

---

## 5. LD pruning

### Command

```bash
plink --bfile data/processed/HapMap_3_r3_1_geno02_mind02_sex_auto_maf05_hwe \
      --exclude range data/processed/inversion.txt \
      --indep-pairwise 50 5 0.2 \
      --out data/processed/indepSNP
```

### Explanation

`--bfile` specifies the input PLINK binary dataset.

`--exclude range data/processed/inversion.txt` tells PLINK to exclude variants located within the genomic coordinate ranges listed in `inversion.txt`.

`--indep-pairwise 50 5 0.2` performs LD pruning.

The parameters mean:
50   = window size
5    = number of SNPs by which the window is shifted at each step
0.2  = LD threshold

The goal is to obtain a subset of SNPs that are approximately independent rather than strongly correlated with one another.

`indepSNP.prune.in` contains the SNPs retained after pruning and is used for the subsequent heterozygosity calculation. This file is also retained for use in later relatedness analysis.

---

## 6. LD-pruning results

The input contained: 1,073,226 variants

Exclusion of the predefined high-LD/inversion regions removed: 9,893 variants

Therefore: 1,073,226 - 9,893 = 1,063,333 variants remained for LD pruning.

LD pruning subsequently removed: 959,189 variants

The number of SNPs retained was therefore: 1,063,333 - 959,189 = 104,144 SNPs

Final LD-pruning result: 104,144 approximately independent SNPs.

PLINK reported the following chromosome-level retained SNP counts:

```text
Chromosome 1:   8,397
Chromosome 2:   7,965
Chromosome 3:   6,957
Chromosome 4:   6,215
Chromosome 5:   6,336
Chromosome 6:   6,092
Chromosome 7:   5,598
Chromosome 8:   5,025
Chromosome 9:   4,983
Chromosome 10:  5,382
Chromosome 11:  5,021
Chromosome 12:  5,250
Chromosome 13:  4,030
Chromosome 14:  3,499
Chromosome 15:  3,404
Chromosome 16:  3,685
Chromosome 17:  3,366
Chromosome 18:  3,413
Chromosome 19:  2,808
Chromosome 20:  3,051
Chromosome 21:  1,713
Chromosome 22:  1,954
```

The chromosome-specific values sum to 104,144 SNPs.

---

## 7. Calculation of heterozygosity

The approximately independent SNP set was then used to calculate individual heterozygosity.

### Command

```bash
plink --bfile data/processed/HapMap_3_r3_1_geno02_mind02_sex_auto_maf05_hwe \
      --extract data/processed/indepSNP.prune.in \
      --het \
      --out data/processed/heterozygosity
```

The calculation included:
164 individuals
104,144 LD-pruned SNPs

The overall genotyping rate for the selected SNP set was: 0.998028

---

## 8. Structure of the heterozygosity output

The `heterozygosity.het` file contains six columns:

```text
FID IID O(HOM) E(HOM) N(NM) F
```

### Interpretation of the columns

`O(HOM)` is the observed number of homozygous genotype calls for the individual.

`E(HOM)` is the expected number of homozygous genotype calls based on allele-frequency expectations.

`N(NM)` is the number of non-missing genotypes among the SNPs used in the calculation.

`F` is the method-of-moments F coefficient calculated by PLINK. It reflects the difference between observed and expected homozygosity and should not be confused with the observed heterozygosity rate used for the outlier analysis below.

---

## 9. Calculation of observed heterozygosity rate

The observed heterozygosity rate was calculated as: (number of non-missing genotypes - number of observed homozygous genotypes)/number of non-missing genotypes

Using the column names from the PLINK output: heterozygosity rate = (N(NM) - O(HOM)) / N(NM)

---

## 10. Heterozygosity distribution

The heterozygosity distribution was visualized using:

```text
scripts/05_heterozygosity_plot.R
```

The output figure is:

```text
results/figures/qc/heterozygosity_distribution.png
```

The plot shows the distribution of individual heterozygosity rates across the 164 individuals, together with the mean and the lower and upper 3-SD thresholds.

---

## 11. Heterozygosity summary statistics

For all 164 individuals:
Number of individuals = 164
Mean heterozygosity   = 0.3538518
SD                    = 0.00296672

The outlier thresholds were calculated as:
Lower cutoff = mean - 3 × SD
Upper cutoff = mean + 3 × SD

giving:
Lower 3-SD cutoff = 0.3449516
Upper 3-SD cutoff = 0.3627519

Therefore, individuals with heterozygosity rates: < 0.3449516 
or: > 0.3627519 were considered heterozygosity outliers.

---

## 12. Identification of heterozygosity outliers

The outlier analysis was performed using:

```text
scripts/heterozygosity_outliers.R
```

The output file is:

```text
data/processed/heterozygosity_outliers.txt
```

Two individuals were identified as heterozygosity outliers:

| FID | IID | Heterozygosity rate | Assessment |
|---:|---|---:|---|
| 1330 | NA12342 | 0.3429725 | Below lower 3-SD cutoff |
| 1459 | NA12874 | 0.3388746 | Below lower 3-SD cutoff |

Both individuals had heterozygosity rates below the lower threshold. No individual exceeded the upper 3-SD cutoff.

Therefore, the number of heterozygosity outliers = 2.

---

## 13. Interpretation of the outliers

Both detected outliers showed unusually low heterozygosity rather than unusually high heterozygosity.

The purpose of this step is to identify extreme deviations from the sample distribution as part of quality control. A heterozygosity outlier is therefore treated as a QC concern according to the predefined criterion, but the heterozygosity result alone does not establish a specific biological cause for the deviation.

---

## 14. Creation of the PLINK removal file

PLINK requires a removal file containing the Family ID (`FID`) and Individual ID (`IID`).

The removal file used in this project is:

```text
data/processed/heterozygosity_fail_ind.txt
```

This file was created from the outlier table using:

```bash
awk 'NR > 1 {print $1, $2}' \
  data/processed/heterozygosity_outliers.txt \
  > data/processed/heterozygosity_fail_ind.txt
```

The header was excluded using `NR > 1`, and only the first two fields (`FID` and `IID`) were retained.

---

## 15. Removal of heterozygosity outliers

The outliers were removed from the full HWE-filtered dataset, rather than from the LD-pruned SNP subset.

### Command

```bash
plink --bfile data/processed/HapMap_3_r3_1_geno02_mind02_sex_auto_maf05_hwe \
      --remove data/processed/heterozygosity_fail_ind.txt \
      --make-bed \
      --out data/processed/HapMap_3_r3_1_geno02_mind02_sex_auto_maf05_hwe_het
```

The resulting dataset is:

```text
data/processed/HapMap_3_r3_1_geno02_mind02_sex_auto_maf05_hwe_het
```

with the following PLINK files:

```text
HapMap_3_r3_1_geno02_mind02_sex_auto_maf05_hwe_het.bed
HapMap_3_r3_1_geno02_mind02_sex_auto_maf05_hwe_het.bim
HapMap_3_r3_1_geno02_mind02_sex_auto_maf05_hwe_het.fam
```

---

## 16. Verification of sample removal

The dataset before heterozygosity-based sample removal contained: 164 individuals

Two individuals were removed:
NA12342
NA12874

The resulting `.fam` file contains: 162 individuals

Verification was performed specifically on column 2:

```bash
awk '$2 == "NA12342" || $2 == "NA12874" {print}' \
  data/processed/HapMap_3_r3_1_geno02_mind02_sex_auto_maf05_hwe_het.fam
```

No output indicates that neither removed individual remains as a genotyped sample.

---

## 17. Final results of Step 5

The main results were:

```text
Input dataset:
164 individuals
1,073,226 variants

High-LD/inversion regions excluded for LD pruning:
9,893 variants

Variants remaining before LD pruning:
1,063,333

Variants retained after LD pruning:
104,144

Mean heterozygosity:
0.3538518

SD:
0.00296672

Lower 3-SD cutoff:
0.3449516

Upper 3-SD cutoff:
0.3627519

Heterozygosity outliers:
2 individuals

Removed individuals:
NA12342
NA12874

Final dataset:
162 individuals
1,073,226 variants
```

The heterozygosity QC step has therefore been completed, and the cleaned dataset is ready for the next stage of the GWAS quality-control pipeline.

The LD-pruned SNP list:

```text
data/processed/indepSNP.prune.in
```

will be reused in the next step for relatedness analysis.
