#' ---
#' title: "Cálculo do PIB - Volume"
#' author: "Michel Rodrigo - michel.alves@fjp.mg.gov.br e João Paulo G. Garcia - joaopauloggarcia@gmail.com"
#' date: "06 de julho de 2021"
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
pacotes <- c("dplyr","tidyr", "sidrar", "stringr",            # vetor contendo nomes dos pacotes utilizados
             "magrittr", "purrr", "rio")

#' Verifica se alguma das bibliotecas necessárias ainda não foi instalada
pacotes_instalados <- pacotes %in% rownames(installed.packages())
if (any(pacotes_instalados == FALSE)) {
  install.packages(pacotes[!pacotes_instalados])
}

#' carrega as bibliotecas
#+ results = "hide"
lapply(pacotes, library, character.only=TRUE)


#' ## Importa os dados

#'  Lista de API's
list_api_precos <- list ("/t/2296/n3/31/v/48,49/p/last%2013/d/v48%202",
                         "/t/3416/n3/31/v/565/p/last%2013/c11046/40311/d/v565%201",
                         "/t/3419/n3/31/v/1190/p/last%2013/c11046/40311/c85/all/d/v1190%201",
                         "/t/6444/n3/31/v/8676/p/last%2013/c11046/40311/c12355/all/d/v8676%201",
                         "/t/6903/n1/all/v/1396/p/last%2013/c842/all/d/v1396%202",
                         "/t/7060/n1/all/v/63/p/all/c315/7169,7202,7215,7256,7260,7276,7279,7355,7418,7432,7448,7451,7481,7482,7485,7549,7627,7634,7647,7683,7713,7720,7727,7728,7766,7789,12222,12393,12427,47659,47660,47662,107641/d/v63%202",
                         "/t/7060/n7/3101/v/63/p/all/c315/7169,7202,7215,7256,7260,7276,7279,7355,7418,7432,7448,7451,7481,7482,7485,7549,7627,7634,7647,7683,7713,7720,7727,7728,7766,7789,12222,12393,12427,47659,47660,47662,107641/d/v63%202"
                         
                         
)


#' Renomeia os objetos da lista. Para cada um dos 22 objetos da lista, será atribuido um nome, que 
#' é obtido das informaçãos disponíveis na própria API:
#' 
#' * Número da tabela: vem depois de /t/. Por exemplo /t/2296/ corresponde à tabela 2296
#' * Território: 
#'     - n1/all indica todas as opções da unidade da federação, portanto, BRASIL.
#'     - n3/31 indica a unidades federativas (n3) cujo código é 31, portanto, MG.
#' * n7/3101 indica as regiões metropolitanas (n7), cujo código é 3101, portanto, RMBH.
#' * 'v' indica variável. 
#' * 'p' indica período.
#' * 'd' indica casas decimais.
#' 
#' Função para extrair o número da tabela (segundo campo da API)
tab_num <- function(api){              
  str_extract(api, "(?<=/t/)\\d*")                  
}

#' Função para substituir os códigos do 4° campo pela Unidade Territorial
tab_UT <- function(api){                  
  ifelse(grepl('n1/all', api), 'BR',                                           
         ifelse(grepl('n3/31', api), 'MG',
                ifelse(grepl('n7/3101', api), 'RMBH', 'Valor de `x` inválido'))
  )
}

#' Obtém os nomes dos objetos da lista com os elementos extraídos
names(list_api_precos) <- paste0(
  'tab_',
  map(list_api_precos, tab_num),
  "_",
  map(list_api_precos, tab_UT)
)

#' Baixa os dados do SIDRA, aplicando a função `get_sidra` a cada uma das API's da lista
saida <- map(list_api_precos, ~ get_sidra(api = .x))

#' ## Manipulação da base de dados
#' 
#' ### Tabelas 2296 
#' 
#' Agregar as variáveis "número-índice" e "moeda corrente" em uma só tabela

saida$tab_2296_MG %<>%
  pivot_wider(
    names_from = "Variável",
    values_from = "Valor",
    id_cols = "Mês"
  )

#' ### Tabelas 3416 e 3419 
#' 
#' Transforma a tabela 3419 para formato wide e agrega uma coluna com valores da tabela 3416

saida$tab_3419_MG %<>%
        pivot_wider(                        # transforma para formato wide: 
        id_cols = "Mês",                    # coluna 'Mês'
        names_from = "Atividades",          # coluna 'Atividades' com os nomes das variáveis 
        values_from = "Valor"               # coluna 'Valores', com os valores da tabela
  ) %>%
        mutate(                             # adiciona a coluna 'Total', com os valores da tabela 3416
                'Total' = saida$tab_3416_MG$Valor
  )
#' Reordena as colunas para 'Total' ficar na segunda posição
saida$tab_3419_MG <- saida$tab_3419_MG[ 
  c(1,15, 2:14)                       
]

#' Remove a tabela 3416
saida["tab_3416_MG"]<- NULL          

#' ### Tabela 6444 
#' 
# Transforma para formato wide
saida$tab_6444_MG %<>%
  pivot_wider(                              # transforma para formato wide:
    id_cols = "Mês",                        # coluna 'Mês'
    names_from = "Atividades de serviços",  # coluna 'Atividades' com os nomes das variáveis 
    values_from = "Valor"                   # coluna 'Valores', com os valores da tabela
  )

#' ### Tabelas 6903 e 7060 
#' 
#' Transforma as tabelas para o formato wide
formatar_wide <- function(x){       # criar função 
  pivot_wider(                    # a mesma função anterior; passa para wide
    data = x,                     # x assume o valor de cada tabela selecionada
    id_cols = "Mês",              # posição original da coluna com os Meses nas tabelas selecionadas
    names_from = "Variável",      # posição original da coluna com os nomes das variáveis
    values_from = "Valor")        # posição original da coluna com os valores correspondentes
}

saida <- saida %>%
  map_at(                           # aplicar a função criada nas tabelas selecionadas
    .at = c(4,5,6),                 # vetor com as tabelas selecionadas
    .f = formatar_wide
  )

#' Substitui valores NA
saida <- rapply(saida, f = function(x) ifelse(is.na(x), 0, x), how = 'replace')


#' ## Exporta as tabelas
#+ eval = FALSE
export(saida,
       file = "preços_SIDRA_wide.xlsx")

