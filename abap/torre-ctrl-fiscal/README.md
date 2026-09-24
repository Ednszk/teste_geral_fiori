# Torre de Controle Fiscal — Custom Entity (OData V4)

Fonte ABAP para o card **"Total NF no período"** da Torre de Controle Fiscal,
exposto via **RAP Custom Entity** em **OData V4**. Estes arquivos são a
referência de código — não são serializados por abapGit; precisam ser
criados/colados manualmente no ADT (Eclipse) no sistema onde o addon
`/TNVAA/` está instalado (mesmo sistema do report `/TNVAA/R_TORRE_CTRL`).

## Por que Custom Entity (e não CDS view normal)?

O card não lê uma tabela 1:1 — ele é um resultado **agregado** (contagens
distintas por chave, com filtros de empresa/filial/direção/classificação).
Uma Custom Entity RAP resolve isso: a entidade não tem tabela por trás,
quem monta a linha de resultado é a classe `ZCL_SZK_CTRL_QUERY`
(`IF_RAP_QUERY_PROVIDER~SELECT`). Não precisa de Behavior Definition
porque é somente leitura (query), sem create/update/delete/draft.

Isso é 100% suportado em **OData V4**: uma Custom Entity é exposta por uma
Service Definition e publicada por uma Service Binding do tipo
**"ODATA V4 - UI"**, exatamente como uma CDS view normal.

## Objetos e ordem de criação (ADT)

1. **Data Definition (Custom Entity)** — `zi_szk_teste_totalnf.ddls.asddls`
   `New ABAP Repository Object → Data Definition`, colar o conteúdo,
   ativar. As anotações `@UI.*` (`HeaderInfo`, `SelectionField` nos
   filtros, `LineItem`/`DataPoint` no `TotalNf`) ficam **inline**, dentro
   da própria Custom Entity — **não** dá pra usar Metadata Extension
   separada aqui: `annotate entity` numa Custom Entity (`define custom
   entity`) devolve `Cannot annotate '...'. The type of the annotated
   entity is not supported` no ADT, porque Metadata Extension só é
   suportada em CDS view entity normal (`define view entity`), não em
   Custom Entity, na maioria das releases do ABAP Platform. Por isso não
   existe mais um arquivo `zc_szk_teste_totalnf.ddls.asddls` separado.
2. **Class** — `zcl_szk_ctrl_query.clas.abap`
   `New ABAP Repository Object → Class`, colar o conteúdo, ativar.
   (Reaproveita a mesma lógica de contagem por chave distinta do
   `conta_lado` do `/TNVAA/R_TORRE_CTRL`, só que sem a quebra por status/
   divergência — isso fica pra v2 do custom entity, quando o dashboard
   crescer além do card único.)
3. **Service Definition** — `zi_szk_teste_totalnf.srvd.asddls`
   `New ABAP Repository Object → Service Definition`, colar o conteúdo,
   ativar. Exposto **sem alias**, então o entity set publicado tem o
   mesmo nome do Custom Entity: `ZI_Szk_teste_totalnf`.
4. **Service Binding** (não é arquivo de texto — criar direto no ADT):
   `New ABAP Repository Object → Service Binding`
   - Nome: `ZUI_SZK_TESTE_DASHBOARD`
   - Binding Type: **ODATA V4 - UI**
   - Service Definition: `ZI_SZK_TESTE_TOTALNF`
   - Salvar, clicar em **Publish**, depois **Preview/Local Preview** pra
     conferir que a entidade `ZI_Szk_teste_totalnf` devolve 1 linha com
     `TotalNf`, `TotalEntrada`, `TotalSaida`, `TotalLegado`.

## Status atual (confirmado via ADT/Fiori Tools)

- ✅ Custom Entity, classe, Service Definition e Service Binding criados,
  ativados e **publicados** no sistema `saps4d.tenova.consulting:44301`
  (client `400`).
- ✅ Service Binding `ZUI_SZK_TESTE_DASHBOARD` com `Local Service
  Endpoint: Published`.
- ✅ **Validado pelo próprio gerador oficial do SAP Fiori Tools**: ao
  rodar o floorplan "Overview Page Application" apontando pra esse
  serviço, ele detectou sozinho as anotações `@UI.*` inline e montou um
  card `sap.ovp.cards.v4.numeric` (o card numérico "de verdade" do OVP
  pra OData V4) em cima da entidade `ZI_Szk_teste_totalnf` — confirma
  que Custom Entity + OData V4 + anotações inline + OVP funcionam
  ponta a ponta neste sistema.
- ⏳ **Pendente**: rodar o app Fiori gerado (projeto separado, fora
  deste repo) ainda está dando 404 em várias bibliotecas UI5
  (`sap/fe/macros/*`, `sap/ui/integration/*`, `sap/suite/ui/commons/*`)
  mesmo usando `npm start` (que já usa o proxy completo pra
  `ui5.sap.com`, não uma lista restrita de libs). Isso é um problema de
  **carregamento de recursos do front-end local** (rede/proxy
  corporativo até `ui5.sap.com`, sob investigação) — não tem relação
  com o backend/CDS/classe, que já estão confirmados funcionando.

URL real e publicada:
```
/sap/opu/odata4/sap/zui_szk_teste_dashboard/srvd/sap/zi_szk_teste_totalnf/0001/
```

## Autorização

A classe hoje não faz `AUTHORITY-CHECK` (o objeto é só leitura de
agregados, sem dado sensível linha a linha). Se isso for uma exigência,
replicar o mesmo padrão do report — `AUTHORITY_CHECK_TCODE`/
`F_SKA1_BUK` por empresa — dentro do `SELECT` da classe, filtrando as
ranges de `Bukrs` pelas empresas autorizadas antes dos `SELECT COUNT`.

## v1 vs. mockup completo

Este v1 cobre só o card **Visão Geral → Total NF no período**
(Total / Entrada / Saída / Legado). Os demais cards do mockup (cheques
operacionais, status, divergências, comportamento) ficam de fora por
enquanto — dá pra evoluir a mesma Custom Entity com mais campos, ou
criar Custom Entities adicionais por card, seguindo o mesmo padrão.
