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
cat("\014")  
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

### Exemplo 1

1 Região, 1 Variável (Pessoal ocupado) e “N” Divisões de comércio

Realiza a filtragem dos dados

``` r
n_divisao <- tab_1407[Territorio %like% "Minas"][, Rank := frank(-Valor, na.last = "keep"), by = Ano]
```

### Exemplo 2

“N” Territórios, 1 Variável(Pessoal ocupado) e 1 Divisão Realiza a
filtragem dos dados

``` r
n_territorio <- tab_1407[Territorio %like% "Minas|Janeiro|Paulo|Sudeste" &
                           Divisao %like% "varejista"]
```

### Exemplo 3

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

## Visualização

### Gráfico de bolhas

As 10 maiores divisões por variável, estado e ano

``` r
n_divisao$Divisao <- fct_reorder(n_divisao$Divisao, -n_divisao$Rank)

g_bolha <-  n_divisao[Rank <= 10] %>%
  ggplot(aes(x = Ano, y = Divisao, text = paste("Rank: ", Rank))) +
  geom_point(
    aes(size = Valor, color = as.factor(Rank)),
    show.legend = F
  ) +
  scale_size(range = c(3, 12)) +
  scale_color_brewer(palette = "Paired") +
  labs(y = "Divisão de comércio e grupo de atividade") 
```

Salva a imagem em um arquivo.

``` r
p <- ggplotly(g_bolha, tooltip = c("text", "y", "size")) %>% hide_guides()
export(p, file = "grafico_bolhas.png")
```

![](pac_sidra_files/figure-gfm/grafico_bolhas-1.png)<!-- -->

### Gráfico de caixa

1 Estado, 1 Variável, todos os Anos e todas as Divisao’s Usando os ranks
podemos escolher a abrangência das Divisao’s

``` r
distribuicao <- n_divisao[Rank %between% c(20,50)] %>%
  ggplot(aes(x = Ano, y = Valor/1000)) +
  geom_jitter(aes(text = paste("Divisao: ", Divisao)),
              fill = "pink", alpha = 0.3, shape = 21) +
  geom_boxplot(aes(fill = Ano), alpha = 0.6) +
  theme_classic()
```

Salva a imagem em um arquivo.

``` r
p <- ggplotly(distribuicao, tooltip = c("text", "y")) %>% hide_guides()
export(p, file = "grafico_caixa.png")
```

![](pac_sidra_files/figure-gfm/grafico_caixa-1.png)<!-- -->

### Gráfico de correlação

Série histórica

``` r
# elaboração do gráfico
serie_h <- n_divisao %>%
  ggplot(aes(x = Ano, y = Valor/1000)) +
  geom_line(aes(color = Divisao, group = Divisao)) +
  ylab("Divisão de comércio e grupo de atividade") +
  theme(legend.position="right")
```

Salva a imagem em um arquivo. Observação, se quiser exbir a legenda,
retire o trecho %&gt;% hide\_guides() da linha a seguir

``` r
p <- ggplotly(serie_h, tooltip = c("color", "y", "x")) %>% hide_guides()
export(p, file = "grafico_correlacao.png")
```

![](pac_sidra_files/figure-gfm/grafico_correlacao-1.png)<!-- -->
