*&---------------------------------------------------------------------*
*& Include MZAVAL003TOP                                      Module Pool      SAPMZAVAL003
*&
*&---------------------------------------------------------------------*

PROGRAM  sapmzaval003.

************************************************************************
*                 Declaração da variáveis.                             *
************************************************************************
DATA: answer,
      cc_alv.


************************************************************************
*                Declaração das estruturas internas.                   *
************************************************************************
TABLES: zaval_cab_03,
        zaval_itm_03.
DATA is_layout TYPE lvc_s_layo.

************************************************************************
*                Declaração da tabela interna.                         *
************************************************************************
DATA it_zitm_03 TYPE TABLE OF zaval_itm_03.

************************************************************************
*                Declaração dos ponteiros.                             *
************************************************************************
DATA: o_container TYPE REF TO cl_gui_custom_container,
      o_alv TYPE REF TO cl_gui_alv_grid.

*----------------------------------------------------------------------*
***INCLUDE MZAVAL003_STATUS_1000O01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_1000O01  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1000O01 OUTPUT.
  SET PF-STATUS 'GUI-001'.
  SET TITLEBAR 'TIT-001'.

ENDMODULE.                 " STATUS_1000O01  OUTPUT

*----------------------------------------------------------------------*
***INCLUDE MZAVAL003_EX_COMMANDI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EX_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ex_command INPUT.

************************************************************************
*                       Variável de resposta                           *
************************************************************************
  CASE sy-ucomm.
    WHEN 'EXIT' OR 'BACK' OR '%EX'.
*Verifica a intenção do usuário em função de invocar uma função específica: "POPUP_TO_CONFIRM".
      PERFORM popup.
  ENDCASE.




ENDMODULE.                 " EX_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      Form  popup
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM popup.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question         = 'Deseja sair?'
      text_button_1         = 'SIM'
      text_button_2         = 'NÃO'
      display_cancel_button = 'X'
    IMPORTING
      answer                = answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

***************************************************************
*             Tratamento da resposta do usuário               *
***************************************************************
  CASE answer.
    WHEN '1'.
      IF SY-DYNNR EQ 2000.
        CLEAR zaval_cab_03.
        LEAVE TO SCREEN 1000.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.
    WHEN OTHERS.
      EXIT.
  ENDCASE.
ENDFORM.                    "popup

*----------------------------------------------------------------------*
***INCLUDE MZAVAL003_USER_COMMAND_1000I01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.

************************************************************************
*                            Consulta BD                               *
************************************************************************
  CASE sy-ucomm.
    WHEN 'DISPLAY'.
*Verificação de entrada de dados no campo de seleção.
      IF zaval_cab_03 is INITIAL.
*Mensagem da classe zmens com a seguinte informação: "Por favor, digite um código válido.".
        MESSAGE i000(zmens).
      ELSE.
        SELECT SINGLE *
          FROM zaval_cab_03
          WHERE znumcot = zaval_cab_03-znumcot.
        LEAVE TO SCREEN 2000.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1000  INPUT

*----------------------------------------------------------------------*
***INCLUDE MZAVAL003_STATUS_2000O01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_2000 OUTPUT.
  SET PF-STATUS 'GUI-002'.
  SET TITLEBAR 'TIT-002'.

************************************************************************
*                        Constitui o ALV.                              *
************************************************************************
  PERFORM f_alv.

ENDMODULE.                 " STATUS_2000  OUTPUT

*----------------------------------------------------------------------*
***INCLUDE MZAVAL003_F_ALVF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_alv .
************************************************************************
*             Seleção dos registros da tabela zavat_itm_03.            *
************************************************************************

  PERFORM f_select_itm_03.

************************************************************************
*                      Constituição do ALV                             *
************************************************************************

*Se o objeto o_alv já foi instanciado, elimine-o da memória.
  IF o_alv IS BOUND.
    o_alv->free( ).
  ENDIF.

*Se o objeto o_container não foi instanciado, instancie-o, tendo como passagem
* de parâmetro o nome do Custom Control criado no Layout da tela.
  IF o_container IS NOT BOUND.
    CREATE OBJECT o_container
      EXPORTING
        container_name = 'CC_ALV'.
  ENDIF.

*Cria o ALV, tendo como passagem de parâmetro o objeto outrora instanciado o_container.
  CREATE OBJECT o_alv
    EXPORTING
      i_parent = o_container.

*Define o layout do ALV.
  PERFORM f_layout_alv.

*Saída da informação (ALV) em função dos parâmetros determinados.
  CALL METHOD o_alv->set_table_for_first_display
    EXPORTING
      i_structure_name = 'ZAVAL_ITM_03'
      is_layout        = is_layout
    CHANGING
      it_outtab        = it_zitm_03.

ENDFORM.                    " F_ALV

*----------------------------------------------------------------------*
***INCLUDE MZAVAL003_F_SELECT_ITM_03F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_SELECT_ITM_03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SELECT_ITM_03 .
  select * from zaval_itm_03
       into table it_zitm_03.
ENDFORM.                    " F_SELECT_ITM_03

*----------------------------------------------------------------------*
***INCLUDE MZAVAL003_F_LAYOUT_ALVF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LAYOUT_ALV .
  is_layout-cwidth_opt = 'X'.
  is_layout-zebra = 'X'.
  is_layout-grid_title = 'Ítens de Cotação'.
ENDFORM.                    " F_LAYOUT_ALV