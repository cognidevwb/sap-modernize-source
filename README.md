# SAP modernization source — structural-analysis demo

A synthetic legacy-style ABAP example for exploring a modernization candidate. This repository is a demo fixture, not an export from a running ECC system.

## Explore in CogniDev

Open this folder and choose **Understand**. Structural analysis runs automatically; no separate SAP playbook needs to be started. Open the **SAP** subsection for smaller cards covering classes, data entities, dependencies, database access, functional areas, transactions, and coverage. **Source files & tags** retains source-folder groups and parsed symbol types; functional-area inferences are labeled separately from observed facts.

- 90 ABAP source files across ten business areas.
- Examples of direct database access, including MARD and VBAK.
- 10 illustrative custom-table DDL files in `database/`. Their `.ddl` format is not consumed by the current SAP export adapter; inspect them as source files.

Inspect classes, routines, database accesses, and source links. Compare the structure with `sap-modernize-target`. SAP standard objects and omitted declarations can remain unresolved.

Analysis artifacts are generated locally and are not committed to this repository.

## Scope

This fixture does not establish a readiness percentage, Clean Core compliance score, migration effort, or runtime correctness. Those require separate assessments and SAP-system evidence. Static analysis coverage is partial.
