#' ---
#' title: "PAM SIDRA"
#' author: "Michel Rodrigo - michel.alves@fjp.mg.gov.br"
#' date: "28 de junho de 2021"
#' output: github_document 
#' ---
#' Importação e manipulação da tabela 5457 do SIDRA - Produção Agrícola Municipal - IBGE 
#' 
#' 
options(warn=-1)

#' # Estrutura do script
#' 
#' ## Limpa a memória e console
cat("\014")  
rm(list = ls())

#' ## Configura o diretório de trabalho
#' Altera a pasta de trabalho para a mesma onde o script está salvo
dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(dir)


#' ## Carrega as bibliotecas
pacotes <- c("tidyverse", "sidrar", "data.table", "openxlsx", "curl")

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
#' ### Agregado - MG
#' 
#' Importa a tabela do SIDRA
MG_agr<- get_sidra( 5457,
                    variable = c(112,214,215,216),
                    period = c("last" = 17),
                    geo = "State",
                    geo.filter = list("State" = 31),
                    classific = "c782",
                    #category = "allxt",
                    header = TRUE,
                    format = 2
)

#' Renomeia a coluna de categorias, deixando a aplicação de filtros mais simples
names(MG_agr)[[7]] <- "Produto"

#' Adiciona uma coluna "Rank" que será útil posteriormente
MG_agr <-  MG_agr %>%
           group_by(Variável, Ano) %>%
           mutate("Valorxt" = ifelse(Produto != 'Total', Valor, as.numeric(NA)),
                 "Rank" = frank(desc(Valorxt), na.last = "keep")
  )

#' ### Agregado _ UF's
#' 
#' A importação online por meio da funcão `get_sidra` só é possível se a consulta retornar menos
#' de 50000 observações. Isso é uma limitação da função. Caso sua consulta atenda essa restrição, use a
#' função a seguir:
#+ eval = false
UF_agr<- get_sidra( 5457,
                    variable = c(112,214,215,216),
                    period = c("last" = 17),
                    geo = "State",
                    classific = "c782",
                    #category = "allxt",
                    header = TRUE,
                    format = 2
)

#' Se sua consulta retornar mais de 50000 observações, a importação deverá ser feita pela url a seguir,
#' salvando os dados em um arquivo csv e em seguido carregando os dados a partir dele. 
#' Esse arquivo só precisa ser baixado uma única vez.
curl_download(
  url = "https://sidra.ibge.gov.br/geratabela?format=br.csv&name=tabela5457.csv&terr=NC&rank=-&query=t/5457/n3/all/v/112,214,215,216/p/last%2017/c782/all/l/,,t%2Bp%2Bv%2Bc782",
  destfile = "t5457_UF.csv"   
)

#' Gera a tabela a partir do arquivo csv
UF_agr <- read.csv2("t5457_UF.csv", skip = 1, na.strings = c("-","..","..."), encoding = "UTF-8")


#' ## Manipulação da base de dados