-- Portfolio 3: Transactions and Concurrency
-- Prerequisite: Load the Portfolio 1 schema and sample data.
-- Open two Query Tool tabs connected to the same database.
-- Run each numbered block separately, in the indicated tab.

-- 1. Run in both A and B. Confirm that the session IDs differ.
SELECT pg_backend_pid();

-- 2. Tab A: Allow only one booked appointment per clinician and start time.
CREATE UNIQUE INDEX IF NOT EXISTS appointments_one_booked_slot_idx
ON appointments (provider_id, scheduled_at)
WHERE status = 'booked';

-- 3. Tab A: Insert the first booking and leave the transaction open.
BEGIN ISOLATION LEVEL READ COMMITTED;

INSERT INTO appointments
    (appointment_id, patient_id, provider_id, scheduled_at, status)
VALUES (
    '00000000-0000-4000-8000-000000000041',
    '1d670d3c-f290-52f4-9409-aaffd1eb59f5',
    '6e8a0983-323d-345f-b33f-f53982ca43e9',
    '2030-06-02 09:00:00+01',
    'booked'
);

-- 4. Tab B: Check visibility before A commits. Expect zero rows.
SELECT appointment_id, scheduled_at, status
FROM appointments
WHERE provider_id = '6e8a0983-323d-345f-b33f-f53982ca43e9'
  AND scheduled_at = TIMESTAMPTZ '2030-06-02 09:00:00+01';

-- 5. Tab B: Try to book the same slot with a different appointment ID.
-- While B is waiting, switch to A for step 6.
INSERT INTO appointments
    (appointment_id, patient_id, provider_id, scheduled_at, status)
VALUES (
    '00000000-0000-4000-8000-000000000042',
    '1d670d3c-f290-52f4-9409-aaffd1eb59f5',
    '6e8a0983-323d-345f-b33f-f53982ca43e9',
    '2030-06-02 09:00:00+01',
    'booked'
);

-- 6. Tab A: Commit. Then check B for the duplicate-key error (23505).
COMMIT;

-- 7. Tab B: Verify that A's booking is now visible. Expect one row.
SELECT appointment_id, scheduled_at, status
FROM appointments
WHERE provider_id = '6e8a0983-323d-345f-b33f-f53982ca43e9'
  AND scheduled_at = TIMESTAMPTZ '2030-06-02 09:00:00+01';

-- 8. Tab A: Insert a booking for a different slot, then roll it back.
BEGIN;

INSERT INTO appointments
    (appointment_id, patient_id, provider_id, scheduled_at, status)
VALUES (
    '00000000-0000-4000-8000-000000000043',
    '1d670d3c-f290-52f4-9409-aaffd1eb59f5',
    '6e8a0983-323d-345f-b33f-f53982ca43e9',
    '2030-06-02 10:00:00+01',
    'booked'
);

ROLLBACK;

-- 9. Tab A: Verify that the rolled-back booking is absent. Expect zero.
SELECT COUNT(*) AS booking_exists
FROM appointments
WHERE appointment_id = '00000000-0000-4000-8000-000000000043';
