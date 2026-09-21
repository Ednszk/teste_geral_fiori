"! Query provider do Custom Entity ZI_SZK_TESTE_TOTALNF.
"! Reaproveita a mesma fonte de dados do report /TNVAA/R_TORRE_CTRL
"! (view /TNVAA/V_ENTRADA e /TNVAA/V_SAIDA), só que devolvendo apenas
"! os totais do card "Total NF no período" (sem a quebra de divergência,
"! que fica pra uma v2 do custom entity).
CLASS zcl_szk_ctrl_query DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

ENDCLASS.


CLASS zcl_szk_ctrl_query IMPLEMENTATION.

  METHOD if_rap_query_provider~select.

    TYPES: BEGIN OF ty_result,
             id           TYPE c LENGTH 1,
             bukrs        TYPE bukrs,
             branch       TYPE j_1bbranc_,
             direcao      TYPE c LENGTH 1,
             cctrb        TYPE /tnvaa/e_cclasstrib,
             dias         TYPE i,
             totalnf      TYPE i,
             totalentrada TYPE i,
             totalsaida   TYPE i,
             totallegado  TYPE i,
           END OF ty_result,
           ty_result_tab TYPE STANDARD TABLE OF ty_result WITH EMPTY KEY.

    DATA: lv_bukrs  TYPE bukrs,
          lv_branch TYPE j_1bbranc_,
          lv_dir    TYPE c LENGTH 1 VALUE 'A',
          lv_cctrb  TYPE /tnvaa/e_cclasstrib,
          lv_dias   TYPE i,
          lv_dtini  TYPE d,
          ls_result TYPE ty_result.

*   -- filtros recebidos do Fiori (form EQ simples, igual ao form GET
*      da Torre em SAPGUI: bukrs/branch/dir/cctrb/dias) ---------------
    TRY.
        DATA(lt_ranges) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
*       filtro complexo demais p/ virar range (ex.: OR entre campos
*       diferentes) - nesse caso devolve sem filtro em vez de derrubar
*       a request.
        CLEAR lt_ranges.
    ENDTRY.

    LOOP AT lt_ranges INTO DATA(ls_range).
      READ TABLE ls_range-range INTO DATA(ls_r) INDEX 1.
      CHECK sy-subrc = 0.
      CASE ls_range-name.
        WHEN 'BUKRS'.   lv_bukrs  = ls_r-low.
        WHEN 'BRANCH'.  lv_branch = ls_r-low.
        WHEN 'DIRECAO'. lv_dir    = ls_r-low.
        WHEN 'CCTRB'.   lv_cctrb  = ls_r-low.
        WHEN 'DIAS'.    lv_dias   = ls_r-low.
      ENDCASE.
    ENDLOOP.
    IF lv_dir IS INITIAL.
      lv_dir = 'A'.
    ENDIF.

*   Dias = 0 -> "todo o período" (mesmo comportamento do R_TORRE_CTRL)
    IF lv_dias > 0.
      lv_dtini = sy-datum - lv_dias.
    ENDIF.

    DATA: lr_bukrs  TYPE RANGE OF bukrs,
          lr_branch TYPE RANGE OF j_1bbranc_,
          lr_cctrb  TYPE RANGE OF /tnvaa/e_cclasstrib.
    IF lv_bukrs IS NOT INITIAL.
      lr_bukrs = VALUE #( ( sign = 'I' option = 'EQ' low = lv_bukrs ) ).
    ENDIF.
    IF lv_branch IS NOT INITIAL.
      lr_branch = VALUE #( ( sign = 'I' option = 'EQ' low = lv_branch ) ).
    ENDIF.
    IF lv_cctrb IS NOT INITIAL.
      lr_cctrb = VALUE #( ( sign = 'I' option = 'EQ' low = lv_cctrb ) ).
    ENDIF.

*   -- contagens (chave distinta, igual ao conta_lado do R_TORRE_CTRL,
*      só que sem a quebra de status/divergência) --------------------
    DATA: lv_ent   TYPE i, lv_sai   TYPE i,
          lv_leg_e TYPE i, lv_leg_s TYPE i.

    IF lv_dir CA 'AE'.
      SELECT COUNT( DISTINCT chave ) FROM /tnvaa/v_entrada
        WHERE bukrs IN @lr_bukrs AND branch IN @lr_branch
          AND cclasstrib IN @lr_cctrb AND credat >= @lv_dtini
        INTO @lv_ent.
      SELECT COUNT( DISTINCT chave ) FROM /tnvaa/v_entrada
        WHERE bukrs IN @lr_bukrs AND branch IN @lr_branch
          AND cclasstrib IN @lr_cctrb AND credat >= @lv_dtini
          AND origem = 'L'
        INTO @lv_leg_e.
    ENDIF.

    IF lv_dir CA 'AS'.
      SELECT COUNT( DISTINCT chave ) FROM /tnvaa/v_saida
        WHERE bukrs IN @lr_bukrs AND branch IN @lr_branch
          AND cclasstrib IN @lr_cctrb AND credat >= @lv_dtini
        INTO @lv_sai.
      SELECT COUNT( DISTINCT chave ) FROM /tnvaa/v_saida
        WHERE bukrs IN @lr_bukrs AND branch IN @lr_branch
          AND cclasstrib IN @lr_cctrb AND credat >= @lv_dtini
          AND origem = 'L'
        INTO @lv_leg_s.
    ENDIF.

    ls_result = VALUE #(
      id           = 'X'
      bukrs        = lv_bukrs
      branch       = lv_branch
      direcao      = lv_dir
      cctrb        = lv_cctrb
      dias         = lv_dias
      totalnf      = lv_ent + lv_sai
      totalentrada = lv_ent
      totalsaida   = lv_sai
      totallegado  = lv_leg_e + lv_leg_s ).

*   entidade sempre devolve exatamente 1 linha (o card) - sem paging.
    io_response->set_total_number_of_records( 1 ).
    io_response->set_data( VALUE ty_result_tab( ( ls_result ) ) ).

  ENDMETHOD.

ENDCLASS.
