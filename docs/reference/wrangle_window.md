# Clean the start and end dates of windows created by construct_window() based on censoring dates

Clean the start and end dates of windows created by construct_window()
based on censoring dates

## Usage

``` r
wrangle_window(
  sp_windows_object,
  censoring_dates = NULL,
  windows_priority = NULL
)
```

## Arguments

- sp_windows_object:

  data.table object containing named start and end date columns,
  typically output of construct_window()

- censoring_dates:

  column name(s) of censoring dates

- windows_priority:

  Optional long or MxM priority table. If NULL, the generic package
  configuration is used.

## Value

object of the same dimensions and type as the input, with end dates
possibly censored
