@EndUserText.label: 'Torre Ctrl Fiscal - Total NF no Periodo (Custom Entity)'

// Custom Entity RAP (sem tabela/CDS view por tras): existe só para servir
// dados de KPI já agregados pela classe em @ObjectModel.query.implementedBy.
// Não precisa de Behavior Definition porque é somente leitura (query).
//
// As anotações @UI.* ficam INLINE aqui (não numa Metadata Extension
// separada): Custom Entity ("define custom entity") não é suportada
// como alvo de Metadata Extension nesta release - o ADT devolve
// "Cannot annotate '...'. The type of the annotated entity is not
// supported" se tentar `annotate entity` nela. Metadata Extension só
// funciona em CDS view entity normal ("define view entity").
@ObjectModel.query.implementedBy: 'ABAP:ZCL_SZK_CTRL_QUERY'
@UI.headerInfo: {
  typeName: 'Total NF',
  typeNamePlural: 'Total NF',
  title: { value: 'TotalNf' }
}
define root custom entity ZI_Szk_teste_totalnf
{
      // chave técnica fixa - a entidade sempre devolve 1 linha (o card),
      // os filtros de negócio (Bukrs/Branch/...) NÃO são chave, são filtro.
  key Id            : abap.char(1);

      @UI.selectionField: [{ position: 10 }]
      @EndUserText.label: 'Empresa'
      Bukrs         : bukrs;

      @UI.selectionField: [{ position: 20 }]
      @EndUserText.label: 'Filial'
      Branch        : j_1bbranc_;

      @UI.selectionField: [{ position: 30 }]
      @EndUserText.label: 'Direção (A=Ambas, E=Entrada, S=Saída)'
      Direcao       : abap.char(1);

      @UI.selectionField: [{ position: 40 }]
      @EndUserText.label: 'Classificação Tributária'
      Cctrb         : /tnvaa/e_cclasstrib;

      @EndUserText.label: 'Janela em dias (0 = todo o período)'
      Dias          : abap.int4;

      @UI.lineItem: [{ position: 10, label: 'Total NF' }]
      @UI.dataPoint: { title: 'Total NF no período' }
      @EndUserText.label: 'Total NF no período'
      TotalNf       : abap.int4;

      @UI.lineItem: [{ position: 20, label: 'Entrada' }]
      @EndUserText.label: 'Total NF Entrada'
      TotalEntrada  : abap.int4;

      @UI.lineItem: [{ position: 30, label: 'Saída' }]
      @EndUserText.label: 'Total NF Saída'
      TotalSaida    : abap.int4;

      @UI.lineItem: [{ position: 40, label: 'Legado' }]
      @EndUserText.label: 'Total NF Legado'
      TotalLegado   : abap.int4;
}
