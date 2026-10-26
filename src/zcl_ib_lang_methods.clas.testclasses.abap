*"* use this source file for your ABAP unit test classes
CLASS ltc_methods DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_ib_lang_methods.

    METHODS setup.
    METHODS gross_uses_default_rate FOR TESTING.
    METHODS min_max_of_list FOR TESTING.
    METHODS increment_default_step FOR TESTING.
    METHODS divide_by_zero_returns_zero FOR TESTING.
ENDCLASS.


CLASS ltc_methods IMPLEMENTATION.

  METHOD setup.
    cut = NEW #( ).
  ENDMETHOD.


  METHOD gross_uses_default_rate.
    cl_abap_unit_assert=>assert_equals( act = cut->gross_amount( '200.00' )
                                        exp = CONV zcl_ib_lang_methods=>ty_amount( '220.00' ) ).
  ENDMETHOD.


  METHOD min_max_of_list.
    cut->min_max( EXPORTING numbers = VALUE #( ( `5` ) ( `-2` ) ( `9` ) )
                  IMPORTING minimum = DATA(low)
                            maximum = DATA(high) ).

    cl_abap_unit_assert=>assert_equals( act = low  exp = -2 ).
    cl_abap_unit_assert=>assert_equals( act = high exp = 9 ).
  ENDMETHOD.


  METHOD increment_default_step.
    DATA(counter) = 10.

    cut->increment( CHANGING counter = counter ).

    cl_abap_unit_assert=>assert_equals( act = counter exp = 11 ).
  ENDMETHOD.


  METHOD divide_by_zero_returns_zero.
    cl_abap_unit_assert=>assert_initial( cut->safe_divide( dividend = 1 divisor = 0 ) ).
  ENDMETHOD.

ENDCLASS.
