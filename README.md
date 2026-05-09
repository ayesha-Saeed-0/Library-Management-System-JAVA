# SRE Final Project — Re-Engineering a Legacy Hospital Management System

## Project Overview
This project applies a full software re-engineering pipeline to two artefacts:
1. **Open-Source Java Project** — Library Management System (Parts A, B, C, D)
2. **Legacy Hospital DB Schema** — HealthBridge Hospital (Parts E, F, G)

---

##  Repository Structure
├── Project/                  # Java LMS project (NetBeans)
├── database/
│   ├── legacy_schema.sql     # Original HealthBridge schema
│   ├── refactoring_scripts.sql # R1–R5 refactoring scripts
│   ├── migration_etl.py      # ETL migration script
│   ├── appointments_legacy.csv # Sample legacy CSV data
│   ├── query.js              # Prisma sample queries
│   └── prisma/               # Prisma schema and migrations
├── sonar-project.properties  # SonarQube configuration
└── README.md

---

##  Setup Instructions

### 1. Prerequisites
- Java JDK 8
- NetBeans IDE
- MySQL 9.7+
- Python 3.10+
- Node.js v22+
- Docker (for SonarQube)

---

### 2. Start SonarQube
```bash
docker run -d --name sonarqube -p 9000:9000 sonarqube:latest
```
Then open browser at: `http://localhost:9000`  
Default login: `admin / admin`

---

### 3. Run SonarScanner
```bash
cd Project/
sonar-scanner
```
Make sure `sonar-project.properties` is in the root of the Java project folder.

---

### 4. Load the Legacy Hospital Schema
Open MySQL Workbench and run:
```bash
mysql -u root -p
```
Then:
```sql
CREATE DATABASE healthbridge;
USE healthbridge;
```
Then run the legacy schema file:
```sql
source database/legacy_schema.sql
```

---

### 5. Run Refactoring Scripts (Parts F)
Run in this exact order in MySQL Workbench:
```sql
source database/refactoring_scripts.sql
```
Or manually in this order: **R1 → R2 → R4 → R5 → R3**

---

### 6. Set Up Prisma
```bash
cd database/
npm install
npx prisma migrate dev --name init
npx prisma studio
```
Make sure your `.env` file has:
DATABASE_URL="mysql://root:yourpassword@localhost:3306/healthbridge"

---

### 7. Run the Migration Script (Part G)
Install dependencies:
```bash
pip install mysql-connector-python
```
Run the ETL script:
```bash
python migration_etl.py
```
Expected output:
Migration complete.
Inserted : 9
Skipped  : 1 (invalid status) — ['1010']
Failed   : 0 (parse errors)   — []

---

### 8. Run Post-Migration Validation Queries
In MySQL Workbench run:
```sql
-- V1: Row count
SELECT COUNT(*) AS migrated_rows FROM appointments;

-- V2: Null dates
SELECT COUNT(*) AS null_dates FROM appointments WHERE appt_datetime IS NULL;

-- V3: Valid statuses
SELECT DISTINCT status FROM appointments;

-- V4: No orphans
SELECT COUNT(*) AS orphans FROM appointments a
LEFT JOIN patients p ON a.patient_id = p.patient_id
WHERE p.patient_id IS NULL;
```

---

### 9. Run Java LMS Project
1. Install [JDK 8](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
2. Install [NetBeans IDE](https://netbeans.org/downloads/)
3. Open NetBeans → File → Open Project → select `Project/` folder
4. In Services tab → JavaDB → Properties → set location to `Database/` folder
5. Right click Databases → New Connection → Java DB Network
6. Use credentials:
Host: localhost
Port: 1527
Database: LMS
User Name: haris
Password: 123
7. Connect and run the project
8. Admin password: `lib`

---