"""Convert Synthea outpatient encounters into MongoDB Extended JSON Lines."""
import argparse
import csv
import io
import json
from collections import defaultdict
from pathlib import Path
from zipfile import ZipFile


def csv_rows(archive, filename):
    with archive.open(filename) as raw:
        with io.TextIOWrapper(raw, encoding="utf-8-sig", newline="") as stream:
            yield from csv.DictReader(stream)


def group_by_encounter(rows, fields):
    groups = defaultdict(list)
    for row in rows:
        groups[row["ENCOUNTER"]].append({
            target: row[source] for source, target in fields.items()
        })
    return groups


def build_encounters(source, destination):
    with ZipFile(source) as archive:
        diagnoses = group_by_encounter(csv_rows(archive, "conditions.csv"), {
            "CODE": "code", "DESCRIPTION": "description"
        })
        prescriptions = group_by_encounter(csv_rows(archive, "medications.csv"), {
            "CODE": "code", "DESCRIPTION": "medicationName"
        })
        laboratory_rows = (
            row for row in csv_rows(archive, "observations.csv")
            if row["CATEGORY"] == "laboratory"
        )
        lab_tests = group_by_encounter(laboratory_rows, {
            "CODE": "code", "DESCRIPTION": "testName",
            "VALUE": "result", "UNITS": "units"
        })

        with destination.open("w", encoding="utf-8", newline="\n") as output:
            count = 0
            for row in csv_rows(archive, "encounters.csv"):
                if row["ENCOUNTERCLASS"] != "outpatient":
                    continue
                encounter_id = row["Id"]
                document = {
                    "_id": encounter_id,
                    "encounterType": row["ENCOUNTERCLASS"],
                    "startedAt": {"$date": row["START"]},
                    "patientId": row["PATIENT"],
                    "providerId": row["PROVIDER"],
                    "diagnoses": diagnoses.get(encounter_id, []),
                    "prescriptions": prescriptions.get(encounter_id, []),
                    "labTests": lab_tests.get(encounter_id, []),
                }
                output.write(json.dumps(document, ensure_ascii=False) + "\n")
                count += 1
    return count


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("synthea_zip", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    if args.synthea_zip.resolve() == args.output.resolve():
        parser.error("Choose an output path different from the input ZIP.")
    count = build_encounters(args.synthea_zip, args.output)
    print(f"Wrote {count} outpatient encounters to {args.output}")
