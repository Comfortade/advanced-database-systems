-- Run after loading the Portfolio 1 schema and sample data.
-- Use a fresh Query Tool tab and run all steps in that same tab.

-- 1. Copy the sample visits and add 50,000 generated encounters.
CREATE TEMP TABLE encounter_benchmark AS
SELECT encounter_id, patient_id, started_at
FROM encounters;

INSERT INTO encounter_benchmark (encounter_id, patient_id, started_at)
SELECT
    md5('benchmark-encounter-' || n)::uuid,
    md5('benchmark-patient-' || ((n - 1) % 1000))::uuid,
    TIMESTAMPTZ '2022-01-01 00:00:00+00' + n * INTERVAL '1 minute'
FROM generate_series(1, 50000) AS g(n);

ANALYZE encounter_benchmark;

SELECT COUNT(*) AS total_encounters
FROM encounter_benchmark;

-- 2. Retrieve the patient's visits.
SELECT encounter_id, started_at
FROM encounter_benchmark
WHERE patient_id = '1d670d3c-f290-52f4-9409-aaffd1eb59f5'
ORDER BY started_at;

-- 3. Capture the plan before indexing.
EXPLAIN (ANALYZE, BUFFERS)
SELECT encounter_id, started_at
FROM encounter_benchmark
WHERE patient_id = '1d670d3c-f290-52f4-9409-aaffd1eb59f5'
ORDER BY started_at;

-- 4. Create the index.
CREATE INDEX encounter_benchmark_patient_started_idx
ON encounter_benchmark (patient_id, started_at);

-- 5. Capture the plan after indexing.
EXPLAIN (ANALYZE, BUFFERS)
SELECT encounter_id, started_at
FROM encounter_benchmark
WHERE patient_id = '1d670d3c-f290-52f4-9409-aaffd1eb59f5'
ORDER BY started_at;
