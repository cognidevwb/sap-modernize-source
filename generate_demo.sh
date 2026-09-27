#!/bin/bash
# Generate comprehensive SAP ECC demo with 100 files

set -e

BASE="/Users/rajasekharkarawalla/cognidev-workbench/sap-modernize-source"
cd "$BASE"

# Order-to-Cash domain (15 files)
cat > src/order_to_cash/zcl_sales_order.abap << 'EOF'
*&---------------------------------------------------------------------*
*& Class ZCL_SALES_ORDER
*& Domain: Order-to-Cash | Criticality: CRITICAL | Clean Core: 30%
*&---------------------------------------------------------------------*
CLASS zcl_sales_order DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS: create_order IMPORTING iv_customer TYPE kunnr
                          RETURNING VALUE(rv_order) TYPE vbeln,
             get_order_status IMPORTING iv_order TYPE vbeln
                             RETURNING VALUE(rv_status) TYPE char10,
             cancel_order IMPORTING iv_order TYPE vbeln.
  PRIVATE SECTION.
    DATA: mv_sales_org TYPE vkorg.
ENDCLASS.

CLASS zcl_sales_order IMPLEMENTATION.
  METHOD create_order.
    " ❌ Clean Core Violation: Direct INSERT
    INSERT INTO zorders VALUES @( VALUE #( order_num = rv_order customer = iv_customer ) ).
  ENDMETHOD.

  METHOD get_order_status.
    " ❌ Direct SELECT
    SELECT SINGLE status FROM vbak INTO rv_status WHERE vbeln = iv_order.
  ENDMETHOD.

  METHOD cancel_order.
    UPDATE vbak SET abstk = 'X' WHERE vbeln = iv_order.
  ENDMETHOD.
ENDCLASS.
EOF

cat > src/order_to_cash/zcl_billing.abap << 'EOF'
*& Domain: Order-to-Cash | Sub: Billing | Criticality: HIGH
CLASS zcl_billing DEFINITION PUBLIC FINAL.
  PUBLIC SECTION.
    METHODS: create_invoice IMPORTING it_items TYPE tt_items
                           RETURNING VALUE(rv_invoice) TYPE vbeln_vf,
             post_to_fi IMPORTING iv_invoice TYPE vbeln_vf.
ENDCLASS.

CLASS zcl_billing IMPLEMENTATION.
  METHOD create_invoice.
    " ❌ Should use BAPI_BILLINGDOC_CREATEFROMDATA
    INSERT INTO vbrk VALUES @( VALUE #( vbeln = rv_invoice ) ).
  ENDMETHOD.

  METHOD post_to_fi.
    " ❌ Direct FI posting
    INSERT INTO bkpf VALUES @( VALUE #( belnr = iv_invoice ) ).
  ENDMETHOD.
ENDCLASS.
EOF

# Generate 13 more O2C files
for i in {1..13}; do
  cat > "src/order_to_cash/zcl_o2c_${i}.abap" << EOF
*& Order-to-Cash Component ${i}
CLASS zcl_o2c_${i} DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS: process.
ENDCLASS.
CLASS zcl_o2c_${i} IMPLEMENTATION.
  METHOD process.
    " Business logic ${i}
  ENDMETHOD.
ENDCLASS.
EOF
done

# Procure-to-Pay (15 files)
cat > src/procure_to_pay/zcl_purchase_order.abap << 'EOF'
*& Domain: Procure-to-Pay | Criticality: CRITICAL
CLASS zcl_purchase_order DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS: create_po IMPORTING iv_vendor TYPE lifnr,
             approve_po IMPORTING iv_po TYPE ebeln.
ENDCLASS.
CLASS zcl_purchase_order IMPLEMENTATION.
  METHOD create_po.
    INSERT INTO ekko VALUES @( VALUE #( ebeln = sy-datum lifnr = iv_vendor ) ).
  ENDMETHOD.
  METHOD approve_po.
    UPDATE ekko SET frgke = 'A' WHERE ebeln = iv_po.
  ENDMETHOD.
ENDCLASS.
EOF

for i in {1..14}; do
  cat > "src/procure_to_pay/zcl_p2p_${i}.abap" << EOF
*& Procure-to-Pay Component ${i}
CLASS zcl_p2p_${i} DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS: execute.
ENDCLASS.
CLASS zcl_p2p_${i} IMPLEMENTATION.
  METHOD execute.
  ENDMETHOD.
ENDCLASS.
EOF
done

# Finance (10 files)
for i in {1..10}; do
  cat > "src/finance/zcl_fi_${i}.abap" << EOF
*& Domain: Financial Accounting | Component ${i}
CLASS zcl_fi_${i} DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS: post_document.
ENDCLASS.
CLASS zcl_fi_${i} IMPLEMENTATION.
  METHOD post_document.
    " FI posting logic
  ENDMETHOD.
ENDCLASS.
EOF
done

# Inventory (10 files)
for i in {1..10}; do
  cat > "src/inventory/zcl_inv_${i}.abap" << EOF
*& Domain: Inventory Management | Component ${i}
CLASS zcl_inv_${i} DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS: check_stock.
ENDCLASS.
CLASS zcl_inv_${i} IMPLEMENTATION.
  METHOD check_stock.
    SELECT labst FROM mard WHERE matnr = '100' INTO TABLE @DATA(stock).
  ENDMETHOD.
ENDCLASS.
EOF
done

# Master Data (8 files)
for i in {1..8}; do
  cat > "src/master_data/zcl_md_${i}.abap" << EOF
*& Domain: Master Data | Component ${i}
CLASS zcl_md_${i} DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS: maintain_master.
ENDCLASS.
CLASS zcl_md_${i} IMPLEMENTATION.
  METHOD maintain_master.
  ENDMETHOD.
ENDCLASS.
EOF
done

# Pricing (7 files)
for i in {1..7}; do
  cat > "src/pricing/zcl_price_${i}.abap" << EOF
*& Domain: Pricing & Conditions | Component ${i}
CLASS zcl_price_${i} DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS: calculate_price.
ENDCLASS.
CLASS zcl_price_${i} IMPLEMENTATION.
  METHOD calculate_price.
  ENDMETHOD.
ENDCLASS.
EOF
done

# Logistics (7 files)
for i in {1..7}; do
  cat > "src/logistics/zcl_log_${i}.abap" << EOF
*& Domain: Shipping & Logistics | Component ${i}
CLASS zcl_log_${i} DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS: ship_goods.
ENDCLASS.
CLASS zcl_log_${i} IMPLEMENTATION.
  METHOD ship_goods.
  ENDMETHOD.
ENDCLASS.
EOF
done

# Production (5 files)
for i in {1..5}; do
  cat > "src/production/zcl_pp_${i}.abap" << EOF
*& Domain: Production Planning | Component ${i}
CLASS zcl_pp_${i} DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS: plan_production.
ENDCLASS.
CLASS zcl_pp_${i} IMPLEMENTATION.
  METHOD plan_production.
  ENDMETHOD.
ENDCLASS.
EOF
done

# Quality (5 files)
for i in {1..5}; do
  cat > "src/quality/zcl_qm_${i}.abap" << EOF
*& Domain: Quality Management | Component ${i}
CLASS zcl_qm_${i} DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS: quality_check.
ENDCLASS.
CLASS zcl_qm_${i} IMPLEMENTATION.
  METHOD quality_check.
  ENDMETHOD.
ENDCLASS.
EOF
done

# Cross-cutting (8 files)
for i in {1..8}; do
  cat > "src/cross_cutting/zcl_util_${i}.abap" << EOF
*& Cross-Cutting: Utilities | Component ${i}
CLASS zcl_util_${i} DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS: utility_function.
ENDCLASS.
CLASS zcl_util_${i} IMPLEMENTATION.
  METHOD utility_function.
  ENDMETHOD.
ENDCLASS.
EOF
done

# Database tables (10 files)
for i in {1..10}; do
  cat > "database/ztable_${i}.ddl" << EOF
@EndUserText.label : 'Custom Table ${i}'
@AbapCatalog.enhancementCategory : #NOT_EXTENSIBLE
define table ztable_${i} {
  key id : abap.char(10);
  field1 : abap.char(40);
  field2 : abap.dec(15,2);
}
EOF
done

echo "Generated 100 SAP files successfully!"
