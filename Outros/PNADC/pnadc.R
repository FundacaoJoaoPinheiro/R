cat("\014")  
rm(list = ls())
#configurar o endereço do arquivo
setwd("H://FJP//scripts//pnadc")


pacotes <- c("tidyr", "plyr", "tidyverse", "data.table", "openxlsx", "sidrar", "reshape2",
             "stringr", "zoo", "lubridate", "gtools", "rio", "dplyr")
carregar <- lapply(pacotes, library, character.only = TRUE)

lib <- modules::use("funcoes_pnadc.R")

ano <- "201801-201804"




list_api_completo <- lib$aplica_modificacao(lib$list_api_completo, ano)



names(list_api_completo) <- lib$nomear_list2(list_api_completo)



saida <- lapply(list_api_completo, lib$funcao_getsidra)

saida <- lib$prepara_saida(saida)


export(saida, file = "planilha_pnadc_parte1.xlsx")



