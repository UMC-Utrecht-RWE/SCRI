# Select Dates Window

This function identifies all records within the records that fall within
a window specified in the window_data table in the start and end
columns.

## Usage

``` r
add_records(
  window_data,
  records,
  only_first_record = TRUE,
  is_wide_format = TRUE,
  start_column_prefix = "start",
  end_column_prefix = "end"
)
```

## Arguments

- window_data:

  The input data object recording start/end dates of each window per
  person, after trimming and cleaning. May be a wide or long format,
  output of wrangle_window

- records:

  A data table containing records with at minimum: id, date, value
  columns.

- only_first_record:

  Logical. If TRUE, only keeps the first record per person. Default is
  FALSE.

- is_wide_format:

  Logical. If TRUE, input window_data is in wide format and needs
  conversion. Default is TRUE.

- start_column_prefix:

  A string for the prefix of start date columns in wide format. Default
  is "start".

- end_column_prefix:

  A string for the prefix of end date columns in wide format. Default is
  "end".

## Value

A data table with the result of the query.
