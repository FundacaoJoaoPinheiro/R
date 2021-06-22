#' ---
#' title: "PAC SIDRA"
#' author: "Michel Rodrigo - michel.alves@fjp.mg.gov.br"
#' date: "22 de junho de 2021"
#' output: github_document 
#' ---
#' 
#' Importação e manipulação da tabela 1407 do SIDRA - Pesquisa Anual de COmércio - IBGE  
#' 
#' Se quiser executar código inline, use o acento grave: dois mais dois igual a `r 2 + 2`
#' 
#' # Opções de visualização
#' 
#' Para configurar as opções de visualização do código, faça como a seguir: #+ r setup, warning = FALSE
  
#+ r setup, warning = FALSE

#' Outras opções:
#' 
#' * eval = TRUE     - executa o código e inclui o resultado
#' * echo = TRUE     - exibe o código e seu resultado
#' * warning = FALSE - exibe as mensagens de aviso
#' * error =  FALSE  - exibe as mensagens de erro
#' * tidy = FALSE    - exibe o código em um formato mais compacto
#' 
#' As configurações acima devem ser colocadas antes de cada bloco de código. caso
#' deseje fazer configurações globais, use
options(warn=-1)

#' # Estrutura do script
#' 
#' ## Inicialização
#' Limpa a memória e console
rm(list = ls())

#' Altera a pasta de trabalho para a mesma onde o script está salvo
dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(dir)

#' ## Bibliotecas
#' Bibliotecas necessárias
pacotes <- c("data.table", "forcats", "magrittr",
                "ggplot2", "plotly", "RColorBrewer")

#' Verifica se alguma das bibliotecas necessárias ainda não foi instalada
pacotes_instalados <- pacotes %in% rownames(installed.packages())
if (any(pacotes_instalados == FALSE)) {
  install.packages(pacotes[!pacotes_instalados])
}

#' carrega as bibliotecas
lapply(pacotes, library, character.only=TRUE)

#' ## Importação  dos dados
#' Verifica se os dados já não foi baixados
entrada  <- if (file.exists("Entrada/tab_1407.csv")) {
  "Entrada/tab_1407.csv"
} else {
  "https://sidra.ibge.gov.br/geratabela?format=us.csv&name=tabela1407.csv&terr=N&rank=-&query=t/1407/n1/all/v/312/p/all/c12354/all/c11066/allxt/l/,,p%2Bt%2Bc12354%2Bv%2Bc11066"
}

#' ## Manipulação da base de dados