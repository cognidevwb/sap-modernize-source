namespace enterprise;
using { cuid, managed } from '@sap/cds/common';
using { enterprise.Materials, enterprise.Plants, enterprise.Suppliers } from './master';
using { enterprise.SalesOrders } from './sales';
entity Stock: managed { key material_ID: UUID; key plantCode: String(4); companyCode: String(4) not null; available: Integer; reserved: Integer default 0; revision: Integer default 0; }
entity Reservations: cuid, managed { order: Association to SalesOrders; material: Association to Materials; plantCode: String(4); quantity: Integer; status: String(20); }
entity PurchaseOrders: cuid, managed { supplier: Association to Suppliers; companyCode: String(4); status: String(20); currency: String(3); total: Decimal(15,2); items: Composition of many PurchaseOrderItems on items.order = $self; }
entity PurchaseOrderItems: cuid { order: Association to PurchaseOrders; material: Association to Materials; plant: Association to Plants; quantity: Integer; unitPrice: Decimal(15,2); dueDate: Date; }
entity GoodsReceipts: cuid, managed { purchaseOrder: Association to PurchaseOrders; material: Association to Materials; plantCode: String(4); quantity: Integer; batch: String(40); inspection: Association to QualityLots; }
entity QualityLots: cuid, managed { material: Association to Materials; batch: String(40); status: String(20); sampled: Integer; defective: Integer; disposition: String(30); findings: Composition of many QualityFindings on findings.lot = $self; }
entity QualityFindings: cuid { lot: Association to QualityLots; characteristic: String(80); measured: Decimal(15,4); lowerBound: Decimal(15,4); upperBound: Decimal(15,4); passed: Boolean; }
entity ProductionOrders: cuid, managed { material: Association to Materials; plant: Association to Plants; quantity: Integer; status: String(20); plannedStart: Timestamp; plannedEnd: Timestamp; }
entity BillsOfMaterial: cuid { parent: Association to Materials; component: Association to Materials; quantity: Decimal(15,4); validFrom: Date; validTo: Date; }
entity WarehouseTasks: cuid, managed { reservation: Association to Reservations; sourceBin: String(30); targetBin: String(30); status: String(20); assignedTo: String(80); }
