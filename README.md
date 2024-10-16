# Installation

Installation via `devtools`:

```r
# install.packages("devtools")
devtools::install_github("nathdep/SMEP24")
```

***
# Research

- Click [**here**](https://github.com/nathdep/SMEP24/blob/main/SMEP_2024.pdf) to view the poster presented at SMEP 2024.
- Click [**here**](https://github.com/nathdep/SMEP24/blob/main/SMEP_2024_article.pdf) to view the SMEP 2024 research proposal related to this project.

***
# Function Index

- Click [**here**](https://github.com/nathdep/SMEP24/wiki/INDEX) to view an online index of the package's functions.
***
# Files

## R
- [**2PL .R syntax**](https://github.com/nathdep/SMEP24/blob/main/R/twopl.R)

- [**Bifactor .R syntax**](https://github.com/nathdep/SMEP24/blob/main/R/bifactor.R)

## Stan 
### Bifactor Item Response Model

- [**All Positive (+λ)**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_ALLPOS.stan)
- [**Control (±λ,Random Initial Values, No Empirical Methods)**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_CONTROL.stan)
- [**ADVI**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_advi.stan)
- [**Empirical TruncNorm (α)**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_empiricalAlpha.stan)
- [**Empirical Positively Bounded μ<sub>λ</sub>**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_empiricalPos.stan)

### 2PL Item Response Model
- [**All Positive (+λ)**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_ALLPOS.stan)
- [**Control (±λ,Random Initial Values, No Empirical Methods)**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_CONTROL.stan)
- [**ADVI**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_advi.stan)
- [**Empirical TruncNorm (α)**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_empiricalAlpha.stan)
- [**Empirical Positively Bounded μ<sub>λ</sub>**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_empiricalPos.stan)

## `bash` Scripts
Click [**here**](https://github.com/nathdep/SMEP24/tree/main/JobScripts) to view the collection of bash scripts used to submit replications and perform Unix-based operations. NOTE: `.job` files are formatted for the *Sun Grid Engine* clustser computing software.
***
# Replication
Click [**here**](https://github.com/nathdep/SMEP24/blob/main/Supp_R/example.R) to access the `example.R` file used to run replications. 
***
# Clean-Up 
Click [**here**](https://github.com/nathdep/SMEP24/blob/main/Supp_R/cleanup.R) to access the `cleanup.R` file needed to re-run simulation environments booted from the HPC queue.

The `simDataFileList.csv` file (a list of all leftover simulation environments booted from the HPC queue/contained in the `simData` directory) may be generated by running `genSimDataList.sh` found [**here**](https://github.com/nathdep/SMEP24/blob/main/genSimDataList.sh). 
***
# Compile
The descriptive statistics for sampled posterior densities may be compiled across replications by running the following `.R` script.

Click [**here**](https://github.com/nathdep/SMEP24/blob/main/Supp_R/compile.R) to access the `compile.R` script. NOTE: make sure to run this file from *within the directory containing the `simData` directory*.
***
# Post-processing
*After compiling the descriptive statistics of sampled posterior densities* across replications, results may be organized in separate `.csv` files according to the methods/control matrices in the `example.R` script.

**Run `postproc.R` *after* executing the `compile.R` script above.**

Click [**here**](https://github.com/nathdep/SMEP24/blob/main/Supp_R/postproc.R) to access the `postproc.R` script. NOTE: make sure to run this file from *within the directory containing the `Findings` directory*.
***
# Findings

Click [**here**](https://github.com/nathdep/SMEP24/tree/main/Visualizations) to view visualizations of model results.

***
# Description of Control/Tested Methods
```r
# EMPIRICAL METHODS
# "empiricalPos" (μ_λ > 0)
# "empiricalAlpha" (λ_i > α)

# STARTING VALUES
# "advi" (item inits from EAP conditioned on StdSumScore -> NUTS)
# "allRand" (all parameters initialized on U(-6,6))
# "stdSumScore" (latent traits initialized on standardized sum scores, all other parameters initialized on U(-6,6))

# MODELS
# "twopl" (2-parameter logistic item response model)
# "bifactor (item response model with 1 General factor and 2 sub-factors)

# SAMPLE SIZE
# Number of examinees = 500 or 2000

### CONTROL MATRIX ###

# ---------------------------------------------------------------
#  startingMethods   empiricalMethods    models    examineeSizes
# ----------------- ------------------ ---------- ---------------
#      ALLPOS               NA           twopl          500
#
#      CONTROL              NA           twopl          500
#
#      ALLPOS               NA          bifactor        500
#
#      CONTROL              NA          bifactor        500
#
#      ALLPOS               NA           twopl         2000
#
#      CONTROL              NA           twopl         2000
#
#      ALLPOS               NA          bifactor       2000
#
#      CONTROL              NA          bifactor       2000
# ---------------------------------------------------------------

### METHODS MATRIX ###

# ---------------------------------------------------------------
#  startingMethods   empiricalMethods    models    examineeSizes
# ----------------- ------------------ ---------- ---------------
#       advi           empiricalPos      twopl          500
#
#      allRand         empiricalPos      twopl          500
#
#    StdSumScore       empiricalPos      twopl          500
#
#       advi          empiricalAlpha     twopl          500
#
#      allRand        empiricalAlpha     twopl          500
#
#    StdSumScore      empiricalAlpha     twopl          500
#
#       advi           empiricalPos     bifactor        500
#
#      allRand         empiricalPos     bifactor        500
#
#    StdSumScore       empiricalPos     bifactor        500
#
#       advi          empiricalAlpha    bifactor        500
#
#      allRand        empiricalAlpha    bifactor        500
#
#    StdSumScore      empiricalAlpha    bifactor        500
#
#       advi           empiricalPos      twopl         2000
#
#      allRand         empiricalPos      twopl         2000
#
#    StdSumScore       empiricalPos      twopl         2000
#
#       advi          empiricalAlpha     twopl         2000
#
#      allRand        empiricalAlpha     twopl         2000
#
#    StdSumScore      empiricalAlpha     twopl         2000
#
#       advi           empiricalPos     bifactor       2000
#
#      allRand         empiricalPos     bifactor       2000
#
#    StdSumScore       empiricalPos     bifactor       2000
#
#       advi          empiricalAlpha    bifactor       2000
#
#      allRand        empiricalAlpha    bifactor       2000
#
#    StdSumScore      empiricalAlpha    bifactor       2000
# ---------------------------------------------------------------
```
***
