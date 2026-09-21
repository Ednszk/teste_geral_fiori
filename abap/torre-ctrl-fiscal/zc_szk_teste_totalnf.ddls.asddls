@Metadata.layer: #CORE

// Extensão de metadados só com anotações UI (o Custom Entity fica limpo).
// É o que faz o OVP desenhar o card: HeaderInfo pro título, SelectionField
// pros filtros globais da Overview Page, LineItem + DataPoint pro número
// grande ("Total NF no período") igual ao mockup da Torre de Controle.
@UI.headerInfo: {
  typeName: 'Total NF',
  typeNamePlural: 'Total NF',
  title: { value: 'TotalNf' }
}
annotate entity ZI_Szk_teste_totalnf with
{
  @UI.selectionField: [{ position: 10 }]
  Bukrs;

  @UI.selectionField: [{ position: 20 }]
  Branch;

  @UI.selectionField: [{ position: 30 }]
  Direcao;

  @UI.selectionField: [{ position: 40 }]
  Cctrb;

  @UI.lineItem: [{ position: 10, label: 'Total NF' }]
  @UI.dataPoint: { title: 'Total NF no período' }
  TotalNf;

  @UI.lineItem: [{ position: 20, label: 'Entrada' }]
  TotalEntrada;

  @UI.lineItem: [{ position: 30, label: 'Saída' }]
  TotalSaida;

  @UI.lineItem: [{ position: 40, label: 'Legado' }]
  TotalLegado;
}
