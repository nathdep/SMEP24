# DESCRIPTION

```
Package: SMEP24
Type: Package
Title: SMEP 2024 Project
Version: 0.1.0
Author: Nathan DePuy and Jonathan Templin
Maintainer: Nathan DePuy <depy@uiowa.edu>
Description: Contains files for the 2024 SMEP project
License: MIT + file LICENSE
Encoding: UTF-8
LazyData: true
Suggests: 
    testthat (>= 3.0.0)
Depends:
    bayesplot,
    cmdstanr,
    ggplot2
Config/testthat/edition: 3
RoxygenNote: 7.3.2
```

***

# `bifactor`: Generate a Bifactor Simulation Environment

## Description

Generate a Bifactor Simulation Environment

## Usage

```r
bifactor(...)
```

## Arguments

* `...`: objects inherited from parent

## Value

an environment stored to a list object of the bifactor simulation environment

***

# `countRhat`: Rhat Convergence Indicator Function

## Description

Rhat Convergence Indicator Function

## Usage

```r
countRhat(modsum, rHatThreshold = 1.05)
```

## Arguments

* `modsum`: object generated from `$summary()` method on a `cmdstanr` model environment
* `rHatThreshold`: maximum tolerance for indicated convergence based on Rhat values

## Value

count of Rhat > threshold

***

# `getDims`: Find Dimensions of Filtered `.GlobalEnv` Object

## Description

Find Dimensions of Filtered `.GlobalEnv` Object

## Usage

```r
getDims(name, envir)
```

## Arguments

* `name`: name of target object
* `envir`: name of target environment

## Value

integer of object's total dimensions

***

# `getInits`: Get Parameter Values for Initializing NUTS

## Description

Get Parameter Values for Initializing NUTS

## Usage

```r
getInits(modsum)
```

## Arguments

* `modsum`: object generated from `$summary()` method on a `cmdstanr` model environment

## Value

a named list object containing *expected a priori* from ADVI-approximated posterior draws

***

# `getStdSumScore`: Calculate Standardized Sum Scores

## Description

Calculate Standardized Sum Scores

## Usage

```r
getStdSumScore(resps)
```

## Arguments

* `resps`: matrix of dichotomized (0/1) item response data

## Value

a vector of standardized sum scores of the measured latent trait

***

# `makeNeg`: Negative Lambda Indicator Function

## Description

Negative Lambda Indicator Function

## Usage

```r
makeNeg(lambda, numNeg = 2)
```

## Arguments

* `lambda`: inputted item discrimination/slope values
* `numNeg`: integer indicating quantity of lambda values to negate

## Value

a vector of all lambda values (including negated lambdas)

***

# `methodSelect`: Method Selector by Modulo

## Description

Method Selector by Modulo

## Usage

```r
methodSelect(base10, methodsMatrix)
```

## Arguments

* `base10`: number in base-10 (decimal) representation
* `methodsMatrix`: matrix containing all combinations of tested methods conditions

## Value

A selected row (after converting from base-10/decimal representation) of the methods matrix that describes the tested conditions

***

# `twopl`: Generate a 2-Parameter Logistic (2PL) IRT Simulation Environment

## Description

Generate a 2-Parameter Logistic (2PL) IRT Simulation Environment

## Usage

```r
twopl(...)
```

## Arguments

* `...`: objects inherited from parent

## Value

an environment stored to a list object of the 2PL simulation environment

