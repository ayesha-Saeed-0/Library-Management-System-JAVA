-- R1: Remove derived columns from billing
ALTER TABLE billing DROP COLUMN tax_amt;
ALTER TABLE billing DROP COLUMN grand_total;
ALTER TABLE billing DROP COLUMN balance;

-- Create view to compute derived values on read
CREATE OR REPLACE VIEW v_billing_summary AS
SELECT
    bill_no,
    pid,
    svc_cost,
    tax_pct,
    ROUND(svc_cost * tax_pct / 100, 2)              AS tax_amt,
    ROUND(svc_cost + svc_cost * tax_pct / 100, 2)   AS grand_total,
    paid,
    ROUND(svc_cost + svc_cost * tax_pct / 100 - paid, 2) AS balance
FROM billing;

-- Reference table for valid status codes
CREATE TABLE appt_status_ref (
    status_code CHAR(1)     PRIMARY KEY,
    description VARCHAR(50) NOT NULL
);

INSERT INTO appt_status_ref VALUES
    ('P', 'Pending'),
    ('C', 'Completed'),
    ('X', 'Cancelled'),
    ('H', 'On Hold'),
    ('R', 'Rescheduled');
-- R2 Remove any existing rows with status codes not in the reference table
-- (same principle as R4 orphan cleanup — FK cannot be added while invalid values exist)
DELETE FROM appointments
WHERE status NOT IN ('P','C','X','H','R');

-- Enforce valid codes via FK
ALTER TABLE appointments
    ADD CONSTRAINT fk_appt_status
    FOREIGN KEY (status) REFERENCES appt_status_ref(status_code);

-- R4 — Fix Missing Constraints in billing and appointments
-- Step 1: Add primary key to billing
ALTER TABLE billing ADD PRIMARY KEY (bill_no);
-- NOTE: bill_no is VARCHAR(50) which is a suboptimal PK type — VARCHAR PKs
-- cause slower joins and are case-sensitive. Recommended follow-up:
-- ADD COLUMN bill_id INT AUTO_INCREMENT PRIMARY KEY,
-- keep bill_no as UNIQUE NOT NULL for the business reference number only.
-- Step 2: Remove orphan billing rows referencing non-existent patients
DELETE FROM billing
WHERE pid NOT IN (SELECT pid FROM pat_master);
-- Step 3: FK from billing to pat_master
ALTER TABLE billing
    ADD CONSTRAINT fk_billing_patient
    FOREIGN KEY (pid) REFERENCES pat_master(pid);
-- Step 4: Remove orphan appointments referencing non-existent doctors
DELETE FROM appointments
WHERE doc_id NOT IN (SELECT DoctorID FROM doctors);
-- Step 5: FK from appointments to doctors
ALTER TABLE appointments
    ADD CONSTRAINT fk_appt_doctor
    FOREIGN KEY (doc_id) REFERENCES doctors(DoctorID);

-- R5 Add audit timestamp columns to appointments
ALTER TABLE appointments
    ADD COLUMN created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                           ON UPDATE CURRENT_TIMESTAMP;

-- R3 Standardise doctors table to snake_case
ALTER TABLE doctors RENAME COLUMN DoctorID   TO doctor_id;
ALTER TABLE doctors RENAME COLUMN FullName   TO full_name;
ALTER TABLE doctors RENAME COLUMN Speciality TO speciality;
ALTER TABLE doctors RENAME COLUMN ContactNo  TO contact_no;
ALTER TABLE doctors RENAME COLUMN JoinDt     TO join_date;
ALTER TABLE doctors RENAME COLUMN Salary     TO salary_monthly;
ALTER TABLE doctors RENAME COLUMN isActive   TO is_active;