Importação dos dados IMRS dimensão Esporte
================
Michel Alves - <michel.alves@fjp.mg.gov.br>
janeiro de 2022

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
pacotes <- c("readxl", "tidyverse", "fuzzyjoin", "janitor", "writexl", "stringdist", "hablar")
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

    ## v ggplot2 3.3.5     v purrr   0.3.4
    ## v tibble  3.1.6     v dplyr   1.0.7
    ## v tidyr   1.1.4     v stringr 1.4.0
    ## v readr   2.1.1     v forcats 0.5.1

    ## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

    ## 
    ## Attaching package: 'janitor'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     chisq.test, fisher.test

    ## 
    ## Attaching package: 'stringdist'

    ## The following object is masked from 'package:tidyr':
    ## 
    ##     extract

    ## 
    ## Attaching package: 'hablar'

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     na_if

    ## The following object is masked from 'package:tibble':
    ## 
    ##     num

Ano para o qual deseja-se obter os dados (ou seja, colaca-se o ano
anterior ao atual)

``` r
ano_dados = 2021
```

## Importação dos dados

Aqui é realizada a leitura dos arquivos em formato .xlsx. Os arquivos
deverão estar na mesma pasta em que o script está salvo.

``` r
dados_imrs <- as_tibble(readxl::read_excel("IMRS2021 - BASE ESPORTE.xlsx", sheet = 1, col_types = c("numeric", "numeric", "numeric", "numeric", "text", "numeric", "text", "numeric", "numeric", "numeric", "text", "text", "text" )))
dados_icms <- as_tibble(readxl::read_excel("Dados_Basicos_Esporte_2022.xlsx", sheet = 1))
dados_quadra <- as_tibble(readxl::read_excel("Quadras.xlsx", sheet = 1))
dados_munic <- as_tibble(readxl::read_excel("Base Suplemento Esporte MUNIC 2016.xls", sheet = 2))
dados_munic_acoes <- as_tibble(readxl::read_excel("Base Suplemento Esporte MUNIC 2016.xls", sheet = 6))
dados_munic_conv <- as_tibble(readxl::read_excel("Base Suplemento Esporte MUNIC 2016.xls", sheet = 5))
dados_munic_equip <- as_tibble(readxl::read_excel("Base Suplemento Esporte MUNIC 2016.xls", sheet = 8))
```

## Tratamento dos dados

### Dados do ICMS

``` r
dados_icms <- dados_icms %>% janitor::clean_names()
```

Faz a conversão dos dados de caracter para númerico

``` r
dados_icms[, c(5:8)] <- sapply(dados_icms[, c(5:8)], as.numeric)
```

Reconstrói o código IBGE

``` r
dados_icms <- dados_icms %>% mutate(ibge = as.character(ibge)) %>%
                             mutate(IBGE6 = apply(dados_icms, 1, function (x) as.numeric(paste0("31", gsub(" ", "0", x["ibge"])))))
```

Cria a coluna de chave, usando o ano anterior (ou seja, o último ano em
que foram calculados os indicadores do IMRS). Posteriormente, essa chave
será atualizada

``` r
dados_icms <- dados_icms %>% mutate(CHAVE = as.numeric(paste0(ano_dados-1, IBGE6)))
```

Assinalando não para os valores ausentes, lembrando que na base do Max,
municipios que não tem conselho de esporte aparecem como missing

``` r
dados_icms[is.na(dados_icms$conselho_de_esportes), "conselho_de_esportes"] <- "NÃO"
```

Cria a tabela de indicadores, que é o resultado da união dos dados do
IMRS com os dados do ICMS utilizando a chave do ano anterior

``` r
indicadores <- merge(dados_imrs, dados_icms, by = c("CHAVE", "IBGE6")) 
```

Atualiza a chave e o ano na tabela indicadores

``` r
indicadores <- indicadores %>% mutate(CHAVE = paste0(ano_dados, substring(CHAVE, 5))) %>% 
                               mutate(ANO = ano_dados)
```

Remove os valores relativos ao ano anterior

``` r
indicadores[, 5:13] <- NA # seleciona todas as linhas e colunas de 5 a 13 e atribui o valor NA a elas
```

Cálculo do indicador: dado as cidades que tem conselho de esportes
(primeira linha), dividir a pontuação pelos pesos

``` r
indicadores <- indicadores %>% mutate(L_PROGE =  if_else_(indicadores$conselho_de_esportes=="SIM",
                                                         if_else_(is.na(indicadores$pontuacao_municipio_soma_das_atividades_do_municipio), 0, 
                                                                  if_else_(is.na(indicadores$pontuacao_municipio_soma_das_atividades_do_municipio/indicadores$peso_da_rcl), 0, indicadores$pontuacao_municipio_soma_das_atividades_do_municipio/indicadores$peso_da_rcl)), 0))

indicadores <- indicadores %>% mutate(L_CONSESP = indicadores$conselho_de_esportes)
```

Corrige o valor das variáveis binárias

``` r
indicadores$L_CONSESP = case_when(indicadores$L_CONSESP == "SIM" ~ "Sim",
                                  indicadores$L_CONSESP == "NÃO" ~ "Não",
                                  TRUE ~ as.character(NA))
```

Default do R é apresentar números em notação cinentífica, aqui
eliminamos essa possibilidade.

``` r
options(scipen = 9999999)
indicadores <- indicadores %>% mutate(L_ILRHE =  if_else_(indicadores$conselho_de_esportes=="SIM",
                                                          if_else_(is.na(indicadores$pontuacao_municipio_soma_das_atividades_do_municipio), 0, (indicadores$pontuacao_municipio_soma_das_atividades_do_municipio/indicadores$soma_pontuacao_municipios_mg)*100), 0))
```

Remove as colunas que não são mais necessárias

``` r
indicadores <- indicadores %>% select(-c(14:22))
```

### Dados MUNIC

Filtra os dados para os municípios de Minas Gerais

``` r
dados_munic <- dados_munic %>% subset(substr(dados_munic$S1, 1, 2) == "31") %>% #seleciona as linhas cujos códigos
                                                                                # de município começam com 31
                               select(c(1, 2)) # seleciona as colunas com as variáveis de interesse
```

Altera o nome da coluna S1 para IBGE7

``` r
colnames(dados_munic) <- c("IBGE7", "S2")
```

Faz a união das duas tabelas de acordo com o código do ibge

``` r
indicadores <- merge(indicadores, dados_munic, by = "IBGE7")
```

Tipo de órgão gestor do esporte

``` r
indicadores <- indicadores %>% mutate(L_ORGESP = if_else_(indicadores$S2 == "Órgão da administração indireta" | 
                                                          indicadores$S2 == "Setor subordinado a outra secretaria" |
                                                          indicadores$S2 == "Secretaria municipal em conjunto com outras políticas setoriais" |  
                                                          indicadores$S2 == "Setor subordinado diretamente à chefia do Executivo", true = "Outros", false = dados_munic$S2,
                                                          missing = NA)) %>%
                               select(-S2)
```

Verifica se todos os valores do indicador l\_orgesp estão corretos

``` r
if (sum(c("Outros", "Não possui estrutura", "Secretaria municipal exclusiva") %in% tabyl(indicadores$L_ORGESP)[[1]]) < 3 ){
  stop("Erro na variável S2 da MUNIC. Algum município não se enquadra em um dos valores esperado ")
}
```

Filtra os dados para os municípios de Minas Gerais

``` r
dados_munic_conv <- dados_munic_conv %>% subset(substr(dados_munic_conv$S1, 1, 2) == "31") %>% #seleciona as linhas cujos códigos 
                                                                                               # de município começam com 31
                                         select(c(1, 5)) # seleciona as colunas com as variáveis de interesse (S1, S57)
```

Altera o nome da coluna S1 para IBGE7

``` r
colnames(dados_munic_conv) <- c("IBGE7", "S57")
```

Faz a união das duas tabelas de acordo com o código do ibge

``` r
indicadores <- merge(indicadores, dados_munic_conv, by = "IBGE7")
```

Obtém o indicador *Observação*: para realizar a leitura a partir da
MUNIC, basta descomentar as próximas duas linhas.

``` r
#indicadores <- indicadores %>% mutate(L_CONVESP = indicadores$S57) %>%
#                               select(-S57)
```

Caso deseje preencher o indicador com Não, basta descomentar as duas
linhas seguintes.

``` r
indicadores <- indicadores %>% mutate(L_CONVESP = "Não") %>%
                               select(-S57)
```

Por fim, se desejar deixar os valores em branco, basta descomentar a
linha a seguir

``` r
#indicadores <- indicadores %>% select(-S57)
```

Filtra os dados para os municípios de Minas Gerais

``` r
dados_munic_equip <- dados_munic_equip %>% subset(substr(dados_munic_equip$S1, 1, 2) == "31") %>% #seleciona as linhas cujos códigos 
                                                                                                  # de município começam com 31
                                        select(c(1, 2, 3)) # seleciona as colunas com as variáveis de interesse (S1, S628, S629)
```

Altera o nome da coluna S1 para IBGE7

``` r
colnames(dados_munic_equip) <- c("IBGE7", "S628", "S629")
```

Faz a união das duas tabelas de acordo com o código do ibge

``` r
indicadores <- merge(indicadores, dados_munic_equip, by = "IBGE7")
```

Obtém o indicador

``` r
indicadores <- indicadores %>% mutate(L_EQUI = indicadores$S628) %>% select(-S628) %>%
                               mutate(L_QUANT = as.numeric(indicadores$S629)) %>% select(-S629)
```

Filtra os dados para os municípios de Minas Gerais

``` r
dados_munic_acoes <- dados_munic_acoes %>% subset(substr(dados_munic_acoes$S1, 1, 2) == "31") %>% #seleciona as linhas cujos códigos 
                                                                                                  # de município começam com 31
                                           select(c(1, 2, 12, 22, 33)) # seleciona as colunas com as variáveis de interesse (S1, S182, S192, S202 e S213)
```

O indicador tem valor Sim se pelo menos uma das variáveis tem valor Sim,
caso contrário é Não

``` r
indicadores <- indicadores %>% mutate(L_PARTESP =  if_else_(dados_munic_acoes$S182 == "Sim" |
                                                            dados_munic_acoes$S192 == "Sim" |
                                                            dados_munic_acoes$S202 == "Sim" |
                                                            dados_munic_acoes$S213 == "Sim", true = "Sim", false = "Não", missing = NA))
```

### Dados INEP

Renomeia as colunas

``` r
colnames(dados_quadra) <- c("IBGE7", "pquadras")
```

Faz a união dos indicadores com os dados sobre percentual de alunos em
escolas com quadra

``` r
indicadores <- merge(indicadores, dados_quadra, by= "IBGE7")
```

Atualiza o indicador

``` r
indicadores <- indicadores %>% mutate(L_ESPESC = indicadores$pquadras) %>%
                               select(-pquadras)
```

Juntando a base original com os indicadores

``` r
dados_imrs <- rbind(dados_imrs, indicadores) 
```

Ajusta o número de casas decimais

``` r
dados_imrs <- dados_imrs %>% mutate(L_PROGE = round(L_PROGE, digits = 2)) %>%
                             mutate(L_ESPESC = round(L_ESPESC, digits = 2)) %>%
                             mutate(L_ILRHE = round(L_ILRHE, digits = 3))
```

Exportando a base. O arquivo gerado terá o mesmo nome do arquivo com os
dados do IMRS, porém com o ano atualizado.

``` r
write_xlsx(dados_imrs,paste0("IMRS", ano_dados+1, " - BASE ESPORTE.xlsx"))
```
