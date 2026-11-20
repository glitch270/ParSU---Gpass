-- PARSU-GPass seed data (sample rows). Run after schema.sql.
USE parsu_gpass;

-- --------------------------------------------------------
-- Seed Data: Document Types
-- --------------------------------------------------------
INSERT INTO `document_types` (`document_type_id`, `document_code`, `document_name`) VALUES
(1, 'OR', 'Official Receipt (OR)'),
(2, 'CR', 'Certificate of Registration (CR)'),
(3, 'APPLICANT_DL', 'Applicant Driver License'),
(4, 'VEHICLE_OWNER_DL', 'Vehicle Owner Driver License'),
(5, 'AUTHORIZATION_LETTER', 'Notarized Authorization Letter'),
(6, 'DEED_OF_SALE', 'Notarized Deed of Sale'),
(7, 'PREVIOUS_OWNER_DL', 'Previous Owner Driver License'),
(8, 'BUYER_DL', 'Buyer Driver License')
ON DUPLICATE KEY UPDATE `document_name` = VALUES(`document_name`);

-- --------------------------------------------------------
-- Seed Data: Document Requirements
-- --------------------------------------------------------
-- Category 1: first_owner_own_name (3 requirements)
INSERT INTO `document_requirements` (`requirement_id`, `ownership_category`, `document_type_id`, `subject_role`, `display_label`, `sort_order`) VALUES
(1, 'first_owner_own_name', 1, 'applicant', 'Official Receipt (OR)', 1),
(2, 'first_owner_own_name', 2, 'applicant', 'Certificate of Registration (CR)', 2),
(3, 'first_owner_own_name', 3, 'applicant', 'Applicant Driver''s License (with 3 signatures)', 3),

-- Category 2: first_owner_relative_name (5 requirements)
(4, 'first_owner_relative_name', 1, 'vehicle', 'Official Receipt (OR)', 1),
(5, 'first_owner_relative_name', 2, 'vehicle', 'Certificate of Registration (CR)', 2),
(6, 'first_owner_relative_name', 4, 'vehicle_owner', 'Registered Vehicle Owner''s Driver''s License (with 3 signatures)', 3),
(7, 'first_owner_relative_name', 3, 'applicant', 'Applicant Driver''s License (with 3 signatures)', 4),
(8, 'first_owner_relative_name', 5, 'vehicle_owner', 'Notarized Authorization Letter (from the registered owner)', 5),

-- Category 3: secondhand_applicant_buyer (5 requirements)
(9, 'secondhand_applicant_buyer', 1, 'vehicle', 'Official Receipt (OR)', 1),
(10, 'secondhand_applicant_buyer', 2, 'vehicle', 'Certificate of Registration (CR)', 2),
(11, 'secondhand_applicant_buyer', 6, 'transaction', 'Notarized Deed of Sale', 3),
(12, 'secondhand_applicant_buyer', 7, 'previous_owner', 'Previous Registered Owner''s Driver''s License (with 3 signatures)', 4),
(13, 'secondhand_applicant_buyer', 3, 'applicant', 'Applicant Driver''s License (with 3 signatures)', 5),

-- Category 4: secondhand_applicant_not_buyer (7 requirements)
(14, 'secondhand_applicant_not_buyer', 1, 'vehicle', 'Official Receipt (OR)', 1),
(15, 'secondhand_applicant_not_buyer', 2, 'vehicle', 'Certificate of Registration (CR)', 2),
(16, 'secondhand_applicant_not_buyer', 6, 'transaction', 'Notarized Deed of Sale', 3),
(17, 'secondhand_applicant_not_buyer', 7, 'previous_owner', 'Previous Registered Owner''s Driver''s License (with 3 signatures)', 4),
(18, 'secondhand_applicant_not_buyer', 3, 'applicant', 'Applicant Driver''s License (with 3 signatures)', 5),
(19, 'secondhand_applicant_not_buyer', 5, 'buyer', 'Notarized Authorization Letter (from the buyer/current owner)', 6),
(20, 'secondhand_applicant_not_buyer', 8, 'buyer', 'Buyer''s Driver''s License (with 3 signatures)', 7)
ON DUPLICATE KEY UPDATE `display_label` = VALUES(`display_label`), `sort_order` = VALUES(`sort_order`);

-- --------------------------------------------------------
-- Seed Data: Default Accounts
-- Passwords:
-- Admin:    Admin@123456    ($2y$10$gQ0NqQ5Z8qLwzW5gQ7d0he7XW9Q5Z8qLwzW5gQ7d0he7XW9Q5Z8qL - standard BCRYPT)
-- Student:  Student@123456
-- Employee: Employee@123456
-- (Hashes below generated via password_hash('...', PASSWORD_BCRYPT))
-- --------------------------------------------------------

INSERT INTO `users` (`user_id`, `email`, `password`, `account_role`, `account_status`) VALUES
(1, 'admin@parsu.edu.ph', '$2y$10$iEIfN6sbnKWsXNbOwreSler/zEnr8slyTSIeX1pfCkaMRylkmgdDG', 'admin', 'active'),
(2, 'student@parsu.edu.ph', '$2y$10$szgG/vjTCQkQmKlPb0SM7uINBqNCf.nZrUmQq6l6AABzm9vCPgq2G', 'applicant', 'active'),
(3, 'employee@parsu.edu.ph', '$2y$10$Y6hwIKLPStyyTloN9Do3MujYyHaTIDJ0CRW93.Yb.MgmOtwmTb.LK', 'applicant', 'active')
ON DUPLICATE KEY UPDATE `email` = VALUES(`email`);

INSERT INTO `applicant_profiles` (`applicant_id`, `user_id`, `applicant_type`, `school_id`, `first_name`, `middle_name`, `last_name`, `suffix`, `contact_number`, `department`, `course_year_section`) VALUES
(1, 2, 'student', 'STUD-2024-0012', 'Juan', 'Cruz', 'Dela Cruz', '', '09123456789', 'College of Computer Studies', 'BSIT - 4A'),
(2, 3, 'employee', 'EMP-2018-0481', 'Maria', 'Santos', 'Reyes', '', '09987654321', 'General Services Office', 'Faculty / Staff')
ON DUPLICATE KEY UPDATE `school_id` = VALUES(`school_id`);
