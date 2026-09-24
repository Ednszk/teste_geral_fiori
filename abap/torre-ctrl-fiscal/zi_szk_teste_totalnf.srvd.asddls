@EndUserText.label: 'Torre Ctrl Fiscal - Total NF (Custom Entity)'

// Exposto SEM alias ("as ...") - o entity set publicado fica com o
// mesmo nome do Custom Entity: ZI_Szk_teste_totalnf. É o nome real
// usado no Service Binding ZUI_SZK_TESTE_DASHBOARD e nas configs do
// app OVP (entitySet / globalFilterEntitySet).
define service ZI_Szk_teste_totalnf {
  expose ZI_Szk_teste_totalnf;
}
