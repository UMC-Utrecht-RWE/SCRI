
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
# library(SCRI)
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

    ##   person_id op_start_date FIRST_TARGET SECOND_TARGET death_date general_end_fup
    ## 1         1    2013-04-26   2021-02-11          <NA>       <NA>      2021-05-07
    ## 2         2    2012-10-31   2021-08-17          <NA>       <NA>      2021-11-10
    ## 3         3    2018-07-08   2021-01-28    2021-03-20       <NA>      2021-06-13
    ## 4         4    2012-03-07   2021-04-13    2021-05-29       <NA>      2021-08-22
    ## 5         5    2017-10-05   2021-04-12          <NA>       <NA>      2021-07-06
    ## 6         6    2013-04-01   2021-02-25          <NA> 2021-09-03      2021-05-21

The `compute_windows()` returns start and end dates for each of the
windows under consideration, anchored to the relevant reference date.
The output by default is wide format. The output object also inherits
all columns from the input `studypopulation`

``` r
sp_windows <- SCRI::compute_windows(studypopulation = StudyPopulation, windowmeta= windowmet, 
                id_column = "person_id")

sp_windows[1,c("person_id", "start_risk_post","end_risk_post","start_control_post","end_control_post")]
```

    ## Key: <person_id>
    ##    person_id start_risk_post end_risk_post start_control_post end_control_post
    ##        <int>          <Date>        <Date>             <Date>           <Date>
    ## 1:         1      2021-02-12    2021-03-25         2021-04-25       2021-06-23

#### Step 2: Cleaning Windows

Now that we have the start and end dates of each window, we can proceed
to the second step: Applying different rules which **alter** or
**clean** those start and end dates based on other available
information. Currently we have implemented **censoring date**
functionality according to two rules:

1)  If a censoring event occurs *during* a window, then the end date of
    that window is moved to the censoring date. All windows that start
    after that censoring date have start\_ and end\_ dates set to NA.

2)  If a censoring event occurs *between* windows, all future start and
    end dates are set to NA.

The function `clean_windows()` takes as input a wide-format dataset
following the same format as that created by
`compute_windows(..., output_format = "wide")`. In addition, the
function takes the names of different date columns in the input dataset
which are used for censoring.

To illustrate, consider this part of the example data with a single
censoring date, general end of follow-up.

    ##    start_risk_post end_risk_post start_control_post end_control_post general_end_fup
    ##             <Date>        <Date>             <Date>           <Date>          <Date>
    ## 1:      2021-02-12    2021-03-25         2021-04-25       2021-06-23      2021-05-07
    ## 2:      2021-03-12    2021-04-22         2021-05-23       2021-07-21      2021-04-14

To censor the risk and control windows shown above, we run the
`clean_windows()` function. Inspecting the output we can see that
censoring rules (1) and (2) have been applied to rows 1 and 2
respectively

``` r
# run the core function
sp_clean <- SCRI::clean_windows(sp_windows,
                                censoring_dates = c("death_date", "general_end_fup"))
```

    ##    start_risk_post end_risk_post start_control_post end_control_post general_end_fup
    ##             <Date>        <Date>             <Date>           <Date>          <Date>
    ## 1:      2021-02-12    2021-03-25         2021-04-25       2021-05-07      2021-05-07
    ## 2:      2021-03-12    2021-04-14               <NA>             <NA>      2021-04-14

#### Step 3: Get records

In this step, we will identify the events that occurred within each
window after they have been **altered** or **cleaned**.

**Select Dates Within Windows**: We use the `get_records()` function to
identify all (or, if specified, only the first) records that fall within
a specified window.

This function identifies all records within the `records_table` that
fall within a window specified in the `scri_trimmed` table in the start
and end columns. It allows for the option to select only the first
record within each window.

**Parameters:**

- `variable_name`: The name of the variable.

- `window_name`: The name of the window.

- `records_table`: The record table of interest, with minimum expected
  columns: person_id, date, value.

- `scri_trimmed`: The trimmed scri.

- `start_window_date_col_name`: The start date column name in the
  scri_trimmed. Default is “start”.

- `end_window_date_col_name`: The end date column name in the
  scri_trimmed. Default is “end”.

- `only_first_date`: A boolean indicating whether to only use the first
  date. Default is FALSE.

- `wide_format_input`: A boolean indicating whether the records table is
  in wide format or not. TRUE applies a melting procedure.

- `start_prefix`: A string that defines the prefix for the start of a
  window. Default is “start”.

- `end_prefix`: string that defines the prefix for the end of a window.
  Default is “end”.

**Example Usage:**

``` r
data(RecordsTable)
# Function call
result <- SCRI::get_records(
  variable_name = "example_variable",
  window_name = "risk_post",
  records_table = RecordsTable,
  scri_trimmed = sp_clean,
  start_window_date_col_name = "start",
  end_window_date_col_name = "end",
  only_first_date = TRUE,
  wide_format_input = TRUE,
  start_prefix = 'start',
  end_prefix = 'end'
)
```

    ##    person_id         variable WindowName WindowLength       Date START_DATE   END_DATE
    ##        <int>           <char>     <char>        <num>     <Date>     <Date>     <Date>
    ## 1:         3 example_variable  risk_post           41 2021-03-01 2021-01-29 2021-03-11
