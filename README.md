
# SCRI

<!-- badges: start -->

[![R-CMD-check](https://github.com/UMC-Utrecht-RWE/SCRI/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/UMC-Utrecht-RWE/SCRI/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of this package is to aid researchers in preparing analytic
datasets for Self Controlled Risk Interval Analysis.

## Installation

You can install the development version of SCRI from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("UMC-Utrecht-RWE/SCRI")
```

## Example

The package implements a processing pipeline, which takes a study
population and *metadata* which specifies analysis options, and outputs
an analytic dataset. The pipeline is described in schematic form below,
with purple boxes representing functions of the pacakge, blue boxes
representing intermediate outputs, red and orange represents user input
in terms of specifying analysis options and (raw) input data
respectively

<figure>
<img
src="https://github.com/UMC-Utrecht-RWE/SCRI/assets/138911044/8cbb1033-3e7b-4a05-9c0f-904e55f9fea3"
alt="image" />
<figcaption aria-hidden="true">image</figcaption>
</figure>

The package comes with sample input files for the `StudyPopulation` and
`WindowsMetadata` files respectively.

### Step 1: Computing Windows

In this step, we use the `compute_windows()` function to calculate the
start and end dates of different analysis windows. Let’s start by
grabbing the relevant windows from our example metadata file

``` r
library(SCRI)
data("StudyPopulation")
data("WindowsMetadata")
windowmet <- WindowsMetadata[grepl("post",WindowsMetadata$window_name),]
print(windowmet)
```

    ##     event         window_name reference_date start_window length_window
    ## 5  AESI_1 clean_lookback_post   FIRST_TARGET         -365           365
    ## 6  AESI_1           risk_post   FIRST_TARGET            1            42
    ## 7  AESI_1        washout_post   FIRST_TARGET           43            30
    ## 8  AESI_1        control_post   FIRST_TARGET           73            60
    ## 10 AESI_1      induction_post   FIRST_TARGET            0             1

We are going to use this object in combination with our
`StudyPopulation`, which contains one row per unit of analysis, with
information on the `reference_date` and other dates which will be
relevant in future steps.

``` r
head(StudyPopulation)
```

    ##    person_id op_start_date FIRST_TARGET SECOND_TARGET death_date
    ## 1:         1    2013-04-26   2021-02-11          <NA>       <NA>
    ## 2:         2    2012-10-31   2021-08-17          <NA>       <NA>
    ## 3:         3    2018-07-08   2021-01-28    2021-03-20       <NA>
    ## 4:         4    2012-03-07   2021-04-13    2021-05-29       <NA>
    ## 5:         5    2017-10-05   2021-04-12          <NA>       <NA>
    ## 6:         6    2013-04-01   2021-02-25          <NA> 2021-09-03
    ##    general_end_fup
    ## 1:      2021-05-07
    ## 2:      2021-11-10
    ## 3:      2021-06-13
    ## 4:      2021-08-22
    ## 5:      2021-07-06
    ## 6:      2021-05-21

The `compute_windows()` returns start and end dates for each of the
windows under consideration, anchored to the relevant reference date.
The output by default is wide format. The output object also inherits
all columns from the input `studypopulation`

``` r
sp_windows <- compute_windows(studypopulation = StudyPopulation, windowmeta= windowmet, 
                id_column = "person_id")

sp_windows[1,c("person_id","start_control_post","end_control_post", "start_risk_post","end_risk_post")]
```

    ##    person_id start_control_post end_control_post start_risk_post end_risk_post
    ## 1:         1         2021-04-25       2021-06-23      2021-02-12    2021-03-25

#### Step 2: Cleaning Windows
