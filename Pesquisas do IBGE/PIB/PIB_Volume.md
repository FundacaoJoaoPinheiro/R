Cálculo do PIB - Volume
================
Michel Rodrigo - <michel.alves@fjp.mg.gov.br> e João Paulo G. Garcia -
<joaopauloggarcia@gmail.com>
02 de julho de 2021

``` r
options(warn=-1)
```

## Limpa a memória e console

``` r
cat("\014")  
```



``` r
rm(list = ls())
```

## Configura o diretório de trabalho

Altera a pasta de trabalho para a mesma onde o script está salvo

``` r
dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(dir)
```

## Carrega as bibliotecas

``` r
pacotes <- c("purrr", "dplyr","tidyr", "sidrar", "stringr",            
             "magrittr", "rio", "data.table")
```

Verifica se alguma das bibliotecas necessárias ainda não foi instalada

``` r
pacotes_instalados <- pacotes %in% rownames(installed.packages())
if (any(pacotes_instalados == FALSE)) {
  install.packages(pacotes[!pacotes_instalados])
}
```

carrega as bibliotecas

``` r
lapply(pacotes, library, character.only=TRUE)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

    ## 
    ## Attaching package: 'magrittr'

    ## The following object is masked from 'package:tidyr':
    ## 
    ##     extract

    ## The following object is masked from 'package:purrr':
    ## 
    ##     set_names

    ## 
    ## Attaching package: 'data.table'

    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     between, first, last

    ## The following object is masked from 'package:purrr':
    ## 
    ##     transpose

## Importa os dados

Lista de API’s

``` r
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
```

Renomeia os objetos da lista. Para cada um dos 22 objetos da lista, será
atribuido um nome, que é obtido das informaçãos disponíveis na própria
API:

-   Número da tabela: vem depois de /t/. Por exemplo /t/2296/
    corresponde à tabela 2296
-   Território:
    -   n1/all indica todas as opções da unidade da federação, portanto,
        BRASIL.
    -   n3/31 indica a unidades federativas (n3) cujo código é 31,
        portanto, MG.
-   n7/3101 indica as regiões metropolitanas (n7), cujo código é 3101,
    portanto, RMBH.
-   ‘v’ indica variável.
-   ‘p’ indica período.
-   ‘d’ indica casas decimais. Função para extrair o número da tabela
    (segundo campo da API)

``` r
tab_num <- function(api){              
  str_extract(api, "(?<=/t/)\\d*")                  
}
```

Função para substituir os códigos do 4° campo pela Unidade Territorial

``` r
tab_UT <- function(api){                  
  ifelse(grepl('n1/all', api), 'BR',                                           
         ifelse(grepl('n3/31', api), 'MG',
                ifelse(grepl('n7/3101', api), 'RMBH', 'Valor de `x` inválido'))
  )
}
```

Obtém os nomes dos objetos da lista com os elementos extraídos

``` r
names(list_api_vol) <- paste0(
  'tab_',
  map(list_api_vol, tab_num),
  "_",
  map(list_api_vol, tab_UT)
)
```

Baixa os dados do SIDRA, aplicando a função `get_sidra` a cada uma das
API’s da lista

``` r
saida <- map(list_api_vol, ~ get_sidra(api = .x))
```

    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed
    ## All others arguments are desconsidered when 'api' is informed

## Manipulação da base de dados

Nessa etapa as tabelas serão transformadas para o formato wide e algumas
colunas serão manipuladas. Basicamente serão realizadas duas operações:
formatar em wide e agregar colunas. Para as tabelas 1092, 1093, 1094,
1086 e 915 apenas a segunda operação será aplicada.

### Editando Colunas

Serão necessárias as colunas CATEGORIAS e VALORES. Em todas as tabelas,
os valores estão na coluna nomeada “Valor”. No entanto, as colunas das
categorias estão com diferentes nomes. Apesar disso, elas seguem um
padrão: ou estão na 10ª, 12ª, 13ª ou 15ª posições.

-   categorias na coluna 10: tabelas 74, 5434

``` r
tipo1 <- c(7, 17)
```

-   categorias na coluna 12: tabelas 3419 (MG e BR)

``` r
tipo2 <- c(12:13)
```

-   categorias na coluna 13: tabelas 291, 289, 5434, 839, 1001, 1002 e
    5457

``` r
tipo3 <- c(6, 8:11, 15:21)
```

-   categorias na coluna 15: tabelas 6444 e 1618

``` r
tipo4 <- c(14, 22)
```

Para algumas tabelas é desejado que tenham junto das categorias suas
unidades de medidas

``` r
for (i in c(7,15,16)) {               # tabelas 74, 291 e 289
  saida[[i]][[10]] = paste0(
    saida[[i]][[10]],                 # coluna 10 é a coluna das categorias
    " (",
    saida[[i]][[12]],                 # coluna 12 é das unidades de medida
    ")"
  )
}
```

Renomeia as colunas de categorias para o nome “Categorias”

``` r
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
```

### Transformação para o formato wide

Antes de aplicar a operação, deve-se selecionar as colunas que vão ser
mantidas, isto é, uma coluna com informação sobre o tempo, a coluna
“Categoria” e a coluna “Valor”.

*Observação*: algumas exceções serão formatadas de forma individual
posteriormente. As exceções são decorrentes de tabelas com informação de
trimestres e as tabelas com mais de uma variável

``` r
excecao <- c(18:21)    # tabelas que trabalham com duas variáveis
```

### Criação de funções para as variáveis TEMPORAIS

Como dito anteriormente, algumas tabelas trabalham com trimestre. Para
essas tabelas, a coluna Ano\_Trimestre será transformada na coluna
Ano\_Mês.

Função para criar uma string no formato “2008 T2” a partir da coluna
‘Trimestre’

``` r
ano_tri <- function(col) {
  paste0(
    str_extract(col, "\\d{4}$"), # extrair o ano
    ' T',
    str_extract(col, "\\d(?=º)") # extrair o trimestre
  )
}
```

Função para associar a coluna ‘`Ano_Trimestre`’ com os meses
correspondentes

``` r
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
```

Função que gera o formato “2002 janeiro”

``` r
ano_mes <- function(df){
  paste0(
    str_extract(df$`Ano_Trimestre`, "^\\d*"),
    " ",
    meses_tri(df)
  )
}
```

*Observação*: essas funções definidas anteriormente serão aplicadas nas
próximas etapas

### Formatações por grupo

#### ABATE

Abate - Tabelas 1092; 1093; 1094; 1086; 915

Essas tabelas não precisam ser formatadas em wide; Serão montadas coluna
a coluna. Inicialmente serão criadas as colunas de mês e trimestre

``` r
saida$tab_1092_MG %<>% mutate(.,                                       
                              `Ano_Trimestre` = ano_tri(.$Trimestre)
)          

saida$tab_1092_MG %<>% mutate(.,                                       
                              `Ano_Mês` = ano_mes(.)
)
```

Cria a tabela “Abate”

``` r
Abate <- tibble(
  'Ano_Trimestre' = saida$tab_1092_MG$`Ano_Trimestre`,
  'Ano_Mês' = saida$tab_1092_MG$`Ano_Mês`,
  'Bovino tab_1092' = saida$tab_1092_MG$Valor,
  'Suínos tab_1093' = saida$tab_1093_MG$Valor,
  'Aves tab_1092' = saida$tab_1092_MG$Valor,
  'Leite tab_1086' = saida$tab_1086_MG$Valor,
  'Ovos tab_915' = saida$tab_915_MG$Valor
)
```

#### PPM - Tabelas 3939 e 74

Transforma a tabela 3939, selecionando somente os dados de interesse

``` r
saida$tab_3939_MG <- saida$tab_3939_MG %>% 
  dcast(Ano ~ `Categorias`, 
        value.var = 'Valor',
        fun.aggregate = sum)
```

Adiciona uma coluna “Aves Total”, que será a soma das colunas
“Galináceos Total” e “Codornas”

``` r
saida$tab_3939_MG %<>%
  mutate(
    `Aves Total` = .$`Galináceos - total` + .$Codornas
  )
```

Transforma a tabela 74, selecionando somente os dados de interesse

``` r
saida$tab_74_MG <- saida$tab_74_MG %>% 
  dcast(Ano ~ `Tipo de produto de origem animal`,
        value.var = 'Valor',
        fun.aggregate = sum)
```

Agrega as linhas das duas tabelas retirando a coluna duplicada “Ano”

``` r
PPM <- bind_cols(
  saida$tab_3939_MG,
  saida$tab_74_MG[,-1]
)
```

### LSPA

#### PAM - Quantidade Produzida - Tabelas 839, 1001, 1002 e 5457

Essas tabelas fazem parte das excessões

Primeiro será aplicado o filtro para variável igual a “Quantidade
Produzida”

``` r
filtro_QP <- saida [excecao] %>%
  map(
    filter,
    Variável == 'Quantidade produzida'
  )
```

Seleciona as colunas a serem mantidas depois da formatação

``` r
filtro_QP %<>%
  map(
    select,
    Ano,                       
    Categorias,
    Valor
  )
```

Passa para o formato wide

``` r
filtro_QP %<>%
  map(
    pivot_wider,
    names_from = 'Categorias',
    values_from = 'Valor'
  )
```

Retira as colunas “Ano” duplicadas, mantendo ela apenas na primeira
tabelawide

``` r
filtro_QP %<>%
  map_at(
    .at = -1,     # manter a coluna em uma tabela
    .f = select,
    - Ano
  )
```

Agrega as tabelas e criar objeto final

``` r
PAM_QP <- bind_cols(
  filtro_QP
)
```

#### PAM - Área plantada - Tabelas 839, 1001, 1002 e 5457

Aplica-se o mesmo procedimento acima, com a dirença que o filtro será
para Área Plantada.

``` r
filtro_AP <- saida [excecao] %>%
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
```

agregar as tabelas e criar objeto final

``` r
PAM_AP <- bind_cols(
  filtro_AP
)
```

#### LSPA - Quantidade Produzida - Tabela 1618

A tabela 1618 tem duas referências temporais.

``` r
LSPA_QP <- saida$tab_1618_MG %>%              
  filter(
    Variável == 'Produção'                    # filtra para Quantidade Produzida
  ) %>%
  select(                                     # seleciona colunas
    Mês,
    `Ano da safra`,
    Categorias,
    Valor
  ) %>%
  pivot_wider(                                # transforma para o formato wide
    names_from = 'Categorias',
    values_from = 'Valor'
  )
```

#### LSPA - Área Plantada - Tabela 1618

Aplica-se o mesmo prodimento acima, filtrando para Área plantada.

``` r
LSPA_AP <- saida$tab_1618_MG %>%
  filter(
    Variável != 'Produção'                    # filtra para Área Plantada
  ) %>%
  select(                                     # seleciona colunas
    Mês,
    `Ano da safra`,
    `Categorias`,
    `Valor`
  ) %>%
  pivot_wider(                                # passa para o formato wide
    names_from = 'Categorias',
    values_from = 'Valor'
  )
```

### PEVS

#### PIM-PF - Tabela 3653 (MG e BR)

``` r
PIM_PF <- saida$tab_3653_MG %>%
  filter(
    Categorias == "3.16 Fabricação de produtos de madeira"|
    Categorias == "3.17 Fabricação de celulose, papel e produtos de papel"|
    Categorias == "3.24 Metalurgia"
  ) %>%
  select(                                     # seleciona colunas
    Mês,
    `Categorias`,
    `Valor`
  ) %>%
  pivot_wider(                                # transforma para o formato wide
    names_from = 'Categorias',
    values_from = 'Valor'
  )

Extracao1 <- saida$tab_289_MG %>%
  select(                                     # seleciona colunas
    `Ano`,
    `Categorias`,
    `Valor`
  ) %>%
  pivot_wider(                                # transforma para o formato wide
    names_from = 'Categorias',
    values_from = 'Valor'
  )
Extracao2 <- saida$tab_291_MG %>%
  select(                                     # selecionar colunas
    `Ano`,
    `Categorias`,
    `Valor`
  ) %>%
  pivot_wider(                                # transforma para o formato wide
    names_from = 'Categorias',
    values_from = 'Valor'
  )

Extracao <- bind_cols(
  Extracao1,
  Extracao2[,-1]
)
```

#### PFI - MG - Tabela 3653 MG

``` r
MG_pim_pf <- saida$tab_3653_MG %>%
  select(                                     # seleciona colunas
    `Mês`,
    `Categorias`,
    `Valor`
  ) %>%
  pivot_wider(                                # transforma para o formato wide
    names_from = 'Categorias',
    values_from = 'Valor'
  )
```

#### PFI - BR - Tabela 3653 BR

``` r
BR_pim_pf <- saida$tab_3653_BR  %>%
  select(                                     # seleciona colunas
    `Mês`,
    `Categorias`,
    `Valor`
  ) %>%
  pivot_wider(                                # transforma para o formato wide
    names_from = 'Categorias',
    values_from = 'Valor'
  )
```

### PMC - tabelas 3416 e 3419

Agrega coluna à tabela 3419 com o valor da tabela 3416

``` r
MG_pmc <- saida$tab_3419_MG %>%
  mutate(
    `Índice de volume de vendas no comércio varejista` = saida$tab_3416_MG$`Índice base fixa (2014=100)`)
```

Reordena a coluna criada para a segunda posição

``` r
MG_pmc <- MG_pmc[c(1,15, 2:14)]
```

Agrega coluna à tabela 3419 com o valor da tabela 3416

``` r
BR_pmc <- saida$tab_3419_BR %>%
  mutate(
    `Índice de volume de vendas no comércio varejista` = saida$tab_3416_BR$`Índice base fixa (2014=100)`)
```

Reordena a coluna criada para a segunda posição

``` r
BR_pmc <- BR_pmc[c(1,15, 2:14)]
```

### PMS

Volume - Tabela 6444

``` r
Volume_pms <- saida$tab_6444_MG  %>%
  select(                                     # seleciona colunas
    `Mês`,
    `Categorias`,
    `Valor`
  ) %>%
  pivot_wider(                                # transforma para o formato wide
    names_from = 'Categorias',
    values_from = 'Valor'
  )
```

### PNADc

PNAD Trimestral - Tabela 5434

``` r
PNAD_trimestral <- saida$tab_5434_MG %>%
  select(                                     # seleciona colunas
    `Trimestre`,
     13, # corresponde a coluna categorias (essa tabela tem duas colunas com esse nome)
    `Valor`
  ) %>%
  pivot_wider(                                # transforma para o formato wide
    names_from = 'Categorias',
    values_from = 'Valor'
  )
```

## Exporta as planilhas

Nessa etapa será criada sete listas, uma pra cada uma das planilhas que
serão exportadas

``` r
V.ABATE <- list(Abate, PPM)
names(V.ABATE) <- c("Abate", "PPM")
V.LSPA <- list(PAM_AP, PAM_QP, LSPA_AP, LSPA_QP)
names(V.LSPA) <- c("PAM-AP", "PAM-QP", "LSPA-AP", "LSPA-QP")
V.PEVS <- list (PIM_PF, Extracao)
names(V.PEVS) <- c("PIM-PF", "Extracao")
V.PIM_PF <- list(MG_pim_pf, BR_pim_pf)
names(V.PIM_PF) <- c("MG PIM-PF", "BR PIM-PF")
V.PMC <- list(MG_pmc, BR_pmc)
names(V.PMC) <- c("MG PMC", "BR PMC")
V.PMS <- list(Volume_pms)
names(V.PMS) <- c("Volume PMS")
V.PNADc <- list(PNAD_trimestral)
names(V.PNADc) <- c("PNAD Trimestral")
```

Em seguida, salva cada planilha em um arquivo separado.

``` r
export(V.ABATE,
       file = 'V_ABATE.xlsx')
export(V.LSPA,
       file = "V_LSPA.xlsx")
export(V.PEVS,
       file = 'V_PEVS.xlsx')
export(V.PIM_PF,
       file = 'V_PIM-PF.xlsx')
export(V.PMC,
       file = 'V_PMC.xlsx')
export(V.PMS,
       file = 'V_PMS.xlsx')
export(V.PNADc,
       file = 'V_PNADc.xlsx')
```
