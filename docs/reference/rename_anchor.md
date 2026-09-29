# Rename Reference Date Columns with Anchor Prefix

This function renames reference date columns in a study population
dataset by adding a prefix and sequential numbering.

## Usage

``` r
rename_anchor(study_population, reference_date_name, prefix_name = "anch_")
```

## Arguments

- study_population:

  A data.table containing the study population data

- reference_date_name:

  A character vector indicating which column(s) in the study population
  to use as index date(s).

- prefix_name:

  Character string to be used as prefix for renamed columns. Default is
  'anch\_'

## Value

The modified study_population data.table with renamed columns

## Examples

``` r
if (FALSE) { # \dontrun{
# Single column rename
study_data <- data.table(id = 1:3, 
           index_date = as.Date(c("2023-01-01", "2023-02-15", "2023-03-10")))
renamed_data <- rename_anchor(study_data, "index_date")

# Multiple column rename
study_data <- data.table(id = 1:3, 
         index_date = as.Date(c("2023-01-01", "2023-02-15", "2023-03-10")),
         cohort_entry = as.Date(c("2022-12-01", "2023-01-01", "2023-02-01")))
renamed_data <- rename_anchor(study_data, 
                      c("index_date", "cohort_entry"), prefix_name = "ref_")
} # }
```
