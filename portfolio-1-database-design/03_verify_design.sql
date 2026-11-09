-- Run after 01_schema.sql and 02_sample_data.sql.
-- Expected result: two visits for Brett333 Kirlin939.
-- This test uses the patient loaded by 02_sample_data.sql and expects two visits.

SELECT
    patients.first_name,
    patients.last_name,
    encounters.started_at
FROM encounters
JOIN patients ON encounters.patient_id = patients.patient_id
WHERE patients.patient_id = '1d670d3c-f290-52f4-9409-aaffd1eb59f5'
ORDER BY encounters.started_at;
