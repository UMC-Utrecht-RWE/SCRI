# Identify Start and End Column Names

This function identifies columns in a data.table that follow the naming
convention of starting with "start\_" or "end\_". It's used for
identifying time window columns.

## Usage

``` r
identify_start_end_cols(data)
```

## Arguments

- data:

  A data.table containing columns with names starting with "start\_" and
  "end\_"

## Value

A list with two elements:

- start_names:

  Character vector of column names starting with "start\_"

- end_names:

  Character vector of column names starting with "end\_"
