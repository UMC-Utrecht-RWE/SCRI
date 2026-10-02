# Compute start and end window dates for each individual in a study population based on metadata info. First step of the SCRI pipeline

Compute start and end window dates for each individual in a study
population based on metadata info. First step of the SCRI pipeline

## Usage

``` r
construct_window(
  study_population,
  window_metadata,
  reference_date_name,
  id_column = "id"
)
```

## Arguments

- study_population:

  data frame containing one row per unit of observation, reference date
  column specified in window_metadata, any other information

- window_metadata:

  metadatat file specifying window names/types, reference date columns,
  start and length of windows (see details)

- reference_date_name:

  A character vector indicating which column(s) in the study population
  to use as index date(s).

- id_column:

  column name identifying the unique unit of observation in the study
  population

## Value

a data.table object with the same columns as study_population, plus
start\_ and end\_ window dates for each window type supplied in
window_metadata
