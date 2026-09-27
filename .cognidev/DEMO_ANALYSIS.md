# SAP demo model analysis

Generated with the existing `understand-brief` and `reading-guide` cycles using `claude-cli / sonnet`.

- 22 source-inferred use cases.
- 37 reading steps; 36 cached file tags.
- All cited files exist and all cached tag hashes match this source snapshot. No fallback tags.
- Tool hashes, evidence hashes and report hashes are recorded in [demo-analysis.json](demo-analysis.json).

## Opening a clone

Open the repository in CogniDev and choose Understand. Structural analysis rebuilds locally; the saved Use Cases and Guided Tour reports are retained. Model refreshes remain explicit.

## Interpretation

These are model-generated source interpretations, not certification, runtime validation, or proof that every described workflow is implemented. The model's wording may describe the intended ERP domain more broadly than this synthetic demo implements. An entity declaration alone does not prove an end-to-end business operation. Source references were checked for existence; semantic correctness still requires review.

Only the model report JSON and file-tag cache are committed. Structural caches, local provider logs, credentials, dependencies, and build output are excluded. The source repo contains the expanded enterprise example; the target remains the smaller ABAP/CDS comparison fixture.

## Use cases supported only by declarative citations

- Record a customer payment against an invoice
- Receive goods against a purchase order
- Inspect and disposition a supplier-delivered quality lot
- Plan and schedule production orders
- Manage warehouse tasks for picking and put-away
- Monitor open orders, stock, and incidents via control tower dashboard
- Reconcile orders against fulfillment and financial records
- Create and maintain master data records
- Maintain pricing conditions for orders
- Process a customer return
