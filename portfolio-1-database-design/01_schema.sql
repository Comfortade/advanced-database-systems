CREATE TABLE patients (
    patient_id UUID PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    birth_date DATE
);

CREATE TABLE providers (
    provider_id UUID PRIMARY KEY,
    full_name TEXT,
    specialty TEXT
);

CREATE TABLE appointments (
    appointment_id UUID PRIMARY KEY,
    patient_id UUID NOT NULL REFERENCES patients(patient_id),
    provider_id UUID NOT NULL REFERENCES providers(provider_id),
    scheduled_at TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL
);

CREATE TABLE encounters (
    encounter_id UUID PRIMARY KEY,
    patient_id UUID NOT NULL REFERENCES patients(patient_id),
    provider_id UUID NOT NULL REFERENCES providers(provider_id),
    appointment_id UUID UNIQUE REFERENCES appointments(appointment_id),
    started_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE diagnoses (
    diagnosis_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    encounter_id UUID NOT NULL REFERENCES encounters(encounter_id),
    diagnosis_code TEXT,
    description TEXT
);

CREATE TABLE prescriptions (
    prescription_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    encounter_id UUID NOT NULL REFERENCES encounters(encounter_id),
    medication_code TEXT,
    medication_name TEXT,
    prescribed_at TIMESTAMPTZ
);

CREATE TABLE lab_tests (
    lab_test_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    encounter_id UUID NOT NULL REFERENCES encounters(encounter_id),
    test_name TEXT NOT NULL,
    result_value TEXT,
    result_unit TEXT
);
