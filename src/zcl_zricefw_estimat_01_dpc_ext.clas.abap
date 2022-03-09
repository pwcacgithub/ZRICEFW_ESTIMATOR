class ZCL_ZRICEFW_ESTIMAT_01_DPC_EXT definition
  public
  inheriting from ZCL_ZRICEFW_ESTIMAT_01_DPC
  create public .

public section.
protected section.

  methods SMARTTABLESET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZRICEFW_ESTIMAT_01_DPC_EXT IMPLEMENTATION.


  METHOD smarttableset_get_entityset.
**TRY.
*CALL METHOD SUPER->SMARTTABLESET_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
*    if it_filter_select_options is NOT INITIAL.
     if_sadl_gw_dpc_util~get_dpc( )->get_entityset( EXPORTING io_tech_request_context = io_tech_request_context
                                                   IMPORTING et_data                 = et_entityset
                                                             es_response_context     = es_response_context ).

     SORT et_entityset BY modelname version DESCENDING.
     DELETE ADJACENT DUPLICATES FROM et_entityset COMPARING modelname.

*     endif.

  ENDMETHOD.
ENDCLASS.
