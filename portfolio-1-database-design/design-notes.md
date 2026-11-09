# Database Design and Modelling

## Scope

I designed a PostgreSQL database for the outpatient department of Comfort Private Hospital, a fictional hospital. The database tracks patients, clinicians, scheduled appointments, completed visits, diagnoses, prescriptions, and lab tests. I used a small sample of synthetic Synthea records to test the design.

## Tables and Relationships

The [ER diagram](er-diagram.png) shows the seven tables. The [SQL schema](01_schema.sql) defines their columns, keys, and constraints.

- Each appointment and encounter links to one patient and one clinician. A patient or clinician can be linked to several appointments or encounters.
- An appointment is a scheduled booking. An encounter is a visit that took place. A missed appointment can exist without an encounter, and an imported Synthea encounter can exist without a linked appointment.
- An encounter can have several diagnoses, prescriptions, or lab tests. Each of those records links to the encounter where it belongs.

## Keys and Constraints

A primary key uniquely identifies a row. For example, `patient_id` identifies a patient, and `encounter_id` identifies a visit. A foreign key links a row to an existing record in another table. For example, `encounters.patient_id` links each visit to its patient.

The `appointment_id` in `encounters` is optional and unique when provided. This allows imported visits without an appointment and prevents one appointment from being linked to multiple encounters.

## Normalisation

- **First normal form (1NF).** Each visit has its own row. Visit dates are stored individually, so a patient's visits can be filtered and sorted.
- **Second normal form (2NF).** The tables use single-column identifiers. For example, `started_at` describes the visit identified by `encounter_id`.
- **Third normal form (3NF).** Patient names and dates of birth are stored in `patients`, and clinician names and specialties are stored in `providers`. Encounters link to those records by ID. If a name needs correcting, it can be updated in one place.

## Verification

I loaded one synthetic patient, one clinician, and two outpatient encounters using records from the [Synthea sample data](https://synthetichealth.github.io/downloads.html). In a fresh database, run `01_schema.sql`, `02_sample_data.sql`, and `03_verify_design.sql` in that order.

The verification query returned two rows for the same patient, with visits on 13 October 2021 and 3 November 2021. This demonstrated the one-to-many relationship between patients and encounters. The test covered patient visit retrieval. Appointment booking and double-booking will be tested separately.
