# Project Brief: PARSU-GPass

## 1. The problem
Students and employees of Partido State University (PSU) who drive to campus must get a gate pass sticker. Today they submit papers by hand, wait in line, and cannot see if their application was approved, declined, or paid. The security office has no single record of who was approved, who paid, and whose sticker has expired.

## 2. Users and what they need to do

| User role | What they need to do in the app |
|-----------|---------------------------------|
| Applicant (student or employee) | Apply for a gate pass for a vehicle, upload required documents, sign, track status, fix a declined application, upload the payment receipt, see the sticker |
| Admin (security/records staff) | Review applications and documents, approve or decline with remarks, verify payments, generate and release stickers, print reports |

## 3. The database behind it
Database: `parsu_gpass` · 14 tables.

| Table | What it holds |
|-------|---------------|
| `users` | Login accounts with an email, a hashed password, a role (applicant/admin) and a status. |
| `applicant_profiles` | Personal details of each student or employee, including school ID and license number. |
| `vehicles` | Each vehicle an applicant registers: type, year model, plate number, color. |
| `applications` | One gate pass application per vehicle, with a number (GP-YYYY-NNNNNN) and a status. |
| `ownership_details` | Who owns the vehicle (own name, relative, second-hand buyer or not); decides which documents are needed. |
| `application_signatures` | The applicant's digital signature image, kept by version. |
| `document_types` | The kinds of documents the system knows (OR, CR, driver's license, deed of sale, etc.). |
| `document_requirements` | Which documents each ownership category must upload, and in what order. |
| `application_documents` | The files an applicant uploaded for an application, kept by version. |
| `application_reviews` | Each admin decision (approved or declined) with remarks. |
| `application_status_history` | A log of every status change of an application: who, when, and why. |
| `payments` | The fee (₱130 student, ₱280 employee), PSU OR number, receipt file, and verification result. |
| `gate_pass_stickers` | The sticker number, issue date, valid-until date, and status (for release, released, expired). |
| `sticker_releases` | The hand-over record: who released the sticker and who received it. |

## 4. Must-have features (for the final project)
1. Register and log in as an applicant or admin (`users`, `applicant_profiles`).
2. Add a vehicle and start a gate pass application (`vehicles`, `applications`, `ownership_details`).
3. Upload the required documents and a signature for the chosen ownership type (`document_requirements`, `application_documents`, `application_signatures`).
4. Approve or decline an application with remarks (`application_reviews`, `application_status_history`).
5. Verify a payment receipt and generate a sticker (`payments`, `gate_pass_stickers`).
6. Release a sticker and record who received it (`sticker_releases`).

## 5. Nice-to-have features (only if there's time)
- Print reports of applications, payments, released and expired stickers.
- Search and filter applications by status, name, or plate number.
- Show a notification when an application status changes.

## 6. Similar apps I looked at
- LTO LTMS portal (Philippine Land Transportation Office): borrow the step-by-step status of a request.
- Parcel tracking pages (J&T Express, Lazada): borrow the timeline that shows every status change with a date.
