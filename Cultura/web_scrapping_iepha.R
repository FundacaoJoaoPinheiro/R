


install.packages("RSelenium")
install.packages('Rcpp') 

library("RSelenium")
library("Rcpp")
library("curl")

library("pdftools")
library("dplyr")

dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(dir)


rD <- rsDriver(browser="firefox", port=4551L, verbose=F)
remDr <- rD[["client"]]



remDr$navigate("http://www.iepha.mg.gov.br/index.php/programas-e-acoes/icms-patrimonio-cultural")
ano <- "2020"

remDr$findElement(using = "xpath", value = "//span[contains(text(), 'Tabelas de Pontuação')]")$clickElement()
url_arquivo <- remDr$findElement(using = "xpath", value = "//a[contains(text(), 'Exercício 2021')]")$getElementAttribute('href')

destfile <- paste0(dir, "/iepha.pdf")

download.file(url_arquivo[[1]], destfile, method = "curl")

pdf_file <- "iepha.pdf"


pos <- pdftools::pdf_data("iepha.pdf")[[1]]

encontra_posicao <- function(nome_variavel){
  nomes <- as.list(scan(text= nome_variavel, what='', sep=' '))
  primeira_palavra_pos <- pos[pos[, "text"] == nomes[[1]],]
  for (palavra in c(1:length(nomes))){
    palavra_pos <- pos[pos[, "text"] == nomes[[palavra]],]
    primeira_palavra_pos <- primeira_palavra_pos[sapply(primeira_palavra_pos$x, function(x) x %in% palavra_pos$x), ]
  }
  if(nrow(primeira_palavra_pos) == 1){
    return(c(primeira_palavra_pos$x, primeira_palavra_pos$y))
  }
  else{
    return(-1)
  }

}

variaveis <- c("Abadia", #primeiro município,
               "SOMATÓRIO PARA CÁLCULO DE PONTUAÇÃO PELOS TOMBAMENTOS",
               "PROTEÇÃO MUNICIPAL calculada com base no")
auxiliares <- c("PONTUAÇÃO POLÍTICA CULTURAL",
                "Pontuação relativa a 30%", 
                "SOMATÓRIO PARA CÁLCULO DE PONTUAÇÃO PELOS TOMBAMENTOS")       
limite_pagina_y <- 566 # posição do final da página, onde está escrito a palavra página

pos_variaveis <- mapply(encontra_posicao, variaveis)
pos_auxiliares <- mapply(encontra_posicao, auxiliares)

municipios <- subset(pos[, c(4, 6)], pos$y >= pos[pos[, "text"] == variaveis[[1]],]$y & pos$y < limite_pagina_y & pos$x >= pos_variaveis[1, 1] & pos$x < pos_auxiliares[1, 1])
municipios <- municipios %>% 
  group_by(y) %>% 
  summarise(nomes_municipios = paste(text, collapse = " ")) %>%
  select(nomes_municipios)

somatorio <- subset(pos[, c(4, 6)], pos$y >= pos[pos[, "text"] == variaveis[[1]],]$y & pos$y < limite_pagina_y & pos$x >= pos_variaveis[1, 2] & pos$x < pos_auxiliares[1, 2])

protecao <-  subset(pos[, c(4, 6)], pos$y >= pos[pos[, "text"] == variaveis[[1]],]$y & pos$y < limite_pagina_y & pos$x >= pos_variaveis[1, 3] & pos$x < pos_auxiliares[1, 3])
ausentes <- sapply(somatorio$y, function(x) if(x %in% protecao$y){})
a <- 
