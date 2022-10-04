#' ---
#' title: "Título do script"
#' author: "Autor do script - email"
#' date: "Data de criação do script"
#' output: github_document 
#' ---
#' 
#' Para exibir texto, use #'. Observe que toda a sintaxe do markdown funciona aqui.
#' 
#' Se quiser executar código inline, use o acento grave: dois mais dois igual a `r 2 + 2`
#' 
#' # Opções de visualização
#' 
#' Para configurar as opções de visualização do código, faça como a seguir: #+ warning = FALSE
  
#+ warning = FALSE

#' Outras opções:
#' 
#' * eval = TRUE     - executa o código e inclui o resultado
#' * echo = TRUE     - exibe o código e seu resultado
#' * warning = FALSE - exibe as mensagens de aviso
#' * error =  FALSE  - exibe as mensagens de erro
#' * tidy = FALSE    - exibe o código em um formato mais compacto
#' * results = 'hide'- excuta o códifo e oculta o resultado
#' 
#' As configurações acima devem ser colocadas antes de cada bloco de código. caso
#' deseje fazer configurações globais, use
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
pacotes <- c("data.table", "forcats", "magrittr",
             "ggplot2", "plotly", "RColorBrewer")

#' Verifica se alguma das bibliotecas necessárias ainda não foi instalada
pacotes_instalados <- pacotes %in% rownames(installed.packages())
if (any(pacotes_instalados == FALSE)) {
  install.packages(pacotes[!pacotes_instalados])
}

#' carrega as bibliotecas
#+ results = "hide"
lapply(pacotes, library, character.only=TRUE)


#' ## Importa os dados

#' ## Manipulação da base de dados