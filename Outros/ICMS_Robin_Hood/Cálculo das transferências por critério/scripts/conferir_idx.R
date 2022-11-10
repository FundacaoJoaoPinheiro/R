library(tidyverse)

#### Os nomes de colunas que todos os arquivos Idx deveriam ter -------------------------

colunas_corretas <- c("Ano", "Mês", "IBGE1", "IBGE2", "SEF", "Municípios", "População", 
  "População dos 50 + Populosos", "Área Geográfica", "Educação", 
  "Patrimônio Cultural", "Receita Própria", "Cota Mínima", "Mineradores", 
  "Saúde per capita", "VAF", "Esportes", "Turismo", "Penitenciárias", 
  "Recursos Hídricos", "Produção de Alimentos", "Unidades de Conservação (IC i)", 
  "Saneamento", "Mata Seca", "Meio Ambiente", "PSF", "ICMS Solidário", 
  "Índice Mínimo per capita", "Índice de participação")

conferir_nomes <- function(x){
  nomes_do_Idx <- colnames(x)
  
  teste <- all(colunas_corretas %in% nomes_do_Idx)
  
  if(!teste){
    print(as.character(colunas_corretas[!colunas_corretas %in% nomes_do_Idx], "\n"))
    warning("Um de seus Idx's, não possui as colunas definidas acima. Confirme se a ortografia dos nomes de cada coluna presentes em seu Idx, estão corretas. Caso queira ver a lista completa com os nomes corretos das colunas, que o seu Idx deveria possuir, execute o seguinte comando:\n\nprint(colunas_corretas)")
  }
  
  return(teste)
}



resultado_nomes <- map(lista_idx, ~conferir_nomes(.))

quais_idx_precisam_ajuste <- map_lgl(resultado_nomes, ~`==`(., FALSE))

algum_idx_e_falso <- any(quais_idx_precisam_ajuste)




if(algum_idx_e_falso){
  print(quais_idx_precisam_ajuste[quais_idx_precisam_ajuste])
  stop("Você precisa ajustar os nomes das colunas nos arquivos de Idx definidos acima")
}






#### Conferindo se os meses dos arquivos de IDX
#### estão de acordo com os meses dos valores brutos
#### definidos na portaria de ICMS

teste <- all(sort(meses_atuais$nomes) %in% sort(nomes_idx()))



if(!teste){
  
  mensagem <- "Não foi encontrado um arquivo IDX referente aos meses acima, que estão definidos na portaria de ICMS. Isso pode estar ocorrendo por duas razões: 1) O nome do mês em questão não está escrito corretamente nos arquivos de Idx. Confira se na coluna Mês, em cada planilha de Idx, o mês em questão está escrito com o nome completo, onde a primeira letra é maiúscula como nos exemplos abaixo:\n\n*Janeiro\n*Fevereiro\n*Março\n\n2) O erro também pode estar ocorrendo, pois o valor da coluna Ano em algum arquivo do Idx, foi trocado por algum outro valor."
  
  teste <- meses_atuais$nomes %in% nomes_idx()
  print(meses_atuais$nomes[!teste])
  stop(mensagem)
}



### Conferindo os códigos de IBGE2

codigos_IBGE2 <- read_csv2("./parametros/codigos.csv")[["IBGE2"]]

map(lista_idx, function(x){
  
  codigos_idx <- x$IBGE2
  
  teste <- all(codigos_idx %in% codigos_IBGE2)
  

  
  if(!teste){
    mes <- unique(x$`Mês`)
    ano <- unique(x$Ano)
    mes_ano <- str_c(mes, ano, sep = "_")
    
    print(mes_ano)
    stop("A planilha Idx, com o mês e ano definidos acima, possui pelo menos um código IBGE2 diferente dos códigos verdadeiros. Isso significa, que ")
  }
  
})



