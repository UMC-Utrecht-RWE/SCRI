
# SCRI

<!-- badges: start -->
[![R-CMD-check](https://github.com/UMC-Utrecht-RWE/SCRI/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/UMC-Utrecht-RWE/SCRI/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of SCRI is to ...

## Installation

You can install the development version of SCRI from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("UMC-Utrecht-RWE/SCRI")
```

## Example

The package implements a processing pipeline, which takes a study population and *metadata* which specifies analysis options, and outputs an analytic dataset. The pipeline is described in schematic form below, with purple boxes representing functions of the pacakge, blue boxes representing intermediate outputs, red and orange represents user input in terms of specifying analysis options and (raw) input data respectively

![image](https://github.com/UMC-Utrecht-RWE/SCRI/assets/138911044/8cbb1033-3e7b-4a05-9c0f-904e55f9fea3)

