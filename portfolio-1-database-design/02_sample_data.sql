-- Source: Synthea sample CSVs.
-- This example uses one synthetic patient, one clinician, and two outpatient visits.
-- Run 01_schema.sql first in a fresh database.

INSERT INTO patients (patient_id, first_name, last_name, birth_date)
VALUES (
    '1d670d3c-f290-52f4-9409-aaffd1eb59f5',
    'Brett333',
    'Kirlin939',
    '1998-12-30'
);

INSERT INTO providers (provider_id, full_name, specialty)
VALUES (
    '6e8a0983-323d-345f-b33f-f53982ca43e9',
    'Mozell819 Prohaska837',
    'GENERAL PRACTICE'
);

INSERT INTO encounters (encounter_id, patient_id, provider_id, started_at)
VALUES
    (
        '1d670d3c-f290-52f4-0e3e-9d6c26ad814e',
        '1d670d3c-f290-52f4-9409-aaffd1eb59f5',
        '6e8a0983-323d-345f-b33f-f53982ca43e9',
        '2021-10-13T04:27:13Z'
    ),
    (
        '1d670d3c-f290-52f4-1711-0c028dd5cf58',
        '1d670d3c-f290-52f4-9409-aaffd1eb59f5',
        '6e8a0983-323d-345f-b33f-f53982ca43e9',
        '2021-11-03T04:27:13Z'
    );
