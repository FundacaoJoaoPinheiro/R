


install.packages("RSelenium")
install.packages('Rcpp') 

library("RSelenium")
library("Rcpp")
library("curl")

library("pdftools")
library("dplyr")
library("tidyverse")

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

numero_paginas <- 24

arquivo_completo <- pdftools::pdf_data("iepha_2021.pdf")
pos <- arquivo_completo[[1]]

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



variaveis <- c("MUNICÍPIO", #primeiro município,
               "SOMATÓRIO PARA CÁLCULO DE PONTUAÇÃO PELOS TOMBAMENTOS",
               "PROTEÇÃO MUNICIPAL calculada com base no",
               "PONTUAÇÃO POLÍTICA CULTURAL", 
               "PONTUAÇÃO INVESTIMENTOS E DESPESAS",
               "PONTUAÇÃO INVENTÁRIO", 
               "PONTUAÇÃO EDUCAÇÃO e DIFUSÃO", 
               "PONTUAÇÃO FINAL TOMBAMENTOS", 
               "PONTUAÇÃO FINAL REGISTROS")

auxiliares <- c("PONTUAÇÃO POLÍTICA CULTURAL",
                "Pontuação relativa a 30%", 
                "SOMATÓRIO PARA CÁLCULO DE PONTUAÇÃO PELOS TOMBAMENTOS",
                "PONTUAÇÃO INVESTIMENTOS E DESPESAS",
                "PONTUAÇÃO INVENTÁRIO",
                "Até 2.000 domicílios",
                "PONTUAÇÃO TOTAL", 
                "De 1 a 5 bens registrados", 
                "PONTUAÇÃO EDUCAÇÃO e DIFUSÃO")       
limite_pagina_y <- 566 # posição do final da página, onde está escrito a palavra página

pos_variaveis <- mapply(encontra_posicao, variaveis)
pos_auxiliares <- mapply(encontra_posicao, auxiliares)

pos <- arquivo_completo[[1]]
primeiro_municipio <- "001-Abadia"
pos_municipio <- encontra_posicao(primeiro_municipio)
  
dados <- data.frame()

for(pagina in c(1:numero_paginas)){
  
  pos <- arquivo_completo[[pagina]]
  
  municipios <- subset(pos[, c(4, 6)], pos$y >= pos_municipio[2] & pos$y < limite_pagina_y & pos$x >= pos_municipio[1] & pos$x < pos_auxiliares[1, 1]-5)
  municipios <- municipios %>% 
    group_by(y) %>% 
    summarise(nomes_municipios = paste(text, collapse = " ")) %>%
    select(c("y", "nomes_municipios"))
  municipios <- municipios[order(municipios$y),]
  numeros_municipios <-  as.integer(sapply(municipios$nomes_municipios, substr, 1, 3))
  municipios <- municipios %>% mutate(nomes_municipios = sapply(municipios$nomes_municipios, substr, 5, 50)) %>%
                               mutate(numero = numeros_municipios, .after = y)
  print(municipios$nomes_municipios)
  
  df <- as_tibble(municipios[c(2, 3)])
  colnames(df) <- c("numero", "NOME MUNICÍPIO")
  
  for(var in c(2:length(variaveis))){
    variavel_atual <-  subset(pos[, c(4, 6)], pos$y >= pos_municipio[2]-3 & pos$y < limite_pagina_y & pos$x >= pos_variaveis[1, var] & pos$x < pos_auxiliares[1, var])
    variavel_atual <- variavel_atual[order(variavel_atual$y), ]
    variavel_atual <- variavel_atual %>%
      mutate(y = map_int(
        .x = y,
        .f = ~ if_else(
          condition = any(.x > municipios$y-5 & .x < municipios$y+5),
          true = municipios[municipios[, "y"]+5 > .x & municipios[, "y"]-5 < .x, ]$y,
          false = as.integer(NA)
        )
      ))
    variavel_atual <- sapply(municipios$y, function(x) ifelse(x %in% variavel_atual$y, as.numeric(sub(",", ".", variavel_atual[variavel_atual[, "y"] == x,]$text)), NA))
    df[[variaveis[var]]] <- variavel_atual
  }
  
  dados <- rbind(dados, df)
  
  
}


