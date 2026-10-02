# Execute Self Controlled Risk Interval Analysis (SCRI) Pipeline

The \`scri()\` function is an all-in-one workflow that automatically
executes all core SCRI steps, including validation, window computation,
data preparation, and model fitting.

## Usage

``` r
scri(
  study_population,
  window_metadata,
  window_priority,
  records_table,
  time_varying_table = NULL,
  reference_date_name,
  reference_window,
  start_followup_criteria,
  end_followup_criteria,
  strata_column_name = NULL,
  only_first_date = TRUE,
  save_intermediate = NULL
)
```

## Arguments

- study_population:

  A \`data.table\` with one row per individual and relevant date
  columns. Must include the reference date(s) and follow-up criteria.

- window_metadata:

  A \`data.table\` describing exposure and control windows, their types,
  and how they are anchored to the study population.

- window_priority:

  Optional long or MxM priority table. If NULL, the generic package
  configuration is used.

- records_table:

  A \`data.table\` with the records related to the outcomes. This is
  composed by id, date and value of the record.

- time_varying_table:

  TO_BE_DEFINED

- reference_date_name:

  A character vector indicating which column(s) in the study population
  to use as index date(s).

- reference_window:

  A name of the window to which we want to compare this h as to be a
  combination between window_name and reerence name e.g:
  clean_lookback_pre_covid_vaccine_1

- start_followup_criteria:

  A character vector of column names defining when follow-up starts.

- end_followup_criteria:

  A character vector of column names defining when follow-up ends. These
  will be used for censoring and trimming windows.

- strata_column_name:

  A name of a strata column used to stratify the analysis

- only_first_date:

  A boolean indicating whether to only use the first date. Default is
  FALSE.

- save_intermediate:

  A path to a folder where the different intermediat file are saved

## Value

An object representing the cleaned set of windows for each individual
(typically a \`data.table\`). The structure depends on downstream
internal processing steps.

## Details

The function performs several internal steps:

- Validates that the structure and content of \`study_population\` and
  \`window_metadata\` are correctly defined

- Computes exposure and control windows based on the provided metadata

- Trims windows using censoring criteria from \`end_followup_criteria\`

If needed, users can also run the validation helpers independently:
\`validate_study_population()\` and \`validate_window_metadata()\`.

Note: The column name \`int_censdate\` is reserved for internal use. The
function will stop if it is included in \`end_followup_criteria\`.

## Examples

``` r
if (FALSE) { # \dontrun{
result <- scri(
  study_population = StudyPopulation,
  window_metadata = WindowMetadata,
  records_table = RecordsTable,
  reference_date_name = "covid_vaccine_1",
  start_followup_criteria = "op_start_date",
  end_followup_criteria = c("death_date", "general_end_fup")
)
} # }
```
