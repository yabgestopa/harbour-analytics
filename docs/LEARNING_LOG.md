# Learning Log — Harbour Analytics

What we did, what it means, and what I learned, in order. Written so a 10-year-old could
follow it. Newest entries at the bottom. Updated at the end of every working session.

> The big picture, one more time: Xero is the **shop till** where the money gets recorded.
> Fivetran is the **delivery van** that copies everything to the warehouse every so often.
> BigQuery is the **warehouse**. dbt is the **robot chef** that turns raw ingredients into
> clean, labelled meals. Power BI is the **menu board** people actually look at.

---

## Session 1 — 2 July 2026: Planning before building

**What we did**
- Created the GitHub repo and a README.
- Wrote `docs/PROJECT_BRIEF.md`: the overview, the architecture diagram, and the tools table.

**What I learned**
- **The modern data stack has layers, and each tool does one job.** Like a sandwich shop:
  someone takes orders (Xero), someone delivers ingredients (Fivetran), there's a fridge
  (BigQuery), a cook (dbt), and a menu board (Power BI). If one breaks, you know where to look.
- **ELT, not ETL.** We copy raw data into the warehouse *first* (Extract, Load), then clean it
  *inside* the warehouse (Transform). Like bringing all the groceries home before cooking,
  instead of chopping vegetables in the supermarket car park.
- **Write the plan down first.** A project brief is a map. Without it you build things you
  don't need.
- **Commit small, with clear messages.** Every commit is a save point in a video game.
  `docs:`, `chore:` and `feat:` at the start say what kind of save point it is
  (writing docs, housekeeping, or a new feature).

## Session 2 — 3 July 2026: Accounts, connections, first data

**What we did**
- Created Google Cloud project `harbour-analytics-501211`, linked billing, enabled the BigQuery API.
- Created a Xero developer app (Web app type) so Fivetran is allowed to read the Xero demo company.
- Connected Fivetran: Xero → BigQuery, into a dataset called `xero`. First sync loaded 946 rows.
- Gave Fivetran's service account only **BigQuery User + BigQuery Data Editor**.
- Added a `.gitignore` for the venv, secrets and dbt build files.
- Recorded every real setting in `docs/SETUP.md`, but never passwords or keys.

**What I learned**
- **Project ID vs project name.** The name (`harbour-analytics`) is a nickname you can change.
  The ID (`harbour-analytics-501211`) is like a passport number: permanent and unique in the world.
- **Billing must be ON even on the free tier**, or Fivetran won't connect. Like a gym that
  needs your card on file even for the free trial week.
- **OAuth / developer apps.** Instead of giving Fivetran your Xero password, Xero gives it a
  special pass that only works for reading data. Like giving the dog-walker a key that only
  opens the back gate, not your whole house. The **redirect URI** is the address Xero sends
  the pass back to.
- **Service accounts and least privilege.** A service account is a robot user. We gave it
  only the permissions it needs (read and write data), not "Editor" (change anything).
  Like giving a babysitter the fridge key, not the car keys.
- **A dataset is a folder of tables.** `xero` is a folder; `account`, `invoice` and the rest are the tables in it.
- **`.gitignore` is a "do not pack" list.** Git skips those files, so secrets (`*.json`,
  `.env`, `profiles.yml`) and junk (`target/`, `.venv/`) never reach GitHub.
- **Secrets live in a password manager, never in the repo.** The Xero client secret is in the
  password manager. `SETUP.md` only says *that* it exists.

## Session 3 — 5 July 2026: Setting up dbt

**What we did**
- Created a Python virtual environment (`.venv`) and installed `dbt-bigquery`.
- Ran `dbt init` to create the dbt project in the `transform/` folder.
- Connected dbt to BigQuery using a personal `profiles.yml`, kept outside the repo.

**What I learned**
- **A virtual environment is a lunchbox.** It keeps this project's Python tools packed
  separately, so they don't get mixed up with other projects' tools.
- **dbt Core** is free software that runs on my laptop. I write `SELECT` statements and dbt
  turns them into tables and views in BigQuery, in the right order.
- **`dbt_project.yml` vs `profiles.yml`.** The project file is the *recipe book* (what to build).
  The profile is the *key to my kitchen* (where to build it and how to log in). The recipe
  book is shared on GitHub; the key stays on my computer.
- **dbt's folders:** `models/` (the SQL recipes), `tests/`, `seeds/` (small CSVs),
  `macros/` (reusable SQL snippets), `snapshots/`, `analyses/`.

## Session 4 — 5 September 2026: First staging model

**What we did**
- Deleted dbt's example models.
- Declared the raw Xero tables as **sources** in `_xero__sources.yml`.
- Built `stg_xero__accounts.sql`: the chart of accounts, cleaned and renamed.
- Documented every column and added tests in `_xero__models.yml`.

**What I learned**
- **Sources.** Instead of hard-coding `harbour-analytics-501211.xero.account`, I write
  `{{ source('xero', 'account') }}`. It's like saving a contact in your phone instead of
  typing the number every time: if the number changes, you update it in one place.
- **The staging layer** is the "wash the vegetables" step. Each staging model maps one-to-one
  to a raw table. It only renames, recasts and tidies, with no joins and no business logic.
  Everything later builds on these clean versions, never on the raw tables.
- **Naming: `stg_xero__accounts`.** `stg` = layer, `xero` = where it came from, double
  underscore, then the thing (plural). You can tell what a model is from its name alone,
  like a library shelf label.
- **The CTE pattern** (`with source as (...), renamed as (...) select * from renamed`):
  each CTE is one clear step, like numbered steps in a recipe.
- **Renaming for humans:** `code` → `account_code`, `updated_date_utc` → `updated_at`,
  `_fivetran_synced` → `synced_at`, grouped under `-- ids`, `-- details`, `-- timestamps`.
- **Tests are smoke alarms.** `unique` + `not_null` on the primary key mean "every account
  appears exactly once". `accepted_values` on `account_class` means "only these 5 values are
  allowed: ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE". If the data breaks a rule, the alarm goes off.
- **Accounting from the data:** `account_class` decides the statement (ASSET/LIABILITY/EQUITY →
  Balance Sheet, REVENUE/EXPENSE → Profit & Loss). Archived accounts can still have history,
  so don't filter them out of balances. The chart of accounts holds *no money amounts*; those
  come from ledger lines.
- **`account_code` is not a key.** It can be blank or repeated. Join on `account_id`. Like two
  kids called Sam in a class: use the student ID, not the first name.
- **Rich descriptions are for people and AI.** Synonyms and example questions in the yml help
  anyone (or any AI tool) understand the table without asking.

## Session 5 — 10 October 2026: Rebuilding the laptop setup

**What we did**
- My SSD died. Cloned the repo from GitHub; everything that had been pushed was safe.
- Recreated what is never in git: the `.venv` (dbt Core 1.12.5, dbt-bigquery 1.12.1) and
  `~/.dbt/profiles.yml` (OAuth login, dataset `dbt_dev`, location `US`).
- Installed the Google Cloud CLI, so dbt can log in as me.
- Found out the GCP free trial ended on 2 October. The project is now in **BigQuery Sandbox**.
  **I must upgrade billing by 1 November 2026** or services may be lost.
- Added `CLAUDE.md` (project rules for Claude) and this learning log.

**What I learned**
- **GitHub is a backup, but only of what you push.** Like a cloud photo album: photos still on
  your phone that hadn't uploaded yet are gone if the phone breaks. Push often.
- **Some things are never in git on purpose** (venv, profiles, keys). Write down *how* to
  recreate them, which is what `SETUP.md` and `CLAUDE.md` are for.
- **The Google Cloud CLI (`gcloud`) is a walkie-talkie to Google's warehouse.** You type
  commands instead of clicking. `gcloud auth application-default login` gives dbt a visitor
  pass with my name on it.
- **Data location matters.** My data lives in the `US` region; dbt must be told the same
  location, like telling the delivery driver which city the warehouse is in.
- **Free trials end.** BigQuery Sandbox still lets you query for free, but loading new data
  (Fivetran) needs billing. Set a **budget alert** after upgrading so nothing surprises you.

---

## Coming up next
1. Upgrade GCP billing (before 1 Nov 2026) and set a budget alert.
2. Finish the Google login, then `dbt debug` and `dbt build` to prove the rebuild works.
3. Staging models for the rest of the sources: contact, invoice, invoice_line_item, payment,
   bank_transaction, manual_journal, manual_journal_line.
4. `fct_general_ledger`, then the financial statement marts, then Power BI.
