# PARSU-GPass: Online Vehicle Gate Pass Management System

Partido State University (PSU) vehicle gate pass.
Web Systems 1 · Final project, based on our Database (IM1) project.

Members: Danreb R. Palaypayon, Carl Andrie D. Torrecampo

## About the project
Students and employees of PSU who drive to campus need a gate pass sticker. PARSU-GPass lets them apply online, upload their documents, pay the fee, and track the status of their application. It gives the security office one record of who was approved, who paid, and whose sticker has expired.

## Users
| Role | What they do |
|------|--------------|
| Applicant (student or employee) | Register, apply for a gate pass, upload documents and a signature, track the status, fix a declined application, upload the payment receipt, view the sticker |
| Admin (security and records staff) | Review applications and documents, approve or decline with remarks, verify payments, generate and release stickers, print reports |

## Main features
1. Register and log in as an applicant or admin
2. Add a vehicle and start a gate pass application
3. Upload the required documents and a signature
4. Approve or decline an application with remarks
5. Verify a payment receipt and generate a sticker
6. Release a sticker and record who received it

## Folders
- `database/` : `schema.sql` (14 tables) and `seed.sql` (sample data)
- `docs/` : brief, CRUD map, sitemap, user flow, wireframes, style guide, screenshots
- `prototype/` : static HTML/CSS pages (Week 14), later PHP (Week 15+)
  - `list.html` : Registered Applicants list (admin)
  - `form.html` : Register form
  - `css/style.css` : shared styles, starting with the style guide variables

## Database
Database name: `parsu_gpass`. To set it up, import `database/schema.sql` first, then `database/seed.sql`.

## How to view the prototype
Open `prototype/list.html` in a browser. The pages are static, so no server or database is needed yet. Use the browser's device toolbar at 390 px to see the phone layout.

## Progress
- [x] Week 14: brief, CRUD map, sitemap, wireframes, style guide, static pages
- [ ] Week 15 and later: PHP and database connection
