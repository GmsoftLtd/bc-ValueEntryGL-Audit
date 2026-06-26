# Value Entry G/L Audit for Business Central

This AL extension for Microsoft Dynamics 365 Business Central (v27+) provides an audit report for verifying whether each Value Entry has been correctly posted to the expected General Ledger (G/L) accounts, based on inventory and general posting group setup.

## Features
- Report: **Value Entry G/L Audit** (ID: 50100)
- List page: **Value Entry G/L Audit** (ID: 50102) — interactive view that highlights mismatched rows in red
- Extension to the **Value Entries** page (ID: 5802) with an action to run the audit
- Shared audit logic in codeunit **Value Entry Audit Mgt.** (ID: 50103), used everywhere
- **Setup page** (ID: 50106) to define the audit horizon (a `DateFormula` such as `-3M`) so the audit scans only a recent window instead of the full table
- **Scheduled run** via a recurring Job Queue Entry (codeunit **Value Entry Audit Job**, ID: 50108) for out-of-hours execution
- **Email delivery** of the audit report (PDF attachment + summary) using the built-in Email module
- **Audit Result** history table (ID: 50105) and results page (ID: 50107) so findings are persisted and reviewable
- Permission set: **Value Entry Audit** (ID: 50100)
- Cross-references:
  - `Value Entry`
  - `Inventory Posting Setup` (resolved by Location Code + Inventory Posting Group)
  - `General Posting Setup`
  - `G/L - Item Ledger Relation`
  - `G/L Entry`
- Highlights mismatches between expected and actual G/L accounts

## Scheduled audit & email
1. Open **Value Entry Audit Setup** (search by name).
2. Set the **Audit Horizon** (e.g. `-3M` to audit the last three months). Leave blank to scan all dates.
3. To receive results by email, enable **Send Email**, enter a **Recipient Email**, and optionally tick **Send Only When Mismatches Found**.
4. Choose **Run Audit Now** to run on demand, or **Schedule Recurring Audit** to create a Job Queue Entry that runs daily at 02:00.
5. Review history with **Show Results**.

> **Cloud prerequisites:** an Email Account must be configured (Email Accounts) for delivery, and the Job Queue must be enabled for scheduled runs. The user running the audit needs read access to inventory and G/L data.

## Installation
1. Clone this repository:
   ```sh
   git clone https://github.com/youraccount/ValueEntryAudit.git
   ```
2. Open the folder in Visual Studio Code.
3. Make sure your `launch.json` and `app.json` are properly configured.
4. Publish the extension to your Business Central sandbox.

## Usage
- **Interactive:** open the **Value Entry G/L Audit** list page (search by name). Rows where the posted G/L accounts differ from the expected accounts are highlighted in red and flagged with **Mismatch**.
- **Report:** from the **Value Entries** page, choose the **Run G/L Audit Report** action, then review the entries flagged as a **Mismatch**.

## License
MIT
