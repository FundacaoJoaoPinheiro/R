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
             "magrittr", "rio")
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

    ## [[1]]
    ## [1] "purrr"     "stats"     "graphics"  "grDevices" "utils"     "datasets" 
    ## [7] "methods"   "base"     
    ## 
    ## [[2]]
    ## [1] "dplyr"     "purrr"     "stats"     "graphics"  "grDevices" "utils"    
    ## [7] "datasets"  "methods"   "base"     
    ## 
    ## [[3]]
    ##  [1] "tidyr"     "dplyr"     "purrr"     "stats"     "graphics"  "grDevices"
    ##  [7] "utils"     "datasets"  "methods"   "base"     
    ## 
    ## [[4]]
    ##  [1] "sidrar"    "tidyr"     "dplyr"     "purrr"     "stats"     "graphics" 
    ##  [7] "grDevices" "utils"     "datasets"  "methods"   "base"     
    ## 
    ## [[5]]
    ##  [1] "stringr"   "sidrar"    "tidyr"     "dplyr"     "purrr"     "stats"    
    ##  [7] "graphics"  "grDevices" "utils"     "datasets"  "methods"   "base"     
    ## 
    ## [[6]]
    ##  [1] "magrittr"  "stringr"   "sidrar"    "tidyr"     "dplyr"     "purrr"    
    ##  [7] "stats"     "graphics"  "grDevices" "utils"     "datasets"  "methods"  
    ## [13] "base"     
    ## 
    ## [[7]]
    ##  [1] "rio"       "magrittr"  "stringr"   "sidrar"    "tidyr"     "dplyr"    
    ##  [7] "purrr"     "stats"     "graphics"  "grDevices" "utils"     "datasets" 
    ## [13] "methods"   "base"

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
padrão: ou estão na 10ª ou na 12ª posições.

-   categorias na coluna 10: tabelas 3939, 74, 3653 (MG e BR), 3416 (MG
    e BR), 291, 289, 5434, 839, 1001, 1002 e 5457

``` r
tipo1 <- c(6:11, 15:21)
```

-   categorias na coluna 12: tabelas 3419 (MG e BR), 6444 e 1618

``` r
tipo2 <- c(12:14, 22)
```
