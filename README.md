# SAP modernization — expanded enterprise source

Open **this folder** in CogniDev, choose **Understand it → SAP**, and explore the detail cards. Use **Re-analyze** if it is already open.

The original 90-file ABAP fixture remains in `src/`. The new `enterprise/` application adds:

- 36 business entities spanning sales, inventory, procurement, manufacturing, quality, finance, and operations.
- Three CAP services with atomic order release, stock/credit reservation, idempotency, finance posting, audit evidence, event outbox and normalized Cloud ALM incident handling.
- Native HANA tables, joined analytical views, SQLScript functions/procedures, HDI configuration and an analyst role.
- ABAP classes, DDIC tables/domain/data element, authorization checks, transactions, scheduled jobs, CDS projection, DCL and an OData V4 service definition/binding.
- BTP MTA/XSUAA/app-router descriptors, Fiori elements source, and three branching Integration Suite design flows.
- Executable local tests, synthetic master data, architecture and operational documentation.

## Run the core

```sh
cd enterprise
npm ci
npm test
npm run check:model
npm run build
npm start
```

Dependencies are pinned to registry versions verified on 2026-09-26. No external SAP credentials are included.

This is an enterprise-oriented reference application with a locally tested core. Live HANA execution, ABAP activation, Fiori/identity-provider integration and deployment qualification still require your SAP environment. Integration flow files are explicitly non-executable designs. See `enterprise/docs/OPERATIONS.md` and `enterprise/docs/SOURCES.md`.

The original ABAP fixture remains under `src/` for comparison with the enterprise additions.

## Model-generated demo reports

The existing **Use Cases** and **Guided Tour** cycles were run with Claude Sonnet. Open Understand to load the saved views; structural analysis rebuilds locally. See [.cognidev/DEMO_ANALYSIS.md](.cognidev/DEMO_ANALYSIS.md) for provenance, validation and interpretation limits. These are source-inferred reports, not proof of deployed functionality.
