# ABAP - Study

> Nível: prática
> A linguagem ABAP moderna (sintaxe 7.4+ e ABAP Cloud): tipos, declarações inline, string templates,
> expressões de construtor e métodos, com três classes executáveis. Relacionados:
> [ABAP-Internal-Tables-language-study](https://github.com/igor-barral/ABAP-Internal-Tables-language-study),
> [ABAP-SQL-db-study](https://github.com/igor-barral/ABAP-SQL-db-study),
> [SAP-BTP-ABAP-Environment-devops-study](https://github.com/igor-barral/SAP-BTP-ABAP-Environment-devops-study).

## Objetivo

ABAP tem mais de quarenta anos, e boa parte do código que se encontra em cliente ainda é escrita no
estilo antigo: declarações no topo, `MOVE`, `CONCATENATE`, `READ TABLE` com variável auxiliar. A partir
do release 7.40 a linguagem ganhou expressões que a aproximam de C#, Java e JavaScript modernos:
declaração inline, *string templates*, expressões de construtor, tabelas em expressões. O ABAP Cloud
usa apenas essa parte moderna.

Este estudo cobre o núcleo da linguagem com código executável em três classes:

| Classe | Tema |
|---|---|
| [`ZCL_IB_LANG_TYPES`](src/zcl_ib_lang_types.clas.abap) | Tipos elementares, `TYPES`, estruturas, `DATA(...)`/`FINAL(...)`, string templates e funções de string |
| [`ZCL_IB_LANG_CONSTRUCTORS`](src/zcl_ib_lang_constructors.clas.abap) | `VALUE`, `NEW`, `CONV`, `CORRESPONDING`, `COND`, `SWITCH`, `REDUCE`, `FILTER` |
| [`ZCL_IB_LANG_METHODS`](src/zcl_ib_lang_methods.clas.abap) | `IMPORTING`, `EXPORTING`, `CHANGING`, `RETURNING`, parâmetros opcionais, controle de fluxo e exceções, com ABAP Unit |

Ao concluir este estudo você deverá ser capaz de responder perguntas como:

- Quais são os tipos elementares do ABAP e como `c`, `n` e `string` se diferenciam?
- O que a sintaxe 7.4+ mudou em relação ao ABAP antigo?
- Qual a diferença entre aspas simples, crase e barra vertical em literais?
- Quando usar `COND` e quando usar `SWITCH`?
- Para que servem `REDUCE` e `FILTER`, e qual a exigência do `FILTER`?
- Qual a diferença entre `EXPORTING`, `CHANGING` e `RETURNING`?

## Ponte

| Conceito | PHP / C# / Java / JS | ABAP |
|---|---|---|
| Variável com tipo inferido | `var x = 10;` (C#), `let x = 10` | `DATA(x) = 10.` |
| Constante local | `const`, `final`, `readonly` | `FINAL(x) = 10.` ou `CONSTANTS` |
| Interpolação | `"Olá {$nome}"`, `$"Olá {nome}"`, `` `Olá ${nome}` `` | `` |Olá { nome }| `` |
| Struct / DTO | `record`, `class` só com campos, objeto JS | `TYPES: BEGIN OF ... END OF` |
| Array/lista tipada | `List<T>`, `array` | Tabela interna (`STANDARD TABLE OF`) |
| Inicializador de coleção | `new List<Order> { ... }`, `[ ... ]` | `VALUE #( ( ... ) ( ... ) )` |
| `new` | `new Foo()` | `NEW zcl_foo( )` ou `NEW #( )` |
| Cast/conversão | `(int)x`, `intval()`, `Number()` | `CONV i( x )` |
| AutoMapper / spread `{...a}` | mapeamento por nome | `CORRESPONDING #( ... )` |
| Ternário / `match` | `a ? b : c`, `match` do PHP 8, `switch` expression do C# | `COND`, `SWITCH` |
| `reduce` / `Aggregate` | `array_reduce`, LINQ `Aggregate` | `REDUCE` |
| `filter` / `Where` | `array_filter`, LINQ `Where` | `FILTER` (exige chave) ou `VALUE #( FOR ... WHERE ... )` |
| `out`/`ref` do C# | parâmetros por referência | `EXPORTING` / `CHANGING` |
| Exceção | `try/catch`, `throw` | `TRY ... CATCH ... ENDTRY`, `RAISE EXCEPTION` |

Diferenças que surpreendem quem vem de fora:

- Toda instrução termina com **ponto**. Não há chaves; blocos fecham com `ENDIF`, `ENDLOOP`,
  `ENDMETHOD`.
- ABAP **não diferencia maiúsculas e minúsculas** em identificadores e palavras-chave.
- Parâmetros e expressões exigem **espaço** dentro dos parênteses: `meth( a )`, não `meth(a)`.
- `=` é tanto atribuição quanto comparação; o contexto decide.
- Não há `null` para tipos de valor: toda variável nasce com **valor inicial** (0, espaço, string
  vazia) e `IS INITIAL` testa isso.
- Variáveis declaradas dentro de `IF` ou `LOOP` valem para o **método inteiro**, não para o bloco.

## Conteúdo

### 1. Tipos elementares

| Tipo | Descrição | Valor inicial | Observação |
|---|---|---|---|
| `i` | Inteiro de 4 bytes | 0 | Uso geral |
| `int8` | Inteiro de 8 bytes | 0 | Contadores grandes |
| `p LENGTH n DECIMALS d` | Decimal compactado | 0 | Valores monetários e quantidades |
| `decfloat16` / `decfloat34` | Ponto flutuante decimal | 0 | Cálculos com casas decimais sem erro binário |
| `f` | Ponto flutuante binário | 0 | Evite para dinheiro |
| `c LENGTH n` | Texto de tamanho fixo | espaços | Completa com espaços à direita |
| `n LENGTH n` | Texto numérico | zeros | Só dígitos, alinhado à direita (CEP, número de documento) |
| `string` | Texto de tamanho variável | vazio | Uso geral |
| `x` / `xstring` | Bytes fixo / variável | hex 00 / vazio | Conteúdo binário |
| `d` | Data `AAAAMMDD` | `00000000` | Aritmética em dias |
| `t` | Hora `HHMMSS` | `000000` | Aritmética em segundos |
| `utclong` | Timestamp UTC | vazio | Moderno, com funções `utclong_*` |
| `abap_bool` | `'X'` ou `' '` | `' '` | Não é um booleano nativo; use `abap_true`/`abap_false` |

Trecho de `ZCL_IB_LANG_TYPES=>elementary_types`:

```abap
DATA price TYPE p LENGTH 8 DECIMALS 2 VALUE '19.90'.   " decimal compactado
DATA code TYPE c LENGTH 5 VALUE 'AB'.                  " completa com espaços
DATA zip TYPE n LENGTH 8 VALUE '1310000'.              " só dígitos, zeros à esquerda
DATA day TYPE d VALUE '20260924'.
...
out->write( |Daqui a 30 dias: { CONV d( day + 30 ) DATE = ISO }| ).
```

### 2. Literais: aspas, crase e barra

| Sintaxe | Tipo | Exemplo |
|---|---|---|
| `'texto'` | Literal de texto, tipo `c` (espaços à direita são ignorados) | `'Pedido'` |
| `` `texto` `` | Literal de string, tipo `string` | `` `Pedido` `` |
| `\|texto { expr }\|` | String template (interpolação) | `\|Pedido { id }\|` |

A diferença importa na inferência: `DATA(a) = 'Pedido'.` cria `c LENGTH 6`; `` DATA(b) = `Pedido`. ``
cria `string`. Isso aparece em `inline_declarations`.

### 3. Estruturas e `TYPES`

```abap
TYPES:
  BEGIN OF ty_address,
    city    TYPE string,
    country TYPE c LENGTH 2,
  END OF ty_address,
  BEGIN OF ty_customer,
    id      TYPE ty_customer_id,
    name    TYPE string,
    address TYPE ty_address,          " estrutura aninhada
    credit  TYPE ty_amount,
    active  TYPE abap_bool,
  END OF ty_customer.
```

O acesso a componentes usa hífen: `customer-address-city`. Referências a objetos usam `->`, e
membros estáticos `=>`.

### 4. Declaração inline

```abap
DATA(total) = 10 * 3.                      " i
DATA(label) = `Pedido`.                    " string
FINAL(max_items) = 50.                     " não pode ser alterada depois
DATA(customer) = VALUE ty_customer( id = 'C002' name = `Metalúrgica Silva` ).
```

A declaração inline também funciona em posições de resultado: `LOOP AT itab INTO DATA(line)`,
`SELECT ... INTO TABLE @DATA(result)`, `IMPORTING minimum = DATA(low)` e
`ASSIGNING FIELD-SYMBOL(<fs>)`.

### 5. String templates e funções de string

```abap
out->write( |Largura e alinhamento: [{ `ABAP` WIDTH = 10 ALIGN = RIGHT }]| ).
out->write( |Preenchimento: [{ `7` WIDTH = 5 ALIGN = RIGHT PAD = '0' }]| ).
out->write( |Maiúsculas: { `clean core` CASE = UPPER }| ).
out->write( |ALPHA = IN: { doc_number ALPHA = IN }| ).   " 42 -> 0000000042
```

Opções de formatação úteis: `WIDTH`, `ALIGN`, `PAD`, `CASE`, `DECIMALS`, `ALPHA = IN/OUT` (zeros
à esquerda, comum em números de documento SAP), `DATE = ISO`, `TIME = ISO`, `TIMESTAMP = ISO`.

Funções embutidas: `strlen`, `condense`, `to_upper`, `to_lower`, `substring`, `find`, `replace`,
`segment`, `contains`, `matches`, `concat_lines_of`, e o operador `&&` para concatenar. Todas estão
em `string_functions`.

### 6. Expressões de construtor

Todas seguem o formato `OPERADOR tipo( ... )`, onde `tipo` pode ser `#` quando o compilador consegue
deduzi-lo do destino.

**VALUE** constrói estruturas e tabelas; `BASE` preserva conteúdo existente e `FOR` percorre outra
tabela:

```abap
orders = VALUE #( ( id = 1 city = `Curitiba`  weight = 120  status = 'O' )
                  ( id = 2 city = `Joinville` weight = 850  status = 'S' ) ).
DATA(more_orders) = VALUE ty_orders( BASE orders ( single ) ).
DATA(cities) = VALUE string_table( FOR o IN orders ( o-city ) ).
```

**NEW** cria objetos e referências de dados: `NEW zcl_x( )`, `NEW #( )`, `NEW string( ... )`.

**CONV** converte explicitamente: `CONV i( weight_text )`, `CONV decfloat34( 1 ) / 3`.

**CORRESPONDING** copia por nome, com `MAPPING` para nomes diferentes e `EXCEPT` para ignorar:

```abap
DATA(views) = CORRESPONDING ty_order_views( orders MAPPING order_id = id ).
```

**COND** e **SWITCH**:

```abap
DATA(size) = COND string( WHEN order-weight < 100  THEN `pequeno`
                          WHEN order-weight < 1000 THEN `médio`
                          ELSE `grande` ).

DATA(status_text) = SWITCH string( order-status
                                   WHEN 'O' THEN `aberto`
                                   WHEN 'S' THEN `enviado`
                                   ELSE `desconhecido` ).
```

**REDUCE** acumula; **FILTER** seleciona linhas usando uma chave:

```abap
DATA(total_weight) = REDUCE i( INIT sum = 0
                               FOR o IN orders
                               NEXT sum = sum + o-weight ).

DATA(open_orders) = FILTER #( orders USING KEY by_status WHERE status = 'O' ).
```

O `FILTER` exige que a tabela tenha uma chave **sorted ou hashed** adequada (aqui a chave secundária
`by_status`) ou que a tabela de filtro do `IN` tenha essa chave. Sem chave, a alternativa é
`VALUE #( FOR o IN orders WHERE ( status = 'O' ) ( o ) )`.

### 7. Métodos e parâmetros

| Tipo de parâmetro | Direção | Uso |
|---|---|---|
| `IMPORTING` | Entrada, somente leitura | Dados de entrada; `OPTIONAL` ou `DEFAULT` para opcionais |
| `EXPORTING` | Saída | Vários resultados; o chamador recebe com `IMPORTING` |
| `CHANGING` | Entrada e saída | O método altera a variável do chamador |
| `RETURNING VALUE(...)` | Saída única, por valor | Método funcional, usável em expressões |

A chamada inverte a perspectiva: o que o método **exporta**, o chamador **importa**:

```abap
min_max( EXPORTING numbers = VALUE #( ( `7` ) ( `3` ) ( `12` ) )
         IMPORTING minimum = DATA(low)
                   maximum = DATA(high) ).
```

Boas práticas do Clean ABAP: prefira `RETURNING` a `EXPORTING`, evite `CHANGING` e não misture os
três no mesmo método. `IS SUPPLIED` diferencia um parâmetro opcional não informado de um informado
com valor inicial (veja `increment`).

### 8. Controle de fluxo e exceções

`IF/ELSEIF/ELSE/ENDIF`, `CASE/WHEN/ENDCASE`, `DO n TIMES` (com `sy-index`), `WHILE`, `LOOP AT` e,
dentro dos laços, `CONTINUE` e `EXIT`. Erros de runtime como divisão por zero são exceções de classe
(`CX_SY_ZERODIVIDE`) tratáveis com `TRY ... CATCH`. A modelagem de exceções próprias fica para o
`ABAP-OO-softwarearchitecture-study`.

### 9. ABAP antigo e ABAP moderno

| ABAP antigo | ABAP 7.4+ |
|---|---|
| `DATA lv_total TYPE i.` no topo, depois `lv_total = ...` | `DATA(total) = ...` |
| `MOVE a TO b.` | `b = a.` |
| `CONCATENATE a b INTO c SEPARATED BY space.` | `` c = \|{ a } { b }\|. `` |
| `READ TABLE itab INTO wa WITH KEY id = 1. IF sy-subrc = 0. ...` | `DATA(wa) = itab[ id = 1 ].` (com `TRY` ou `OPTIONAL`) |
| `CREATE OBJECT lo_obj.` | `DATA(obj) = NEW zcl_x( ).` |
| `IF x = 1. y = 'A'. ELSE. y = 'B'. ENDIF.` | `y = COND #( WHEN x = 1 THEN 'A' ELSE 'B' ).` |
| `LOOP ... APPEND wa TO result.` para transformar tabelas | `VALUE #( FOR ... )` |
| Prefixos húngaros `lv_`, `lt_`, `ls_`, `gv_` | Nomes descritivos sem prefixo (Clean ABAP) |

## Respostas

**Quais são os tipos elementares e como `c`, `n` e `string` se diferenciam?**
Numéricos (`i`, `int8`, `p`, `decfloat16/34`, `f`), caractere (`c`, `n`, `string`), bytes (`x`,
`xstring`), data e hora (`d`, `t`, `utclong`). `c` tem tamanho fixo e completa com espaços; `n` tem
tamanho fixo, aceita só dígitos e completa com zeros à esquerda; `string` tem tamanho variável.

**O que a sintaxe 7.4+ mudou em relação ao ABAP antigo?**
Trouxe declaração inline, string templates, expressões de construtor (`VALUE`, `NEW`, `CONV`,
`CORRESPONDING`, `COND`, `SWITCH`, `REDUCE`, `FILTER`), expressões de tabela (`itab[ ... ]`) e
chamadas funcionais em qualquer posição de operando. O código fica mais curto, declarativo e com
menos variáveis auxiliares, e é essa a sintaxe que o ABAP Cloud usa.

**Qual a diferença entre aspas simples, crase e barra vertical?**
`'...'` é literal de texto do tipo `c`, `` `...` `` é literal do tipo `string`, e `|...|` é string
template com interpolação `{ }` e opções de formatação.

**Quando usar `COND` e quando usar `SWITCH`?**
`SWITCH` quando se compara **um único operando** com valores fixos (como um `switch` de C#). `COND`
quando cada ramo tem uma **condição livre**, com faixas, vários campos ou funções (como uma cadeia
de ternários).

**Para que servem `REDUCE` e `FILTER`?**
`REDUCE` percorre uma tabela e acumula um resultado (soma, texto, estrutura). `FILTER` devolve as
linhas que atendem a uma condição de igualdade sobre uma chave sorted ou hashed; sem chave, use
`VALUE` com `FOR ... WHERE`.

**Qual a diferença entre `EXPORTING`, `CHANGING` e `RETURNING`?**
`EXPORTING` devolve um ou mais valores; `CHANGING` recebe uma variável do chamador e a altera;
`RETURNING` devolve um único valor e permite usar a chamada dentro de expressões. O Clean ABAP
recomenda `RETURNING` sempre que possível.

## Como rodar

### Verificação local (sem sistema SAP)

```bash
docker compose run --rm abaplint
```

Resultado esperado: `abaplint: 0 issue(s) found`, com as três classes e o include de testes
analisados (`"version": "Cloud"` em [`abaplint.json`](abaplint.json)).

### Execução real

1. BTP ABAP Environment trial, projeto ABAP Cloud no ADT.
2. Criar o pacote `ZIB_ABAP_LANG` e importar este repositório pelo abapGit
   ([abapGit-devops-study](https://github.com/igor-barral/abapGit-devops-study)).
3. Ativar tudo e executar cada classe com F9: `ZCL_IB_LANG_TYPES`, `ZCL_IB_LANG_CONSTRUCTORS`,
   `ZCL_IB_LANG_METHODS`.
4. Rodar os testes de `ZCL_IB_LANG_METHODS` com Ctrl+Shift+F10.

## Referências

- ABAP Keyword Documentation: https://help.sap.com (buscar "ABAP Keyword Documentation", seções
  "Constructor Expressions" e "String Templates").
- SAP Learning, "Acquiring Core ABAP Skills": https://learning.sap.com
- Clean ABAP: https://github.com/SAP/styleguides
- ABAP cheat sheets oficiais da SAP: https://github.com/SAP-samples/abap-cheat-sheets
- SAP Community, tag ABAP Development: https://community.sap.com
