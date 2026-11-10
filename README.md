# Advanced Database Systems Portfolio

## Case Study

Comfort Private Hospital is a fictional private hospital. This portfolio focuses on designing a database for its outpatient department, from booking an appointment to retrieving a patient's visit history.

## Database Users and Operations

- Records staff register patients, book and cancel appointments, and mark missed appointments.
- Doctors record consultations and diagnoses, prescribe medications, order laboratory tests, and review patient histories.
- Laboratory staff record test results for doctors to review.

The database will store patients, clinicians, appointments, encounters, diagnoses, medication records, and laboratory records. An appointment is a scheduled booking. An encounter is a visit that took place. A missed appointment stays in the schedule history without creating an encounter.

## Test Data

I will use the public Synthea sample CSVs to populate and test the database. The sample contains synthetic patient, provider, encounter, diagnosis, medication, and observation records. I will create additional appointment records to test missed appointments and what happens when two staff members try to book the same doctor for the same time slot.

[Synthea sample data](https://synthetichealth.github.io/downloads.html)

### Portfolio 1: Database Design and Modelling

I designed and implemented a PostgreSQL database for the outpatient
department of Comfort Private Hospital. The schema has seven tables:
patients, providers, appointments, encounters, diagnoses, prescriptions,
and lab tests.

Appointments represent scheduled bookings, while encounters represent
visits that took place. Patient details are stored once in the patients
table. Each encounter uses a patient ID to link to that record.

I loaded one synthetic Synthea patient, one clinician, and two outpatient
encounters. A verification query joined the patients and encounters tables
and returned both visits for the same patient.

To reproduce the test, run `01_schema.sql`, `02_sample_data.sql`, and
`03_verify_design.sql` in that order in a fresh PostgreSQL database.

- [Entity-relationship diagram](portfolio-1-database-design/er-diagram.png)
- [Design and normalisation notes](portfolio-1-database-design/design-notes.md)
- [Database schema](portfolio-1-database-design/01_schema.sql)
- [Sample data](portfolio-1-database-design/02_sample_data.sql)
- [Verification query](portfolio-1-database-design/03_verify_design.sql)

### Portfolio 2: Query Processing and Optimisation

I tested how PostgreSQL retrieves one patient's encounters in chronological
order. The temporary benchmark table contained the two outpatient encounters
from Portfolio 1 and 50,000 generated encounters. I ran the same query before
and after adding an index on `(patient_id, started_at)`.

| Measure | Before indexing | After indexing |
|---|---|---|
| Scan method | Sequential scan | Bitmap Index Scan followed by Bitmap Heap Scan |
| Separate sort by visit start time | Yes | Yes |
| Actual rows returned | 2 | 2 |
| Execution time | 10.507 ms | 3.015 ms |
| Planning time | 0.184 ms | 61.582 ms |

Before indexing, PostgreSQL scanned the table and filtered out 50,000 rows.
After indexing, it used the index to locate the matching rows and still
sorted the two results by visit start time. Execution time fell by about
71% in this comparison, while planning time increased. These measurements
come from one run per condition.

To reproduce the comparison, load the Portfolio 1 schema and sample data.
Then run the blocks in `benchmark.sql` in order, one block at a time, in the
same pgAdmin Query Tool tab. Capture the first execution plan before running
`CREATE INDEX`.

- [Benchmark SQL](portfolio-2-query-optimisation/benchmark.sql)
- [Query results](portfolio-2-query-optimisation/results.txt)
- [Before-index execution plan](portfolio-2-query-optimisation/before-index.png)
- [After-index execution plan](portfolio-2-query-optimisation/after-index.png)

### Portfolio 3: Transactions and Concurrency

I used two PostgreSQL sessions to simulate two staff members trying to
book the same clinician for the 09:00 slot on 2 June 2030. A partial unique
index enforces one appointment with status `booked` per clinician and
scheduled start time.

Session A inserted a booking inside a transaction. Session B checked the
slot before A committed, then attempted to book the same slot with a
different appointment ID. After A committed, PostgreSQL rejected B's insert
with SQL state `23505`. The error named `appointments_one_booked_slot_idx`,
showing that the conflict was on the clinician and start time.

I tested rollback separately by inserting a 10:00 appointment and rolling
back the transaction. The verification query returned `booking_exists = 0`.

To reproduce the experiment, load the Portfolio 1 schema and sample data
into a fresh database. Open two pgAdmin Query Tool tabs and run each
numbered block in `booking_test.sql` in the indicated tab.

- [Booking test SQL](portfolio-3-transactions/booking_test.sql)
- [Observed results](portfolio-3-transactions/results.txt)
