CREATE DATABASE IF NOT EXISTS parsu_gpass
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE parsu_gpass;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS sticker_releases, gate_pass_stickers, payments,
  application_status_history, application_reviews, application_documents,
  document_requirements, document_types, application_signatures,
  ownership_details, applications, vehicles, applicant_profiles, users;
SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------------------------------------------------------
-- 1. USERS                      keys: user_id (PK); email (UNIQUE)      F1, F2
-- ----------------------------------------------------------------------------
CREATE TABLE users (
  user_id         INT          NOT NULL AUTO_INCREMENT,
  email           VARCHAR(150) NOT NULL,
  `password`      VARCHAR(255) NOT NULL,
  account_role    ENUM('applicant','admin')  NOT NULL DEFAULT 'applicant',
  account_status  ENUM('active','inactive')  NOT NULL DEFAULT 'active',
  created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_users        PRIMARY KEY (user_id),
  CONSTRAINT uq_users_email  UNIQUE (email),
  CONSTRAINT chk_users_email CHECK (CHAR_LENGTH(email) >= 5 AND email LIKE '%@%.%'),
  CONSTRAINT chk_users_password CHECK (CHAR_LENGTH(`password`) >= 60)  -- bcrypt hash
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 2. APPLICANT_PROFILES         keys: applicant_id (PK); user_id, school_id,
--                               license_number (UNIQUE)                F3-F6
-- ----------------------------------------------------------------------------
CREATE TABLE applicant_profiles (
  applicant_id         INT          NOT NULL AUTO_INCREMENT,
  user_id              INT          NOT NULL,
  applicant_type       ENUM('student','employee') NOT NULL,
  school_id            VARCHAR(50)  NOT NULL,
  first_name           VARCHAR(100) NOT NULL,
  middle_name          VARCHAR(100) NULL,
  last_name            VARCHAR(100) NOT NULL,
  suffix               VARCHAR(20)  NULL,
  contact_number       VARCHAR(30)  NOT NULL,
  department           VARCHAR(150) NOT NULL,
  course_year_section  VARCHAR(150) NULL,
  license_number       VARCHAR(50)  NULL,          -- one license per applicant (A1)
  created_at           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_applicant_profiles PRIMARY KEY (applicant_id),
  CONSTRAINT uq_profile_user       UNIQUE (user_id),
  CONSTRAINT uq_profile_school_id  UNIQUE (school_id),
  CONSTRAINT uq_profile_license    UNIQUE (license_number),   -- NULLs allowed
  CONSTRAINT fk_profile_user FOREIGN KEY (user_id)
    REFERENCES users (user_id) ON DELETE CASCADE,
  CONSTRAINT chk_profile_names CHECK (CHAR_LENGTH(TRIM(first_name)) > 0
                                  AND CHAR_LENGTH(TRIM(last_name))  > 0),
  CONSTRAINT chk_profile_contact CHECK (CHAR_LENGTH(contact_number) >= 7)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 3. VEHICLES                   key: vehicle_id (PK)                      F7
-- ----------------------------------------------------------------------------
CREATE TABLE vehicles (
  vehicle_id     INT         NOT NULL AUTO_INCREMENT,
  applicant_id   INT         NOT NULL,
  vehicle_type   VARCHAR(50) NOT NULL,
  year_model     YEAR        NOT NULL,
  plate_number   VARCHAR(30) NOT NULL,
  color          VARCHAR(50) NOT NULL,
  created_at     TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_vehicles PRIMARY KEY (vehicle_id),
  CONSTRAINT fk_vehicle_applicant FOREIGN KEY (applicant_id)
    REFERENCES applicant_profiles (applicant_id) ON DELETE RESTRICT,
  CONSTRAINT chk_vehicle_year  CHECK (year_model BETWEEN 1950 AND 2100),
  CONSTRAINT chk_vehicle_plate CHECK (CHAR_LENGTH(TRIM(plate_number)) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 4. APPLICATIONS               keys: application_id (PK);
--                               application_number (UNIQUE)             F8, F9
--    No applicant_id column: the applicant is reached through vehicle_id.
-- ----------------------------------------------------------------------------
CREATE TABLE applications (
  application_id      INT         NOT NULL AUTO_INCREMENT,
  vehicle_id          INT         NOT NULL,
  application_number  VARCHAR(50) NOT NULL,
  application_status  ENUM('pending','declined','resubmitted','approved',
                           'payment_pending','payment_verification','paid',
                           'for_release','released') NOT NULL DEFAULT 'pending',
  submitted_at        DATETIME    NULL,
  updated_at          TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT pk_applications       PRIMARY KEY (application_id),
  CONSTRAINT uq_application_number UNIQUE (application_number),
  CONSTRAINT fk_app_vehicle FOREIGN KEY (vehicle_id)
    REFERENCES vehicles (vehicle_id) ON DELETE RESTRICT,
  CONSTRAINT chk_application_number
    CHECK (application_number REGEXP '^GP-[0-9]{4}-[0-9]{6}$')   -- GP-YYYY-NNNNNN
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 5. OWNERSHIP_DETAILS          keys: ownership_id (PK); application_id (UNIQUE)
--                               an application has 0..1 ownership record  F10, F11
-- ----------------------------------------------------------------------------
CREATE TABLE ownership_details (
  ownership_id               INT          NOT NULL AUTO_INCREMENT,
  application_id             INT          NOT NULL,
  ownership_category         ENUM('first_owner_own_name','first_owner_relative_name',
                                  'secondhand_applicant_buyer',
                                  'secondhand_applicant_not_buyer') NOT NULL,
  owner_name                 VARCHAR(150) NULL,
  buyer_name                 VARCHAR(150) NULL,
  previous_owner_name        VARCHAR(150) NULL,
  relationship_to_applicant  VARCHAR(100) NULL,
  created_at                 TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ownership_details     PRIMARY KEY (ownership_id),
  CONSTRAINT uq_ownership_application UNIQUE (application_id),
  CONSTRAINT fk_ownership_app FOREIGN KEY (application_id)
    REFERENCES applications (application_id) ON DELETE CASCADE,
  -- the ownership category decides which name columns are required
  CONSTRAINT chk_own_relative CHECK (ownership_category <> 'first_owner_relative_name'
    OR (owner_name IS NOT NULL AND relationship_to_applicant IS NOT NULL)),
  CONSTRAINT chk_own_buyer CHECK (ownership_category <> 'secondhand_applicant_buyer'
    OR previous_owner_name IS NOT NULL),
  CONSTRAINT chk_own_not_buyer CHECK (ownership_category <> 'secondhand_applicant_not_buyer'
    OR (previous_owner_name IS NOT NULL AND buyer_name IS NOT NULL
        AND relationship_to_applicant IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 6. APPLICATION_SIGNATURES     keys: signature_id (PK);
--                               (application_id, version_number) (UNIQUE) F20, F21
-- ----------------------------------------------------------------------------
CREATE TABLE application_signatures (
  signature_id    INT          NOT NULL AUTO_INCREMENT,
  application_id  INT          NOT NULL,
  signature_file  VARCHAR(255) NOT NULL,
  version_number  INT          NOT NULL DEFAULT 1,
  is_current      TINYINT(1)   NOT NULL DEFAULT 1,
  signed_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_application_signatures PRIMARY KEY (signature_id),
  CONSTRAINT uq_app_signature_version  UNIQUE (application_id, version_number),
  CONSTRAINT fk_signature_app FOREIGN KEY (application_id)
    REFERENCES applications (application_id) ON DELETE CASCADE,
  CONSTRAINT chk_sig_version CHECK (version_number >= 1),
  CONSTRAINT chk_sig_current CHECK (is_current IN (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 7. DOCUMENT_TYPES             keys: document_type_id (PK);
--                               document_code (UNIQUE)                 F22, F23
-- ----------------------------------------------------------------------------
CREATE TABLE document_types (
  document_type_id  INT          NOT NULL AUTO_INCREMENT,
  document_code     VARCHAR(50)  NOT NULL,
  document_name     VARCHAR(150) NOT NULL,
  CONSTRAINT pk_document_types PRIMARY KEY (document_type_id),
  CONSTRAINT uq_document_code  UNIQUE (document_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 8. DOCUMENT_REQUIREMENTS      keys: requirement_id (PK);
--                               (ownership_category, document_type_id,
--                                subject_role) (UNIQUE)                 F24, F25
-- ----------------------------------------------------------------------------
CREATE TABLE document_requirements (
  requirement_id      INT          NOT NULL AUTO_INCREMENT,
  ownership_category  ENUM('first_owner_own_name','first_owner_relative_name',
                           'secondhand_applicant_buyer',
                           'secondhand_applicant_not_buyer') NOT NULL,
  document_type_id    INT          NOT NULL,
  subject_role        VARCHAR(100) NOT NULL,
  display_label       VARCHAR(255) NOT NULL,
  sort_order          INT          NOT NULL DEFAULT 1,
  CONSTRAINT pk_document_requirements PRIMARY KEY (requirement_id),
  CONSTRAINT uq_req_category_doc_role
    UNIQUE (ownership_category, document_type_id, subject_role),
  CONSTRAINT fk_req_doc_type FOREIGN KEY (document_type_id)
    REFERENCES document_types (document_type_id) ON DELETE CASCADE,
  CONSTRAINT chk_req_sort CHECK (sort_order >= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 9. APPLICATION_DOCUMENTS      keys: document_id (PK);
--                               (application_id, requirement_id,
--                                version_number) (UNIQUE)               F26, F27
-- ----------------------------------------------------------------------------
CREATE TABLE application_documents (
  document_id     INT          NOT NULL AUTO_INCREMENT,
  application_id  INT          NOT NULL,
  requirement_id  INT          NOT NULL,
  file_name       VARCHAR(255) NOT NULL,
  file_path       VARCHAR(255) NOT NULL,
  file_type       VARCHAR(50)  NOT NULL,
  file_size       INT          NOT NULL,
  version_number  INT          NOT NULL DEFAULT 1,
  is_current      TINYINT(1)   NOT NULL DEFAULT 1,
  uploaded_by     INT          NOT NULL,
  uploaded_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_application_documents PRIMARY KEY (document_id),
  CONSTRAINT uq_app_req_version UNIQUE (application_id, requirement_id, version_number),
  CONSTRAINT fk_doc_app FOREIGN KEY (application_id)
    REFERENCES applications (application_id) ON DELETE CASCADE,
  CONSTRAINT fk_doc_req FOREIGN KEY (requirement_id)
    REFERENCES document_requirements (requirement_id) ON DELETE RESTRICT,
  CONSTRAINT fk_doc_user FOREIGN KEY (uploaded_by)
    REFERENCES users (user_id) ON DELETE RESTRICT,
  CONSTRAINT chk_doc_size    CHECK (file_size BETWEEN 1 AND 5242880),   -- 5 MB limit
  CONSTRAINT chk_doc_version CHECK (version_number >= 1),
  CONSTRAINT chk_doc_current CHECK (is_current IN (0,1)),
  CONSTRAINT chk_doc_type    CHECK (CHAR_LENGTH(file_type) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 10. APPLICATION_REVIEWS       key: review_id (PK)                       F28
-- ----------------------------------------------------------------------------
CREATE TABLE application_reviews (
  review_id        INT       NOT NULL AUTO_INCREMENT,
  application_id   INT       NOT NULL,
  admin_id         INT       NOT NULL,
  review_decision  ENUM('approved','declined') NOT NULL,
  remarks          TEXT      NOT NULL,
  reviewed_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_application_reviews PRIMARY KEY (review_id),
  CONSTRAINT fk_review_app FOREIGN KEY (application_id)
    REFERENCES applications (application_id) ON DELETE CASCADE,
  CONSTRAINT fk_review_admin FOREIGN KEY (admin_id)
    REFERENCES users (user_id) ON DELETE RESTRICT,
  -- a decline must always carry remarks
  CONSTRAINT chk_review_remarks
    CHECK (review_decision <> 'declined' OR CHAR_LENGTH(TRIM(remarks)) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 11. APPLICATION_STATUS_HISTORY   key: history_id (PK)                   F29
-- ----------------------------------------------------------------------------
CREATE TABLE application_status_history (
  history_id       INT         NOT NULL AUTO_INCREMENT,
  application_id   INT         NOT NULL,
  previous_status  VARCHAR(50) NULL,
  new_status       VARCHAR(50) NOT NULL,
  changed_by       INT         NULL,
  remarks          TEXT        NULL,
  changed_at       TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_application_status_history PRIMARY KEY (history_id),
  CONSTRAINT fk_hist_app FOREIGN KEY (application_id)
    REFERENCES applications (application_id) ON DELETE CASCADE,
  CONSTRAINT fk_hist_user FOREIGN KEY (changed_by)
    REFERENCES users (user_id) ON DELETE RESTRICT,
  CONSTRAINT chk_hist_change CHECK (previous_status IS NULL OR previous_status <> new_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 12. PAYMENTS                  keys: payment_id (PK); application_id,
--                               psu_or_number (UNIQUE)                 F12-F14
--                               an application has 0..1 payment
-- ----------------------------------------------------------------------------
CREATE TABLE payments (
  payment_id            INT           NOT NULL AUTO_INCREMENT,
  application_id        INT           NOT NULL,
  amount                DECIMAL(10,2) NOT NULL,
  psu_or_number         VARCHAR(100)  NOT NULL,
  receipt_file          VARCHAR(255)  NOT NULL,
  payment_status        ENUM('pending_verification','verified','rejected')
                        NOT NULL DEFAULT 'pending_verification',
  verified_by           INT           NULL,
  verification_remarks  TEXT          NULL,
  payment_date          DATE          NOT NULL,
  verified_at           DATETIME      NULL,
  created_at            TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_payments            PRIMARY KEY (payment_id),
  CONSTRAINT uq_payment_application UNIQUE (application_id),
  CONSTRAINT uq_payment_or_number   UNIQUE (psu_or_number),
  CONSTRAINT fk_pay_app FOREIGN KEY (application_id)
    REFERENCES applications (application_id) ON DELETE RESTRICT,
  CONSTRAINT fk_pay_admin FOREIGN KEY (verified_by)
    REFERENCES users (user_id) ON DELETE RESTRICT,
  CONSTRAINT chk_pay_amount CHECK (amount > 0),
  CONSTRAINT chk_pay_or     CHECK (CHAR_LENGTH(TRIM(psu_or_number)) > 0),
  -- a payment is verified/rejected only together with a verification time
  CONSTRAINT chk_pay_verified CHECK (
       (payment_status = 'pending_verification' AND verified_at IS NULL)
    OR (payment_status <> 'pending_verification' AND verified_at IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 13. GATE_PASS_STICKERS        keys: sticker_id (PK); application_id,
--                               sticker_number (UNIQUE)                F15-F17
--    applicant_type is a snapshot of the type at issue time (A2).
--    Fee/validity length (2 years student, 3 years employee) is applied by the
--    application when it sets valid_until; the database enforces the ordering.
-- ----------------------------------------------------------------------------
CREATE TABLE gate_pass_stickers (
  sticker_id      INT         NOT NULL AUTO_INCREMENT,
  application_id  INT         NOT NULL,
  sticker_number  VARCHAR(50) NOT NULL,
  applicant_type  ENUM('student','employee') NOT NULL,
  issue_date      DATE        NOT NULL,
  valid_until     DATE        NOT NULL,
  sticker_status  ENUM('for_release','released','expired') NOT NULL DEFAULT 'for_release',
  generated_by    INT         NOT NULL,
  generated_at    TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_gate_pass_stickers  PRIMARY KEY (sticker_id),
  CONSTRAINT uq_sticker_application UNIQUE (application_id),
  CONSTRAINT uq_sticker_number      UNIQUE (sticker_number),
  CONSTRAINT fk_sticker_app FOREIGN KEY (application_id)
    REFERENCES applications (application_id) ON DELETE RESTRICT,
  CONSTRAINT fk_sticker_admin FOREIGN KEY (generated_by)
    REFERENCES users (user_id) ON DELETE RESTRICT,
  CONSTRAINT chk_sticker_number CHECK (sticker_number REGEXP '^GP-[0-9]{4}-[0-9]{6}$'),
  CONSTRAINT chk_sticker_dates  CHECK (valid_until > issue_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 14. STICKER_RELEASES          keys: release_id (PK); sticker_id (UNIQUE) F18, F19
--                               a sticker has 0..1 release record
-- ----------------------------------------------------------------------------
CREATE TABLE sticker_releases (
  release_id       INT          NOT NULL AUTO_INCREMENT,
  sticker_id       INT          NOT NULL,
  released_by      INT          NOT NULL,
  received_by      VARCHAR(150) NOT NULL,
  release_remarks  TEXT         NULL,
  released_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_sticker_releases PRIMARY KEY (release_id),
  CONSTRAINT uq_release_sticker  UNIQUE (sticker_id),
  CONSTRAINT fk_rel_sticker FOREIGN KEY (sticker_id)
    REFERENCES gate_pass_stickers (sticker_id) ON DELETE CASCADE,
  CONSTRAINT fk_rel_admin FOREIGN KEY (released_by)
    REFERENCES users (user_id) ON DELETE RESTRICT,
  CONSTRAINT chk_release_received CHECK (CHAR_LENGTH(TRIM(received_by)) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
