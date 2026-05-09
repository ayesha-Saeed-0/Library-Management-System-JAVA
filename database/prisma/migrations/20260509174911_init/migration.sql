-- CreateTable
CREATE TABLE `patients` (
    `patient_id` INTEGER NOT NULL AUTO_INCREMENT,
    `full_name` VARCHAR(191) NOT NULL,
    `date_of_birth` DATE NOT NULL,
    `sex` ENUM('M', 'F', 'N') NOT NULL,
    `reg_doctor_id` INTEGER NOT NULL,
    `total_visits` INTEGER NOT NULL DEFAULT 0,

    PRIMARY KEY (`patient_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `patient_phones` (
    `phone_id` INTEGER NOT NULL AUTO_INCREMENT,
    `patient_id` INTEGER NOT NULL,
    `phone_number` VARCHAR(20) NOT NULL,
    `phone_type` VARCHAR(191) NOT NULL DEFAULT 'mobile',

    PRIMARY KEY (`phone_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `patient_addresses` (
    `address_id` INTEGER NOT NULL AUTO_INCREMENT,
    `patient_id` INTEGER NOT NULL,
    `address_line1` VARCHAR(191) NOT NULL,
    `address_line2` VARCHAR(191) NULL,
    `city` VARCHAR(100) NOT NULL,
    `address_type` ENUM('home', 'work', 'billing', 'postal') NOT NULL DEFAULT 'home',

    PRIMARY KEY (`address_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `doctors` (
    `doctor_id` INTEGER NOT NULL,
    `full_name` VARCHAR(191) NOT NULL,
    `speciality` VARCHAR(191) NOT NULL,
    `contact_no` VARCHAR(191) NOT NULL,
    `join_date` VARCHAR(191) NOT NULL,
    `salary_monthly` DOUBLE NOT NULL,
    `dept_id` INTEGER NOT NULL,
    `is_active` VARCHAR(191) NOT NULL,

    PRIMARY KEY (`doctor_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `appointments` (
    `appt_id` INTEGER NOT NULL,
    `patient_id` INTEGER NOT NULL,
    `doc_id` INTEGER NOT NULL,
    `appt_datetime` DATETIME(3) NOT NULL,
    `status` CHAR(1) NOT NULL,
    `fee` DECIMAL(10, 2) NOT NULL,
    `discount` DECIMAL(10, 2) NOT NULL,
    `room_number` INTEGER NOT NULL,
    `building_block` VARCHAR(191) NOT NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    PRIMARY KEY (`appt_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `patients` ADD CONSTRAINT `patients_reg_doctor_id_fkey` FOREIGN KEY (`reg_doctor_id`) REFERENCES `doctors`(`doctor_id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `patient_phones` ADD CONSTRAINT `patient_phones_patient_id_fkey` FOREIGN KEY (`patient_id`) REFERENCES `patients`(`patient_id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `patient_addresses` ADD CONSTRAINT `patient_addresses_patient_id_fkey` FOREIGN KEY (`patient_id`) REFERENCES `patients`(`patient_id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `appointments` ADD CONSTRAINT `appointments_doc_id_fkey` FOREIGN KEY (`doc_id`) REFERENCES `doctors`(`doctor_id`) ON DELETE RESTRICT ON UPDATE CASCADE;
