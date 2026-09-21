# Torre de Controle Fiscal — Overview Page (`torretotalnf`)

App **Overview Page (OVP)** freestyle, gerado à mão, consumindo o **OData V4**
do custom entity `ZI_SZK_TESTE_TOTALNF` (ver `../abap/torre-ctrl-fiscal`).
Escopo v1: só o card **"Total NF no período"** (Total / Entrada / Saída),
igual ao topo do mockup da Torre de Controle Fiscal.

## Pré-requisito

O backend precisa estar ativo e publicado **antes** de rodar este app:
1. Objetos ABAP de `../abap/torre-ctrl-fiscal/README.md` criados e ativados.
2. Service Binding `ZSZK_UI_TORRE_TOTALNF` (OData V4 - UI) **publicado**.
3. `webapp/manifest.json` → `sap.app.dataSources.mainService.uri` ajustado
   se o nome do binding/definição publicado no seu sistema for diferente
   do sugerido no README do backend.

## Rodar localmente

```bash
cd torretotalnf
npm install
npm start
```

Isso abre `test/flpSandbox.html`, que registra um tile local
"Torre de Controle Fiscal" e carrega o componente via
`fiori-tools-proxy` (mesma proxy/host/client configurados em `ui5.yaml`,
apontando pro sistema `lnl-s4h.opustech.com.br:5200` client `200`, igual
ao app `pbapi1` já existente neste repo).

## Como o card é montado

- **Filtros globais** (Empresa/Filial/Direção/Classificação Tributária):
  vêm das anotações `@UI.selectionField` na entidade `TotalNf`
  (`zc_szk_teste_totalnf.ddls.asddls` no backend) — o OVP lê isso do
  `$metadata` e monta a barra de filtro sozinho, sem precisar declarar
  nada a mais no `manifest.json`.
- **Card "Total NF no período"**: `sap.ovp.cards.list` apontando pra
  `entitySet: "TotalNf"`. Como a entidade sempre devolve **1 linha**
  (é um agregado, não uma lista de documentos), o `DataPoint` no campo
  `TotalNf` é o que vira o número grande do card; `LineItem` traz
  Entrada/Saída/Legado como as linhas de detalhe.

## Limitação conhecida / o que validar

Não há como testar este `manifest.json` fim a fim sem um backend real
respondendo (este ambiente não tem acesso ao sistema SAP nem ao runtime
RAP). O suporte do OVP a **OData V4** é mais recente e mais restrito que
o suporte a V2 — nem todo tipo de card do OVP funciona com V4 (o card
`sap.ovp.cards.list` usado aqui é um dos suportados). Antes de considerar
isso "pronto":

1. Publique o Service Binding e confira no **Preview** do ADT que
   `GET .../TotalNf` devolve a linha esperada.
2. Rode `npm start` e confira se o card renderiza. Se o schema do
   `manifest.json` precisar de ajuste fino (nome de propriedades da
   seção `sap.ovp`, versão mínima de UI5 etc.), o caminho mais seguro é
   regenerar via **SAP Fiori tools → floorplan "Overview Page
   Application"** apontando pro serviço já publicado — o wizard lê as
   anotações reais do `$metadata` e monta a config validada; dá pra
   comparar com este `manifest.json` e portar filtros/card.

## Próximos passos (fora do escopo v1)

- Cards de "Cheques Operacionais", "Total por Status" e "Divergências"
  do mockup completo — cada um pode virar uma Custom Entity nova
  seguindo o mesmo padrão (`ZI_...` + classe `IF_RAP_QUERY_PROVIDER`).
- Alternar tema claro/escuro (o report SAPGUI tinha isso via
  `sapevent:theme`; no Fiori isso é o tema do Launchpad/UI5, não algo
  que o app precisa implementar).
