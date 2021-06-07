import("stringr")
import("sidrar")
import("tidyr")
import("tidyverse")
import("dplyr")

export("list_api_completo")
list_api_completo <- list(
  "/t/5917/n1/all/v/606/p/all/c2/all",
  "/t/5917/n3/31/v/606/p/all/c2/all",
  "/t/5917/n7/3101/v/606/p/all/c2/all",
  "/t/4092/n1/all/v/1641/p/all/c629/all",
  "/t/4092/n3/31/v/1641/p/all/c629/all",
  "/t/4092/n7/3101/v/1641/p/all/c629/all",
  "/t/4093/n3/all/v/4099/p/last%201/c2/all/d/v4099%201",
  "/t/4094/n1/all/v/4099/p/all/c58/all/d/v4099%201",
  "/t/4094/n3/31/v/4099/p/all/c58/all/d/v4099%201",
  "/t/4095/n1/all/v/4088/p/all/c1568/11628,11629,11630,11631,11632,11779,120706",
  "/t/4095/n3/31/v/4088/p/all/c1568/11628,11629,11630,11631,11632,11779,120706",
  "/t/6402/n1/all/v/4099/p/all/c86/all/d/v4099%201",
  "/t/6402/n3/31/v/4099/p/all/c86/all/d/v4099%201",
  "/t/5434/n1/all/v/4090/p/all/c693/all",
  "/t/5434/n3/31/v/4090/p/all/c693/all",
  "/t/4097/n1/all/v/4090/p/all/c11913/all",
  "/t/4097/n3/31/v/4090/p/all/c11913/all",
  "/t/4100/n1/all/v/1641/p/all/c604/all",
  "/t/4100/n3/31/v/1641/p/all/c604/all",
  "/t/6811/n1/all/v/9849/p/all/d/v9849%201",
  "/t/6811/n3/31/v/9849/p/all/d/v9849%201",
  "/t/4099/n1/all/v/4099,4114,4116,4118/p/all/d/v4099%201,v4114%201,v4116%201,v4118%201",
  "/t/4099/n3/31/v/4099,4114,4116,4118/p/all/d/v4099%201,v4114%201,v4116%201,v4118%201",
  "/t/5436/n1/all/v/5933/p/all/c2/all",
  "/t/5436/n3/31/v/5933/p/all/c2/all",
  "/t/5436/n7/3101/v/5933/p/all/c2/all",
  "/t/5437/n1/all/v/5933/p/all/c58/all",
  "/t/5437/n3/31/v/5933/p/all/c58/all",
  "/t/5438/n1/all/v/5933/p/all/c1568/11628,11629,11630,11631,11632,11779,120704,120706",
  "/t/5438/n3/31/v/5933/p/all/c1568/11628,11629,11630,11631,11632,11779,120704,120706",
  "/t/6405/n1/all/v/5933/p/all/c86/all",
  "/t/6405/n3/31/v/5933/p/all/c86/all",
  "/t/5442/n1/all/v/5932/p/all/c693/all",
  "/t/5442/n3/31/v/5932/p/all/c693/all",
  "/t/5439/n1/all/v/5932/p/all/c12029/all",
  "/t/5439/n3/31/v/5932/p/all/c12029/all",
  "/t/5440/n1/all/v/5932/p/all/c11913/all",
  "/t/5440/n3/31/v/5932/p/all/c11913/all",
  "/t/5606/n1/all/n3/31/v/6293/p/all",
  "/t/5606/n3/31/v/6293/p/all")




implode <- function(..., sep='') {
  paste(..., collapse=sep)
}


substitui_ano <- function(x, periodo) {
  str_replace(x, regex('/p/(.*?)/', x,  ignore_case = TRUE, multiline = FALSE, comments = FALSE, dotall = FALSE), 
              implode(c("/p/", periodo, "/")))
}


export("aplica_modificacao")
aplica_modificacao <- function(x, periodo) {
  lapply(list_api_completo, substitui_ano, periodo)
}


campo_2 <- function(x) {regmatches(x, regexec('/t/(.*?)/', x))}

campo_4 <- function(x){regmatches(x, regexec("/t/[^\\s]{1,4}/[^\\s]{1,2}/(.*?)/", x))}

extrair_list_1 <- function(x){lapply(x, "[[", 1)}

extrair_list_2 <- function(x){lapply(x, "[[", 2)}

codigo_UT <- function(x){ifelse(grepl('all', x), 'BR', ifelse(grepl('^31$', x), 'MG',ifelse(grepl('^3101$', x), 'RMBH', 'Valor de `x` inválido')))}


export("nomear_list2")
nomear_list2 <- function(x){
  paste0('tab_',
         extrair_list_2(campo_2(x)),
         "_",
         lapply(extrair_list_2(campo_4(x)), codigo_UT))}

export("funcao_getsidra")
funcao_getsidra <-function(x){get_sidra(api = x)}


export("prepara_saida")
prepara_saida <- function(saida) {
  
  
  saida$tab_5917_BR<- subset(saida$tab_5917_BR, select = c("Brasil", "Trimestre", "Sexo", "Valor"))
  saida$tab_5917_BR<- pivot_wider(saida$tab_5917_BR, names_from="Sexo", values_from = "Valor")        
  
  saida$tab_5917_MG<- subset(saida$tab_5917_MG, select = c("Unidade da Federação", "Trimestre", "Sexo", "Valor"))
  saida$tab_5917_MG<-pivot_wider(saida$tab_5917_MG, names_from="Sexo", values_from = "Valor")
  
  saida$tab_5917_RMBH<- subset(saida$tab_5917_RMBH, select = c("Região Metropolitana", "Trimestre", "Sexo", "Valor"))
  saida$tab_5917_RMBH<-pivot_wider(saida$tab_5917_RMBH, names_from="Sexo", values_from = "Valor")
  
  saida$tab_4092_BR<- (subset(saida$tab_4092_BR, select= c("Brasil", "Variável", "Trimestre", "Condição em relação à força de trabalho e condição de ocupação", "Valor")))
  saida$tab_4092_BR<-pivot_wider(saida$tab_4092_BR, names_from="Condição em relação à força de trabalho e condição de ocupação", values_from="Valor") 
  
  saida$tab_4092_MG<- (subset(saida$tab_4092_MG, select= c("Unidade da Federação", "Variável", "Trimestre", "Condição em relação à força de trabalho e condição de ocupação", "Valor")))
  saida$tab_4092_MG<-pivot_wider(saida$tab_4092_MG, names_from="Condição em relação à força de trabalho e condição de ocupação", values_from="Valor") 
  
  saida$tab_4092_RMBH<- (subset(saida$tab_4092_RMBH, select= c("Região Metropolitana", "Variável", "Trimestre", "Condição em relação à força de trabalho e condição de ocupação", "Valor")))
  saida$tab_4092_RMBH<-pivot_wider(saida$tab_4092_RMBH, names_from="Condição em relação à força de trabalho e condição de ocupação", values_from="Valor") 
  
  saida$tab_4093_UF<- subset(saida$tab_4093_BR, select = c("Unidade da Federação", "Variável", "Trimestre", "Sexo","Valor"))
  saida$tab_4093_UF<-pivot_wider(saida$tab_4093_UF, names_from="Sexo", values_from="Valor")
  
  saida$tab_4093_BR<- NULL
  
  saida$tab_4094_BR<- subset(saida$tab_4094_BR, select = c("Brasil", "Variável", "Trimestre", "Grupo de idade", "Unidade de Medida", "Valor"))
  saida$tab_4094_BR<-pivot_wider(saida$tab_4094_BR, names_from="Grupo de idade", values_from="Valor")
  
  saida$tab_4094_MG<- subset(saida$tab_4094_MG, select = c("Unidade da Federação", "Variável", "Trimestre", "Grupo de idade", "Unidade de Medida", "Valor"))
  saida$tab_4094_MG<-pivot_wider(saida$tab_4094_MG, names_from="Grupo de idade", values_from="Valor")
  
  saida$tab_4095_BR<- subset(saida$tab_4095_BR, select = c("Brasil", "Variável", "Trimestre", "Nível de instrução", "Valor"))
  saida$tab_4095_BR<-pivot_wider(saida$tab_4095_BR, names_from="Nível de instrução", values_from="Valor")
  
  saida$tab_4095_MG<- subset(saida$tab_4095_MG, select = c("Unidade da Federação", "Variável", "Trimestre", "Nível de instrução", "Valor"))
  saida$tab_4095_MG<-pivot_wider(saida$tab_4095_MG, names_from="Nível de instrução", values_from="Valor")
  
  saida$tab_6402_BR<- subset(saida$tab_6402_BR, select = c("Brasil", "Variável", "Trimestre", "Cor ou raça", "Valor"))
  saida$tab_6402_BR<-pivot_wider(saida$tab_6402_BR, names_from="Cor ou raça", values_from="Valor")
  
  saida$tab_6402_MG<- subset(saida$tab_6402_MG, select = c("Unidade da Federação", "Variável", "Trimestre", "Cor ou raça", "Valor"))
  saida$tab_6402_MG<-pivot_wider(saida$tab_6402_MG, names_from="Cor ou raça", values_from="Valor")
  
  saida$tab_5434_BR<- subset(saida$tab_5434_BR, select = c("Brasil", "Variável", "Trimestre", "Grupamento de atividades no trabalho principal - PNADC", "Valor"))
  saida$tab_5434_BR<-pivot_wider(saida$tab_5434_BR, names_from="Grupamento de atividades no trabalho principal - PNADC", values_from="Valor")
  
  saida$tab_5434_MG<- subset(saida$tab_5434_MG, select = c("Unidade da Federação", "Variável", "Trimestre", "Grupamento de atividades no trabalho principal - PNADC", "Valor"))
  saida$tab_5434_MG<-pivot_wider(saida$tab_5434_MG, names_from="Grupamento de atividades no trabalho principal - PNADC", values_from="Valor")
  
  saida$tab_4097_BR<- subset(saida$tab_4097_BR, select = c("Brasil", "Variável", "Trimestre", "Posição na ocupação e categoria do emprego no trabalho principal", "Valor"))
  saida$tab_4097_BR <-pivot_wider(saida$tab_4097_BR, names_from="Posição na ocupação e categoria do emprego no trabalho principal", values_from="Valor")
  
  saida$tab_4097_MG<- subset(saida$tab_4097_MG, select = c("Unidade da Federação", "Variável", "Trimestre", "Posição na ocupação e categoria do emprego no trabalho principal", "Valor"))
  saida$tab_4097_MG<-pivot_wider(saida$tab_4097_MG, names_from="Posição na ocupação e categoria do emprego no trabalho principal", values_from="Valor")
  
  saida$tab_4100_BR<- subset(saida$ tab_4100_BR, select = c("Brasil", "Variável", "Trimestre", "Tipo de medida de subutilização da força de trabalho na semana de referência", "Valor"))
  saida$tab_4100_BR<-pivot_wider(saida$ tab_4100_BR, names_from="Tipo de medida de subutilização da força de trabalho na semana de referência", values_from="Valor")
  
  saida$tab_4100_MG<- subset(saida$tab_4100_MG, select = c("Unidade da Federação", "Variável", "Trimestre", "Tipo de medida de subutilização da força de trabalho na semana de referência", "Valor"))
  
  saida$tab_4100_MG<-pivot_wider(saida$tab_4100_MG, names_from="Tipo de medida de subutilização da força de trabalho na semana de referência", values_from="Valor")
  
  saida$tab_4099_BR<- subset(saida$tab_4099_BR, select = c("Brasil", "Variável", "Trimestre", "Unidade de Medida", "Valor"))
  saida$tab_4099_BR<-pivot_wider(saida$tab_4099_BR, names_from="Variável", values_from="Valor")
  
  saida$tab_4099_MG<- subset(saida$tab_4099_MG, select = c("Unidade da Federação", "Variável", "Trimestre", "Unidade de Medida", "Valor"))
  saida$tab_4099_MG<-pivot_wider(saida$tab_4099_MG, names_from="Variável", values_from="Valor")
  
  saida$tab_5436_BR<- subset(saida$tab_5436_BR, select = c("Variável", "Trimestre", "Sexo", "Unidade de Medida", "Valor"))
  saida$tab_5436_BR<-pivot_wider(saida$tab_5436_BR, names_from="Sexo", values_from="Valor")
  
  saida$tab_5436_MG<- subset(saida$tab_5436_MG, select = c("Variável", "Trimestre", "Sexo", "Unidade de Medida", "Valor"))
  saida$tab_5436_MG<-pivot_wider(saida$tab_5436_MG, names_from="Sexo", values_from="Valor")
  
  saida$tab_5436_RMBH<- subset(saida$tab_5436_RMBH, select = c("Variável", "Trimestre", "Sexo", "Unidade de Medida", "Valor"))
  saida$tab_5436_RMBH<-pivot_wider(saida$tab_5436_RMBH, names_from="Sexo", values_from="Valor")
  
  saida$tab_5437_BR<- subset(saida$tab_5437_BR, select = c("Brasil", "Variável", "Trimestre", "Unidade de Medida", "Grupo de idade", "Valor"))
  saida$tab_5437_BR<-pivot_wider(saida$tab_5437_BR, names_from="Grupo de idade", values_from="Valor")
  
  saida$tab_5437_MG<- subset(saida$tab_5437_MG, select = c("Unidade da Federação", "Variável", "Trimestre", "Unidade de Medida", "Grupo de idade", "Valor"))
  saida$tab_5437_MG<-pivot_wider(saida$tab_5437_MG, names_from="Grupo de idade", values_from="Valor")
  
  saida$tab_5438_BR<- subset(saida$tab_5438_BR, select = c("Brasil", "Variável", "Trimestre", "Unidade de Medida", "Nível de instrução", "Valor"))
  
  saida$tab_5438_BR<-pivot_wider(saida$tab_5438_BR, names_from="Nível de instrução", values_from="Valor")
  
  saida$tab_5438_MG<- subset(saida$tab_5438_MG, select = c("Unidade da Federação", "Variável", "Trimestre", "Unidade de Medida", "Nível de instrução", "Valor"))
  saida$tab_5438_MG<-pivot_wider(saida$tab_5438_MG, names_from="Nível de instrução", values_from="Valor")
  
  saida$tab_6405_BR<- subset(saida$tab_6405_BR, select = c("Brasil", "Variável", "Trimestre", "Unidade de Medida", "Cor ou raça", "Valor"))
  saida$tab_6405_BR<-pivot_wider(saida$tab_6405_BR, names_from="Cor ou raça", values_from="Valor")
  
  saida$tab_6405_MG<- subset(saida$tab_6405_MG, select = c("Unidade da Federação", "Variável", "Trimestre", "Unidade de Medida", "Cor ou raça", "Valor"))
  saida$tab_6405_MG<-pivot_wider(saida$tab_6405_MG, names_from="Cor ou raça", values_from="Valor")
  
  saida$tab_5442_BR<- subset(saida$tab_5442_BR, select = c("Brasil", "Variável", "Trimestre", "Unidade de Medida", "Grupamento de atividades no trabalho principal - PNADC", "Valor"))
  saida$tab_5442_BR<-pivot_wider(saida$tab_5442_BR, names_from="Grupamento de atividades no trabalho principal - PNADC", values_from="Valor")
  
  saida$tab_5442_MG<- subset(saida$tab_5442_MG, select = c("Unidade da Federação", "Variável", "Trimestre", "Unidade de Medida", "Grupamento de atividades no trabalho principal - PNADC", "Valor"))
  saida$tab_5442_MG<-pivot_wider(saida$tab_5442_MG, names_from="Grupamento de atividades no trabalho principal - PNADC", values_from="Valor")
  
  saida$tab_5439_BR<- subset(saida$tab_5439_BR, select = c("Brasil", "Variável", "Trimestre", "Unidade de Medida", "Posição na ocupação no trabalho principal", "Valor"))
  saida$tab_5439_BR<-pivot_wider(saida$tab_5439_BR, names_from="Posição na ocupação no trabalho principal", values_from="Valor")
  
  saida$tab_5439_MG<- subset(saida$tab_5439_MG, select = c("Unidade da Federação", "Variável", "Trimestre", "Unidade de Medida", "Posição na ocupação no trabalho principal", "Valor"))
  saida$tab_5439_MG <-pivot_wider(saida$tab_5439_MG, names_from="Posição na ocupação no trabalho principal", values_from="Valor")
  
  saida$tab_5440_BR<- subset(saida$tab_5440_BR, select = c("Brasil", "Variável", "Trimestre", "Unidade de Medida", "Posição na ocupação e categoria do emprego no trabalho principal", "Valor"))
  saida$tab_5440_BR <-pivot_wider(saida$tab_5440_BR, names_from="Posição na ocupação e categoria do emprego no trabalho principal", values_from="Valor")
  
  saida$tab_5440_MG<- subset(saida$tab_5440_MG, select = c("Unidade da Federação", "Variável", "Trimestre", "Unidade de Medida", "Posição na ocupação e categoria do emprego no trabalho principal", "Valor"))
  saida$tab_5440_MG<-pivot_wider(saida$tab_5440_MG, names_from="Posição na ocupação e categoria do emprego no trabalho principal", values_from="Valor")
  
  saida$tab_5606_BR<- subset(saida$tab_5606_BR, select = c("Brasil e Unidade da Federação", "Variável", "Trimestre", "Valor"))
  
  saida$tab_5606_MG<- subset(saida$tab_5606_MG, select = c("Unidade da Federação", "Variável", "Trimestre", "Valor"))
  
  saida$tab_6811_BR<- subset(saida$tab_6811_BR, select = c("Brasil", "Variável", "Trimestre", "Valor"))
  saida$tab_6811_MG<- subset(saida$tab_6811_MG, select = c("Unidade da Federação", "Variável", "Trimestre", "Valor"))
  
  #Renomear
  saida$tab_5917_BR<- rename(saida$tab_5917_BR, c("População total"= "Total", "População total (homens)" = "Homens"  ,"População total (mulheres)"= "Mulheres" ))
  
  saida$tab_5917_MG<- rename(saida$tab_5917_MG, c("População total"= "Total", "População total (homens)" = "Homens"  ,"População total (mulheres)"= "Mulheres" ))
  
  saida$tab_5917_RMBH<- rename(saida$tab_5917_RMBH, c("População total"= "Total", "População total (homens)" = "Homens"  ,"População total (mulheres)"= "Mulheres" ))
  
  
  saida$tab_4092_BR<- rename(saida$tab_4092_BR, c("População em idade para trabalhar"= "Total", "Força de trabalho (PEA)" ="Força de trabalho"))
  
  saida$tab_4092_MG<- rename(saida$tab_4092_MG, c("População em idade para trabalhar"= "Total", "Força de trabalho (PEA)" ="Força de trabalho"))
  
  saida$tab_4092_RMBH<- rename(saida$tab_4092_RMBH, c("População em idade para trabalhar"= "Total", "Força de trabalho (PEA)" ="Força de trabalho"))
  
  saida$tab_6811_BR<-rename(saida$tab_6811_BR, c("Percentual (%) de pessoas desalentadas" = "Valor"))
  saida$tab_6811_MG<-rename(saida$tab_6811_MG, c("Percentual (%) de pessoas desalentadas" = "Valor"))
  
  saida$tab_5436_BR<-rename(saida$tab_5436_BR, c("Brasil"= "Total"))
  saida$tab_5436_MG<-rename(saida$tab_5436_MG, c("Minas Gerais" = "Total"))
  saida$tab_5436_RMBH<-rename(saida$tab_5436_RMBH, c("RMBH" = "Total"))
  
  saida$tab_4093_UF<- rename(saida$tab_4093_UF, c("Taxa de desoc. (%) - Total" = "Total", "Taxa de desoc. (%) - Homens" = "Homens", "Taxa de desoc. (%) - Mulheres" = "Mulheres"))
  
  #Ordenando
  saida$tab_4095_BR <-saida$tab_4095_BR[c("Brasil", "Variável", "Trimestre",   
                                          "Sem instrução e menos de 1 ano de estudo", "Ensino fundamental incompleto ou equivalente", "Ensino fundamental completo ou equivalente", 
                                          "Ensino médio incompleto ou equivalente","Ensino médio completo ou equivalente", "Ensino superior incompleto ou equivalente", "Ensino superior completo ou equivalente")]
  
  saida$tab_4095_MG <-saida$tab_4095_MG[c("Unidade da Federação", "Variável", "Trimestre",  
                                          "Sem instrução e menos de 1 ano de estudo", "Ensino fundamental incompleto ou equivalente", "Ensino fundamental completo ou equivalente", 
                                          "Ensino médio incompleto ou equivalente","Ensino médio completo ou equivalente", "Ensino superior incompleto ou equivalente", "Ensino superior completo ou equivalente")]
  
  saida$tab_4097_BR<- saida$tab_4097_BR[
    c("Brasil",
      "Variável",
      "Trimestre",
      "Total",
      "Empregado no setor privado, exclusive trabalhador doméstico",
      "Empregado no setor privado, exclusive trabalhador doméstico - com carteira de trabalho assinada",
      "Empregado no setor privado, exclusive trabalhador doméstico - sem carteira de trabalho assinada",
      "Trabalhador doméstico",
      "Trabalhador doméstico - com carteira de trabalho assinada",
      "Trabalhador doméstico - sem carteira de trabalho assinada",
      "Empregado no setor público",
      "Empregado no setor público, exclusive militar e funcionário público estatutário - com carteira de trabalho assinada",
      "Empregado no setor público, exclusive militar e funcionário público estatutário - sem carteira de trabalho assinada",
      "Empregado no setor público - militar e funcionário público estatutário",
      "Empregador",
      "Conta própria",
      "Trabalhador familiar auxiliar"
    )]
  
  
  saida$tab_4097_MG<- saida$tab_4097_MG[
    c("Unidade da Federação",
      "Variável",
      "Trimestre",
      "Total",
      "Empregado no setor privado, exclusive trabalhador doméstico",
      "Empregado no setor privado, exclusive trabalhador doméstico - com carteira de trabalho assinada",
      "Empregado no setor privado, exclusive trabalhador doméstico - sem carteira de trabalho assinada",
      "Trabalhador doméstico",
      "Trabalhador doméstico - com carteira de trabalho assinada",
      "Trabalhador doméstico - sem carteira de trabalho assinada",
      "Empregado no setor público",
      "Empregado no setor público, exclusive militar e funcionário público estatutário - com carteira de trabalho assinada",
      "Empregado no setor público, exclusive militar e funcionário público estatutário - sem carteira de trabalho assinada",
      "Empregado no setor público - militar e funcionário público estatutário",
      "Empregador",
      "Conta própria",
      "Trabalhador familiar auxiliar"
    )]
  
  
  return(saida)
  
}

