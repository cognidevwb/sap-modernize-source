*& Domain: Inventory Management | Component 7
CLASS zcl_inv_7 DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS: check_stock.
ENDCLASS.
CLASS zcl_inv_7 IMPLEMENTATION.
  METHOD check_stock.
    SELECT labst FROM mard WHERE matnr = '100' INTO TABLE @DATA(stock).
  ENDMETHOD.
ENDCLASS.
