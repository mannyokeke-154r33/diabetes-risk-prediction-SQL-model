# SQL-to-Model Diabetes Risk Prediction System

An educational healthcare data project that combines SQL analysis with a transparent diabetes-risk classifier written from scratch in NumPy.

## Dataset

Source: [Diabetes Risk Prediction Dataset on Kaggle](https://www.kaggle.com/datasets/srisyra02/diabetes-risk-prediction-dataset)

The dataset contains approximately 50,000 synthetic patient records and 42 columns covering demographics, metabolic markers, lifestyle, comorbidities, and risk labels.

Place the downloaded file here:

~~~text
data/raw/diabetes_risk/diabetes_risk_prediction_dataset.csv
~~~

## Reference implementation

The model structure is based on this from-scratch logistic-regression example:

<https://github.com/amitshekhariitbhu/build-your-own-x-machine-learning/blob/main/tutorials/miscellaneous-applications/diabetes-prediction-system/diabetes_prediction_system.py>

This project adapts that idea to a newer Kaggle dataset using SQL staging, data-quality analysis, median imputation, feature standardization, gradient descent, and classification metrics.

## Project question

Can a SQL-backed pipeline use routine health indicators to classify high diabetes-risk records while making leakage and data-quality decisions explicit?

## Target definition

The source target is Diabetes_Risk. For this educational binary model:

- High becomes 1
- Low or Moderate becomes 0

This is a project-defined classification target, not a diagnosis.

## Leakage controls

The model excludes fields that appear to be derived from the target or downstream recommendations:

- Diabetes_Risk_Score
- AI_Health_Recommendation
- Doctor_Consultation_Needed
- BMI_CATEGORY
- Diabetes_Risk

## Workflow

1. Inspect the raw CSV with pandas.
2. Stage the raw records in SQLite.
3. Use SQL to analyze target balance, missingness, risk bands, and comorbidity patterns.
4. Impute numeric missing values using training-set medians only.
5. Standardize features using training-set statistics only.
6. Train logistic regression from scratch with NumPy gradient descent.
7. Compare the model with a majority-class baseline using accuracy, precision, recall, and F1.

## Results

### SQL findings

- High-risk records represented 73.19% of the dataset.
- High-risk prevalence increased from 63.23% for BMI below 25 to 80.54% for BMI of 30 or higher.
- High-risk prevalence increased from 57.81% among patients younger than 30 to 82.95% among patients aged 60 or older.
- Patients with a family history of diabetes had an 82.91% high-risk rate, compared with 63.52% for patients without one.
- The dataset contained no duplicate or null Patient_ID values.

### Model findings

The model used 40,001 training records and 9,999 test records.

| Metric | Result |
|---|---:|
| Majority baseline accuracy | 73.2% |
| Model accuracy | 83.0% |
| Precision | 85.5% |
| Recall | 92.4% |
| F1 score | 88.8% |

The model improved accuracy over the majority-class baseline. Since the target is imbalanced, F1, precision, and recall are reported alongside accuracy.

These findings are educational associations from a synthetic dataset. They should not be interpreted as clinical evidence or used for diagnosis.

## Assistant collaboration model

This is a guided vibe-coding project. The assistant helps by:

- Improving the user's project scope and repository structure.
- Reviewing user's code and query output.
- Diagnosing errors and explaining the underlying cause.
- Checking for data leakage, reproducibility problems, and misleading healthcare claims.

You own the hands-on learning work. You are expected to:

- Download and inspect the dataset.
- Complete the SQL TODOs.
- Type the Python code.
- Run the pipeline and interpret the output.
- Make and verify Git commits.
- Decide how to communicate the project.

The working loop is:
1. Explain
2. Implement
3. Run
4. Review
5. Improve.

## Limitation

The dataset is synthetic and the model is educational. It is not a diagnostic tool, clinical decision-support system, or production healthcare application. Its intended use is limited to academic and research purposes.

## Run locally

~~~bash
source .venv/bin/activate
python src/inspect_data.py
python src/load_database.py
sqlite3 "data/processed/diabetes_risk/diabetes_risk.sqlite" < "sql/analysis.sql"
python src/diabetes_prediction_system.py
~~~
