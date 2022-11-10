

colunas_corretas <- c("IBGE2", "População", "População dos 50 + Populosos", "Área Geográfica", 
                      "Educação", "Patrimônio Cultural", "Receita Própria", "Cota Mínima", 
                      "Mineradores", "Saúde per capita", "VAF", "Esportes", "Turismo", 
                      "Penitenciárias", "Recursos Hídricos", "Produção de Alimentos", 
                      "Unidades de Conservação (IC i)", "Saneamento", "Mata Seca", 
                      "Meio Ambiente", "PSF", "ICMS Solidário", "Índice Mínimo per capita", 
                      "Índice de participação", "Compensações", "Valor Líquido + Compensações",
                      "Ano", "Mês"
)



teste <- all(colunas_corretas %in% colnames(dados))

if(!teste){
  
  print(as.character(colunas_corretas[!colunas_corretas %in% colnames(dados)], "\n"))
  stop("O seu arquivo de transferência, não possui as colunas definidas acima. Confirme se a ortografia dos nomes de cada coluna, estão corretas. Caso queira ver a lista completa com os nomes corretos das colunas, que o seu arquivo deveria possuir, execute o seguinte comando:\n\nprint(colunas_corretas)")
}





teste_IBGE2 <- all(dados$IBGE2 %in% codigos_IBGE$IBGE2)

if(!teste_IBGE2){
  codigos_nao_encontrados <- codigos_IBGE$IBGE2[!codigos_IBGE$IBGE2 %in% dados$IBGE2]
  print(codigos_nao_encontrados)
  stop("Não foram encontrados os códigos IBGE2 definidos acima. Será que você por engano, acabou trocando a coluna de códigos do IBGE de 6 dígitos (IBGE1), pela coluna com os códigos de 4 dígitos (IBGE2)? Ou então, será que os códigos das cidades definidos acima, foram alterados em seu arquivo?")
}
