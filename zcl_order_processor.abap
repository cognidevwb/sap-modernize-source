*&---------------------------------------------------------------------*
*& Class ZCL_ORDER_PROCESSOR
*& Description: Sales order processing with Clean Core violations
*& Author: SAP Custom Development Team
*& Created: 2018-03-15
*& Migration Status: NEEDS S/4HANA CLEAN CORE COMPLIANCE
*&---------------------------------------------------------------------*
CLASS zcl_order_processor DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_order_item,
        material   TYPE matnr,
        quantity   TYPE menge_d,
        unit       TYPE meins,
        net_price  TYPE netpr,
        plant      TYPE werks_d,
      END OF ty_order_item,
      tt_order_items TYPE STANDARD TABLE OF ty_order_item WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_order_header,
        order_type      TYPE auart,
        sales_org       TYPE vkorg,
        distr_channel   TYPE vtweg,
        division        TYPE spart,
        customer_id     TYPE kunnr,
        po_number       TYPE bstkd,
        requested_date  TYPE edatu,
      END OF ty_order_header.

    TYPES:
      BEGIN OF ty_order_result,
        order_number TYPE vbeln,
        success      TYPE abap_bool,
        message      TYPE string,
        net_value    TYPE netwr,
      END OF ty_order_result.

    METHODS:
      "! Create sales order
      "! @parameter iv_header | Order header data
      "! @parameter it_items | Order line items
      "! @parameter rs_result | Created order number and status
      create_order
        IMPORTING
          iv_header         TYPE ty_order_header
          it_items          TYPE tt_order_items
        RETURNING
          VALUE(rs_result)  TYPE ty_order_result,

      "! Get order details
      "! @parameter iv_order_number | Sales order number
      "! @parameter rs_order | Order details
      get_order_details
        IMPORTING
          iv_order_number   TYPE vbeln
        RETURNING
          VALUE(rs_order)   TYPE ty_order_result,

      "! Calculate order total
      "! @parameter it_items | Order items
      "! @parameter rv_total | Total order value
      calculate_total
        IMPORTING
          it_items         TYPE tt_order_items
        RETURNING
          VALUE(rv_total)  TYPE netwr.

  PRIVATE SECTION.
    DATA:
      mv_sales_org TYPE vkorg,
      mo_pricing   TYPE REF TO zcl_pricing_engine,
      mo_validator TYPE REF TO data.

    METHODS:
      "! Validate order before creation
      validate_order
        IMPORTING
          iv_header        TYPE ty_order_header
          it_items         TYPE tt_order_items
        RETURNING
          VALUE(rv_valid)  TYPE abap_bool,

      "! Apply pricing logic
      apply_pricing
        IMPORTING
          it_items              TYPE tt_order_items
        RETURNING
          VALUE(rt_priced_items) TYPE tt_order_items,

      "! Check inventory availability
      check_availability
        IMPORTING
          iv_material         TYPE matnr
          iv_plant            TYPE werks_d
          iv_quantity         TYPE menge_d
        RETURNING
          VALUE(rv_available) TYPE abap_bool.

ENDCLASS.

CLASS zcl_order_processor IMPLEMENTATION.

  METHOD create_order.
    DATA:
      lv_valid       TYPE abap_bool,
      lt_priced_items TYPE tt_order_items,
      lv_total        TYPE netwr,
      lv_order_num    TYPE vbeln.

    CLEAR rs_result.

    " Step 1: Validate order
    lv_valid = validate_order(
      iv_header = iv_header
      it_items  = it_items
    ).

    IF lv_valid = abap_false.
      rs_result-success = abap_false.
      rs_result-message = 'Order validation failed'.
      RETURN.
    ENDIF.

    " Step 2: Apply pricing
    lt_priced_items = apply_pricing( it_items ).

    " Step 3: Calculate total
    lv_total = calculate_total( lt_priced_items ).

    " Step 4: Create order in SAP
    " ⚠️ CLEAN CORE VIOLATION: Direct database INSERT
    " SIMPLIFICATION ITEM SI-0001: Use BAPI_SALESORDER_CREATEFROMDAT2 instead
    TRY.
        lv_order_num = |SO{ sy-datum }{ sy-uzeit }|.

        INSERT INTO zorders VALUES @(
          VALUE #(
            order_number  = lv_order_num
            customer_id   = iv_header-customer_id
            order_type    = iv_header-order_type
            sales_org     = iv_header-sales_org
            created_date  = sy-datum
            created_time  = sy-uzeit
            created_by    = sy-uname
            net_value     = lv_total
            status        = 'NEW'
          )
        ).

        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
          rs_result-order_number = lv_order_num.
          rs_result-success = abap_true.
          rs_result-net_value = lv_total.
          rs_result-message = |Order { lv_order_num } created successfully|.
        ELSE.
          ROLLBACK WORK.
          rs_result-success = abap_false.
          rs_result-message = 'Database insert failed'.
        ENDIF.

      CATCH cx_sy_dynamic_osql_error INTO DATA(lx_error).
        rs_result-success = abap_false.
        rs_result-message = lx_error->get_text( ).
    ENDTRY.

  ENDMETHOD.

  METHOD get_order_details.
    " ⚠️ CLEAN CORE VIOLATION: Direct SELECT from custom table
    " RECOMMENDATION: Expose via OData service for external consumption
    SELECT SINGLE
      order_number,
      customer_id,
      net_value,
      status
    FROM zorders
    INTO @DATA(ls_order)
    WHERE order_number = @iv_order_number.

    IF sy-subrc = 0.
      rs_order-order_number = ls_order-order_number.
      rs_order-net_value = ls_order-net_value.
      rs_order-success = abap_true.
      rs_order-message = 'Order found'.
    ELSE.
      rs_order-success = abap_false.
      rs_order-message = 'Order not found'.
    ENDIF.
  ENDMETHOD.

  METHOD calculate_total.
    CLEAR rv_total.

    LOOP AT it_items INTO DATA(ls_item).
      rv_total = rv_total + ( ls_item-quantity * ls_item-net_price ).
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_order.
    rv_valid = abap_true.

    " Validate header
    IF iv_header-customer_id IS INITIAL.
      rv_valid = abap_false.
      RETURN.
    ENDIF.

    IF iv_header-sales_org IS INITIAL.
      rv_valid = abap_false.
      RETURN.
    ENDIF.

    " Validate items
    IF it_items IS INITIAL.
      rv_valid = abap_false.
      RETURN.
    ENDIF.

    " Check stock availability for each item
    LOOP AT it_items INTO DATA(ls_item).
      DATA(lv_available) = check_availability(
        iv_material = ls_item-material
        iv_plant    = ls_item-plant
        iv_quantity = ls_item-quantity
      ).

      IF lv_available = abap_false.
        rv_valid = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD apply_pricing.
    rt_priced_items = it_items.

    " Create pricing engine instance
    IF mo_pricing IS NOT BOUND.
      CREATE OBJECT mo_pricing.
    ENDIF.

    " Apply pricing to each item
    LOOP AT rt_priced_items ASSIGNING FIELD-SYMBOL(<fs_item>).
      <fs_item>-net_price = mo_pricing->calculate_price(
        iv_material = <fs_item>-material
        iv_quantity = <fs_item>-quantity
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD check_availability.
    " ⚠️ CLEAN CORE VIOLATION: Direct access to MARD table
    " SIMPLIFICATION ITEM SI-0342: Use ATP check BAPI instead
    " RECOMMENDATION: Call external Inventory microservice via API
    SELECT SINGLE labst
      FROM mard
      INTO @DATA(lv_stock)
      WHERE matnr = @iv_material
        AND werks = @iv_plant.

    IF sy-subrc = 0 AND lv_stock >= iv_quantity.
      rv_available = abap_true.
    ELSE.
      rv_available = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
