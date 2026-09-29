# Prepare Analytical Dataset from SCRI Identified Records

This function processes a dataset of SCRI (Self Controlled Risk Interval
Analysis) identified records and prepares it for further analytical use.
It can aggregate events by patient ID and optionally merge with a
stratification variable.

## Usage

``` r
prepare_analytical_dataset(
  SCRI_identified_records,
  strata_column_name = NULL,
  only_first_date = FALSE
)
```

## Arguments

- SCRI_identified_records:

  A data.table containing SCRI identified records with columns: id,
  outcome, window_name, window_length, date

- strata_column_name:

  Character string specifying the column name in study_population to use
  for stratification. Default is NULL (no stratification).

- only_first_date:

  Logical. If TRUE, only the first event is considered. If FALSE, all
  events are summed. Default is FALSE.

## Value

A data.table with processed data ready for analysis

## Examples

``` r
if (FALSE) { # \dontrun{
data <- data.table(
  id = 1:3, outcome = "SCRI", window_name = "W1",
  window_length = 30, date = as.Date(c("2023-01-01", NA, "2023-02-15"))
)
pop <- data.table(id = 1:3, gender = c("M", "F", "M"))
prepare_analytical_dataset(data, "gender", FALSE, pop)
} # }
```
