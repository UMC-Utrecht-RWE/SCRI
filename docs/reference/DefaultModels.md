# Default Model Configuration for Study Designs

A dataset specifying which statistical model should be used by default
for each study design type. This allows different self-controlled study
designs (SCRI, SCCS, SCAD, CCS) to have different default models.

## Usage

``` r
DefaultModels
```

## Format

A data frame with 4 rows and 2 columns:

- design_name:

  Character. Study design identifier (e.g., "scri", "sccs", "scad",
  "ccs").

- model_name:

  Character. The default model for this design. Must exist in
  [`ValidModels`](ValidModels.md).

## Details

This dataset is accessed by [`get_DefaultModels`](get_DefaultModels.md)
when model_name is NULL in
[`validate_model_name`](validate_model_name.md).

Current defaults by design:

- **scri**: Self-Controlled Risk Interval -\> log_reg

- **sccs**: Self-Controlled Case Series -\> log_reg

- **scad**: Self-Controlled Age-Dependent -\> log_reg

- **ccs**: Case-Cohort Study -\> log_reg

To change the default model for a design, update the corresponding row
in data/create_models.R and regenerate the data files with:
`usethis::use_data(ValidModels, overwrite = TRUE)`
`usethis::use_data(DefaultModels, overwrite = TRUE)`

## Examples

``` r
data("DefaultModels")
print(DefaultModels)
#>   design_name model_name
#> 1        scri    log_reg
```
