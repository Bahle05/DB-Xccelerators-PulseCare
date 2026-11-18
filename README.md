# PulseCare: Primary Healthcare Clinical Database

A normalised MySQL database for a digital primary healthcare clinic, with a Python command-line client that runs ten clinical queries, from a simple patient directory to automated allergy-conflict and polypharmacy screening.

> Group project (team **DB Xccelerators**) for CSC312 Database Systems at the University of the Western Cape.

## Data model

Ten related tables cover the full patient journey:

| Area | Tables |
|---|---|
| People | `Patient`, `StaffMember`, `PatientAllergy` |
| Care | `Consultation`, `VitalSigns` |
| Pharmacy | `Medication`, `Prescription`, `PrescriptionItem`, `DrugContraindication` |
| Governance | `AuditLog` |

The schema is normalised to third normal form, with foreign keys enforcing referential integrity. For example, a prescription item can't reference a medication that isn't in the formulary, and allergies are stored as their own rows rather than as a comma-separated list.

## The ten queries

| # | Query | Shows |
|---|---|---|
| 1 | View all registered patients alphabetically | `SELECT`, `ORDER BY` |
| 2 | Search the medication formulary by active ingredient | `LIKE` pattern matching |
| 3 | Patient encounter directory with ages calculated on the fly | joins, `TIMESTAMPDIFF` |
| 4 | High-risk allergy screening | natural join |
| 5 | Pharmacy fulfilment bottleneck tracking | multi-table joins |
| 6 | Bedside triage: cardiovascular anomaly detection | joins, filtering on vital sign thresholds, `AVG` |
| 7 | Clinician workload and patient acuity profiling | `GROUP BY`, aggregates |
| 8 | Pharmaceutical inventory demand and restocking thresholds | aggregates, `HAVING` |
| 9 | Automated allergy conflict detection (clinical decision support) | cross-checking prescriptions against allergies |
| 10 | High-risk polypharmacy and contraindication screening | joins, `GROUP BY`, `HAVING` |

## Run it

```bash
git clone https://github.com/Bahle05/DB-Xccelerators-PulseCare.git
cd DB-Xccelerators-PulseCare
pip install -r requirements.txt
mysql -u <user> -p < pulsecare_db.sql      # creates the schema and sample data
cp .env.example .env                        # then fill in your database connection
python pulsecare_client.py
```

The client opens a menu where you can run any query on its own, or all ten in sequence, with results printed as formatted tables. Database credentials are read only from environment variables and are never stored in the code.

## Tech stack

MySQL · Python 3 · mysql-connector-python · python-dotenv

## Team

DB Xccelerators, CSC312 Database Systems, University of the Western Cape, 2026.
Repository maintained by [Bahle Ludidi](https://www.linkedin.com/in/bahle-ludidi-727657352).
