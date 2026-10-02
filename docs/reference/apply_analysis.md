# Apply SCRI Analysis Across Outcomes

This function applies Self Controlled Risk Interval Analysis (SCRI)
statistics computation across each unique outcome in the input
analytical dataset. It prepares the data, loops over outcomes, and
aggregates the computed statistics.

## Usage

``` r
apply_analysis(
  SCRI_analytical_dataset,
  reference_date_name,
  reference_window,
  strata_column_name = NULL
)
```

## Arguments

- SCRI_analytical_dataset:

  A \`data.table\` containing the analytical dataset, including
  variables: \`length\`, \`outcome\`, and others required for SCRI.

- reference_date_name:

  A name of the reference date e.g.: covid_vaccine_1

- reference_window:

  A name of the window to which we want to compare this has to be a
  combination between window_name and reerence name e.g:
  clean_lookback_pre_covid_vaccine_1

- strata_column_name:

  A name of a strata column used to stratify the analysis

## Value

A data frame with the combined SCRI results for all outcomes.

## Examples

``` r
if (FALSE) { # \dontrun{
results <- apply_analysis(SCRI_data)
} # }
```
