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
