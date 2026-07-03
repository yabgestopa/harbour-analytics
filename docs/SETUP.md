# Setup Notes — Harbour Analytics

Real configuration values recorded here as we create accounts.
This file is safe to commit — no secrets, passwords, or keys ever go here.

## Google Cloud

- Project name: harbour-analytics
- Project ID: harbour-analytics-501211
- Billing account: "My Billing Account" (free trial)
- Billing confirmed linked to this project: yes (checked via
  Billing > Account management > Projects linked to this billing account)
- Trial credit: NZ$530, expires 2 October 2026
- Currency note: billing shown in NZD, not USD
- BigQuery API: enabled and confirmed (query editor loads successfully)

## Xero Developer App

- App name: harbour-analytics
- Integration type: Web app
- Company/application URL: https://github.com/yabgestopa/harbour-analytics
- Redirect URI: https://fivetran.com/integrations/xero/oauth2/return
- Client ID and Client Secret: generated, stored in password manager
  (NEVER recorded in this repo)
- Note: Fivetran's current guidance recommends "Custom connection" as the
  primary auth method for AU/NZ/UK/US orgs, but Web app is still fully
  supported and is what we used here.

  ## Fivetran → BigQuery Sync

- Connection: xero → BigQuery, destination schema "xero"
- Authentication: Web app (works for NZ org; Fivetran recommends
  Custom connection as the primary method for AU/NZ/UK/US, but Web app
  is fully supported — noted as a known, accepted tradeoff)
- Service account granted: BigQuery User + BigQuery Data Editor
  (least-privilege, not Editor)
- First sync: 3 July 2026, successful historical sync, 946 rows loaded
- Confirmed in BigQuery console: xero dataset with real tables
  (account, allocation, asset, bank_transaction, etc.) and real rows
- 2 minor warnings noted (tables excluded, custom connection recommended)
  — both non-blocking, documented here rather than actioned