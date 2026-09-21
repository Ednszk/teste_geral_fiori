@EndUserText.label: 'Torre Ctrl Fiscal - Total NF no Periodo (Custom Entity)'

// Custom Entity RAP (sem tabela/CDS view por tras): existe só para servir
// dados de KPI já agregados pela classe em ZObjectModel.query.implementedBy.
// Não precisa de Behavior Definition porque é somente leitura (query).
@ObjectModel.query.implementedBy: 'ABAP:ZCL_SZK_CTRL_QUERY'
define root custom entity ZI_Szk_teste_totalnf
{
      // chave técnica fixa - a entidade sempre devolve 1 linha (o card),
      // os filtros de negócio (Bukrs/Branch/...) NÃO são chave, são filtro.
  key Id            : abap.char(1);

      @EndUserText.label: 'Empresa'
      Bukrs         : bukrs;

      @EndUserText.label: 'Filial'
      Branch        : j_1bbranc_;

      @EndUserText.label: 'Direção (A=Ambas, E=Entrada, S=Saída)'
      Direcao       : abap.char(1);

      @EndUserText.label: 'Classificação Tributária'
      Cctrb         : /tnvaa/e_cclasstrib;

      @EndUserText.label: 'Janela em dias (0 = todo o período)'
      Dias          : abap.int4;

      @EndUserText.label: 'Total NF no período'
      TotalNf       : abap.int4;

      @EndUserText.label: 'Total NF Entrada'
      TotalEntrada  : abap.int4;

      @EndUserText.label: 'Total NF Saída'
      TotalSaida    : abap.int4;

      @EndUserText.label: 'Total NF Legado'
      TotalLegado   : abap.int4;
}
