# Hospital Readmission & FHIR Readiness Audit

An educational healthcare data-engineering project using Python, pandas, SQLite, and SQL to analyze hospital readmission patterns and assess encounter-record completeness.

## Project question

Which encounter characteristics are associated with readmission, and how complete are those encounter records for downstream healthcare-data conversion?

## Dataset

Source: [Diabetes 130-US Hospitals dataset on Kaggle](https://www.kaggle.com/datasets/brandao/diabetes)

The dataset contains 101,766 historical encounter records from 130 U.S. hospitals covering 1999–2008. The raw files are not committed to this repository.

Expected local source path:

```text
data/raw/archive/diabetic_data.csv
```

## Workflow

1. Load and inspect the raw CSV with pandas.
2. Convert `?` placeholders into missing values.
3. Load the encounter data into SQLite.
4. Run eight SQL analyses using filtering, `CASE`, CTEs, conditional aggregation, subqueries, and percentage calculations.
5. Evaluate a project-defined conversion-readiness score.

## Key findings

### Readmission distribution

| Readmission label | Encounters | Percentage |
|---|---:|---:|
| No readmission | 54,864 | 53.91% |
| Readmitted after 30 days | 35,545 | 34.93% |
| Readmitted within 30 days | 11,357 | 11.16% |

These are encounter-level percentages, not unique-patient readmission rates.

### Observed associations

- The 70+ age group had the highest `<30` readmission percentage at **11.85%**.
- Encounters lasting 7–10 days had the highest `<30` readmission percentage at **13.63%**.
- Encounters with 4+ prior inpatient visits had a `<30` readmission percentage of **30.70%**, compared with **8.44%** for encounters with no prior inpatient visits.
- Encounters where A1C was not measured had an `<30` readmission percentage of **11.42%**, compared with **9.66%** for the `Norm` category.

These comparisons are descriptive associations. They do not establish causation or clinical risk.

### Data-quality and readiness findings

- The dataset contains **0 fully duplicated rows**.
- All **101,766 encounter IDs are distinct**.
- `medical_specialty` is missing in **49.08%** of rows.
- `payer_code` is missing in **39.56%** of rows.
- `diag_1` is missing in **0.02%** of rows.
- Under the project-defined readiness rule, **99.98%** of encounters were classified as `Ready` and **0.02%** as `Review`.
- No encounters were classified as `Blocked`.

The readiness score is an educational project metric, not formal FHIR certification. Specialty and payer fields are treated as optional enrichment fields rather than automatic conversion blockers.

## Repository structure

```text
SQL Project Two/
├── data/
│   ├── raw/          # local Kaggle files; ignored by Git
│   └── processed/    # generated SQLite database; ignored by Git
├── outputs/          # generated summaries; ignored by Git
├── sql/
│   └── analysis.sql
├── src/
│   ├── inspect_data.py
│   └── load_database.py
├── tests/
└── README.md
```

## Run locally

From the project root:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python src/inspect_data.py
python src/load_database.py
sqlite3 "data/processed/hospital_readmissions.sqlite" < "sql/analysis.sql"
```

## Limitations

- The dataset is historical and should not be presented as a current 2026 hospital-performance report.
- Multiple rows may belong to the same patient, so encounter-level findings are not patient-level estimates.
- The analysis is descriptive and educational; it is not a clinical decision-support system.
- The readiness score is project-defined and does not replace formal FHIR validation.

## Future improvements

- Add explicit SQLite schema documentation and data dictionary notes.
- Export each query result to a reproducible output file.
- Add automated data-contract tests.
- Map coded admission and discharge fields using the source documentation.
- Add formal FHIR resource fixtures and validation.
