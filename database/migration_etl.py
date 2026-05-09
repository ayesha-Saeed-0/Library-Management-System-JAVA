import csv
import mysql.connector
from decimal import Decimal
from datetime import datetime

VALID_STATUSES = {'P', 'C', 'X', 'H', 'R'}

def parse_appt_date(raw):
    raw = raw.strip()
    return datetime.strptime(raw, '%d/%m/%Y %H:%M')

def split_room(raw):
    try:
        parts = raw.strip().split()
        room_number = int(parts[1])
        building_block = ' '.join(parts[2:])
        return room_number, building_block
    except (IndexError, ValueError):
        return None, None

def migrate(csv_path, db_config):
    try:
        conn = mysql.connector.connect(**db_config)
    except mysql.connector.Error as e:
        print(f"[ERROR] Could not connect to database: {e}")
        return

    conn.autocommit = False
    cursor = conn.cursor()
    skipped = []
    failed = []
    inserted = 0

    try:
        with open(csv_path, newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                appt_id = row['appt_id']

                # T4: Validate status
                if row['status'] not in VALID_STATUSES:
                    skipped.append(appt_id)
                    print(f"[SKIP] appt_id={appt_id} — unknown status '{row['status']}'")
                    continue

                # T1: Parse date
                try:
                    appt_dt = parse_appt_date(row['appt_date'])
                except ValueError as e:
                    failed.append(appt_id)
                    print(f"[FAIL] appt_id={appt_id} — bad date '{row['appt_date']}': {e}")
                    continue

                # T2: Split room
                room_no, block = split_room(row['room'])
                if room_no is None:
                    failed.append(appt_id)
                    print(f"[FAIL] appt_id={appt_id} — bad room value '{row['room']}'")
                    continue

                # T3: patient_nm, patient_ph, doc_name intentionally omitted
                cursor.execute(
                    """
                    INSERT INTO appointments
                        (appt_id, patient_id, doc_id, appt_datetime,
                         status, fee, discount, room_number, building_block)
                    VALUES
                        (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                    """,
                    (
                        appt_id,
                        row['patient_id'],
                        row['doc_id'],
                        appt_dt,
                        row['status'],
                        Decimal(row['fee']),
                        Decimal(row['discount']),
                        room_no,
                        block
                    )
                )
                inserted += 1

        conn.commit()
        print(f"\nMigration complete.")
        print(f"  Inserted : {inserted}")
        print(f"  Skipped  : {len(skipped)} (invalid status) — {skipped}")
        print(f"  Failed   : {len(failed)} (parse errors)   — {failed}")

    except Exception as e:
        conn.rollback()
        print(f"\n[FATAL] Unhandled error — all inserts rolled back: {e}")
        raise
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    db_config = {
        'host'    : 'localhost',
        'user'    : 'root',
        'password': 'password',
        'database': 'healthbridge'
    }
    migrate('appointments_legacy.txt', db_config)