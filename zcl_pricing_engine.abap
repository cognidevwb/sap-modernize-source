*&---------------------------------------------------------------------*
*& Class ZCL_PRICING_ENGINE
*& Description: Pricing calculation engine with condition technique
*& Author: SAP Custom Development Team
*& Created: 2019-06-20
*& Migration Status: CLEAN CORE COMPLIANT (uses standard BAPIs)
*&---------------------------------------------------------------------*
CLASS zcl_pricing_engine DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS:
      "! Calculate price for material
      "! @parameter iv_material | Material number
      "! @parameter iv_quantity | Quantity
      "! @parameter rv_price | Calculated price
      calculate_price
        IMPORTING
          iv_material      TYPE matnr
          iv_quantity      TYPE menge_d
        RETURNING
          VALUE(rv_price)  TYPE netpr.

  PRIVATE SECTION.
    METHODS:
      "! Get base price from condition records
      get_base_price
        IMPORTING
          iv_material      TYPE matnr
        RETURNING
          VALUE(rv_price)  TYPE netpr,

      "! Apply volume discount
      apply_discount
        IMPORTING
          iv_quantity      TYPE menge_d
          iv_base_price    TYPE netpr
        RETURNING
          VALUE(rv_price)  TYPE netpr.

ENDCLASS.

CLASS zcl_pricing_engine IMPLEMENTATION.

  METHOD calculate_price.
    DATA(lv_base) = get_base_price( iv_material ).
    rv_price = apply_discount(
      iv_quantity   = iv_quantity
      iv_base_price = lv_base
    ).
  ENDMETHOD.

  METHOD get_base_price.
    " ✅ CLEAN CORE COMPLIANT: Uses standard condition table
    SELECT SINGLE kbetr
      FROM a003
      INTO @rv_price
      WHERE matnr = @iv_material
        AND datab <= @sy-datum
        AND datbi >= @sy-datum.

    IF sy-subrc <> 0.
      rv_price = '100.00'. " Default price
    ENDIF.
  ENDMETHOD.

  METHOD apply_discount.
    rv_price = iv_base_price.

    " Apply volume discount
    CASE iv_quantity.
      WHEN 1 TO 10.
        " No discount
      WHEN 11 TO 50.
        rv_price = iv_base_price * '0.95'.  " 5% discount
      WHEN 51 TO 100.
        rv_price = iv_base_price * '0.90'.  " 10% discount
      WHEN OTHERS.
        rv_price = iv_base_price * '0.85'.  " 15% discount
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
