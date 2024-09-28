# Installation

Installation via `devtools`:

```r
# install.packages("devtools")
devtools::install_github("nathdep/SMEP24")
```

***
# Research Article

Click [**here**](https://github.com/nathdep/SMEP24/blob/main/SMEP_2024.pdf) to view the SMEP 2024 research article related to this project.

***
# Function Index

- Click [**here**](https://github.com/nathdep/SMEP24/wiki/INDEX) to view an online index of the package's functions.
***
# Simulation Files

- [**2PL .R syntax**](https://github.com/nathdep/SMEP24/blob/main/R/twopl.R)

- [**Bifactor .R syntax**](https://github.com/nathdep/SMEP24/blob/main/R/bifactor.R)

***
# Stan Files for Label-Switching Methods

## Bifactor Model

- [**All Positive (+λ)**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_ALLPOS.stan)
- [**Control (±λ,Random Initial Values, No Empirical Methods)**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_CONTROL.stan)
- [**ADVI**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_advi.stan)
- [**Empirical TruncNorm (α)**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_empiricalAlpha.stan)
- [**Empirical Positively Bounded μ<sub>λ</sub>**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_empiricalPos.stan)

## 2PL Model
- [**All Positive (+λ)**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_ALLPOS.stan)
- [**Control (±λ,Random Initial Values, No Empirical Methods)**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_CONTROL.stan)
- [**ADVI**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_advi.stan)
- [**Empirical TruncNorm (α)**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_empiricalAlpha.stan)
- [**Empirical Positively Bounded μ<sub>λ</sub>**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_empiricalPos.stan)

# Replication
Click [**here**](https://github.com/nathdep/SMEP24/blob/main/example.R) to access the example `.R` file displayed below.
***
# Description of Controls/Tested Methods
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
```
***
# Control Matrix

```r
# --------------------------------------------
#   models    startingMethods   examineeSizes
# ---------- ----------------- ---------------
#   twopl         ALLPOS             500
#
#  bifactor       ALLPOS             500
#
#   twopl         CONTROL            500
#
#  bifactor       CONTROL            500
#
#   twopl         ALLPOS            2000
#
#  bifactor       ALLPOS            2000
#
#   twopl         CONTROL           2000
#
#  bifactor       CONTROL           2000
# --------------------------------------------
```
***
# Methods Matrix 

----------------------------------------------------------------
 starting_methods   empiricalMethods    models    examineeSizes
------------------ ------------------ ---------- ---------------
       advi           empiricalPos      twopl          500

     allRand          empiricalPos      twopl          500

   StdSumScore        empiricalPos      twopl          500

       advi          empiricalAlpha     twopl          500

     allRand         empiricalAlpha     twopl          500

   StdSumScore       empiricalAlpha     twopl          500

       advi           empiricalPos     bifactor        500

     allRand          empiricalPos     bifactor        500

   StdSumScore        empiricalPos     bifactor        500

       advi          empiricalAlpha    bifactor        500

     allRand         empiricalAlpha    bifactor        500

   StdSumScore       empiricalAlpha    bifactor        500

       advi           empiricalPos      twopl         2000

     allRand          empiricalPos      twopl         2000

   StdSumScore        empiricalPos      twopl         2000

       advi          empiricalAlpha     twopl         2000

     allRand         empiricalAlpha     twopl         2000

   StdSumScore       empiricalAlpha     twopl         2000

       advi           empiricalPos     bifactor       2000

     allRand          empiricalPos     bifactor       2000

   StdSumScore        empiricalPos     bifactor       2000

       advi          empiricalAlpha    bifactor       2000

     allRand         empiricalAlpha    bifactor       2000

   StdSumScore       empiricalAlpha    bifactor       2000
----------------------------------------------------------------


***
# Clean-Up 
Click [**here**](https://github.com/nathdep/SMEP24/blob/main/cleanup.R) to access the `.R` file needed to re-run simulation environments booted from the HPC queue.

The `simDataFileList.csv` file (a list of all leftover simulation environments booted from the HPC queue/contained in the `simData` directory) may be generated by running `genSimDataList.sh` found [**here**](https://github.com/nathdep/SMEP24/blob/main/genSimDataList.sh). 
***
# Compile
The descriptive statistics for sampled posterior densities may be compiled across replications by running the following `.R` script.

Click [**here**](https://github.com/nathdep/SMEP24/blob/main/compile.R) to access the `compile.R` script. NOTE: make sure to run this file from *within the directory containing the `simData` directory*.
***
#Post-processing
*After compiling the descriptive statistics of sampled posterior densities* across replications, results may be organized in separate `.csv` files according to the methods/control matrices in the `example.R` script.

**Run `postproc.R` *after* executing the `compile.R` script above.**

Click [**here**](https://github.com/nathdep/SMEP24/blob/main/postproc.R) to access the `postproc.R` script. NOTE: make sure to run this file from *within the directory containing the `Findings` directory*.
***
