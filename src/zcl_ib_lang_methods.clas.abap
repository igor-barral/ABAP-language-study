"! <p class="shorttext synchronized">Métodos, parâmetros e controle de fluxo</p>
"! IMPORTING, EXPORTING, CHANGING e RETURNING; parâmetros opcionais
"! e com valor padrão; IF, CASE, DO, WHILE, LOOP e exceções.
CLASS zcl_ib_lang_methods DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    TYPES ty_amount TYPE p LENGTH 15 DECIMALS 2.

    "! Método funcional: um RETURNING permite usar a chamada em expressões.
    "! @parameter net      | Valor líquido
    "! @parameter tax_rate | Alíquota em percentual (padrão 10)
    "! @parameter gross    | Valor bruto
    METHODS gross_amount
      IMPORTING net          TYPE ty_amount
                tax_rate     TYPE ty_amount DEFAULT 10
      RETURNING VALUE(gross) TYPE ty_amount.

    "! Vários resultados via EXPORTING.
    "! @parameter numbers | Números de entrada
    "! @parameter minimum | Menor valor
    "! @parameter maximum | Maior valor
    METHODS min_max
      IMPORTING numbers TYPE string_table
      EXPORTING minimum TYPE i
                maximum TYPE i.

    "! CHANGING: o chamador passa uma variável que o método altera.
    "! @parameter counter | Contador incrementado
    "! @parameter step    | Incremento opcional
    METHODS increment
      IMPORTING step    TYPE i OPTIONAL
      CHANGING  counter TYPE i.

    "! Divisão segura, trata a exceção de divisão por zero.
    "! @parameter dividend | Dividendo
    "! @parameter divisor  | Divisor
    "! @parameter result   | Quociente, ou zero se o divisor for zero
    METHODS safe_divide
      IMPORTING dividend      TYPE i
                divisor       TYPE i
      RETURNING VALUE(result) TYPE decfloat34.

    "! Classificação com CASE.
    "! @parameter weekday | Dia da semana (1 = segunda)
    "! @parameter result  | Dia útil ou fim de semana
    METHODS day_kind
      IMPORTING weekday       TYPE i
      RETURNING VALUE(result) TYPE string.
ENDCLASS.


CLASS zcl_ib_lang_methods IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    " Chamada funcional e parâmetro padrão
    out->write( |gross_amount( 100 ) = { gross_amount( '100.00' ) }| ).
    out->write( |gross_amount( net = 100 tax_rate = 18 ) = { gross_amount( net = '100.00' tax_rate = 18 ) }| ).

    " EXPORTING recebido com declaração inline
    min_max( EXPORTING numbers = VALUE #( ( `7` ) ( `3` ) ( `12` ) )
             IMPORTING minimum = DATA(low)
                       maximum = DATA(high) ).
    out->write( |min_max: { low } / { high }| ).

    " CHANGING
    DATA(counter) = 0.
    increment( CHANGING counter = counter ).
    increment( EXPORTING step = 5 CHANGING counter = counter ).
    out->write( |increment: { counter }| ).

    out->write( |safe_divide( 10 / 4 ) = { safe_divide( dividend = 10 divisor = 4 ) }| ).
    out->write( |safe_divide( 10 / 0 ) = { safe_divide( dividend = 10 divisor = 0 ) }| ).

    " DO com contador de sistema e WHILE
    DO 3 TIMES.
      out->write( |DO, iteração { sy-index }: { day_kind( sy-index + 4 ) }| ).
    ENDDO.

    DATA(power) = 1.
    WHILE power < 100.
      power = power * 2.
    ENDWHILE.
    out->write( |WHILE: primeira potência de 2 acima de 100 = { power }| ).

    " LOOP com CONTINUE e EXIT
    DATA(items) = VALUE string_table( ( `a` ) ( `` ) ( `b` ) ( `stop` ) ( `c` ) ).
    LOOP AT items INTO DATA(item).
      IF item IS INITIAL.
        CONTINUE.
      ELSEIF item = `stop`.
        EXIT.
      ENDIF.
      out->write( |LOOP: { item }| ).
    ENDLOOP.
  ENDMETHOD.


  METHOD gross_amount.
    gross = net + net * tax_rate / 100.
  ENDMETHOD.


  METHOD min_max.
    CLEAR: minimum, maximum.
    IF numbers IS INITIAL.
      RETURN.
    ENDIF.

    minimum = CONV i( numbers[ 1 ] ).
    maximum = minimum.
    LOOP AT numbers INTO DATA(number).
      DATA(value) = CONV i( number ).
      minimum = nmin( val1 = minimum val2 = value ).
      maximum = nmax( val1 = maximum val2 = value ).
    ENDLOOP.
  ENDMETHOD.


  METHOD increment.
    " IS SUPPLIED diferencia "não informado" de "informado com zero"
    counter = counter + COND i( WHEN step IS SUPPLIED THEN step ELSE 1 ).
  ENDMETHOD.


  METHOD safe_divide.
    TRY.
        result = CONV decfloat34( dividend ) / divisor.
      CATCH cx_sy_zerodivide.
        result = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD day_kind.
    CASE weekday.
      WHEN 1 OR 2 OR 3 OR 4 OR 5.
        result = `dia útil`.
      WHEN 6 OR 7.
        result = `fim de semana`.
      WHEN OTHERS.
        result = `inválido`.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
