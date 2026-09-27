*& Domain: Inventory Management | Component 3
CLASS zcl_inv_3 DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS: check_stock.
ENDCLASS.
CLASS zcl_inv_3 IMPLEMENTATION.
  METHOD check_stock.
    SELECT labst FROM mard WHERE matnr = '100' INTO TABLE @DATA(stock).
  ENDMETHOD.
ENDCLASS.
