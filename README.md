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

## Portfolio Plan

| Activity | Planned work |
|---|---|
| Database design and modelling | Draw an entity-relationship diagram and implement the relational schema in PostgreSQL. |
| Query processing and optimisation | Retrieve patient visit histories and compare query execution plans before and after adding an index. |
| Transactions and concurrency | Use two database sessions to test whether the system prevents a doctor from being double-booked. |
| NoSQL and advanced data models | Model an outpatient encounter and its related clinical details as a document. |
| Distributed and cloud databases | Explain how a primary database and a replica could support the clinic and how replication delays could affect appointment availability. |
