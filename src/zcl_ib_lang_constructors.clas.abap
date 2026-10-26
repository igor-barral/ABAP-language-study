"! <p class="shorttext synchronized">Expressões de construtor</p>
"! VALUE, NEW, CONV, CORRESPONDING, COND, SWITCH, REDUCE e FILTER
"! aplicadas a um mesmo cenário: pedidos de frete.
CLASS zcl_ib_lang_constructors DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    TYPES:
      BEGIN OF ty_order,
        id     TYPE i,
        city   TYPE string,
        weight TYPE i,
        status TYPE c LENGTH 1,
      END OF ty_order,
      ty_orders TYPE STANDARD TABLE OF ty_order WITH EMPTY KEY
                WITH NON-UNIQUE SORTED KEY by_status COMPONENTS status,
      BEGIN OF ty_order_view,
        order_id TYPE i,
        city     TYPE string,
        weight   TYPE i,
      END OF ty_order_view,
      ty_order_views TYPE STANDARD TABLE OF ty_order_view WITH EMPTY KEY,
      ty_statuses    TYPE SORTED TABLE OF ty_order-status WITH UNIQUE KEY table_line.

  PRIVATE SECTION.
    DATA orders TYPE ty_orders.

    METHODS value_and_new
      IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS conv_and_corresponding
      IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS cond_and_switch
      IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS reduce_and_filter
      IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
ENDCLASS.


CLASS zcl_ib_lang_constructors IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    " VALUE para tabela: cada ( ... ) é uma linha
    orders = VALUE #( ( id = 1 city = `Curitiba`  weight = 120  status = 'O' )
                      ( id = 2 city = `Joinville` weight = 850  status = 'S' )
                      ( id = 3 city = `Londrina`  weight = 40   status = 'O' )
                      ( id = 4 city = `Maringá`   weight = 2300 status = 'D' ) ).

    value_and_new( out ).
    conv_and_corresponding( out ).
    cond_and_switch( out ).
    reduce_and_filter( out ).
  ENDMETHOD.


  METHOD value_and_new.
    " VALUE para estrutura
    DATA(single) = VALUE ty_order( id = 10 city = `Cascavel` weight = 75 status = 'O' ).

    " BASE mantém o conteúdo atual e acrescenta linhas
    DATA(more_orders) = VALUE ty_orders( BASE orders ( single ) ).

    " FOR dentro de VALUE: equivalente a um map
    DATA(cities) = VALUE string_table( FOR o IN orders ( o-city ) ).

    " NEW cria objeto (ou referência de dado) e devolve a referência
    DATA(text_ref) = NEW string( `referência de dado criada com NEW` ).

    out->write( |VALUE + BASE: { lines( more_orders ) } pedidos| ).
    out->write( cities ).
    out->write( text_ref->* ).
  ENDMETHOD.


  METHOD conv_and_corresponding.
    " CONV converte explicitamente, útil em chamadas e cálculos
    DATA(weight_text) = `850`.
    DATA(weight) = CONV i( weight_text ).
    DATA(ratio) = CONV decfloat34( 1 ) / 3.

    " CORRESPONDING copia componentes com o mesmo nome;
    " MAPPING resolve nomes diferentes, EXCEPT ignora campos
    DATA(views) = CORRESPONDING ty_order_views( orders MAPPING order_id = id ).
    DATA(first_view) = CORRESPONDING ty_order_view( orders[ 1 ] MAPPING order_id = id EXCEPT weight ).

    out->write( |CONV i: { weight + 1 } / CONV decfloat34: { ratio }| ).
    out->write( views ).
    out->write( |CORRESPONDING com EXCEPT: { first_view-order_id } { first_view-city } peso={ first_view-weight }| ).
  ENDMETHOD.


  METHOD cond_and_switch.
    LOOP AT orders INTO DATA(order).
      " COND: condições livres, avaliadas em ordem
      DATA(size) = COND string( WHEN order-weight < 100  THEN `pequeno`
                                WHEN order-weight < 1000 THEN `médio`
                                ELSE `grande` ).

      " SWITCH: compara um único operando com valores fixos
      DATA(status_text) = SWITCH string( order-status
                                         WHEN 'O' THEN `aberto`
                                         WHEN 'S' THEN `enviado`
                                         WHEN 'D' THEN `entregue`
                                         ELSE `desconhecido` ).

      out->write( |Pedido { order-id }: { size }, { status_text }| ).
    ENDLOOP.
  ENDMETHOD.


  METHOD reduce_and_filter.
    " REDUCE: acumula um valor percorrendo a tabela (equivalente a reduce/fold)
    DATA(total_weight) = REDUCE i( INIT sum = 0
                                   FOR o IN orders
                                   NEXT sum = sum + o-weight ).

    " REDUCE com WHERE e LET (variável auxiliar local à iteração)
    DATA(summary) = REDUCE string( INIT text = ``
                                   FOR o IN orders WHERE ( status = 'O' )
                                   LET line = |#{ o-id }| IN
                                   NEXT text = text && line && ` ` ).

    " FILTER exige chave ordenada ou hash (aqui a chave secundária by_status)
    DATA(open_orders) = FILTER #( orders USING KEY by_status WHERE status = 'O' ).

    " FILTER ... IN usa outra tabela como filtro (a chave usada é a da tabela filtro)
    DATA(wanted) = VALUE ty_statuses( ( 'S' ) ( 'D' ) ).
    DATA(shipped_or_delivered) = FILTER #( orders IN wanted WHERE status = table_line ).

    out->write( |REDUCE soma de pesos: { total_weight }| ).
    out->write( |REDUCE com LET: { summary }| ).
    out->write( |FILTER abertos: { lines( open_orders ) } / FILTER IN: { lines( shipped_or_delivered ) }| ).
  ENDMETHOD.

ENDCLASS.
