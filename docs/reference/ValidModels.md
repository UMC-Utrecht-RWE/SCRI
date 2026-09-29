# Valid Models Registry for SCRI Analysis

A dataset containing all statistical models available for use in
self-controlled risk interval (SCRI) analysis and related study designs.
This registry defines the complete set of supported models and their
descriptions.

## Usage

``` r
ValidModels
```

## Format

A data frame with 2 rows and 2 columns:

- model_name:

  Character. Unique identifier for the model (e.g., "log_reg",
  "lin_reg").

- description:

  Character. User-facing description explaining what the model does and
  when to use it.

## Details

This dataset is used by [`get_ValidModels`](get_ValidModels.md) to
retrieve available models. When adding new models to SCRI, add a
corresponding row to this dataset.

The current valid models are:

- **log_reg**: Logistic regression for binary outcomes

- **lin_reg**: Linear regression for continuous outcomes

## Examples

``` r
data("ValidModels")
print(ValidModels)
#>   model_name                                                        description
#> 1    log_reg   Logistic regression: used for modeling binary outcome variables.
#> 2    lin_reg Linear regression: used for modeling continuous outcome variables.
```
