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
