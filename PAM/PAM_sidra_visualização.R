#' ---
#' title: "PAM SIDRA - Visualização"
#' author: "Michel Rodrigo - michel.alves@fjp.mg.gov.br"
#' date: "29 de junho de 2021"
#' output: github_document 
#' ---
#' Esse script contém exemplos de visualização dos dados gerados no script "PAM_sidra_importação". Execute
#' o referido script antes de executar esse.

options(warn=-1)

#' # Estrutura do script
#' 
#' ## Limpa a memória e console
cat("\014")  
#rm(list = ls())

#' ## Configura o diretório de trabalho
#' Altera a pasta de trabalho para a mesma onde o script está salvo
dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(dir)

load(".RData")

#' ## Carrega as bibliotecas
pacotes <- c("tidyverse", "sidrar", "data.table", "openxlsx", "curl", "ggplot2", "plotly")

#' Verifica se alguma das bibliotecas necessárias ainda não foi instalada
pacotes_instalados <- pacotes %in% rownames(installed.packages())
if (any(pacotes_instalados == FALSE)) {
  install.packages(pacotes[!pacotes_instalados])
}

#' carrega as bibliotecas
#+ results = "hide"
lapply(pacotes, library, character.only=TRUE)

#' ## Geração de gráficos
#' 
#' ### "N" Maiores de Minas

#' Filtra os dados. Inicialmente os dados serão manipulados, selecionando "n" maiores
t_maiores <- MG_agr %>%
  group_by(Variável,Ano) %>%                    # poderíamos fazer outros filtros, por exemplo da Variável
  slice_max(Valor, n = 5) %>%                  # seleciona as cinco maiores linhas por Ano e Variável (que foram agrupadas)
  filter(Ano >= 2010, Produto != "Total")       # de 2010 para frente para facilitar a visualização

#' Constrói o gráfico 
g_maiores <-  t_maiores %>%
  ggplot(aes(x = Ano, y = factor(Produto), text = Rank)) +
  geom_point(
    mapping = aes(size = Valor, alpha = -Rank, color = Variável),
    show.legend = F
  ) +
  facet_wrap(~Variável, nrow = 2, scales = "free_y") +
  scale_size(range = c(4.5,10)) +
  scale_alpha(range = c(0.3,1)) +
  labs(y = "Produtos da Lavoura") 

# Visualizar o gráfico
g_maiores

## visualizar o gráfico com o plotly (opcional)
p <- plotly::ggplotly(g_maiores, tooltip = c("text", "y", "size")) %>% plotly::hide_guides()
export(p, file = "n_maiores.png")