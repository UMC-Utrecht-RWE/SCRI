# WindowMetadata

A metadata file, describing different window types (control, exposed,
lookback, induction, washout) for SCRI analysis and how they are
anchored

## Usage

``` r
WindowMetadata
```

## Format

\## \`WindowMetadata\` A data frame with 8 rows and 4 variables:

- outcome:

  Outcome identifier (e.g., myocarditis, pericarditis).

- window_name:

  window identifier (chr)

- start_window:

  How many days before reference_date does the window start? start_date
  = reference_date + start_window

- length_window:

  How many days after start_date does the window end? end_date =
  reference_date + start_window + length_window -1
