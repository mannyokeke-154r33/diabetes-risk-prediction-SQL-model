-- SQL-to-Model Diabetes Risk Prediction System

-- Q1: Source target distribution
SELECT
    Diabetes_Risk,
    COUNT(*) AS patient_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM diabetes_risk), 2) AS percentage
FROM diabetes_risk
GROUP BY Diabetes_Risk
ORDER BY patient_count DESC;

-- Q2: Numeric clinical fields that contain missing values
WITH field_completeness AS (
    SELECT 'Age' AS field_name, COUNT(*) AS total_rows,
           SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS missing_count
    FROM diabetes_risk

    UNION ALL
    SELECT 'Height_cm', COUNT(*),
           SUM(CASE WHEN Height_cm IS NULL THEN 1 ELSE 0 END)
    FROM diabetes_risk

    UNION ALL
    SELECT 'Weight_kg', COUNT(*),
           SUM(CASE WHEN Weight_kg IS NULL THEN 1 ELSE 0 END)
    FROM diabetes_risk

    UNION ALL
    SELECT 'Blood_Glucose', COUNT(*),
           SUM(CASE WHEN Blood_Glucose IS NULL THEN 1 ELSE 0 END)
    FROM diabetes_risk

    UNION ALL
    SELECT 'HbA1c', COUNT(*),
           SUM(CASE WHEN HbA1c IS NULL THEN 1 ELSE 0 END)
    FROM diabetes_risk

    UNION ALL
    SELECT 'Total_Cholesterol', COUNT(*),
           SUM(CASE WHEN Total_Cholesterol IS NULL THEN 1 ELSE 0 END)
    FROM diabetes_risk

    UNION ALL
    SELECT 'HDL', COUNT(*),
           SUM(CASE WHEN HDL IS NULL THEN 1 ELSE 0 END)
    FROM diabetes_risk

    UNION ALL
    SELECT 'LDL', COUNT(*),
           SUM(CASE WHEN LDL IS NULL THEN 1 ELSE 0 END)
    FROM diabetes_risk

    UNION ALL
    SELECT 'Triglycerides', COUNT(*),
           SUM(CASE WHEN Triglycerides IS NULL THEN 1 ELSE 0 END)
    FROM diabetes_risk

    UNION ALL
    SELECT 'Exercise_Hours_Per_Week', COUNT(*),
           SUM(CASE WHEN Exercise_Hours_Per_Week IS NULL THEN 1 ELSE 0 END)
    FROM diabetes_risk
)
SELECT
    field_name,
    total_rows,
    missing_count,
    ROUND(100.0 * missing_count / total_rows, 2) AS missing_percentage
FROM field_completeness
ORDER BY missing_count DESC;

-- Q3: High-risk prevalence by blood-glucose band
WITH glucose_bucketed AS (
    SELECT
        CASE
            WHEN Blood_Glucose IS NULL THEN 'Unknown'
            WHEN Blood_Glucose < 100 THEN '<100'
            WHEN Blood_Glucose < 126 THEN '100-125'
            WHEN Blood_Glucose < 200 THEN '126-199'
            ELSE '200+'
        END AS glucose_band,
        Diabetes_Risk
    FROM diabetes_risk
),
glucose_summary AS (
    SELECT
        glucose_band,
        COUNT(*) AS patient_count,
        SUM(CASE WHEN Diabetes_Risk = 'High' THEN 1 ELSE 0 END)
            AS high_risk_count
    FROM glucose_bucketed
    GROUP BY glucose_band
)
SELECT
    glucose_band,
    patient_count,
    high_risk_count,
    ROUND(100.0 * high_risk_count / patient_count, 2)
        AS high_risk_percentage
FROM glucose_summary
ORDER BY CASE glucose_band
    WHEN '<100' THEN 1
    WHEN '100-125' THEN 2
    WHEN '126-199' THEN 3
    WHEN '200+' THEN 4
    ELSE 5
END;

-- Q4: High-risk prevalence by BMI band
WITH bmi_bucketed AS (
    SELECT
        CASE
            WHEN BMI IS NULL THEN 'Unknown'
            WHEN BMI < 18.5 THEN '<18.5'
            WHEN BMI < 25 THEN '18.5-24.9'
            WHEN BMI < 30 THEN '25-29.9'
            ELSE '30+'
        END AS bmi_band,
        Diabetes_Risk
    FROM diabetes_risk
),
bmi_summary AS (
    SELECT
        bmi_band,
        COUNT(*) AS patient_count,
        SUM(CASE WHEN Diabetes_Risk = 'High' THEN 1 ELSE 0 END)
            AS high_risk_count
    FROM bmi_bucketed
    GROUP BY bmi_band
)
SELECT
    bmi_band,
    patient_count,
    high_risk_count,
    ROUND(100.0 * high_risk_count / patient_count, 2)
        AS high_risk_percentage
FROM bmi_summary
ORDER BY CASE bmi_band
    WHEN '<18.5' THEN 1
    WHEN '18.5-24.9' THEN 2
    WHEN '25-29.9' THEN 3
    WHEN '30+' THEN 4
    ELSE 5
END;

-- Q5: High-risk prevalence by age band
WITH age_bucketed AS (
    SELECT
        CASE
            WHEN Age IS NULL THEN 'Unknown'
            WHEN Age < 30 THEN '<30'
            WHEN Age < 45 THEN '30-44'
            WHEN Age < 60 THEN '45-59'
            ELSE '60+'
        END AS age_band,
        Diabetes_Risk
    FROM diabetes_risk
),
age_summary AS (
    SELECT
        age_band,
        COUNT(*) AS patient_count,
        SUM(CASE WHEN Diabetes_Risk = 'High' THEN 1 ELSE 0 END)
            AS high_risk_count
    FROM age_bucketed
    GROUP BY age_band
)
SELECT
    age_band,
    patient_count,
    high_risk_count,
    ROUND(100.0 * high_risk_count / patient_count, 2)
        AS high_risk_percentage
FROM age_summary
ORDER BY CASE age_band
    WHEN '<30' THEN 1
    WHEN '30-44' THEN 2
    WHEN '45-59' THEN 3
    WHEN '60+' THEN 4
    ELSE 5
END;

-- Q6: High-risk prevalence by age band
SELECT
    Family_History_Diabetes AS family_history,
    COUNT(*) AS patient_count,
    SUM(
        CASE WHEN Diabetes_Risk = 'High' THEN 1 ELSE 0 END
    ) AS high_risk_count,
    ROUND(
        100.0 *
        SUM(CASE WHEN Diabetes_Risk = 'High' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS high_risk_percentage
FROM diabetes_risk
GROUP BY Family_History_Diabetes
ORDER BY high_risk_percentage DESC;

-- Q7: Comorbidity prevalence and high-risk prevalence
SELECT
    COUNT(*) AS total_patients,

    SUM(CASE WHEN Hypertension = 'Yes' THEN 1 ELSE 0 END)
        AS hypertension_count,

    ROUND(
        100.0 * SUM(CASE WHEN Hypertension = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS hypertension_percentage,

    SUM(CASE WHEN Heart_Disease = 'Yes' THEN 1 ELSE 0 END)
        AS heart_disease_count,

    ROUND(
        100.0 * SUM(CASE WHEN Heart_Disease = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS heart_disease_percentage,

    SUM(
        CASE
            WHEN Hypertension = 'Yes'
              OR Heart_Disease = 'Yes'
            THEN 1 ELSE 0
        END
    ) AS either_comorbidity_count,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN Hypertension = 'Yes'
                  OR Heart_Disease = 'Yes'
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS either_comorbidity_percentage
FROM diabetes_risk;

-- Q8: Audit the table for duplicate Patient_ID values.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT Patient_ID) AS distinct_patient_ids,
    COUNT(*) - COUNT(DISTINCT Patient_ID) AS duplicate_id_rows,
    SUM(CASE WHEN Patient_ID IS NULL THEN 1 ELSE 0 END)
        AS null_patient_ids
FROM diabetes_risk;

-- Q9: Confirm that excluded derived fields are present but not used as model inputs.
PRAGMA table_info(diabetes_risk);
