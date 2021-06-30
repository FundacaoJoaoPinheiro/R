#' ---
#' title: "PIA SIDRA"
#' author: "Michel Rodrigo - michel.alves@fjp.mg.gov.br e João Paulo G. Garcia - joaopauloggarcia@gmail.com"
#' date: "30 de junho de 2021"
#' output: github_document 
#' ---
#' Importação e manipulação da tabela 1848 do SIDRA - Pesquisa Industrial Anual - IBGE 

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
lapply(pacotes, library, character.only=TRUE)


#' ## Importa os dados
#' 
#' Verifica se o arquivo com os dados já está salvo no diretório. Caso não esteja, os 
#' dados serão obtidos de forma online, realizando a consulta no site do sidra.
entrada  <- if (file.exists("Entrada/tab_1848.csv")) {
  "tab_1848.csv"
} else {
  "https://sidra.ibge.gov.br/geratabela?format=us.csv&name=tabela1848.csv&terr=NC&rank=-&query=t/1848/n1/all/n3/all/v/631,673,810,811,834,840/p/all/c12762/allxt/l/,,p%2Bt%2Bv%2Bc12762"
}

#' Importa a tabela
tab_1848 <- fread(entrada,
                  integer64 = "numeric",
                  na.strings = c('"-"','"X"'),
                  colClasses = c(list("factor" = c(1:5))),
                  col.names = c("Ano", "UF", "Estado",
                                "Var", "CNAE", "Valor"), 
                  encoding = "UTF-8")

#' ## Manipulação da base de dados
#' 
#' ### Exemplo 1 
#' 1 UF, 1 Variável e "N" CNAE's
n_cnae <- tab_1848[UF == "31" &
                   CNAE %like% "ferro" &
                   Var %like% "produção industrial"
                   ][, Rank := frank(-Valor, na.last = "keep"), by = Ano]

#' ### Exemplo 2
#' 1 UF, todas as Variáveis (tirando pessoal ocupado) e 1 CNAE
n_var <- tab_1848[UF == "31" &
                  Var  %like% "Mil Reais" &
                  CNAE %like% "10.8"]

#' ### Exemplo 3
#' "N" UF, 1 Variável e 1 CNAE
n_uf <- tab_1848[UF %in% c("31", "33", "35", "41") &
                 Var %like% "Pessoal" &
                 CNAE %like% "14 "]

#' ### Exemplo 4
#' Todos os Estados, 2 Variáveis (em formato wide), 6 Anos e todas as CNAE's

#' Filtra os dados e transforma para o formato wide com a função "dcast"
wide_var <- tab_1848[UF != "1" &
                     Var %like% "Salário|Custos" &
                     Ano %in% as.factor(2013:2018)] %>%
                     dcast(Ano + Estado + CNAE ~ Var, value.var = "Valor")

#' Simplifica os nomes de colunas
colnames(wide_var)[4:5] = c("Custos", "Salarios")

#' Cria as colunas de rank
wide_var[, `:=` (Rank_C = frank(-Custos, na.last = "keep"),
                 Rank_S = frank(-Salarios, na.last = "keep")),
         by = .(Ano, Estado)]

#' ## Visualização
#' 
#' ### Gráfico de bolhas
#' As 10 maiores CNAE's por Variável, Estado e Ano.

#' Coloca as CNAE's em ordem crescente
n_cnae$CNAE <- fct_reorder(n_cnae$CNAE, -n_cnae$Rank)

#' Constrói o gráfico
g_bolha <-  n_cnae[Rank <= 10] %>%
  ggplot(aes(x = Ano, y = CNAE, text = paste("Rank: ", Rank))) +
  geom_point(
    aes(size = Valor, color = as.factor(Rank)),
    show.legend = F
  ) +
  scale_size(range = c(3, 12)) +
  scale_color_brewer(palette = "Paired") +
  labs(y = "Produtos da Lavoura") 

#' Visualizar o gráfico
g_bolha

#' Opcionalmente, visualizar com o plotly
#+ eval = FALSE
p <- ggplotly(g_bolha, tooltip = c("text", "y", "size")) %>% hide_guides()

#' Se desejar salvar o gráfico em um arquivo .png
#+ eval = FALSE
export(p, file = "maiores_CNAE.png")

#' ### Gráfico de caixa
#' 1 Estado, 1 Variável, todos os Anos e todas as CNAE's

#' Usando os ranks pode-se escolher a abrangência das CNAE's
distribuicao <- n_cnae[Rank %between% c(1,5)] %>%
                      ggplot(aes(x = Ano, y = Valor/1000)) +
                      geom_jitter(aes(text = paste("CNAE: ", CNAE)),
                                  fill = "pink", alpha = 0.3, shape = 21) +
                      geom_boxplot(aes(fill = Ano), alpha = 0.6) +
                      theme_classic()

#' Visualiza o gráfico
distribuicao

#' Opcionalmente, visualizar com o plotly
#+ eval = FALSE
ggplotly(distribuicao, tooltip = c("text", "y")) %>% hide_guides()

#' ### Gráfico de correlação

#' Usando os ranks pode-se escolher a abrangência das duas variáveis
g_corr <- wide_var[Rank_C > 20 & Rank_S > 20] %>%
                  ggplot(aes(x = Salarios/1000, y = Custos/1000)) +
                  geom_jitter(aes(fill = Estado, text = paste("CNAE: ", CNAE),
                                  shape = "21", alpha = 0.3)) +
                  geom_smooth(aes(color = Ano), alpha = 0.6) +
                  theme_bw() +
                  facet_wrap(~Ano, nrow = 2)

#' Visualiza o gráfico
g_corr

#' ### Série histórica

#' Constrói o gráfico
serie_h <- n_cnae %>%
          ggplot(aes(x = Ano, y = Valor/1000)) +
          geom_line(aes(color = CNAE, group = CNAE)) +
          ylab("VPB Industrial (Mil Reais)")

#' Visualiza o gráfico
ggplotly(serie_h, tooltip = c("colors", "y", "x"))

