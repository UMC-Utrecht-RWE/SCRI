# melt_window_data

This function takes windows_trimmed in a wide format and transforms it
in a long format.

## Usage

``` r
melt_window_data(
  window_data,
  start_column_prefix = "start",
  end_column_prefix = "end"
)
```

## Arguments

- window_data:

  A data table in wide format.

- start_column_prefix:

  A string that defines the prefix for the start of a window. Default is
  "start".

- end_column_prefix:

  A string that defines the prefix for the end of a window. Default is
  "end".

## Value

A data table in long format.
