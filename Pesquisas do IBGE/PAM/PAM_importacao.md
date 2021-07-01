PAM SIDRA - Importação
================
Michel Rodrigo - <michel.alves@fjp.mg.gov.br>
28 de junho de 2021

Importação e manipulação da tabela 5457 do SIDRA - Produção Agrícola
Municipal - IBGE

``` r
options(warn=-1)
```

# Estrutura do script

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
pacotes <- c("tidyverse", "sidrar", "data.table", "openxlsx", "curl")
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

    ## -- Attaching packages --------------------------------------- tidyverse 1.3.1 --

    ## v ggplot2 3.3.3     v purrr   0.3.4
    ## v tibble  3.1.1     v dplyr   1.0.6
    ## v tidyr   1.1.3     v stringr 1.4.0
    ## v readr   1.4.0     v forcats 0.5.1

    ## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

    ## 
    ## Attaching package: 'data.table'

    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     between, first, last

    ## The following object is masked from 'package:purrr':
    ## 
    ##     transpose

    ## Using libcurl 7.64.1 with Schannel

    ## 
    ## Attaching package: 'curl'

    ## The following object is masked from 'package:readr':
    ## 
    ##     parse_date

## Importação e manipulação dos dados

### Agregado - MG

Importa a tabela do SIDRA

``` r
MG_agr<- get_sidra( 5457,
                    variable = c(112,214,215,216),
                    period = c("last" = 17),
                    geo = "State",
                    geo.filter = list("State" = 31),
                    classific = "c782",
                    #category = "allxt",
                    header = TRUE,
                    format = 2
)
```

Renomeia a coluna de categorias, deixando a aplicação de filtros mais
simples

``` r
names(MG_agr)[[7]] <- "Produto"
```

Adiciona uma coluna “Rank” que será útil posteriormente

``` r
MG_agr <-  MG_agr %>%
           group_by(Variável, Ano) %>%
           mutate("Valorxt" = ifelse(Produto != 'Total', Valor, as.numeric(NA)),
                 "Rank" = frank(desc(Valorxt), na.last = "keep")
  )
```

### Agregado - UF’s

A importação online por meio da funcão `get_sidra` só é possível se a
consulta retornar menos de 50000 observações. Isso é uma limitação da
função. Caso sua consulta atenda essa restrição, use a função a seguir:

``` r
# UF_agr<- get_sidra( 5457,
#                     variable = c(112,214,215,216),
#                     period = c("last" = 17),
#                     geo = "State",
#                     classific = "c782",
#                     #category = "allxt",
#                     header = TRUE,
#                     format = 2
# )
```

Se sua consulta retornar mais de 50000 observações, a importação deverá
ser feita pela url a seguir, salvando os dados em um arquivo csv e em
seguido carregando os dados a partir dele. Esse arquivo só precisa ser
baixado uma única vez.

``` r
# curl_download(
#   url = "https://sidra.ibge.gov.br/geratabela?format=br.csv&name=tabela5457.csv&terr=NC&rank=-&query=t/5457/n3/all/v/112,214,215,216/p/last%2017/c782/all/l/,,t%2Bp%2Bv%2Bc782",
#   destfile = "t5457_UF.csv"   
# )
```

Gera a tabela a partir do arquivo csv

``` r
UF_agr <- read.csv2("t5457_UF.csv", skip = 1, na.strings = c("-","..","..."), encoding = "UTF-8")
```

Renomeia coluna de Valor

``` r
colnames(UF_agr)[[6]] <- "Valor"
```

Renomeia a coluna dos Produtos

``` r
colnames(UF_agr)[[5]] <- "Produto"
```

Cria coluna de ranks

``` r
UF_agr <-  UF_agr %>%
           group_by(Ano, Variável, `Unidade.da.Federação`)%>%
           mutate("Valorxt" = ifelse(Produto != 'Total', Valor, as.numeric(NA)),
                  "Rank" = rank(desc(Valorxt), na.last = "keep")
)
```

### Desagregado MG

Não é possível importar tabelas para as Regiões Intermediárias
diretamente. Para trabalhar com os dados dessas regiões, é necessário,
antes, importar os dados desagrados

``` r
MG_mun <- bind_rows(
  read.csv2("MG_mun1.csv", 
            skip = 1, 
            nrows = 2088144, 
            na.strings = c("..","...","-"), 
            encoding = "UTF-8"),
  read.csv2("MG_mun2.csv", 
            skip = 1, 
            nrows = 2088144, 
            na.strings = c("..","...","-"), 
            encoding = "UTF-8")
) 
```

Renomeia a coluna de valores

``` r
colnames(MG_mun)[[6]] <- "Valor"
```

Renomeia a coluna de produtos

``` r
colnames(MG_mun)[[5]] <- "Produto"
```

Cria coluna com as RegInts. Importa os dados para uma tabela

``` r
geo_cod <- read.xlsx("regints")
```

Cria as colunas

``` r
MG_mun <- MG_mun %>%
          mutate("RegInt" = geo_cod$nome_rgint[match(MG_mun$Cód.,
                                        geo_cod$CD_GEOCODI)],
                 "Cód.RegInt" = geo_cod$cod_rgint[match(MG_mun$Cód.,
                                           geo_cod$CD_GEOCODI)]
                 )
```

Realocar as colunas criadas para o começo da tabela

``` r
MG_mun <- MG_mun %>%
          relocate("Cód.RegInt", "RegInt", 
                    .after = Município
          )
```

### Agregado - Regiões Intermediárias (MG e BR)

A seguir será gerada uma tabela para as RegInt’s de MG. Para realizar o
mesmo processo para o Brasil, basta substituir MG\_mun por BR\_mun EM
TODAS AS PRÓXIMAS LINHAS OBS: as outras tabelas já fornecem dados
desagregados filtráveis por RegInt

``` r
regint_agr <- MG_mun %>%
              group_by(Ano, Cód.RegInt, RegInt, Variável, Produto) %>%
              summarise("Valor" = sum(Valor, na.rm = TRUE))
```

    ## `summarise()` has grouped output by 'Ano', 'Cód.RegInt', 'RegInt', 'Variável'. You can override using the `.groups` argument.

cria coluna de ranks

``` r
regint_agr <- regint_agr %>%
  mutate("Rank" = frank(desc(Valor), na.last = "keep")) 
```

### Desagregado - BR

Os dados desagregados para todos os municípios do Brasil são muitos, não
sendo possível importar todos de uma vez. É necessário baixar
manualmente e então acessar os arquivos na memória do computador. A
opção é baixar um arquvo csv por ano, entre 2002 e 2018.

#### Importa as tabelas em uma lista

Inicialmente cria-se um vetor com os nomes das tabelas

``` r
nomes <- paste0("tab", "_", "5457", "_", 2002:2018) # ex: "tab_5457_2012"
```

Cria uma lista que será preenchida com as 17 tabelas importadas
utilizando as função `read.csv2` em combinação com o comando `for`

``` r
tabelas <- vector("list", 17)
for (i in 1:17) {
  tabelas[[i]] <- read.csv2(file = paste0(nomes[[i]], ".csv"),
                            skip = 1,                          # pular linhas com as descrições das tabelas
                            nrows = 1602144,                    # não ler as notas
                            na.strings = c("-","..","..."),    # NA's; ver notas no final da página: https://sidra.ibge.gov.br/tabela/5457
                            encoding = "UTF-8")
}
```

Nomeia os itens da lista com os nomes das tabelas

``` r
names(tabelas) <- nomes
```

#### Formata a tabela

Cria uma tabela única com todos os dados de município (BR)

``` r
BR_mun <- bind_rows(tabelas)
```

Renomeia a coluna de valores

``` r
colnames(BR_mun)[[6]] <- "Valor"
```

Renomeia a coluna de produtos

``` r
colnames(BR_mun)[[5]] <- "Produto"
```

Cria algumas colunas que serão úteis. Inicialmente baixa o arquivo csv
com os municípios por regint

``` r
# curl_download(
#     url = "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/divisao_regional/divisao_regional_do_brasil/divisao_regional_do_brasil_em_geo_cod_2017/tabelas/geo_cod_composicao_por_municipios_2017_20180911.xlsx",
#     destfile = "regints"
# )
```

Importa os dados para uma tabela

``` r
geo_cod <- read.xlsx("regints")
```

Cria as coluna com a função mutate

``` r
BR_mun <- BR_mun %>%
 mutate(
   "UF" = str_sub(BR_mun$Município,-5.-2),            # extrair a penúltima (-2) e a antepenúltima (-5. letras; ex: Cabixi (RO) --> RO
   "RegInt" = geo_cod$nome_rgint[match(BR_mun$Cód.,
                                       geo_cod$CD_GEOCODI)],
   "Cód.RegInt" = geo_cod$cod_rgint[match(BR_mun$Cód.,
                                          geo_cod$CD_GEOCODI)]
 )
```

Realoca as colunas criadas para o começo da tabela

``` r
BR_mun <- BR_mun %>%
 relocate(
   "Cód.RegInt", "RegInt", "UF",
   .after = Município
)
```
