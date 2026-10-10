# Harbour Analytics

Portfolio analytics-engineering project: Xero demo company -> Fivetran -> BigQuery -> dbt -> Power BI.
See `docs/PROJECT_BRIEF.md` (goals, architecture) and `docs/SETUP.md` (real config values).

## Working style

The project is being built by hand to learn the stack. Explain and guide; propose one
model/file at a time and let the user drive. Don't bulk-generate models.

## Rules

- **Explain everything like I'm 10.** Every new tool, concept, command or decision gets a
  plain-language explanation with a concrete example or everyday analogy. No unexplained jargon.
- **Always follow best practice.** When there's a choice, pick the industry best practice,
  say what it is and why in one or two lines, and go with it rather than asking.
- **Keep the learning log.** `docs/LEARNING_LOG.md` is the record of everything done and
  learned. At the end of each session (or when asked), add a dated entry: "What we did" +
  "What I learned" (in the explain-like-I'm-10 style), and update "Coming up next".
- **Rundown requests.** When asked for a rundown, recap or review, read
  `docs/LEARNING_LOG.md` (plus `git log` for anything newer) and give a review that includes:
  - **Visuals**: diagrams of the pipeline (Xero → Fivetran → BigQuery → dbt → Power BI),
    the dbt layers and model lineage, drawn as text diagrams in the terminal. Offer a
    visual web page (Artifact) version for a richer view.
  - **The code**: show the actual files written so far (e.g. `stg_xero__accounts.sql`,
    the source and model yml) and walk through them line by line in plain language.
  - **Concepts** session by session, with the analogies from the log.
  - Finish by offering to quiz me.
- **Push often.** Remind me to commit and push at the end of each session. Work that only
  lives on the laptop isn't backed up.

## Layout

- `transform/` — the dbt project (project + profile name: `transform`)
- `transform/models/staging/xero/` — sources (`_xero__sources.yml`), model docs/tests
  (`_xero__models.yml`), and `stg_xero__<entity>.sql` models
- `.venv/` at repo root (gitignored) — Python env with `dbt-bigquery`

## Environment

- GCP project: `harbour-analytics-501211`; raw Fivetran data in dataset `xero`
- dbt Core 1.12 / dbt-bigquery 1.12 (uses `data_tests:` and `accepted_values: arguments:` syntax)
- `profiles.yml` lives in `~/.dbt/` and is never committed (nor any `*.json` keyfile)

## Commands (run from `transform/`)

```
..\.venv\Scripts\Activate.ps1
dbt debug
dbt build                       # run + test everything
dbt build -s stg_xero__accounts # one model
```

## Conventions

- Staging: one model per source table, `with source as (...), renamed as (...) select * from renamed`
- Columns grouped with comments: `-- ids`, `-- details`, `-- amounts`, `-- timestamps`
- Rename `_fivetran_synced` -> `synced_at`, `updated_date_utc` -> `updated_at`
- Every model documented in the yml with rich, agent-friendly descriptions; PKs tested `unique` + `not_null`
- Commit messages: conventional commits (`feat:`, `docs:`, `chore:`)

## Progress

- Full history: `docs/LEARNING_LOG.md`
- **GCP free trial ended 2026-10-02; project is in BigQuery Sandbox. Billing must be upgraded
  by 2026-11-01.** Remind me until it's done.
- Done: GCP + BigQuery, Xero app, Fivetran sync (first sync 2026-07-03), dbt init, `stg_xero__accounts`
- Next: remaining staging models for the declared sources (contact, invoice, invoice_line_item,
  payment, bank_transaction, manual_journal, manual_journal_line), then `fct_general_ledger`
  and financial-statement marts
