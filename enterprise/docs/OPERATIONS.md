# Operating and qualifying the sample

## Locally reproducible

Node 22 or newer. From `enterprise/`:

```sh
npm ci
npm test
npm run check:model
npm run build
npm start
```

The development profile uses an in-memory SQLite database and synthetic CSV data. It provides mock identities `planner` and `operator`; use the generated service index to inspect available endpoints. The Fiori entry point is `/controltower/webapp/index.html`. Assign the Viewer role alongside Planner for order reads, and the correct companyCode attribute. Production uses XSUAA and HANA bindings instead of mock identities.

## Deployment configuration

`mta.yaml` describes CAP server, transactional HDI deployer, native analytics HDI deployer, and app router. Supply XSUAA role assignments and company attributes. Review plans, quotas, network controls, OAuth destinations and retention for the target subaccount. Build output goes into `dist/`, which is excluded from source analysis to avoid counting generated tables twice.

## Qualification still required

- Deploy and execute native SQLScript in the intended HANA Cloud revision; validate query plans, contention and isolation.
- Activate ABAP/DDIC/CDS/DCL/service objects in a matching SAP system and run ATC/ABAP Unit.
- Validate actual S/4 released APIs and migration constraints for the target product release.
- Configure and export executable Integration Suite flows; validate Cloud ALM webhook mappings and OAuth bindings.
- Validate Fiori interaction, XSUAA role assignments and HTTP authentication with a live identity provider.
- Add durable outbox worker scheduling, transport bindings and operational reconciliation. The provided worker helper is single-worker and at-least-once.
- Exercise load, disaster recovery, backups, secret rotation, audit retention and data residency controls.

The local tests establish business-rule and transaction behavior on SQLite; they do not certify HANA runtime performance, SAP activation, compliance, or enterprise production readiness.
