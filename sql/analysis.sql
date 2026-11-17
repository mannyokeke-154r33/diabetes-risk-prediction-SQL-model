-- Hospital Readmission & FHIR Readiness Audit

-- Q1: Readmission distribution with percentages
SELECT
    readmitted,
    COUNT(*) AS encounter_count,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM diabetes_encounters),
        2
    ) AS encounter_percentage
FROM diabetes_encounters
GROUP BY readmitted
ORDER BY encounter_count DESC;

-- Q2: Which age group has the highest percentage of <30-day readmissions?
WITH bucketed AS (
    SELECT
        CASE
            WHEN age IN ('[0-10)', '[10-20)', '[20-30)') THEN '0-29'
            WHEN age IN ('[30-40)', '[40-50)') THEN '30-49'
            WHEN age IN ('[50-60)', '[60-70)') THEN '50-69'
            WHEN age IN ('[70-80)', '[80-90)', '[90-100)') THEN '70+'
            ELSE 'Unknown'
        END AS age_group,
        readmitted
    FROM diabetes_encounters
), age_summary AS (
    SELECT
        age_group,
        COUNT(*) AS encounter_count,
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmitted_under_30
    FROM bucketed
    GROUP BY age_group
)
SELECT
    age_group,
    encounter_count,
    readmitted_under_30,
    ROUND(100.0 * readmitted_under_30 / encounter_count, 2) AS under_30_percentage
FROM age_summary
ORDER BY CASE age_group
    WHEN '0-29' THEN 1
    WHEN '30-49' THEN 2
    WHEN '50-69' THEN 3
    WHEN '70+' THEN 4
    ELSE 5
END;

-- Q3: How does length of stay relate to <30-day readmission?
WITH stay_bucketed AS (
    SELECT
        CASE
            WHEN time_in_hospital BETWEEN 1 AND 3 THEN '1-3 days'
            WHEN time_in_hospital BETWEEN 4 AND 6 THEN '4-6 days'
            WHEN time_in_hospital BETWEEN 7 AND 10 THEN '7-10 days'
            WHEN time_in_hospital >= 11 THEN '11+ days'
            ELSE 'Unknown'
        END AS stay_group,
        time_in_hospital,
        readmitted
    FROM diabetes_encounters
), stay_summary AS (
    SELECT
        stay_group,
        COUNT(*) AS encounter_count,
        ROUND(AVG(time_in_hospital), 2) AS average_stay,
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmitted_under_30
    FROM stay_bucketed
    GROUP BY stay_group
)
SELECT
    stay_group,
    encounter_count,
    average_stay,
    readmitted_under_30,
    ROUND(100.0 * readmitted_under_30 / encounter_count, 2) AS under_30_percentage
FROM stay_summary
ORDER BY CASE stay_group
    WHEN '1-3 days' THEN 1
    WHEN '4-6 days' THEN 2
    WHEN '7-10 days' THEN 3
    WHEN '11+ days' THEN 4
    ELSE 5
END;

-- Q4: How does prior inpatient utilization relate to <30-day readmission?
WITH utilization_bucketed AS (
    SELECT
        CASE
            WHEN number_inpatient = 0 THEN '0 prior visits'
            WHEN number_inpatient = 1 THEN '1 prior visit'
            WHEN number_inpatient BETWEEN 2 AND 3 THEN '2-3 prior visits'
            WHEN number_inpatient >= 4 THEN '4+ prior visits'
            ELSE 'Unknown'
        END AS prior_inpatient_group,
        readmitted
    FROM diabetes_encounters
), utilization_summary AS (
    SELECT
        prior_inpatient_group,
        COUNT(*) AS encounter_count,
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmitted_under_30
    FROM utilization_bucketed
    GROUP BY prior_inpatient_group
)
SELECT
    prior_inpatient_group,
    encounter_count,
    readmitted_under_30,
    ROUND(100.0 * readmitted_under_30 / encounter_count, 2) AS under_30_percentage
FROM utilization_summary
ORDER BY CASE prior_inpatient_group
    WHEN '0 prior visits' THEN 1
    WHEN '1 prior visit' THEN 2
    WHEN '2-3 prior visits' THEN 3
    WHEN '4+ prior visits' THEN 4
    ELSE 5
END;

-- Q5: Which conversion-critical fields are incomplete?
WITH field_completeness AS (
    SELECT
        'encounter_id' AS field_name,
        COUNT(*) AS total_rows,
        SUM(CASE WHEN encounter_id IS NULL THEN 1 ELSE 0 END) AS missing_count
    FROM diabetes_encounters

    UNION ALL

    SELECT
        'patient_nbr',
        COUNT(*),
        SUM(CASE WHEN patient_nbr IS NULL THEN 1 ELSE 0 END)
    FROM diabetes_encounters

    UNION ALL

    SELECT
        'gender',
        COUNT(*),
        SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END)
    FROM diabetes_encounters

    UNION ALL

    SELECT
        'age',
        COUNT(*),
        SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END)
    FROM diabetes_encounters

    UNION ALL

    SELECT
        'diag_1',
        COUNT(*),
        SUM(CASE WHEN diag_1 IS NULL THEN 1 ELSE 0 END)
    FROM diabetes_encounters

    UNION ALL

    SELECT
        'medical_specialty',
        COUNT(*),
        SUM(CASE WHEN medical_specialty IS NULL THEN 1 ELSE 0 END)
    FROM diabetes_encounters

    UNION ALL

    SELECT
        'payer_code',
        COUNT(*),
        SUM(CASE WHEN payer_code IS NULL THEN 1 ELSE 0 END)
    FROM diabetes_encounters
)
SELECT
    field_name,
    total_rows,
    missing_count,
    ROUND(100.0 * missing_count / total_rows, 2) AS missing_percentage
FROM field_completeness
ORDER BY missing_count DESC;

-- Q6: Are encounter IDs unique?
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT encounter_id) AS distinct_encounter_ids,
    COUNT(*) - COUNT(DISTINCT encounter_id) AS duplicate_id_rows
FROM diabetes_encounters;

-- Q7: What percentage of encounters meet the project-defined readiness rule?
-- This is an educational metric, not formal FHIR certification.
WITH scored AS (
    SELECT
        encounter_id,
        (
            CASE WHEN encounter_id IS NOT NULL THEN 1 ELSE 0 END
            + CASE WHEN patient_nbr IS NOT NULL THEN 1 ELSE 0 END
            + CASE
                WHEN gender IS NOT NULL AND gender <> 'Unknown/Invalid' THEN 1
                ELSE 0
              END
            + CASE WHEN age IS NOT NULL THEN 1 ELSE 0 END
            + CASE WHEN diag_1 IS NOT NULL THEN 1 ELSE 0 END
            + CASE WHEN admission_type_id IS NOT NULL THEN 1 ELSE 0 END
            + CASE WHEN discharge_disposition_id IS NOT NULL THEN 1 ELSE 0 END
        ) AS readiness_score
    FROM diabetes_encounters
), classified AS (
    SELECT
        readiness_score,
        CASE
            WHEN readiness_score = 7 THEN 'Ready'
            WHEN readiness_score >= 5 THEN 'Review'
            ELSE 'Blocked'
        END AS readiness_status
    FROM scored
)
SELECT
    readiness_status,
    readiness_score,
    COUNT(*) AS encounter_count,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM diabetes_encounters),
        2
    ) AS encounter_percentage
FROM classified
GROUP BY readiness_status, readiness_score
ORDER BY readiness_score DESC;

-- Q8: Does A1C measurement status differ across <30-day readmission outcomes?
WITH a1c_status AS (
    SELECT
        CASE
            WHEN A1Cresult IS NULL OR A1Cresult = 'None' THEN 'Not measured'
            ELSE A1Cresult
        END AS measurement_status,
        readmitted
    FROM diabetes_encounters
)
SELECT
    measurement_status,
    COUNT(*) AS encounter_count,
    SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmitted_under_30,
    ROUND(
        100.0 * SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS under_30_percentage
FROM a1c_status
GROUP BY measurement_status
ORDER BY under_30_percentage DESC;
