# Torre de Controle Fiscal — Overview Page (`torretotalnf`)

App **Overview Page (OVP)** consumindo o **OData V4** do custom entity
`ZI_Szk_teste_totalnf` (ver `../abap/torre-ctrl-fiscal`). Escopo v1: só o
card **"Total NF no período"** (Total / Entrada / Saída / Legado), igual
ao topo do mockup da Torre de Controle Fiscal.

## Status atual

O `manifest.json` deste app foi **atualizado pra refletir a configuração
real, validada pelo gerador oficial do SAP Fiori Tools** rodando contra o
serviço já publicado (`ZUI_SZK_TESTE_DASHBOARD`, sistema
`saps4d.tenova.consulting:44301` client `400`, projeto separado deste
repo). O gerador detectou sozinho as anotações inline da Custom Entity e
montou o card com o template **`sap.ovp.cards.v4.numeric`** (não
`sap.ovp.cards.list`, que era meu palpite inicial antes de testar) —
esse é o valor confirmado a usar num card OVP numérico em cima de OData
V4.

Ou seja: o **backend está confirmado funcionando ponta a ponta**. O que
ainda está em aberto é rodar o app localmente: mesmo com `npm start`
(proxy completo pra `ui5.sap.com`, não uma lista restrita de libs), o
navegador dá 404 em `sap/fe/macros/*`, `sap/ui/integration/*`,
`sap/suite/ui/commons/*` — sintoma de bloqueio de rede/proxy corporativo
até `ui5.sap.com` na máquina de teste, não um problema de configuração
do app. Ainda sob diagnóstico.

## Pré-requisito

O backend precisa estar ativo e publicado **antes** de rodar este app:
1. Objetos ABAP de `../abap/torre-ctrl-fiscal/README.md` criados e ativados.
2. Service Binding `ZUI_SZK_TESTE_DASHBOARD` (OData V4 - UI) **publicado**.
3. `webapp/manifest.json` → `sap.app.dataSources.mainService.uri` ajustado
   se o nome do binding/definição publicado no seu sistema for diferente.

## Rodar localmente

```bash
cd torretotalnf
npm install
npm start
```

Isso abre `test/flpSandbox.html`, que registra um tile local
"Torre de Controle Fiscal" e carrega o componente via `fiori-tools-proxy`
(host/client configurados em `ui5.yaml` — ajuste pro seu backend real).

## Como o card é montado

- **Filtros globais** (Empresa/Filial/Direção/Classificação Tributária):
  vêm das anotações `@UI.selectionField` **inline** na Custom Entity
  (`../abap/torre-ctrl-fiscal/zi_szk_teste_totalnf.ddls.asddls`) — o OVP
  lê isso do `$metadata` e monta a barra de filtro (`MacroFilterBar`)
  sozinho.
- **Card "Total NF no período"**: `sap.ovp.cards.v4.numeric` apontando
  pra `entitySet: "ZI_Szk_teste_totalnf"`. Como a entidade sempre devolve
  **1 linha** (é um agregado, não uma lista de documentos), o
  `DataPoint` no campo `TotalNf` vira o número grande do card;
  `LineItem` traz Entrada/Saída/Legado como linhas de detalhe.

## Diferença em relação ao app real gerado

O app rodando de fato (fora deste repo, gerado via SAP Fiori Tools no VS
Code) usa namespace `com.szk.projectdashboard` e tem arquivos que este
scaffold não replica 1:1 (ex.: `webapp/test/flp.html` do próprio
gerador, mock data em `localService/mainService/data`,
`webapp/annotations/annotation.xml` — um XML de anotação local vazio,
criado automaticamente pelo wizard, sem conteúdo próprio, já que as
anotações `@UI.*` vêm inline do backend). Este scaffold (`torretotalnf`)
existe pra manter uma referência versionada e testável dentro deste
repositório; se o app "de verdade" evoluir bastante, vale considerar
trazer o projeto real pra dentro deste repo no lugar deste scaffold.

## Próximos passos (fora do escopo v1)

- Resolver o bloqueio de rede/proxy até `ui5.sap.com` na máquina onde o
  app é rodado (ou apontar `ui5.yaml` pro `/resources` do próprio
  sistema SAP, se a versão de UI5 dele for compatível).
- Cards de "Cheques Operacionais", "Total por Status" e "Divergências"
  do mockup completo — cada um pode virar uma Custom Entity nova
  seguindo o mesmo padrão (`ZI_...` + classe `IF_RAP_QUERY_PROVIDER`).
