*& Domain: Inventory Management | Component 9
CLASS zcl_inv_9 DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS: check_stock.
ENDCLASS.
CLASS zcl_inv_9 IMPLEMENTATION.
  METHOD check_stock.
    SELECT labst FROM mard WHERE matnr = '100'.
  ENDMETHOD.
ENDCLASS.
