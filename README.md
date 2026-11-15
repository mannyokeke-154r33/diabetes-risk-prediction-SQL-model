# Hospital Readmission & FHIR Readiness Audit

An educational healthcare SQL project using the Kaggle Diabetes 130-US Hospitals dataset.

## Project question

Which encounter characteristics are associated with hospital readmission, and how complete are those encounter records for downstream healthcare-data conversion?

## Scope

- Load the Kaggle CSV into SQLite.
- Profile missing values, placeholder values, duplicates, and identifier uniqueness.
- Use SQL filtering, `CASE`, aggregation, subqueries, and optional window functions.
- Compare readmission categories across encounter characteristics.
- Create a project-defined conversion-readiness score.
- Document findings without presenting them as clinical advice or a predictive model.

## Dataset

Download the data from Kaggle:

<https://www.kaggle.com/datasets/brandao/diabetes>

The dataset is historical encounter data from 130 U.S. hospitals covering 1999–2008. The source data is not included in this repository.

Expected source files after extraction:

- `diabetic_data.csv`
- `IDS_mapping.csv`

## Repository status

This repository is being built in stages. The first stage is dataset acquisition and manual schema inspection.

## Planned structure

```text
SQL Project Two/
├── data/
│   ├── raw/          # local Kaggle files; ignored by Git
│   └── processed/    # generated files; ignored by Git
├── outputs/          # generated summaries; ignored by Git
├── sql/
├── src/
├── tests/
└── README.md
```

## Limitations

- The data is historical, not a current 2026 hospital performance report.
- The analysis is descriptive and educational; it does not establish causation or clinical risk.
- Any readiness score will be explicitly defined by this project and is not a formal FHIR certification.
