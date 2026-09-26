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
