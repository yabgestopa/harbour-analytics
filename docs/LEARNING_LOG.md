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

## Session 6 — 1 November 2026: Finding my way around BigQuery, billing, first draft of contacts

**What we did**
- Tried to see the "real" SQL behind `stg_xero__accounts`. `dbt compile` failed with
  *"Your default credentials were not found"*: dbt's Google login isn't saved on this laptop.
  So we filled in the `source()` placeholder by hand and got plain SQL to paste into BigQuery.
- Got a set of five "where am I?" queries to run in the BigQuery console (saved below).
- Wrote a first draft of `stg_xero__contacts` directly in BigQuery and reviewed it. It isn't
  saved as a dbt file yet.
- Checked billing on the deadline day. The project `harbour-analytics-501211` is linked to
  **"My Billing Account"**, status **Active**, $0 spent in the last 30 days. Out of Sandbox.
- Started creating a budget alert: Alerts only, NZD $5/month, emails at 50/90/100%.
- Made the rules stricter: every chat gets a learning-log entry, and console screens get
  explained, not just "click here".

**What I learned**

*BigQuery: finding my way around*
- **BigQuery is a filing cabinet.** The **project** (`harbour-analytics-501211`) is the
  cabinet. Each **dataset** is a drawer: `xero` holds the raw data Fivetran delivers, and
  `dbt_dev` holds what dbt builds. Each **table** is a folder in a drawer.
- **The five "where am I?" queries** (save them in the console with *Save → Save query*):
  1. *Which drawers exist?* `INFORMATION_SCHEMA.SCHEMATA` lists datasets.
     `INFORMATION_SCHEMA` is BigQuery's own index card system: tables that describe your tables.
  2. *What's in the `xero` drawer and how big is it?*
     `select table_id, row_count, size_bytes, last_modified_time from \`harbour-analytics-501211\`.xero.__TABLES__`
     gives one row per table with its row count. Empty tables jump out.
  3. *When did Fivetran last deliver?* `max(_fivetran_synced)` per table. `_fivetran_synced`
     is the delivery stamp Fivetran puts on every row. An old date means deliveries stopped.
  4. *Peek inside:* `select * from ... limit 20`. The **Preview** tab in the left panel does
     the same thing **for free**, because it doesn't run a query.
  5. *What has dbt built?* `dbt_dev.INFORMATION_SCHEMA.TABLES`.
- **Backticks** (`` `harbour-analytics-501211`.xero.account ``) wrap a name that has
  hyphens in it, so BigQuery doesn't read the `-` as a minus sign. It's like putting a
  long name in quotes so nobody mistakes it for two names.
- **A view vs a table.** A table stores the data. A **view** is a saved question: every time
  you open it, it runs the query again on fresh data. Like a saved Google search vs a printout.
  dbt builds staging models as views.
- **`limit` doesn't make a query cheaper in BigQuery.** BigQuery charges by how much data it
  *reads*, and it still reads the whole column first. Preview is the free way to look.

*dbt*
- **Compiling.** A dbt model has placeholders like `{{ source('xero', 'account') }}` that only
  dbt understands. *Compiling* swaps them for the real names
  (`` `harbour-analytics-501211`.`xero`.`account` ``) to make plain SQL. Like a recipe that
  says "flour from the usual cupboard": dbt knows which cupboard, BigQuery doesn't. After
  `dbt compile`, the plain SQL is in `transform/target/compiled/...`.
- **Why dbt couldn't log in.** `profiles.yml` says `method: oauth`, meaning "log in as me, Ru,
  using my Google account". That needs a saved Google login on the laptop, called
  *Application Default Credentials*, which is like a key card. It's missing or expired. Fix:
  `gcloud auth application-default login`, which opens a browser so I can sign in once.
- **Writing in the console vs writing in dbt.** Testing SQL in BigQuery first is a great way
  to try things out. But the version that counts is the `.sql` file in `transform/models/`,
  because that's what's saved in git, tested and rebuilt. Anything only in the console is
  like a note on a whiteboard: it gets wiped.
- **Reviewing my contacts draft:**
  - Use `{{ source('xero', 'contact') }}`, not the hard-coded name (same reason as session 4).
  - `merged_to_contact_id` belongs under `-- ids`. In Xero, when two duplicate contacts get
    merged, the old one points to the one it became. Like a "we've moved" sign on an old shop.
  - True/false columns (`is_supplier`, `is_customer`, `is_deleted`) get their own
    `-- flags` group, so they're easy to spot.
  - `_fivetran_deleted` → `is_deleted`: Fivetran doesn't actually remove rows that were
    deleted in Xero. It marks them, like crossing a name out instead of tearing the page out.
    In staging we **keep** those rows and just label them. Deciding to hide them comes later.
  - **Name check:** it's `stg_xero__contacts` with a **double** underscore. The double
    underscore separates the source from the thing, like the gap between surname and first name.

*Google Cloud billing*
- **Sandbox vs upgraded.** Sandbox is a library card that only lets you read in the library:
  queries work, but tables expire after 60 days and Fivetran can't load data. Upgrading
  means putting a card on file. You still only pay above the free allowance
  (1 TB of queries + 10 GB of storage each month), and this project is far below that.
- **"Linked" isn't the same as "active".** A project can be attached to a billing account
  that's paused after a free trial, like a gym membership card that's still in your wallet
  but expired. Check **Your billing accounts → Status = Active**.
- **Health checks (💡)** are Google's suggestions for your account, like a car dashboard light
  that says "tyre pressure low": not an emergency, worth a look.
- **Budgets:**
  - A **budget** is a spending limit you choose so you notice when you're near it, like
    writing down your pocket-money amount.
  - **Alerts only vs Spend cap:** an alert is a smoke alarm (it beeps, nothing stops). A spend
    cap is a sprinkler (it stops the service). Caps only work for some services, so we used
    alerts, which work everywhere.
  - **CUDs / provisioned throughput:** ways of paying ahead for a discount, like a yearly bus
    pass. Not something we use.
  - **Scope:** which projects and services the budget watches. Only `harbour-analytics`,
    so other projects don't muddy the numbers.
  - **Thresholds 50/90/100%:** emails at $2.50, $4.50 and $5. Several warnings work like a
    fuel gauge that warns you at half a tank and again near empty, not only once you've run out.
  - **Actual vs Forecasted:** *Actual* = already spent. *Forecasted* = Google's guess for the
    end of the month. Normal spend is $0, so **any** alert email means something unusual is
    running.
  - **Billing admins:** the people allowed to manage billing. That's just me, so emails go
    to my Gmail.
- **Quotas** are hard limits on one thing, like the maximum data BigQuery may scan per day
  (*IAM & Admin → Quotas → "Query usage per day"*). A budget warns, a quota blocks. Not
  needed yet.

*GitHub*
- **GitHub only saves files.** Setting up Google Cloud, BigQuery, Xero and Fivetran happened
  by clicking on their websites, so those settings live on their servers. What's in the repo
  is the *paperwork*: the commits that updated `docs/SETUP.md` (`f6ed67c`, `1377b1a`,
  `bae3876`, `9b34d76`, all on 3 July). Like the power company holding the actual
  connection while you keep the paperwork that proves it's connected.
- **The README is the book cover.** GitHub shows `README.md` under the file list on the
  repo's front page. Mine only says "Harbour Analytics", so visitors can't see what works.
- **Finding my way around github.com:** the **Code** tab shows files. The **"13 commits"**
  link lists every save point (same as `git log --oneline`). Clicking a commit shows a
  **diff**: green lines added, red lines removed, like track changes in Word. Inside a file,
  **History** shows every commit that touched just that file.
- **GitDiagram** (`gitdiagram.com/<user>/<repo>`) is a real, free tool that draws a diagram
  from a public repo's file list and README. It's an AI guess, so check it. Never give it a
  GitHub token. A hand-made Mermaid diagram in the README is better for a portfolio.
- **Visual review page:** https://claude.ai/artifact/NnZgqdjwdKDjowmdFFNqvh now has a
  "You are here" route map and a tour of the repo on GitHub.

---

## Coming up next
1. Finish the budget alert if it isn't saved yet. Check the Sandbox banner is gone in BigQuery.
2. Fix dbt's login: `gcloud auth application-default login`, then `dbt debug`.
3. Run query 3 above to see if Fivetran is still syncing. It may have paused while in Sandbox.
4. Save `stg_xero__contacts.sql` as a dbt file, document and test it in `_xero__models.yml`,
   then `dbt build -s stg_xero__contacts`.
5. Write a proper README (what it is, pipeline diagram in Mermaid, what's working, links to docs).
6. Remaining staging models: invoice, invoice_line_item, payment, bank_transaction,
   manual_journal, manual_journal_line.
7. `fct_general_ledger`, then the financial statement marts, then Power BI.
8. Commit and push.
