"! <p class="shorttext synchronized">Tipos, declarações e strings</p>
"! Tipos elementares, TYPES, estruturas, declaração inline
"! (DATA/FINAL), string templates e funções de string.
CLASS zcl_ib_lang_types DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    TYPES ty_customer_id TYPE c LENGTH 10.
    TYPES ty_amount TYPE p LENGTH 15 DECIMALS 2.

    TYPES:
      BEGIN OF ty_address,
        city    TYPE string,
        country TYPE c LENGTH 2,
      END OF ty_address,
      BEGIN OF ty_customer,
        id      TYPE ty_customer_id,
        name    TYPE string,
        address TYPE ty_address,
        credit  TYPE ty_amount,
        active  TYPE abap_bool,
      END OF ty_customer.

  PRIVATE SECTION.
    METHODS elementary_types
      IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS structures
      IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS inline_declarations
      IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS string_templates
      IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS string_functions
      IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
ENDCLASS.


CLASS zcl_ib_lang_types IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    elementary_types( out ).
    structures( out ).
    inline_declarations( out ).
    string_templates( out ).
    string_functions( out ).
  ENDMETHOD.


  METHOD elementary_types.
    " Numéricos
    DATA counter TYPE i VALUE 42.                  " inteiro de 4 bytes
    DATA big_counter TYPE int8 VALUE 9000000000.   " inteiro de 8 bytes
    DATA price TYPE p LENGTH 8 DECIMALS 2 VALUE '19.90'. " decimal compactado
    DATA ratio TYPE decfloat34 VALUE '0.1'.        " ponto flutuante decimal
    " Caracteres de tamanho fixo e variável
    DATA code TYPE c LENGTH 5 VALUE 'AB'.          " completa com espaços
    DATA zip TYPE n LENGTH 8 VALUE '1310000'.      " só dígitos, zeros à esquerda
    DATA text TYPE string VALUE `texto de tamanho variável`.
    DATA raw TYPE xstring VALUE '48656C6C6F'.
    " Data, hora e booleano
    DATA day TYPE d VALUE '20260924'.
    DATA time TYPE t VALUE '143000'.
    DATA flag TYPE abap_bool VALUE abap_true.

    out->write( |i={ counter } int8={ big_counter } p={ price } decfloat34={ ratio * 3 }| ).
    out->write( |c="{ code }" (strlen { strlen( code ) }) n={ zip } string="{ text }"| ).
    out->write( |xstring={ raw } d={ day DATE = ISO } t={ time TIME = ISO } flag={ flag }| ).
    " Aritmética de data: d + i soma dias
    out->write( |Daqui a 30 dias: { CONV d( day + 30 ) DATE = ISO }| ).
  ENDMETHOD.


  METHOD structures.
    DATA customer TYPE ty_customer.

    customer-id = 'C001'.
    customer-name = `Transportes Andrade`.
    customer-address-city = `Curitiba`.
    customer-address-country = 'BR'.
    customer-credit = '15000.00'.
    customer-active = abap_true.

    out->write( |{ customer-id } { customer-name } ({ customer-address-city }/{ customer-address-country })| ).
    out->write( customer-address ).  " estrutura plana vai direto para o console

    CLEAR customer-address.
    out->write( |Após CLEAR do componente: cidade="{ customer-address-city }"| ).
  ENDMETHOD.


  METHOD inline_declarations.
    " DATA(...) infere o tipo pelo lado direito
    DATA(total) = 10 * 3.                      " i
    DATA(label) = `Pedido`.                    " string (crase)
    DATA(fixed) = 'Pedido'.                    " c LENGTH 6 (aspas simples)
    " FINAL(...) declara uma variável que não pode ser alterada depois
    FINAL(max_items) = 50.

    DATA(customer) = VALUE ty_customer( id = 'C002' name = `Metalúrgica Silva` ).

    out->write( |total={ total } label={ label } fixed={ fixed } max_items={ max_items }| ).
    out->write( |Cliente inline: { customer-id } { customer-name }| ).
  ENDMETHOD.


  METHOD string_templates.
    DATA(amount) = CONV ty_amount( '1234567.891' ).
    DATA(doc_number) = CONV ty_customer_id( '42' ).

    out->write( |Largura e alinhamento: [{ `ABAP` WIDTH = 10 ALIGN = RIGHT }]| ).
    out->write( |Preenchimento: [{ `7` WIDTH = 5 ALIGN = RIGHT PAD = '0' }]| ).
    out->write( |Maiúsculas: { `clean core` CASE = UPPER }| ).
    out->write( |Decimais: { amount DECIMALS = 1 }| ).
    out->write( |ALPHA = IN: { doc_number ALPHA = IN } / ALPHA = OUT: { CONV ty_customer_id( '0000000042' ) ALPHA = OUT }| ).
    " Quebra de linha e tabulação por escape
    out->write( |Linha 1\nLinha 2\tcom tab| ).
  ENDMETHOD.


  METHOD string_functions.
    DATA(sentence) = `  ABAP moderno para quem vem de Java  `.
    DATA(clean) = condense( sentence ).

    out->write( |condense: "{ clean }"| ).
    out->write( |strlen: { strlen( clean ) }| ).
    out->write( |to_upper: { to_upper( clean ) }| ).
    out->write( |substring: { substring( val = clean off = 0 len = 4 ) }| ).
    out->write( |find: posição de "Java" = { find( val = clean sub = `Java` ) }| ).
    out->write( |replace: { replace( val = clean sub = `Java` with = `C#` ) }| ).
    out->write( |segment: { segment( val = `a;b;c` index = 2 sep = `;` ) }| ).
    out->write( |concatenação com &&: { `Fundamentos ` && `são portáveis` }| ).
    out->write( |contains: { xsdbool( contains( val = clean sub = `ABAP` ) ) }| ).
  ENDMETHOD.

ENDCLASS.
