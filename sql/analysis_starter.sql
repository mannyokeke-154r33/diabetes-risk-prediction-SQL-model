-- Hospital Readmission & FHIR Readiness Audit
-- This starter file intentionally contains prompts rather than finished answers.

-- Before writing analysis queries, confirm the table name and row grain.
-- Expected grain: one row per encounter.

-- Q1. How many encounter rows are in the table?
-- TODO: Write a COUNT(*) query.

-- Q2. What values appear in readmitted?
-- TODO: GROUP BY readmitted and order from most common to least common.

-- Q3. What percentage of encounters were readmitted in less than 30 days?
-- TODO: Use SUM(CASE WHEN ...) divided by COUNT(*).

-- Q4. Which age groups have the highest <30-day readmission rate?
-- TODO: Create an age bucket with CASE, then calculate count and percentage.

-- Q5. Does length of stay appear different across readmission categories?
-- TODO: Compare time_in_hospital by readmitted.

-- Q6. How does prior inpatient utilization relate to readmission category?
-- TODO: Create useful utilization buckets with CASE.

-- Q7. Which fields contain the most missing or placeholder values?
-- TODO: Treat NULL and '?' as incomplete where appropriate.

-- Q8. Are encounter_id values unique?
-- TODO: Compare COUNT(*) with COUNT(DISTINCT encounter_id).

-- Q9. Build a project-defined conversion-readiness score.
-- TODO: Score required identifiers and core encounter fields only after
-- documenting the rule in README.md.
