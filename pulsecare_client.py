"""
================================================================================
CSC312: Structured Query Language & Database Systems
Practical Assignment 2 - Question 1: Programmatic Connectivity

File Name: pulsecare_client.py
Team Name: DB Xccelerators
Team Members:
  - Simphiwe Bala (4495191)
  - Sandile Lubisi (4429192)
  - Bahle Ludidi (4439359)
  - Noluthando Nondumiso Mlangeni (4455777)
  - Nhlakanipho Nene (4425977)
Description: Modular Python client connecting to MySQL to execute and display
             PulseCare clinical queries with formatted tabular outputs.
================================================================================
"""

import os
import sys
from typing import Dict, Any, List, Tuple

# Attempt import of mysql.connector
try:
    import mysql.connector
    from mysql.connector import Error
except ImportError:
    print("[ERROR] 'mysql-connector-python' is not installed.")
    print("Please install it via: pip install mysql-connector-python")
    sys.exit(1)


# ==============================================================================
# Database Configuration
# ==============================================================================
# Default configuration uses environment variables with fallback to local settings
DB_CONFIG: Dict[str, Any] = {
    "host": os.getenv("DB_HOST", "172.21.12.21"),       
    "port": int(os.getenv("DB_PORT", 29359)),
    "user": os.getenv("DB_USER", "4439359"),            
    "password": os.getenv("DB_PASSWORD", "!St4439359"),        
    "database": os.getenv("DB_NAME", "pulsecare_db") 
}


# ==============================================================================
# Query Portfolio (Organized by Complexity)
# ==============================================================================
QUERIES = [
    {
        "id": 1,
        "title": "View All Registered Patients Alphabetically",
        "tier": "Simple",
        "context": "Administrative retrieval of registered patients sorted alphabetically by surname for reception triage.",
        "sql": """
            SELECT 
                patient_id, 
                first_name, 
                last_name, 
                biological_sex, 
                date_of_birth 
            FROM Patient 
            ORDER BY last_name ASC, first_name ASC;
        """
    },
    {
        "id": 2,
        "title": "Search Medication Formulary by Active Ingredient",
        "tier": "Simple",
        "context": "Pharmacological search for formulations containing 'Metformin' to evaluate stock availability and generic substitution.",
        "sql": """
            SELECT 
                med_id, 
                commercial_name, 
                active_ingredient 
            FROM Medication 
            WHERE active_ingredient LIKE '%Metformin%' 
            ORDER BY commercial_name ASC;
        """
    },
    {
        "id": 3,
        "title": "Patient Encounter Directory with Dynamic Age Derivation",
        "tier": "Medium",
        "context": "Combines Patient and Consultation tables using date arithmetic to dynamically derive patient age without 3NF data redundancy.",
        "sql": """
            SELECT 
                p.patient_id,
                CONCAT(p.first_name, ' ', p.last_name) AS full_patient_name,
                p.biological_sex,
                TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) AS calculated_age,
                c.consultation_id,
                c.consultation_datetime,
                c.encounter_status
            FROM Patient p
            INNER JOIN Consultation c ON p.patient_id = c.patient_id
            ORDER BY c.consultation_datetime DESC;
        """
    },
    {
        "id": 4,
        "title": "High-Risk Allergy Screening via Natural Join",
        "tier": "Medium",
        "context": "Relational NATURAL JOIN on shared patient_id to isolate patients with severe or anaphylactic drug allergies.",
        "sql": """
            SELECT 
                patient_id,
                p.first_name,
                p.last_name,
                pa.reaction_severity,
                pa.reaction_description,
                pa.diagnosis_date
            FROM Patient p
            NATURAL JOIN PatientAllergy pa
            WHERE pa.reaction_severity IN ('Severe', 'Anaphylactic')
            ORDER BY pa.diagnosis_date ASC;
        """
    },
    {
        "id": 5,
        "title": "Pharmacy Fulfillment Bottleneck Tracking",
        "tier": "Medium",
        "context": "LEFT OUTER JOIN identifying pending prescriptions lacking an assigned reviewing pharmacist to resolve dispensary delays.",
        "sql": """
            SELECT 
                pr.presc_id,
                CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
                CONCAT(doc.first_name, ' ', doc.last_name) AS prescribing_doctor,
                pr.prescription_date,
                pr.fulfillment_status,
                pharm.first_name AS assigned_pharmacist
            FROM Prescription pr
            INNER JOIN Consultation c ON pr.consultation_id = c.consultation_id
            INNER JOIN Patient p ON c.patient_id = p.patient_id
            INNER JOIN StaffMember doc ON pr.prescribed_by_staff_id = doc.staff_id
            LEFT JOIN StaffMember pharm ON pr.dispensed_by_pharmacist_id = pharm.staff_id
            WHERE pr.fulfillment_status = 'Pending' 
               OR pr.dispensed_by_pharmacist_id IS NULL;
        """
    },
    {
        "id": 6,
        "title": "Bedside Triage Cardiovascular Anomaly Detection",
        "tier": "Medium",
        "context": "Nested scalar subquery in WHERE filtering patient encounters with heart rates exceeding clinic-wide average baseline.",
        "sql": """
            SELECT 
                c.consultation_id,
                CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
                v.heart_rate_bpm,
                v.systolic_bp,
                v.body_temperature_celsius,
                c.consultation_datetime
            FROM VitalSigns v
            INNER JOIN Consultation c ON v.consultation_id = c.consultation_id
            INNER JOIN Patient p ON c.patient_id = p.patient_id
            WHERE v.heart_rate_bpm > (
                SELECT AVG(heart_rate_bpm) 
                FROM VitalSigns
            )
            ORDER BY v.heart_rate_bpm DESC;
        """
    },
    {
        "id": 7,
        "title": "Clinician Workload and Patient Acuity Profiling",
        "tier": "Complex",
        "context": "Aggregates consultation volume alongside vital sign statistics (AVG BP, MAX temp, MIN SpO2) grouped by doctor.",
        "sql": """
            SELECT 
                doc.staff_id,
                CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name,
                COUNT(c.consultation_id) AS total_consultations,
                ROUND(AVG(v.systolic_bp), 1) AS avg_systolic_bp,
                MAX(v.body_temperature_celsius) AS peak_temperature_c,
                MIN(v.oxygen_saturation_pct) AS lowest_spo2_pct
            FROM StaffMember doc
            INNER JOIN Consultation c ON doc.staff_id = c.doctor_id
            INNER JOIN VitalSigns v ON c.consultation_id = v.consultation_id
            GROUP BY doc.staff_id, doc.first_name, doc.last_name
            ORDER BY total_consultations DESC;
        """
    },
    {
        "id": 8,
        "title": "Pharmaceutical Inventory Demand and Restocking Thresholds",
        "tier": "Complex",
        "context": "Multi-table join calculating prescription count, total units, and dosing frequency, filtered with a post-aggregation HAVING threshold.",
        "sql": """
            SELECT 
                m.med_id,
                m.commercial_name,
                m.active_ingredient,
                COUNT(pi.presc_id) AS total_prescription_orders,
                SUM(pi.quantity_ordered) AS total_units_dispensed,
                ROUND(AVG(pi.daily_frequency), 2) AS avg_daily_dose_frequency
            FROM Medication m
            INNER JOIN PrescriptionItem pi ON m.med_id = pi.med_id
            GROUP BY m.med_id, m.commercial_name, m.active_ingredient
            HAVING SUM(pi.quantity_ordered) >= 25
            ORDER BY total_units_dispensed DESC;
        """
    },
    {
        "id": 9,
        "title": "Automated Allergy Conflict Safety Detection (CDSS)",
        "tier": "Complex",
        "context": "Correlated subquery acting as an automated Clinical Decision Support firewall, cross-referencing orders against patient allergies.",
        "sql": """
            SELECT 
                p.patient_id,
                CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
                pr.presc_id,
                m.commercial_name AS prescribed_drug,
                m.active_ingredient,
                pa.reaction_severity,
                pa.reaction_description
            FROM Patient p
            INNER JOIN Consultation c ON p.patient_id = c.patient_id
            INNER JOIN Prescription pr ON c.consultation_id = pr.consultation_id
            INNER JOIN PrescriptionItem pi ON pr.presc_id = pi.presc_id
            INNER JOIN Medication m ON pi.med_id = m.med_id
            INNER JOIN PatientAllergy pa ON p.patient_id = pa.patient_id 
                AND m.med_id = pa.med_id
            WHERE m.med_id IN (
                SELECT pa_inner.med_id 
                FROM PatientAllergy pa_inner 
                WHERE pa_inner.patient_id = p.patient_id
            );
        """
    },
    {
        "id": 10,
        "title": "High-Risk Polypharmacy and Contraindication Screening",
        "tier": "Complex",
        "context": "Multi-way join with nested UNION subquery and HAVING clause to detect high-risk prescriptions containing interacting drug pairs.",
        "sql": """
            SELECT 
                pr.presc_id,
                CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
                pr.prescription_date,
                COUNT(pi.med_id) AS total_contraindicated_candidates,
                SUM(pi.quantity_ordered) AS total_units_ordered
            FROM Prescription pr
            INNER JOIN Consultation c ON pr.consultation_id = c.consultation_id
            INNER JOIN Patient p ON c.patient_id = p.patient_id
            INNER JOIN PrescriptionItem pi ON pr.presc_id = pi.presc_id
            WHERE pr.presc_id IN (
                SELECT pi_sub.presc_id
                FROM PrescriptionItem pi_sub
                WHERE pi_sub.med_id IN (
                    SELECT drug_1_id FROM DrugContraindication
                    UNION
                    SELECT drug_2_id FROM DrugContraindication
                )
            )
            GROUP BY pr.presc_id, p.first_name, p.last_name, pr.prescription_date
            HAVING COUNT(pi.med_id) >= 1
            ORDER BY total_contraindicated_candidates DESC;
        """
    }
]


# ==============================================================================
# Helper Formatting Functions
# ==============================================================================
def print_separator(char="=", length=85) -> None:
    print(char * length)


def print_table(headers: List[str], rows: List[Tuple[Any, ...]]) -> None:
    """Prints tabular query results with clean aligned formatting."""
    if not rows:
        print("  [No matching records found]")
        return

    # Calculate column widths
    str_rows = [[str(item) if item is not None else "NULL" for item in row] for row in rows]
    col_widths = [len(h) for h in headers]
    for row in str_rows:
        for idx, val in enumerate(row):
            col_widths[idx] = max(col_widths[idx], len(val))

    # Format header
    header_str = " | ".join(h.ljust(col_widths[i]) for i, h in enumerate(headers))
    divider_str = "-+-".join("-" * col_widths[i] for i in range(len(headers)))
    
    print("  " + header_str)
    print("  " + divider_str)
    for row in str_rows:
        row_str = " | ".join(val.ljust(col_widths[i]) for i, val in enumerate(row))
        print("  " + row_str)


# ==============================================================================
# Core Database Functions
# ==============================================================================
def get_connection():
    """Establishes a connection to the MySQL database."""
    return mysql.connector.connect(
        host=DB_CONFIG["host"],
        port=DB_CONFIG["port"],
        user=DB_CONFIG["user"],
        password=DB_CONFIG["password"],
        database=DB_CONFIG["database"],
        charset="utf8mb4",
        collation="utf8mb4_unicode_ci"
    )


def test_connection() -> bool:
    """Verifies that the database server is reachable and responsive."""
    print("\n[INFO] Testing connection to database...")
    print(f"       Host: {DB_CONFIG['host']}:{DB_CONFIG['port']} | DB: {DB_CONFIG['database']} | User: {DB_CONFIG['user']}")
    try:
        conn = get_connection()
        if conn.is_connected():
            db_info = conn.get_server_info
            cursor = conn.cursor()
            cursor.execute("SELECT DATABASE();")
            current_db = cursor.fetchone()[0]
            print(f"[SUCCESS] Connected to MySQL Server version: {db_info}")
            print(f"[SUCCESS] Active Schema: {current_db}\n")
            cursor.close()
            conn.close()
            return True
    except Error as e:
        print(f"[ERROR] Database connection failed: {e}")
        print("Tip: Check host IP, port, credentials, and ensure MySQL is running.\n")
        return False
    return False


def run_query(query_dict: Dict[str, Any]) -> None:
    """Executes a single query and displays formatted results."""
    print_separator("-")
    print(f"Query {query_dict['id']} [{query_dict['tier']}]: {query_dict['title']}")
    print(f"Clinical Context: {query_dict['context']}")
    print_separator("-")
    
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(query_dict["sql"])
        
        headers = [col[0] for col in cursor.description]
        records = cursor.fetchall()
        
        print_table(headers, records)
        print(f"\nTotal rows returned: {len(records)}\n")
        
        cursor.close()
        conn.close()
    except Error as e:
        print(f"[ERROR] Execution failed for Query {query_dict['id']}: {e}\n")


def run_all_queries() -> None:
    """Executes the entire 10-query portfolio sequentially."""
    print_separator("=")
    print("      EXECUTING PULSECARE FULL 10-QUERY ANALYTICAL SUITE")
    print_separator("=")
    for q in QUERIES:
        run_query(q)
    print_separator("=")
    print("      ALL QUERIES EXECUTED SUCCESSFULLY")
    print_separator("=")


# ==============================================================================
# Interactive CLI Menu
# ==============================================================================
def display_menu() -> None:
    print_separator("=")
    print("                PULSECARE CLINICAL DATABASE MANAGEMENT SYSTEM")
    print("                   CSC312 Practical Assignment 2 Client")
    print_separator("=")
    print(" 1. Test Database Connectivity")
    print(" 2. Run All Queries (10 Queries: Simple, Medium & Complex)")
    print(" 3. Run Query by ID (1 to 10)")
    print(" 4. Display Connection Configuration")
    print(" 5. Exit")
    print_separator("=")


def main() -> None:
    while True:
        display_menu()
        choice = input("Enter choice (1-5): ").strip()
        
        if choice == "1":
            test_connection()
        elif choice == "2":
            if test_connection():
                run_all_queries()
        elif choice == "3":
            try:
                qid = int(input("Enter Query ID (1-10): ").strip())
                selected = next((q for q in QUERIES if q["id"] == qid), None)
                if selected:
                    run_query(selected)
                else:
                    print("[WARNING] Invalid Query ID. Please enter a number between 1 and 10.")
            except ValueError:
                print("[WARNING] Please enter a valid numerical ID.")
        elif choice == "4":
            print("\nCurrent Active Configuration:")
            for k, v in DB_CONFIG.items():
                masked_v = "******" if k == "password" and v else v
                print(f"  {k}: {masked_v}")
            print()
        elif choice == "5":
            print("\nExiting PulseCare Client. Goodbye!")
            break
        else:
            print("[WARNING] Invalid selection. Please enter a number from 1 to 5.\n")


if __name__ == "__main__":
    main()
