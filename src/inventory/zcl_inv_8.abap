*& Domain: Inventory Management | Component 8
CLASS zcl_inv_8 DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS: check_stock.
ENDCLASS.
CLASS zcl_inv_8 IMPLEMENTATION.
  METHOD check_stock.
    SELECT labst FROM mard WHERE matnr = '100' INTO TABLE @DATA(stock).
  ENDMETHOD.
ENDCLASS.
