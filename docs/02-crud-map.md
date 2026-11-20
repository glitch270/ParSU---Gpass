# CRUD Map: PARSU-GPass

Roles: Applicant (student or employee) and Admin. There is no guest role. Registering and logging in are pages anyone can open, but they belong to the applicant.
A "–" means the app has no page for that action. The reason is in the notes under the table.

## 1. CRUD map

| Table | C | R | U | D | Pages | Who |
|-------|---|---|---|---|-------|-----|
| `users` | ✓ | ✓ | ✓ | – | register, login, profile | Applicant: C (register), R, U own (email, password) · Admin: R, U status (deactivate) |
| `applicant_profiles` | ✓ | ✓ | ✓ | – | register, profile, applicants-list, applicant-view | Self: C (at register), R, U · Admin: R |
| `vehicles` | ✓ | ✓ | ✓ | – | application-form, application-view, applicant-view | Applicant: C, R, U own (only while application is pending or declined) · Admin: R |
| `applications` | ✓ | ✓ | ✓ | – | application-form, my-applications, application-view, applications-list, application-review | Applicant: C, R own, U (resubmit after decline) · Admin: R all, U status |
| `ownership_details` | ✓ | ✓ | ✓ | – | application-form, application-view, application-review | Applicant: C, R, U own (while pending or declined) · Admin: R |
| `application_signatures` | ✓ | ✓ | ✓ | – | signature, application-view, application-review | Applicant: C new signature, R own · System: U `is_current` on re-sign · Admin: R |
| `document_types` | – | ✓ | – | – | documents (shown as document names) | Everyone logged in: R · Changed only through `seed.sql` |
| `document_requirements` | – | ✓ | – | – | documents (the checklist for the chosen ownership type) | Applicant: R · Admin: R · Changed only through `seed.sql` |
| `application_documents` | ✓ | ✓ | ✓ | – | documents, application-view, application-review | Applicant: C, R own, replace own (new version) · Admin: R |
| `application_reviews` | ✓ | ✓ | – | – | application-review, application-view | Admin: C, R · Applicant: R remarks on own application |
| `application_status_history` | ✓ | ✓ | – | – | application-view, application-review | System: C on every status change · Applicant: R own · Admin: R all |
| `payments` | ✓ | ✓ | ✓ | – | payment-form, payments-list, payment-verify | Applicant: C (upload receipt), R own · Admin: R all, U verify or reject |
| `gate_pass_stickers` | ✓ | ✓ | ✓ | – | stickers-list, sticker-release, my-sticker, reports | Admin: C (generate), R, U status · Applicant: R own |
| `sticker_releases` | ✓ | ✓ | – | – | sticker-release, my-sticker, reports | Admin: C, R · Applicant: R own |

## 2. Why each "–" (reasons)

**Delete is "–" on every table.** Nothing is deleted in the app. This is a records system, and most foreign keys use `ON DELETE RESTRICT`.
- `users`: admin accounts are referenced by reviews, payments, and stickers, so deleting one would break the audit trail. The account is set to `inactive` instead.
- `applicant_profiles`: removed only by database cascade from `users`, never from a page. Applications and payments depend on it.
- `vehicles`: applications reference it with `RESTRICT`. A wrong entry is fixed with Update.
- `applications`, `payments`, `gate_pass_stickers`: kept as a permanent record. The status field shows what happened (declined, expired).
- `ownership_details`, `application_signatures`, `application_documents`, `application_status_history`: they cascade with their application and are never deleted on their own. Old signatures and document versions are kept as history.
- `application_reviews`, `sticker_releases`: they are evidence of an admin decision or a hand-over, so they are never removed.
- `document_types`, `document_requirements`: reference data, not edited by users.

**Create is "–"** on `document_types` and `document_requirements`: the lists of required documents are fixed by PSU policy and loaded from `seed.sql`.
**Update is "–"** on `document_types`, `document_requirements`, `application_reviews`, `application_status_history`, and `sticker_releases`: reference data, or an audit log. A new decision is a new row, not an edit.

## 3. Form fields for two tables

### 3a. `applicant_profiles` (Register page, together with the `users` fields)

| Column | Form control | Required? | Note |
|--------|--------------|-----------|------|
| `email` (users) | `<input type="email" maxlength="150">` | * | Unique |
| `password` (users) | `<input type="password" minlength="8">` | * | PHP stores a bcrypt hash. A "Confirm password" field is form-only, not a column |
| `account_role` (users) | none | – | PHP sets `applicant`. The user must never choose it |
| `applicant_id` | none | – | AUTO_INCREMENT |
| `user_id` | none | – | PHP fills it from the new `users` row |
| `applicant_type` | `<select>` or radio: student, employee | * | The ENUM values |
| `school_id` | `<input type="text" maxlength="50">` | * | Unique |
| `first_name` | `<input type="text" maxlength="100">` | * | |
| `middle_name` | `<input type="text" maxlength="100">` | no | NULL allowed |
| `last_name` | `<input type="text" maxlength="100">` | * | |
| `suffix` | `<input type="text" maxlength="20">` | no | Jr., III, etc. |
| `contact_number` | `<input type="tel" maxlength="30" minlength="7">` | * | Table has a length check of 7 or more |
| `department` | `<input type="text" maxlength="150">` | * | |
| `course_year_section` | `<input type="text" maxlength="150">` | no | Students only |
| `license_number` | `<input type="text" maxlength="50">` | no | NULL allowed, unique |
| `created_at` | none | – | DEFAULT CURRENT_TIMESTAMP |

### 3b. `vehicles` (Vehicle section of the application form)

| Column | Form control | Required? | Note |
|--------|--------------|-----------|------|
| `vehicle_id` | none | – | AUTO_INCREMENT. On Edit it is a hidden field |
| `applicant_id` | none | – | PHP takes it from the logged-in session, not from the form |
| `vehicle_type` | `<input type="text" maxlength="50">` | * | e.g. Motorcycle, Car, Tricycle |
| `year_model` | `<input type="number" min="1950" max="2100">` | * | Matches the table's year check |
| `plate_number` | `<input type="text" maxlength="30">` | * | |
| `color` | `<input type="text" maxlength="50">` | * | |
| `created_at` | none | – | DEFAULT CURRENT_TIMESTAMP |

## 4. Schema changes

None. The Phase 3 `schema.sql` is unchanged.

Note: the old ERD image still shows `license_number` in `vehicles` and `applicant_id` in `applications`. The SQL is correct (the license is in `applicant_profiles`, and `applications` has no `applicant_id`). The image is out of date, not the database.
