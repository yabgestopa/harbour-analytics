# Project Brief — Harbour Analytics

## 1. Overview

An end-to-end analytics engineering portfolio project: real accounting data
ingested from Xero, landed in BigQuery via Fivetran, modelled into a tested
General Ledger and financial statements using dbt, and reported in Power BI.

Built by hand, one command and one file at a time, to genuinely learn the
modern data stack rather than have it generated.

## 2. Architecture

Xero (accounting software, holds the real data)
   |
   |  Fivetran — a tool that automatically copies data on a schedule
   v
BigQuery (the warehouse — a database in the cloud, holds the raw copy)
   |
   |  dbt — SQL that cleans, joins, and organises the raw data
   v
BigQuery again (this time: clean, tested, trustworthy tables)
   |
   |  connect directly
   v
Power BI (the report you actually look at)

## 3. Tools & Accounts

| Tool | What it is | Plan we're using | Why |
|---|---|---|---|
| Xero | Accounting software | Free demo company | Comes pre-loaded with realistic data — no need to create our own |
| Fivetran | Copies data from Xero into BigQuery automatically | Free plan | Free tier easily covers our small data volume |
| Google BigQuery | Cloud data warehouse — stores the data | Free tier, billing enabled | Free tier is generous; billing must be *on* even though we won't be charged, or Fivetran refuses to connect |
| dbt Core | Turns raw data into clean, tested tables using SQL | Free, open-source, run on our own laptop | No cost, and running it locally means we see everything happen |
| Power BI | Builds the report/dashboard | Power BI Desktop, free | Already familiar to us — just pointed at new data |
