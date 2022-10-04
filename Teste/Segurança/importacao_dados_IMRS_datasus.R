#' ---
#' title: "Importação dos dados IMRS dimensão Segurança"
#' author: "Michel Alves - michel.alves@fjp.mg.gov.br"
#' date: "janeiro de 2022"
#' output: github_document 
#' ---
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
pacotes <- c("readxl", "tidyverse", "janitor", "writexl", "hablar", "RSelenium", "XML")

#' Verifica se alguma das bibliotecas necessárias ainda não foi instalada
pacotes_instalados <- pacotes %in% rownames(installed.packages())
if (any(pacotes_instalados == FALSE)) {
  install.packages(pacotes[!pacotes_instalados])
}

#' carrega as bibliotecas
#+ results = "hide"
lapply(pacotes, library, character.only=TRUE)


#' Configura o browser. Caso aconteça o erro de porta ocupada, basta alterar o número da porta e executar o script novamente.
rD <- rsDriver(browser="firefox", port=4554L, verbose=F)
remDr <- rD[["client"]]


#' Endereço base do datasus
url = "http://tabnet.datasus.gov.br/cgi/deftohtm.exe?sim/cnv/pext10mg.def"

#' Ano para extração dos dados
ano <- "2020"

#' Lista com os xpath das seleções que devem ser feitas no datasus para cada indicador
lista = list(c('P_SUICIDIOS_SIM', "//select[@name='SGrande_Grupo_CID10']/*[text()[contains(., 'X60-X84 Lesões autoprovocadas voluntariamente')]]"),
          c('P_MORTESTRAN_SIM', "//select[@name='SGrande_Grupo_CID10']/*[text()[contains(., 'V01-V99 Acidentes de transporte')]]"),
          c('P_HOMI_SIM', "//select[@name='SGrande_Grupo_CID10']/*[text()[contains(., 'X85-Y09 Agressões')]]"),
          c('P_HOMITX_SIM', "//select[@name='SGrande_Grupo_CID10']/*[text()[contains(., 'X85-Y09 Agressões')]]"),
          c('P_HOMMENOR15_SIM', "//select[@name='SGrande_Grupo_CID10']/*[text()[contains(., 'X85-Y09 Agressões')]]", "//img[../select[contains(@name,'SFaixa_Etária_det')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '0 a 6 dias')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '7 a 27 dias')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '28 a 364 dias')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., 'Menor 1 ano (ign)')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '1 a 4 anos')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '5 a 9 anos')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '10 a 14 anos')]]"),
          c('P_HOM15A24_SIM', "//select[@name='SGrande_Grupo_CID10']/*[text()[contains(., 'X85-Y09 Agressões')]]", "//img[../select[contains(@name,'SFaixa_Etária_det')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '15 a 19 anos')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '20 a 24 anos')]]"),
          c('P_HOM25A29_SIM', "//select[@name='SGrande_Grupo_CID10']/*[text()[contains(., 'X85-Y09 Agressões')]]", "//img[../select[contains(@name,'SFaixa_Etária_det')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '25 a 29 anos')]]"),
          c('P_HOMMAIOR30_SIM', "//select[@name='SGrande_Grupo_CID10']/*[text()[contains(., 'X85-Y09 Agressões')]]", "//img[../select[contains(@name,'SFaixa_Etária_det')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '30 a 34 anos')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '35 a 39 anos')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '40 a 44 anos')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '45 a 49 anos')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '50 a 54 anos')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '55 a 59 anos')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '60 a 64 anos')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '65 a 69 anos')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '70 a 74 anos')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '75 a 79 anos')]]", "//select[@name='SFaixa_Etária_det']/*[text()[contains(., '80 anos e mais')]]"),
          c('P_HOMBRANCA_SIM', "//select[@name='SGrande_Grupo_CID10']/*[text()[contains(., 'X85-Y09 Agressões')]]",  "//img[../select[contains(@name,'SCor/raça')]]", "//select[@name='SCor/raça']/*[text()[contains(., 'Branca')]]"),
          c('P_HOMPRETA_SIM', "//select[@name='SGrande_Grupo_CID10']/*[text()[contains(., 'X85-Y09 Agressões')]]", "//img[../select[contains(@name,'SCor/raça')]]", "//select[@name='SCor/raça']/*[text()[contains(., 'Preta')]]"),
          c('P_HOMPARDA_SIM', "//select[@name='SGrande_Grupo_CID10']/*[text()[contains(., 'X85-Y09 Agressões')]]", "//img[../select[contains(@name,'SCor/raça')]]", "//select[@name='SCor/raça']/*[text()[contains(., 'Parda')]]"),
          c('P_HOMOUTROS_SIM', "//select[@name='SGrande_Grupo_CID10']/*[text()[contains(., 'X85-Y09 Agressões')]]", "//img[../select[contains(@name,'SCor/raça')]]", "//select[@name='SCor/raça']/*[text()[contains(., 'Indígena')]]", "//select[@name='SCor/raça']/*[text()[contains(., 'Amarela')]]", "//select[@name='SCor/raça']/*[text()[contains(., 'Ignorado')]]"),
          c('P_HOMHOMEM_SIM', "//select[@name='SGrande_Grupo_CID10']/*[text()[contains(., 'X85-Y09 Agressões')]]", "//img[../select[contains(@name,'SSexo')]]", "//select[@name='SSexo']/*[text()[contains(., 'Masc')]]"),
          c('P_HOMMULHER_SIM', "//select[@name='SGrande_Grupo_CID10']/*[text()[contains(., 'X85-Y09 Agressões')]]", "//img[../select[contains(@name,'SSexo')]]", "//select[@name='SSexo']/*[text()[contains(., 'Fem')]]")
)


#' Realiza a leitura dos arquivos excel
dados_pop <- as_tibble(readxl::read_excel("IMRS2021 - BASE DEMOGRAFIA 2000 a 2020.xlsx", sheet =1))

#' ## Faz a extração dos dados
#' 
#' ### Dados DATASUS

#' Para cada um dos indicadores na lista
for(indicador in c(1: length(lista))){
  
  #' Vai para a página inicial
  remDr$navigate(url)
  
  #' Seleciona os dados na linha
  remDr$findElement(using = "xpath", value = "//select[@name='Linha']//option[@value='Município']")$clickElement()
  
  #' Seleciona os dados da coluna  
  remDr$findElement(using = "xpath", value = "//select[@name='Coluna']//option[@value='Ano_do_Óbito']")$clickElement()
  
  #' Seleciona os dados que serão o conteúdo
  remDr$findElement(using = "xpath", value ="//select[@name='Incremento']//option[@value='Óbitos_p/Residênc']")$clickElement()  #desmarca a opção de óbitos p/Residência
  remDr$findElement(using = "xpath", value = "//select[@name='Incremento']//option[@value='Óbitos_p/Ocorrênc']")$clickElement()  #marca a opção de óbitos por Ocorrência
  
  #' Seleciona o período. Inicialmente verifica-se se o ano desejado está disponível e em seguida verifica se o ano desejado já está selecionado. Caso não esteja, o 
  #' ano é selecionado
  opcoes <- remDr$findElement(using = "name", value = 'Arquivos')
  a <- opcoes$selectTag()
  if(!(as.character(ano) %in% a$text)){ #verifica se existe o ano desejado
    stop("Ano não disponível")
  }
  else if(!a$selected[which(a$text == as.character(ano))]){ #verifica se ano desejado está selecionado
    remDr$findElement(using = "xpath", value = paste0("//select[@name='Arquivos']//option[contains(text(),", as.character(ano), ")]"))$clickElement()
  }
  
  #' Marca a opção Exibir linhas zeradas
  remDr$findElement(using = "xpath", value = "//input[@name='zeradas']")$clickElement()
  
  #' Seleciona a opção CID-10
  remDr$findElement(using = "xpath", value = "//img[../select[contains(@name,'SGrande_Grupo_CID10')]]")$clickElement()   #procura pela imagem tal que o pai tem um filho select cujo nome contém o texto desejado, em outras palavras, procura pelo símbolo de mais próximo ao texto Grande Grupo CID10
  remDr$findElement(using = "xpath", value = "//select[@name='SGrande_Grupo_CID10']//option[@value='TODAS_AS_CATEGORIAS__']")$clickElement()  #desmarca a opção todas as categorias
  
  #' Para cada indicador, faz as seleções
  for(item in c(2:length(lista[[indicador]]))){
    remDr$findElement(using = "xpath", value = lista[[indicador]][item])$clickElement()
  }
  
  #' Clica no botão mostra
  remDr$findElement(using = "xpath", value =  '//input[@name="mostre"]')$clickElement()
  
  #' Procura pela tabela de dados no html
  elem <- remDr$findElement(using="class", value="tabdados")
  
  #' Obtém o HTML
  elemtxt <- elem$getElementAttribute("outerHTML")
  
  #' Extrai a informação estruturada da tabela
  elem_html <- htmlTreeParse(elemtxt, useInternalNodes = T, asText = TRUE, encoding = "UTF-8")
  
  #' Converte a tabela em um dataframe
  tabela <- readHTMLTable(elem_html, header = T, stringsAsFactors = FALSE)[[1]]
  
  #' Seleciona as colunas de interesse
  tabela <- tabela %>% select(c(1, 3))
  
  #' Seleciona as linhas de interess
  tabela <- tabela[c(2:854), ]
  
  #' Altera os nomes das colunas
  names(tabela) <- c("municipio", "total")
  
  #' Substitui o - por NA
  tabela <- tabela %>% replace(tabela=='-', NA)
  
  #' Converte os números para o formato numérico
  tabela[, 2] <- sapply(tabela[, 2], as.numeric)
  
  #' Cria uma nova coluna com o código do ibge, extraindo a informação da coluna de municípios
  tabela <- tabela %>% mutate(IBGE6 = apply(tabela, 1, function(x) substr(x["municipio"], 1, 6) ))
  
  #' Converte o código de ibge para formato numérico
  tabela[, 3] <- sapply(tabela[, 3], as.numeric)

  #' Se for o primeiro indicador da lista, cria a tabela de indicadores com o código e o valor.
  #' Caso contrário, faz a união da tabela atual com a de indicadores 
  if(indicador == 1){
    indicadores <- tabela[, c(3, 2)]
  }
  else{
     indicadores <- merge(indicadores, tabela[, c(2, 3)], by="IBGE6")
  }
  
  #' Altera o nome da coluna que foi recém adicioanada para o nome do indicador
  names(indicadores)[names(indicadores)=="total"] <- lista[[indicador]][1]
  
  #' Imprime o nome do indicador
  print(lista[[indicador]][1])
 
}

#' ### Dados população

#' Filtra os dados para os municípios de Minas Gerais
dados_pop <- dados_pop %>% subset(dados_pop$ANO == as.numeric(ano)) %>% #seleciona as linhas para o ano de interesse
                           select(c(IBGE6, D_POPTA)) # seleciona as colunas com o código e a população

#' Faz a união da tabela de indicadores com a de população
indicadores <- merge(indicadores, dados_pop, by="IBGE6")

#' Atualiza o indicador calculando a taxa de homicídio por 100 mil habitantes
indicadores <- indicadores %>% mutate(P_HOMITX_SIM = round((P_HOMITX_SIM / D_POPTA) * 100000, digits = 2)) %>% select(-D_POPTA)
