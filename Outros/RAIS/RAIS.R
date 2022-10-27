#' ---
#' title: "RAIS"
#' author: "Michel Rodrigo - michel.alves@fjp.mg.gov.br e Heloísa"
#' date: "12 de julho de 2021"
#' output: github_document 
#' ---

options(warn=-1)


#' ## Limpa a memória e console
cat("\014")  
rm(list = ls())

#' ## Configura o diretório de trabalho
#' Altera a pasta de trabalho para a mesma onde o script está salvo
dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(dir)


#' ## Carrega as bibliotecas
pacotes <- c("rio", "openxlsx", "csv")

#' Verifica se alguma das bibliotecas necessárias ainda não foi instalada
pacotes_instalados <- pacotes %in% rownames(installed.packages())
if (any(pacotes_instalados == FALSE)) {
  install.packages(pacotes[!pacotes_instalados])
}

#' carrega as bibliotecas
#+ results = "hide"
lapply(pacotes, library, character.only=TRUE)


#' ## Importa os dados
source('http://cemin.wikidot.com/local--files/raisr/rais.r')
