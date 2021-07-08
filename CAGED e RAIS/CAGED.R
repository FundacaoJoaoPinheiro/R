#' ---
#' title: "CAGED"
#' author: "Michel Rodrigo - michel.alves@fjp.mg.gov.br e Heloísa"
#' date: "08 de julho de 2021"
#' output: github_document 
#' ---
#' 

options(warn=-1)

  
 
#' ## Limpa a memória e console
cat("\014")  
rm(list = ls())

#' ## Configura o diretório de trabalho
#' Altera a pasta de trabalho para a mesma onde o script está salvo
dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(dir)


#' ## Carrega as bibliotecas
pacotes <- c("tidyverse", "srvyr", "csv",
             "data.table", "openxlsx", "rio")

#' Verifica se alguma das bibliotecas necessárias ainda não foi instalada
pacotes_instalados <- pacotes %in% rownames(installed.packages())
if (any(pacotes_instalados == FALSE)) {
  install.packages(pacotes[!pacotes_instalados])
}

#' carrega as bibliotecas
#+ results = "hide"
lapply(pacotes, library, character.only=TRUE)


#' ## Importa os dados
#' 
#' *Observação*: os dados já deverão ter sido baixados, conforme as instruções presentes aqui
#' 
cagedjan2020<- read.table("CAGEDESTAB202001.txt", head=T, sep=";", encoding = "UTF-8")
cagedfev2020<- read.table("CAGEDESTAB202002.txt", head=T, sep=";", encoding = "UTF-8")
cagedmar2020<- read.table("CAGEDESTAB202003.txt", head=T, sep=";", encoding = "UTF-8")
cagedabril2020<- read.table("CAGEDESTAB202004.txt", head=T, sep=";", encoding = "UTF-8")
cagedmaio2020<- read.table("CAGEDESTAB202005.txt", head=T, sep=";", encoding = "UTF-8")
cagedjun2020<- read.table("CAGEDESTAB202006.txt", head=T, sep=";", encoding = "UTF-8")
cagedjul2020<- read.table("CAGEDESTAB202007.txt", head=T, sep=";", encoding = "UTF-8")
cagedagos2020<- read.table("CAGEDESTAB202008.txt", head=T, sep=";", encoding = "UTF-8")
cagedset2020<- read.table("CAGEDESTAB202009.txt", head=T, sep=";", encoding = "UTF-8")
cagedout2020<- read.table("CAGEDESTAB202010.txt", head=T, sep=";", encoding = "UTF-8")
cagednov2020<- read.table("CAGEDESTAB202011.txt", head=T, sep=";", encoding = "UTF-8")
cageddez2020<- read.table("CAGEDESTAB202012.txt", head=T, sep=";", encoding = "UTF-8")

#' ## Manipulação das bases de dados
#' 
#' Função para criar um nova coluna na tabela com os respectivos nomes dos setores econômicos.
#' A sexta coluna da tabela deve conter a letra relativa a cada setor.
nomes <- function(tabela){
  
  ifelse(tabela[6] == "A", "Agricultura, pecuária, produção florestal, pesca e aquicultura",
  ifelse(tabela[6] == "B", "Indústrias Extrativas",
  ifelse(tabela[6] == "C", "Indústrias de Transformação",
  ifelse(tabela[6] == "D", "Eletricidade e Gás",        
  ifelse(tabela[6] == "E", "Água, Esgoto, Atividades de Gestão de Resíduos e Descontaminação",
  ifelse(tabela[6] == "F", "Construção",
  ifelse(tabela[6] == "G", "Comércio, Reparação de Veículos Automotores e Motocicletas",
  ifelse(tabela[6] == "H", "Transporte, Armazenagem e Correio",
  ifelse(tabela[6] == "I", "Alojamento e Alimentação",
  ifelse(tabela[6] == "J", "Informação e Comunicação",
  ifelse(tabela[6] == "K", "Atividades Financeiras, de Seguros e Serviços Relacionados",
  ifelse(tabela[6] == "L", "Atividades Imobiliárias",
  ifelse(tabela[6] == "M", "Atividades Profissionais, Científicas e Técnicas",
  ifelse(tabela[6] == "N", "Atividades Administrativas e Serviços Complementares",
  ifelse(tabela[6] == "O", "Administração Pública, Defesa e Seguridade Social",
  ifelse(tabela[6] == "P", "Educação",
  ifelse(tabela[6] == "Q", "Saúde Humana e Serviços Sociais",
  ifelse(tabela[6] == "R", "Artes, Cultura, Esporte e Recreação",
  ifelse(tabela[6] == "S", "Outras Atividades de Serviços",
  ifelse(tabela[6] == "T", "Serviços Domésticos",
  ifelse(tabela[6] == "U", "Organismos Internacionais e Outras Instituições Extraterritoriais",
  ifelse(tabela[6] == "Z", "Não identificado"))))))))))))))))))))))
}

#' ### Janeiro
#'
#' Seleciona as colunas de interesse
cagedjan2020<-subset(cagedjan2020, select = c("competência", "uf", "município", "seção", "saldomovimentação"))

#' Duplica a coluna de códigos de setor e aplica a função para substituir o código pelo nome
cagedjan2020$setor_nomes = cagedjan2020$seção
cagedjan2020[, "setor_nomes"] <- apply(cagedjan2020, 1, nomes)

#' Gera a tabela com saldo de empregos por UF
#+ eval = FALSE
saldo_UF<- aggregate(cagedjan2020$saldo ~ cagedjan2020$uf, FUN= sum)
saldo_UF<- data.frame(rename(saldo_UF, "UF"="cagedjan2020$uf", "Saldo_janeiro"="cagedjan2020$saldo"))
export(saldo_UF, file="caged_janeiro_UF.xlsx")


