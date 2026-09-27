namespace enterprise;
using { cuid, managed } from '@sap/cds/common';
entity IntegrationEvents: managed { key ID: UUID; topic: String(100); aggregateID: UUID; payload: LargeString; status: String(20) default 'PENDING'; attempts: Integer default 0; nextAttemptAt: Timestamp; deliveredAt: Timestamp; }
entity Commands: managed { key requestID: String(80); orderID: UUID; actor: String(255); companyCode: String(4); response: LargeString; }
entity Incidents: cuid, managed { externalEventID: String(100); source: String(40); companyCode: String(4); service: String(100); severity: String(12); status: String(20); summary: String(300); correlationID: String(100); acknowledgedBy: String(255); }
entity MonitoringEvents: managed { key externalEventID: String(100); incident_ID: UUID; receivedAt: Timestamp; }
entity ServiceObjectives: cuid { service: String(100); targetAvailability: Decimal(6,3); maxLatencyMs: Integer; owner: String(100); }
entity AuditEvents: cuid, managed { actor: String(255); action: String(80); aggregateID: UUID; companyCode: String(4); correlationID: String(100); detail: String(300); }
entity ReconciliationRuns: cuid, managed { system: String(80); startedAt: Timestamp; finishedAt: Timestamp; expectedCount: Integer; actualCount: Integer; status: String(20); }
entity DeadLetters: cuid, managed { event: Association to IntegrationEvents; reason: String(300); resolved: Boolean default false; }
