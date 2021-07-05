#' ---
#' title: "Cálculo do PIB - Volume"
#' author: "Michel Rodrigo - michel.alves@fjp.mg.gov.br e João Paulo G. Garcia - joaopauloggarcia@gmail.com"
#' date: "02 de julho de 2021"
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
pacotes <- c("purrr", "dplyr","tidyr", "sidrar", "stringr",            
             "magrittr", "rio", "data.table")

#' Verifica se alguma das bibliotecas necessárias ainda não foi instalada
pacotes_instalados <- pacotes %in% rownames(installed.packages())
if (any(pacotes_instalados == FALSE)) {
  install.packages(pacotes[!pacotes_instalados])
}

#' carrega as bibliotecas
lapply(pacotes, library, character.only=TRUE)


#' ## Importa os dados

#'  Lista de API's 
list_api_vol <- list("/t/1092/n3/31/v/284/p/last%205/c12716/allxt/c18/992/c12529/118225",
                     "/t/1093/n3/31/v/284/p/last%205/c12716/allxt/c12529/118225",
                     "/t/1094/n3/31/v/284/p/last%205/c12716/allxt/c12529/118225",
                     "/t/1086/n3/31/v/282/p/last%205/c12716/allxt/c12529/118225/d/v282%200",
                     "/t/915/n3/31/v/29/p/last%205/c12716/allxt",
                     "/t/3939/n3/31/v/all/p/last%202/c79/all",
                     "/t/74/n3/31/v/106/p/last%202/c80/allxt",
                     "/t/3653/n3/31/v/3135/p/last%2013/c544/all/d/v3135%201",
                     "/t/3653/n1/all/v/3135/p/last%2013/c544/all/d/v3135%201",
                     "/t/3416/n3/31/v/564/p/last%2013/c11046/40311/d/v564%201",
                     "/t/3416/n1/all/v/564/p/last%2013/c11046/40311/d/v564%201",
                     "/t/3419/n3/31/v/1186/p/last%2013/c11046/40311/c85/all/d/v1186%201",
                     "/t/3419/n1/all/v/1186/p/last%2013/c11046/40311/c85/all/d/v1186%201",
                     "/t/6444/n3/31/v/8677/p/last%2013/c11046/40311/c12355/all/d/v8677%201",
                     "/t/291/n3/31/v/142/p/last%202/c194/3455,3456,3458,3459",
                     "/t/289/n3/31/v/144/p/last%202/c193/3433,3434,3435",
                     "/t/5434/n3/31/v/4090/p/last%205/c693/all",
                     "/t/839/n3/31/v/109,214/p/last%202/c81/allxt",
                     "/t/1001/n3/31/v/109,214/p/last%202/c81/allxt",
                     "/t/1002/n3/31/v/109,214/p/last%202/c81/allxt",
                     "/t/5457/n3/31/v/214,8331/p/last%202/c782/allxt",
                     "/t/1618/n3/31/v/35,109/p/last%2013/c49/all/c48/allxt"
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
names(list_api_vol) <- paste0(
  'tab_',
  map(list_api_vol, tab_num),
  "_",
  map(list_api_vol, tab_UT)
)

#' Baixa os dados do SIDRA, aplicando a função `get_sidra` a cada uma das API's da lista
saida <- map(list_api_vol, ~ get_sidra(api = .x))

#' ## Manipulação da base de dados
#' 
#' Nessa etapa as tabelas serão transformadas para o formato wide e algumas colunas serão manipuladas.
#' Basicamente serão realizadas duas operações: formatar em wide e agregar colunas. Para
#' as tabelas 1092, 1093, 1094, 1086 e 915 apenas a segunda operação será aplicada.
#'
#' ### Editando Colunas
#' 
#' Serão necessárias as colunas CATEGORIAS e VALORES. Em todas as tabelas, os valores estão na 
#' coluna nomeada "Valor". No entanto, as colunas das categorias estão com diferentes nomes. Apesar disso, 
#' elas seguem um padrão: ou estão na 10ª, 12ª ou 13ª posições.
#'
#' * categorias na coluna 10: tabelas 74, 3653 (MG e BR), 3416 (MG e BR), 291, 289, 5434, 839, 1001, 1002 e 5457
tipo1 <- c(7, 17)

#' * categorias na coluna 12: tabelas 3419 (MG e BR), 6444 e 
tipo2 <- c(12:13)

#' * categorias na coluna 13: tabelas 3939
tipo3 <- c(6, 8:11, 15:16, 21)

#' * categorias na coluna 15: tabelas 1618
tipo4 <- c(14, 22)

#' Para algumas tabelas é desejado que tenham junto das categorias suas unidades de medidas
for (i in c(7,15,16)) {               # tabelas 74, 291 e 289
  saida[[i]][[10]] = paste0(
    saida[[i]][[10]],                 # coluna 10 é a coluna das categorias
    " (",
    saida[[i]][[12]],                 # coluna 12 é das unidades de medida
    ")"
  )
}

#' Renomeia as colunas de categorias para o nome "Categorias"
for (i in tipo1) {
  colnames(saida[[i]])[[10]] <- "Categorias"
}
for (i in tipo2) {
  colnames(saida[[i]])[[12]] <- "Categorias"
}
for (i in tipo3) {
  colnames(saida[[i]])[[13]] <- "Categorias"
}
for (i in tipo4) {
  colnames(saida[[i]])[[15]] <- "Categorias"
}



#' ### Transformação para o formato wide
#'
#' Antes de aplicar a operação, deve-se selecionar as colunas que vão ser mantidas, isto é, 
#' uma coluna temporal (sempre a 6ª), a coluna "Categoria" e a coluna "Valores".
#' 
#' *Observação*: algumas exceções serão formatadas de forma individual posteriormente. As exceções
#' são decorrentes de tabelas com informação de trimestres e as tabelas com mais de uma variável
excecao1<- c(1:14,22)    # tabelas que trabalham com trimestre ou duas referências temporais
excecao2 <- c(15:16, 18:21)    # tabelas que trabalham com duas variáveis

#' Seleciona as colunas a serem mantidas após a formatação
saida[-c(excecao1, excecao2)] %<>%              # retirar tabelas que são excessões
  map(                              
    select,
    8,
    Categorias,
    Valor
  )

#' Transforma as tabelas para formato wide
saida[-c(excecao1, excecao2)] %<>%
  map(
    pivot_wider,
    names_from = 'Categorias',
    values_from = 'Valor'
  )

#' ### Criação de funções para as variáveis TEMPORAIS 
#'
#' Como dito anteriormente, algumas tabelas trabalham com trimestre. Para essas tabelas, a coluna 
#' Ano_Trimestre será transformada na coluna Ano_Mês.
#' 
#' Função para criar uma string no formato "2008 T2" a partir da coluna 'Trimestre'
ano_tri <- function(col) {
  paste0(
    str_extract(col, "\\d{4}$"), # extrair o ano
    ' T',
    str_extract(col, "\\d(?=º)") # extrair o trimestre
  )
}

#' Função para associar a coluna '`Ano_Trimestre`' com os meses correspondentes
meses_tri <- function(df){
  case_when(str_detect(df$`Ano_Trimestre`, "(?<=T)1") & 
              str_detect(df$`Referência temporal`, "1(?=º)") ~ 'janeiro',
            str_detect(df$`Ano_Trimestre`, "(?<=T)1") & 
              str_detect(df$`Referência temporal`, "2(?=º)") ~ 'fevereiro',
            str_detect(df$`Ano_Trimestre`, "(?<=T)1") & 
              str_detect(df$`Referência temporal`, "3(?=º)") ~ 'março',
            str_detect(df$`Ano_Trimestre`, "(?<=T)2") & 
              str_detect(df$`Referência temporal`, "1(?=º)") ~ 'abril',
            str_detect(df$`Ano_Trimestre`, "(?<=T)2") & 
              str_detect(df$`Referência temporal`, "2(?=º)") ~ 'maio',
            str_detect(df$`Ano_Trimestre`, "(?<=T)2") & 
              str_detect(df$`Referência temporal`, "3(?=º)") ~ 'junho',
            str_detect(df$`Ano_Trimestre`, "(?<=T)3") & 
              str_detect(df$`Referência temporal`, "1(?=º)") ~ 'julho',
            str_detect(df$`Ano_Trimestre`, "(?<=T)3") & 
              str_detect(df$`Referência temporal`, "2(?=º)") ~ 'agosto',
            str_detect(df$`Ano_Trimestre`, "(?<=T)3") & 
              str_detect(df$`Referência temporal`, "3(?=º)") ~ 'setembro',
            str_detect(df$`Ano_Trimestre`, "(?<=T)4") & 
              str_detect(df$`Referência temporal`, "1(?=º)") ~ 'outubro',
            str_detect(df$`Ano_Trimestre`, "(?<=T)4") & 
              str_detect(df$`Referência temporal`, "2(?=º)") ~ 'novembro',
            str_detect(df$`Ano_Trimestre`, "(?<=T)4") & 
              str_detect(df$`Referência temporal`, "3(?=º)") ~ 'dezembro',
            TRUE ~ 'Valor de `df` inválido')
}

#' Função que gera o formato "2002 janeiro"
ano_mes <- function(df){
  paste0(
    str_extract(df$`Ano_Trimestre`, "^\\d*"),
    " ",
    meses_tri(df)
  )
}

#' *Observação*: essas funções definidas anteriormente serão aplicadas nas próximas 
#' 
#' ### Formatações por grupo

#' #### ABATE
#' 
#' Abate - Tabelas 1092; 1093; 1094; 1086; 915
#'  
#' Essas tabelas não precisam ser formatadas em wide; Serão montadas coluna a coluna. Inicialmente
#' serão criadas as colunas de mês e trimestre
saida$tab_1092_MG %<>% mutate(.,                                       
                              `Ano_Trimestre` = ano_tri(.$Trimestre)
)          

saida$tab_1092_MG %<>% mutate(.,                                       
                              `Ano_Mês` = ano_mes(.)
)

#' Cria a tabela "Abate"
Abate <- tibble(
  'Ano_Trimestre' = saida$tab_1092_MG$`Ano_Trimestre`,
  'Ano_Mês' = saida$tab_1092_MG$`Ano_Mês`,
  'Bovino tab_1092' = saida$tab_1092_MG$Valor,
  'Suínos tab_1093' = saida$tab_1093_MG$Valor,
  'Aves tab_1092' = saida$tab_1092_MG$Valor,
  'Leite tab_1086' = saida$tab_1086_MG$Valor,
  'Ovos tab_915' = saida$tab_915_MG$Valor
)

#' #### PPM - Tabelas 3939 e 74
#'
#' Transforma a tabela 3939, selecionando somente os dados de interesse
saida$tab_3939_MG <- saida$tab_3939_MG %>% 
  dcast(Ano ~ `Categorias`, 
        value.var = 'Valor',
        fun.aggregate = sum)


#' Adiciona uma coluna "Aves Total", que será a soma das colunas "Galináceos Total" e "Codornas"
saida$tab_3939_MG %<>%
  mutate(
    `Aves Total` = .$`Galináceos - total` + .$Codornas
  )

#' Transforma a tabela 74, selecionando somente os dados de interesse
saida$tab_74_MG <- saida$tab_74_MG %>% 
  dcast(Ano ~ `Tipo de produto de origem animal`,
        value.var = 'Valor',
        fun.aggregate = sum)

#' Agrega as linhas das duas tabelas retirando a coluna duplicada "Ano"
PPM <- bind_cols(
  saida$tab_3939_MG,
  saida$tab_74_MG[,-1]
)

#' ### LSPA
#'  
#' #### PAM - Quantidade Produzida - Tabelas 839, 1001, 1002 e 5457
#' 
#' Essas tabelas fazem parte das excessões, portanto ainda não foram formatadas
#' 
#' primeiro vamos filtrar a coluna de variável para "Quantidade Produzida"
filtro_QP <- saida [excecao2] %>%
  map(
    filter,
    Variável == 'Quantidade produzida'
  )

#' Seleciona as colunas a serem mantidas depois da formatação
filtro_QP %<>%
  map(
    select,
    Ano,                       
    Categorias,
    Valor
  )

#' Passa para o formato wide
filtro_QP %<>%
  map(
    pivot_wider,
    names_from = 'Categorias',
    values_from = 'Valor'
  )

#' agora vamos retirar as colunas "Ano" duplicadas, mantendo ela apenas na primeira tabelawide
filtro_QP %<>%
  map_at(
    .at = -1,     # vamos manter a coluna em uma tabela
    .f = select,
    - Ano
  )

# agregar as tabelas e criar objeto final
PAM_QP <- bind_cols(
  filtro_QP
)

#' #### PAM - Área plantada - Tabelas 839, 1001, 1002 e 5457

#' a mesma coisa de cima, só que agora vamos filtrar a "Área Plantada"
#' 
filtro_AP <- saida [excecao2] %>%
  map(
    filter,
    Variável != 'Quantidade produzida'
  ) %>%
    map(
      select,
      Ano,                       
      `Categorias`,
      Valor
    ) %>%
    map(
      pivot_wider,
      names_from = 'Categorias',
      values_from = 'Valor'
    ) %>%
    map_at(
      .at = -1,
      .f = select,
      - Ano
    ) 
#' agregar as tabelas e criar objeto final
PAM_AP <- bind_cols(
  filtro_AP
)

#' #### LSPA - Quantidade Produzida - Tabela 1618 
#' 
## tabela 1618 também está entre as exceções, no caso porque tem duas referências temporais
## vamos fazer as mesmas operações de antes, filtrando a variável e selecionando colunas
LSPA_QP <- saida$tab_1618_MG %>%              
  filter(
    Variável == 'Produção'                    # filtrar para Quantidade Produzida
  ) %>%
  select(                                     # selecionar colunas
    Mês,
    `Ano da safra`,
    Categorias,
    Valor
  ) %>%
  pivot_wider(                                # passar para o formato wide
    names_from = 'Categorias',
    values_from = 'Valor'
  )

#' #### LSPA - Área Plantada - Tabela 1618 
#' O mesmo que a de cima, só que filtrando para área plantada
LSPA_AP <- saida$tab_1618_MG %>%
  filter(
    Variável != 'Produção'                    # filtrar para Área Plantada
  ) %>%
  select(                                     # selecionar colunas
    Mês,
    `Ano da safra`,
    `Categorias`,
    `Valor`
  ) %>%
  pivot_wider(                                # passar para o formato wide
    names_from = 'Categorias',
    values_from = 'Valor'
  )

#' ### PEVS 
#' 
#' #### PIM-PF - Tabela 3653 (MG e BR)
#'
#'
PIM_PF <- saida$tab_3653_MG %>%
  filter(
    Categorias == "3.16 Fabricação de produtos de madeira"|
    Categorias == "3.17 Fabricação de celulose, papel e produtos de papel"|
    Categorias == "3.24 Metalurgia"
  ) %>%
  select(                                     # selecionar colunas
    Mês,
    `Categorias`,
    `Valor`
  ) %>%
  pivot_wider(                                # passar para o formato wide
    names_from = 'Categorias',
    values_from = 'Valor'
  )

Extracao1 <- saida$tab_289_MG %>%
  select(                                     # selecionar colunas
    `Ano`,
    `Categorias`,
    `Valor`
  ) %>%
  pivot_wider(                                # passar para o formato wide
    names_from = 'Categorias',
    values_from = 'Valor'
  )
Extracao2 <- saida$tab_291_MG %>%
  select(                                     # selecionar colunas
    `Ano`,
    `Categorias`,
    `Valor`
  ) %>%
  pivot_wider(                                # passar para o formato wide
    names_from = 'Categorias',
    values_from = 'Valor'
  )

Extracao <- bind_cols(
  Extracao1,
  Extracao2[,-1]
)

# 3.4.1 MG (nova) - Tabela 3653 MG ------------------------------------------
MG_pim_pf <- saida$tab_3653_MG %>%
  select(                                     # selecionar colunas
    `Mês`,
    `Categorias`,
    `Valor`
  ) %>%
  pivot_wider(                                # passar para o formato wide
    names_from = 'Categorias',
    values_from = 'Valor'
  )

# 3.4.2 BR (nova) - Tabela 3653 BR ------------------------------------------
BR_pim_pf <- saida$tab_3653_BR  %>%
  select(                                     # selecionar colunas
    `Mês`,
    `Categorias`,
    `Valor`
  ) %>%
  pivot_wider(                                # passar para o formato wide
    names_from = 'Categorias',
    values_from = 'Valor'
  )

# 3.5 V.PMC ======================================================================
## 3.5.1 MG (nova) - tabelas 3416 e 3419 ---------------------------------------
# essas tabelas já foram formatadas na 2.2. Basta manipular as colunas

# agregar coluna à tabela 3419 com o valor da tabela 3416
MG_pmc <- saida$tab_3419_MG %>%
  mutate(
    `Índice de volume de vendas no comércio varejista` = saida$tab_3416_MG$`Índice base fixa (2014=100)`)

# reordenar a coluna criada para a segunda posição
MG_pmc <- MG_pmc[c(1,15, 2:14)]

## 3.5.2 BR (nova) - tabelas 3416 e 3419 ---------------------------------------
# essas tabelas já foram formatadas na 2.2. Basta manipular as colunas

# agregar coluna à tabela 3419 com o valor da tabela 3416
BR_pmc <- saida$tab_3419_BR %>%
  mutate(
    `Índice de volume de vendas no comércio varejista` = saida$tab_3416_BR$`Índice base fixa (2014=100)`)
# reordenar a coluna criada para a segunda posição
BR_pmc <- BR_pmc[c(1,15, 2:14)]

# 3.6 V.PMS ======================================================================
# Volume - Tabela 6444 ------------------------------------------
## essas tabelas já foram formatadas na 2.2
Volume_pms <- saida$tab_6444_MG  %>%
  select(                                     # selecionar colunas
    `Mês`,
    `Categorias`,
    `Valor`
  ) %>%
  pivot_wider(                                # passar para o formato wide
    names_from = 'Categorias',
    values_from = 'Valor'
  )

