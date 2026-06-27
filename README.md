# BC Value Entry G/L Audit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Business Central](https://img.shields.io/badge/BC-v27+-blue.svg)](https://learn.microsoft.com/en-us/dynamics365/business-central/)

A free, MIT-licensed Business Central extension that **audits Value Entries against the G/L** — it cross-checks the accounts each inventory transaction *actually* posted to against the accounts the posting setup *says* it should have used, and flags every mismatch.

> ⭐ If this saves you time, please **star the repo** — it helps other Business Central folks find it.

---

## What it does

When inventory costs don't tie out to the G/L, finding the cause is usually a manual, painful reconciliation. This extension does it for you: for each Value Entry it derives the **expected** inventory and offset accounts from the Inventory Posting Setup and General Posting Setup, reads the **actual** accounts from the related G/L entries, and highlights any row where they differ.

- **Expected inventory account** — from `Inventory Posting Setup` (resolved by Location Code + Inventory Posting Group)
- **Expected offset account** — from `General Posting Setup`, chosen by Item Ledger Entry Type (Sale → COGS, Purchase → Direct Cost Applied, Adjmt. → Inventory Adjmt.)
- **Actual accounts** — read from `G/L - Item Ledger Relation` → `G/L Entry`
- **Mismatch** — flagged (and highlighted red) whenever expected ≠ actual

## Features

- **List page** — interactive audit view that highlights mismatched rows in red
- **Report** — *Value Entry G/L Audit* (RDLC layout) with per-row mismatch highlighting and a totals line, runnable from the Value Entries page
- **Setup page** — define an **audit horizon** (a `DateFormula` such as `-3M`) so the audit scans only a recent window instead of the full (potentially millions of rows) table
- **Scheduled run** — a recurring Job Queue Entry for out-of-hours execution
- **Email delivery** — sends the audit report (PDF attachment + summary), optionally only when mismatches are found
- **Audit Result history** — every run's findings are persisted and reviewable
- Shared audit logic in one codeunit, used by the report, list page, and scheduled job

## Scheduled audit & email

1. Open **Value Entry Audit Setup** (search by name).
2. Set the **Audit Horizon** (e.g. `-3M` to audit the last three months). Leave blank to scan all dates.
3. To receive results by email, enable **Send Email**, enter a **Recipient Email**, and optionally tick **Send Only When Mismatches Found**.
4. Choose **Run Audit Now** to run on demand, or **Schedule Recurring Audit** to create a Job Queue Entry that runs daily at 02:00.
5. Review history with **Show Results**.

> **Cloud prerequisites:** an Email Account must be configured for delivery, and the Job Queue must be enabled for scheduled runs. The user running the audit needs read access to inventory and G/L data.

## Installation

### From source

1. Clone this repo:
   ```sh
   git clone https://github.com/GmsoftLtd/bc-ValueEntryGL-Audit.git
   ```
2. Open the folder in VS Code with the AL Language extension.
3. Confirm the object ID range (default 50100-50149) doesn't conflict with your tenant.
4. Press F5 to publish to your BC sandbox, or build with **AL: Package** and upload the `.app` via **Extension Management**.

### From a packaged .app

Releases (when available) on the [Releases page](https://github.com/GmsoftLtd/bc-ValueEntryGL-Audit/releases).

## Usage

- **Interactive:** open the **Value Entry G/L Audit** list page. Rows where the posted G/L accounts differ from the expected accounts are highlighted red and flagged **Mismatch**.
- **Report:** from the **Value Entries** page choose **Run G/L Audit Report**, then review the entries flagged as a mismatch.
- **Scheduled:** configure the setup and let the Job Queue run it out-of-hours, emailing the PDF.

## Limitations

- **Two-leg heuristic** — the "actual" accounts are read as the first related G/L entry (inventory leg) and the next (offset leg). This fits standard inventory postings; entries with unusual G/L splits may need interpretation.
- **Sales/Purchase/Adjustment mapping** — the expected offset is mapped for the common Item Ledger Entry Types; other types fall back to the Direct Cost Applied account.
- **Read-only audit** — it reports discrepancies; it does not post corrections.

## More free BC tools by GMSOFT

A set of free, open-source Business Central extensions:

- [bc-safety-stock](https://github.com/GmsoftLtd/bc-safety-stock) — Z-score **safety stock** calculator (how much buffer to hold)
- [bc-eoq-calculator](https://github.com/GmsoftLtd/bc-eoq-calculator) — Wilson **EOQ** calculator (how much to order)
- [bc-reorder-point](https://github.com/GmsoftLtd/bc-reorder-point) — **reorder point** calculator (when to order)
- **bc-ValueEntryGL-Audit** — inventory-to-G/L **audit** (you are here)

## License

MIT — see [LICENSE](LICENSE).

## Author

**Grigorios Mavrogeorgis** — Director & Founder of [GMSOFT Limited](https://gmsoft.co.uk)
Microsoft Dynamics 365 Business Central Community Super User, Season 1 2026 · [Inside Business Central blog](https://insidebusinesscentral.com)
