*& Domain: Inventory Management | Component 4
CLASS zcl_inv_4 DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS: check_stock.
ENDCLASS.
CLASS zcl_inv_4 IMPLEMENTATION.
  METHOD check_stock.
    SELECT labst FROM mard WHERE matnr = '100' INTO TABLE @DATA(stock).
  ENDMETHOD.
ENDCLASS.
