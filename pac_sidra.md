PAC SIDRA
================
Michel Rodrigo - <michel.alves@fjp.mg.gov.br>
22 de junho de 2021

Importação e manipulação da tabela 1407 do SIDRA - Pesquisa Anual de
Comércio - IBGE

``` r
options(warn=-1)
```

# Estrutura do script

## Inicialização

Limpa a memória e console

``` r
rm(list = ls())
```

Altera a pasta de trabalho para a mesma onde o script está salvo

``` r
dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(dir)
```

## Bibliotecas

Bibliotecas necessárias

``` r
pacotes <- c("data.table", "forcats", "magrittr",
                "ggplot2", "plotly", "RColorBrewer")
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
    ## Attaching package: 'plotly'

    ## The following object is masked from 'package:ggplot2':
    ## 
    ##     last_plot

    ## The following object is masked from 'package:stats':
    ## 
    ##     filter

    ## The following object is masked from 'package:graphics':
    ## 
    ##     layout

    ## [[1]]
    ## [1] "data.table" "stats"      "graphics"   "grDevices"  "utils"     
    ## [6] "datasets"   "methods"    "base"      
    ## 
    ## [[2]]
    ## [1] "forcats"    "data.table" "stats"      "graphics"   "grDevices" 
    ## [6] "utils"      "datasets"   "methods"    "base"      
    ## 
    ## [[3]]
    ##  [1] "magrittr"   "forcats"    "data.table" "stats"      "graphics"  
    ##  [6] "grDevices"  "utils"      "datasets"   "methods"    "base"      
    ## 
    ## [[4]]
    ##  [1] "ggplot2"    "magrittr"   "forcats"    "data.table" "stats"     
    ##  [6] "graphics"   "grDevices"  "utils"      "datasets"   "methods"   
    ## [11] "base"      
    ## 
    ## [[5]]
    ##  [1] "plotly"     "ggplot2"    "magrittr"   "forcats"    "data.table"
    ##  [6] "stats"      "graphics"   "grDevices"  "utils"      "datasets"  
    ## [11] "methods"    "base"      
    ## 
    ## [[6]]
    ##  [1] "RColorBrewer" "plotly"       "ggplot2"      "magrittr"     "forcats"     
    ##  [6] "data.table"   "stats"        "graphics"     "grDevices"    "utils"       
    ## [11] "datasets"     "methods"      "base"

## Importação dos dados

Verifica se os dados já não foram baixados

``` r
entrada  <- if (file.exists("tab_1407.csv")) {
  "tab_1407.csv"
} else {
  "https://sidra.ibge.gov.br/geratabela?format=us.csv&name=tabela1407.csv&terr=N&rank=-&query=t/1407/n1/all/v/312/p/all/c12354/all/c11066/allxt/l/,,p%2Bt%2Bc12354%2Bv%2Bc11066"
}
```

Realiza a importação da tabela

``` r
tab_1407 <- fread(entrada,
                  integer64 = "numeric",
                  na.strings = c('"-"','"X"'),
                  colClasses = c(list("factor" = c(1:5))),
                  col.names = c("Ano", "Brasil", "Territorio",
                                "Var", "Divisao", "Valor"),
                  encoding = "UTF-8")
```

## Manipulação dos dados

### EXEMPLO 1

1 Região, 1 Variável (Pessoal ocupado) e “N” Divisões de comércio

Realiza a filtragem dos dados

``` r
n_divisao <- tab_1407[Territorio %like% "Minas"][, Rank := frank(-Valor, na.last = "keep"), by = Ano]
```

### EXEMPLO 2

“N” Territórios, 1 Variável(Pessoal ocupado) e 1 Divisão Realiza a
filtragem dos dados

``` r
n_territorio <- tab_1407[Territorio %like% "Minas|Janeiro|Paulo|Sudeste" &
                           Divisao %like% "varejista"]
```

### EXEMPLO 3

Todos os Estados, 1 Variável, 2 Divisões (em formato wide) e 6 anos

``` r
wide_div <- tab_1407[!(Territorio %like% "Brasil|Região") &
                       Divisao %like% "veículos,|4.4Combustíveis" &
                       Ano %in% as.factor(2013:2018)] %>%
  dcast(Ano + Territorio ~ Divisao, value.var = "Valor")
```

Simplifica os nomes de colunas

``` r
colnames(wide_div)[3:4] = c("Comercio.de.veiculos", "Combustiveis")
```

Cria colunas de rank

``` r
wide_div[, `:=` (Rank_V = frank(-Comercio.de.veiculos, na.last = "keep"),
                 Rank_C = frank(-Combustiveis, na.last = "keep")),
         by = .(Ano, Territorio)]
```
