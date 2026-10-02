# SCRI

## SCRI: Self-Controlled Risk Interval analysis for repeated exposures

SCRI is an R package for performing Self-Controlled Risk Interval (SCRI)
analyses. It supports flexible study designs with multiple reference
dates, repeated exposures or doses, and configurable risk-window
priorities.

The package provides an end-to-end workflow for: - validating study
inputs and window definitions, - constructing analysis windows from
exposure and reference dates, - resolving overlapping or censored
windows, - matching outcome records to analysis windows, - preparing
analytical datasets, - and estimating event counts, person-time,
incidence rate ratios, and confidence intervals using conditional
logistic regression.

### Core workflow

The main workflow is built around [`scri()`](reference/scri.md), which
combines the individual steps into a single analysis pipeline. For more
fine-grained control, the workflow can be run step by step with:

- [`construct_window()`](reference/construct_window.md) — generate
  analysis windows from reference dates
- [`wrangle_window()`](reference/wrangle_window.md) — censor and resolve
  overlapping windows
- [`add_records()`](reference/add_records.md) — link outcome records to
  analysis windows
- [`scri()`](reference/scri.md) — run the full validated SCRI pipeline

### Design highlights

- Supports repeated exposures and multiple reference dates
- Allows configurable window-priority rules for overlapping exposure
  windows
- Includes validation helpers for study populations, window metadata,
  and model names
- Uses explicit identifiers and outcome fields for clearer data handling
- Designed for reproducible, transparent SCRI analyses

### Getting started

See the package vignette and function documentation for a complete
worked example and details on data requirements, window construction,
and model configuration.
