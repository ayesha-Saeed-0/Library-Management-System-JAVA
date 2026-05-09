--HealthBridgeHospitalManagementSystem — Legacy Schema--Accumulated2009–2024.Neverformally reviewed.
CREATE TABLE pat_master(
pid INT,
p_name VARCHAR(255),
dob VARCHAR(50),-- stored as 'DD/MM/YYYY' plain text
sex CHAR(1),-- 'M', 'F', or '3' for non-binary
ph1 VARCHAR(255),
ph2 VARCHAR(255),
ph3 VARCHAR(255),-- repeating phone group
addr1 VARCHAR(255),
addr2 VARCHAR(255),
city VARCHAR(255),
reg_doc VARCHAR(255),-- doctor full name stored as plain text
reg_doc_id VARCHAR(255),-- sometimes INT string, sometimes 'DR-042'
total_visitsINT,-- updated manually, not via trigger
last_bill FLOAT,-- stores PKR amounts; FLOAT used for
currency
notes TEXT-- JSON blobs, free text, and CSV tags all mixed
);
CREATE TABLE appointments(
appt_id INT,
patient_id INT,
patient_nm VARCHAR(255),-- duplicated from pat_master
patient_ph VARCHAR(255),-- duplicated from pat_master
doc_id INT,
doc_name VARCHAR(255),-- duplicated from doctors table
appt_date VARCHAR(50),-- 'YYYY-MM-DD HH:MM' stored as text
status CHAR(1),-- 'P'=Pending 'C'=Complete 'X'=Cancel 'H'=Hold'R'=Rescheduled
fee FLOAT,
discount FLOAT,
net_fee FLOAT,-- always = fee-discount (derived value)
room VARCHAR(255)-- 'Room 3 Block B' — two facts in one column
);
CREATE TABLE doctors(
DoctorID INT PRIMARY KEY,
FullName VARCHAR(255),
Speciality VARCHAR(255),
ContactNo VARCHAR(255),
JoinDt VARCHAR(50),-- date stored as text
Salary FLOAT,-- monthly salary stored as FLOAT
dept_id INT,-- references departments but no FK defined
isActive CHAR(1)-- 'Y', 'N', or sometimes '1'
);
CREATE TABLE billing(
bill_no VARCHAR(50),-- intended as PK but no constraint defined
pid INT,
pname VARCHAR(255),-- patient name duplicated again
services TEXT,-- 'Lab,Xray,OPD' — comma-separated list
svc_cost FLOAT,
tax_pct FLOAT,
tax_amt FLOAT,-- derived: svc_cost * tax_pct / 100
grand_total FLOAT,-- derived: svc_cost + tax_amt
paid FLOAT,
balance FLOAT,-- derived: grand_total-paid
created VARCHAR(50),-- date stored as text
created_by VARCHAR(255)-- username as free text; no FK to users
);
CREATE TABLE departments(
dept_id INT PRIMARY KEY,
dept_nm VARCHAR(255),
hod VARCHAR(255),-- head-of-department stored as plain name
budget FLOAT
);