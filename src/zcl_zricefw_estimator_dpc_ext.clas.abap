class ZCL_ZRICEFW_ESTIMATOR_DPC_EXT definition
  public
  inheriting from ZCL_ZRICEFW_ESTIMATOR_DPC
  create public .

public section.
protected section.

  methods ESTIMATIONDATASE_CREATE_ENTITY
    redefinition .
  methods ESTIMATIONDATASE_GET_ENTITYSET
    redefinition .
  methods RICEFWOBJECTSSET_CREATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZRICEFW_ESTIMATOR_DPC_EXT IMPLEMENTATION.


  METHOD estimationdatase_create_entity.

* Work Area Declaration
    DATA : lw_data TYPE zricefw_estm.


* Local Variable Declaration
    DATA : lv_version TYPE char4,
           lv_number  TYPE char10.

*    IF iv_entity_name = 'EstimationData'.

**--- Transform data into the internal structure
      TRY.
          io_data_provider->read_entry_data(
            IMPORTING
              es_data = lw_data
              ).
        CATCH /iwbep/cx_mgw_tech_exception .
      ENDTRY.

      IF lw_data-date_time IS INITIAL.
        CONCATENATE sy-datum sy-uzeit INTO lw_data-date_time.
        lw_data-version = 0.

        CALL FUNCTION 'NUMBER_GET_NEXT'
          EXPORTING
            nr_range_nr = '01'
            object      = 'ZESTM'
            quantity    = '00000000000000000001'
          IMPORTING
            number      = lv_number.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ELSE.

*  SELECT MAX( version ) FROM zricefw_estm INTO lv_version WHERE date_time = lw_data-date_time.
*  SELECT
**    date_time
**          modelname
*          modelid
**          createddate
**          createdtime
**          headerdata
**          baselinedata
**          modeldata
**          engagemanager
**          engagepartner
**          radiobutton
*           MAX( version )
**          history
*   FROM zricefw_estm INTO CORRESPONDING FIELDS OF lw_ricefw_estm
*   WHERE modelname = lw_data-modelname
*   GROUP BY modelid version.
*  ENDSELECT.

        SELECT modelid,
               version
         FROM zricefw_estm INTO TABLE @DATA(lt_zricefw_estm)
         WHERE modelname = @lw_data-modelname.
        IF sy-subrc EQ 0.
          SORT lt_zricefw_estm BY version DESCENDING.
          READ TABLE lt_zricefw_estm INTO DATA(lw_zricefw_estm) INDEX 1.
          IF sy-subrc EQ 0.
            lw_data-version = lw_zricefw_estm-version + 1.
            lv_number = lw_zricefw_estm-modelid.
          ENDIF.
        ENDIF.
        CONCATENATE sy-datum sy-uzeit INTO lw_data-date_time.
      ENDIF.


* Fetch user name from v_usernames
      SELECT SINGLE name_text
            FROM v_username INTO @DATA(lv_username)
          WHERE bname = @sy-uname.
      IF sy-subrc EQ 0.
        lw_data-username = lv_username.
      ENDIF.


      lw_data-createddate = sy-datum.
      lw_data-createdtime = sy-uzeit.
      lw_data-modelid = lv_number.

      MODIFY zricefw_estm FROM lw_data.

      er_entity-date_time = lw_data-date_time.
      er_entity-modelname = lw_data-modelname.
      er_entity-engagemanager = lw_data-engagemanager.
      er_entity-engagepartner = lw_data-engagepartner.
      er_entity-radiobutton = lw_data-radiobutton.
      er_entity-modelid = lv_number.

*    ELSE.

**--- transform DATA into the internal structure
*      TRY.
*          io_data_provider->read_entry_data(
*            IMPORTING
*              es_data = rw_data
*              ).
*        CATCH /iwbep/cx_mgw_tech_exception .
*      ENDTRY.
*
*      MODIFY zricefw_objects FROM rw_data.

*    ENDIF.

  ENDMETHOD.


  METHOD estimationdatase_get_entityset.
*Local Variable Declaration
 DATA : lv_date_time TYPE date_time,
        lv_history   TYPE char1,
        lv_model_name TYPE char50.

*Internal Table Declaration
    DATA: lt_filter_select_options TYPE /iwbep/t_mgw_select_option.

**Work Area Declaration
    DATA: lw_filter            TYPE /iwbep/s_mgw_select_option,
          lw_filter_input      TYPE /iwbep/s_cod_select_option.

lt_filter_select_options = io_tech_request_context->get_filter( )->get_filter_select_options( ).

    IF lt_filter_select_options IS NOT INITIAL.
      READ TABLE lt_filter_select_options INTO lw_filter WITH KEY property = 'DATE_TIME'.
      IF sy-subrc EQ 0.
        READ TABLE lw_filter-select_options INTO lw_filter_input INDEX 1.
        IF sy-subrc EQ 0.
          lv_date_time = lw_filter_input-low.  "Date Time
        ENDIF.
      ENDIF.
      READ TABLE lt_filter_select_options INTO lw_filter WITH KEY property = 'HISTORY'.
      IF sy-subrc EQ 0.
        READ TABLE lw_filter-select_options INTO lw_filter_input INDEX 1.
        IF sy-subrc EQ 0.
          lv_history = lw_filter_input-low.   "History Flag
        ENDIF.
      ENDIF.
      READ TABLE lt_filter_select_options INTO lw_filter WITH KEY property = 'MODELNAME'.
      IF sy-subrc EQ 0.
        READ TABLE lw_filter-select_options INTO lw_filter_input INDEX 1.
        IF sy-subrc EQ 0.
          lv_model_name = lw_filter_input-low.   "History Flag
        ENDIF.
      ENDIF.
      ENDIF.


IF lv_history = 'X'.
    SELECT date_time
           modelname
           modelid
           createddate
           createdtime
           headerdata
           baselinedata
           modeldata
           engagemanager
           engagepartner
           radiobutton
           version
           history
           username
           engmntdata
      FROM zricefw_estm INTO TABLE et_entityset WHERE modelname = lv_model_name.
      IF sy-subrc EQ 0.
         SORT et_entityset BY modelname DESCENDING version DESCENDING.
      ENDIF.
ELSE.
    SELECT date_time
           modelname
           modelid
           createddate
           createdtime
           headerdata
           baselinedata
           modeldata
           engagemanager
           engagepartner
           radiobutton
           version
           history
           username
           engmntdata
      FROM zricefw_estm INTO TABLE et_entityset.
      IF sy-subrc EQ 0.
         SORT et_entityset BY modelname DESCENDING version DESCENDING.
         DELETE ADJACENT DUPLICATES FROM et_entityset COMPARING modelname.
      ENDIF.
ENDIF.
  ENDMETHOD.


  method RICEFWOBJECTSSET_CREATE_ENTITY.
DATA : rw_data TYPE zricefw_objects.
**--- transform DATA into the internal structure
      TRY.
          io_data_provider->read_entry_data(
            IMPORTING
              es_data = rw_data
              ).
        CATCH /iwbep/cx_mgw_tech_exception .
      ENDTRY.

      MODIFY zricefw_objects FROM rw_data.



  endmethod.
ENDCLASS.
