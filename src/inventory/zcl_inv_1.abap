*& Domain: Inventory Management | Component 1
CLASS zcl_inv_1 DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS: check_stock.
ENDCLASS.
CLASS zcl_inv_1 IMPLEMENTATION.
  METHOD check_stock.
    SELECT labst FROM mard WHERE matnr = '100'.
  ENDMETHOD.
ENDCLASS.
