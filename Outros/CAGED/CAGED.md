CAGED
================
Michel Rodrigo - <michel.alves@fjp.mg.gov.br> e Heloísa
08 de julho de 2021

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
pacotes <- c("tidyverse", "srvyr", "csv",
             "data.table", "openxlsx", "rio")
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
    ## v tibble  3.1.2     v dplyr   1.0.7
    ## v tidyr   1.1.3     v stringr 1.4.0
    ## v readr   1.4.0     v forcats 0.5.1

    ## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

    ## 
    ## Attaching package: 'srvyr'

    ## The following object is masked from 'package:stats':
    ## 
    ##     filter

    ## 
    ## Attaching package: 'data.table'

    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     between, first, last

    ## The following object is masked from 'package:purrr':
    ## 
    ##     transpose

## Importa os dados

*Observação*: os dados já deverão ter sido baixados, conforme as
instruções presentes aqui

``` r
cagedjan2020<- read.table("CAGEDESTAB202001.txt", head=T, sep=";", encoding = "UTF-8")
cagedfev2020<- read.table("CAGEDESTAB202002.txt", head=T, sep=";", encoding = "UTF-8")
cagedmar2020<- read.table("CAGEDESTAB202003.txt", head=T, sep=";", encoding = "UTF-8")
cagedabril2020<- read.table("CAGEDESTAB202004.txt", head=T, sep=";", encoding = "UTF-8")
cagedmaio2020<- read.table("CAGEDESTAB202005.txt", head=T, sep=";", encoding = "UTF-8")
cagedjun2020<- read.table("CAGEDESTAB202006.txt", head=T, sep=";", encoding = "UTF-8")
cagedjul2020<- read.table("CAGEDESTAB202007.txt", head=T, sep=";", encoding = "UTF-8")
cagedagos2020<- read.table("CAGEDESTAB202008.txt", head=T, sep=";", encoding = "UTF-8")
cagedset2020<- read.table("CAGEDESTAB202009.txt", head=T, sep=";", encoding = "UTF-8")
cagedout2020<- read.table("CAGEDESTAB202010.txt", head=T, sep=";", encoding = "UTF-8")
cagednov2020<- read.table("CAGEDESTAB202011.txt", head=T, sep=";", encoding = "UTF-8")
cageddez2020<- read.table("CAGEDESTAB202012.txt", head=T, sep=";", encoding = "UTF-8")
```

## Manipulação das bases de dados

Função para renomear os respectivos nomes dos setores econômicos. A
sexta coluna da tabela deve conter a letra relativa a cada setor.

``` r
nomes <- function(tabela){
  
  ifelse(tabela[6] == "A", "Agricultura, pecuária, produção florestal, pesca e aquicultura",
  ifelse(tabela[6] == "B", "Indústrias Extrativas",
  ifelse(tabela[6] == "C", "Indústrias de Transformação",
  ifelse(tabela[6] == "D", "Eletricidade e Gás",        
  ifelse(tabela[6] == "E", "Água, Esgoto, Atividades de Gestão de Resíduos e Descontaminação",
  ifelse(tabela[6] == "F", "Construção",
  ifelse(tabela[6] == "G", "Comércio, Reparação de Veículos Automotores e Motocicletas",
  ifelse(tabela[6] == "H", "Transporte, Armazenagem e Correio",
  ifelse(tabela[6] == "I", "Alojamento e Alimentação",
  ifelse(tabela[6] == "J", "Informação e Comunicação",
  ifelse(tabela[6] == "K", "Atividades Financeiras, de Seguros e Serviços Relacionados",
  ifelse(tabela[6] == "L", "Atividades Imobiliárias",
  ifelse(tabela[6] == "M", "Atividades Profissionais, Científicas e Técnicas",
  ifelse(tabela[6] == "N", "Atividades Administrativas e Serviços Complementares",
  ifelse(tabela[6] == "O", "Administração Pública, Defesa e Seguridade Social",
  ifelse(tabela[6] == "P", "Educação",
  ifelse(tabela[6] == "Q", "Saúde Humana e Serviços Sociais",
  ifelse(tabela[6] == "R", "Artes, Cultura, Esporte e Recreação",
  ifelse(tabela[6] == "S", "Outras Atividades de Serviços",
  ifelse(tabela[6] == "T", "Serviços Domésticos",
  ifelse(tabela[6] == "U", "Organismos Internacionais e Outras Instituições Extraterritoriais",
  ifelse(tabela[6] == "Z", "Não identificado"))))))))))))))))))))))
}

meses <- c("Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", 
           "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro")
```

Para cada mês

``` r
for(i in c(1:length(meses))){
  
  
  if(meses[i] == "Janeiro")   tabela <- cagedjan2020 else 
  if(meses[i] == "Fevereiro") tabela <- cagedfev2020 else
  if(meses[i] == "Março")     tabela <- cagedmar2020 else
  if(meses[i] == "Abril")     tabela <- cagedabril2020 else
  if(meses[i] == "Maio")      tabela <- cagedmaio2020 else
  if(meses[i] == "Junho")     tabela <- cagedjun2020 else
  if(meses[i] == "Julho")     tabela <- cagedjul2020 else
  if(meses[i] == "Agosto")    tabela <- cagedagos2020 else
  if(meses[i] == "Setembro")  tabela <- cagedset2020 else
  if(meses[i] == "Outubro")   tabela <- cagedout2020 else
  if(meses[i] == "Novembro")  tabela <- cagednov2020 else
  if(meses[i] == "Dezembro")  tabela <- cageddez2020
  
  #' Seleciona as colunas de interesse
  tabela<-subset(tabela, select = c("competência", "uf", "município", "seção", "saldomovimentação"))
  
  
  #' Duplica a coluna de códigos de setor e aplica a função para substituir o código pelo nome
  tabela$setor_nomes = tabela$seção
  tabela[, "setor_nomes"] <- apply(tabela, 1, nomes)
  
  #' #### Tabela com saldo de empregos por UF
  #+ eval = FALSE
  saldo_UF<- aggregate(tabela$saldo ~ tabela$uf, FUN= sum)
  saldo_UF<- data.frame(rename(saldo_UF, "UF"="tabela$uf", !!paste("Saldo_", meses[i], sep = ""):="tabela$saldo"))
  export(saldo_UF, file= paste("caged_", meses[i], "_UF.xlsx", sep = ""))
  
  #' ####  Tabela com saldo de empregos por setor de atividade IBGE
  #+ eval = FALSE
  saldo_Brasil_setor<- aggregate(tabela$saldo, by=list(tabela$seção,tabela$setor_nomes), FUN=sum)
  saldo_Brasil_setor<- data.frame(rename(saldo_Brasil_setor, "setor"="Group.1", "setor_nomes"="Group.2", !!paste("saldo_", meses[i], sep = ""):="x"))
  export(saldo_Brasil_setor, file = paste("caged_", meses[i], "_BR_setor.xlsx", sep = ""))
  
  #' #### Tabela com saldo de empregos MG por município
  #+ eval = FALSE
  saldo_MG<- aggregate(tabela$saldo, by=list(mun=tabela$município, uf=tabela$uf), FUN=sum)
  saldo_MG<- filter(saldo_MG, saldo_MG$uf==31)
  saldo_MG<- data.frame(rename(saldo_MG, !!paste("saldo_", meses[i], sep = ""):="x"))
  export(saldo_MG, file = paste("caged_", meses[i], "_MG.xlsx", sep = ""))
  
  #' #### Tabela com saldo de empregos MG por setor de atividade IBGE
  #+ eval = FALSE
  saldo_MG_setor<- aggregate(tabela$saldo, by=list(setor=tabela$seção, tabela$setor_nomes, uf=tabela$uf), FUN=sum)
  saldo_MG_setor<- filter(saldo_MG_setor, saldo_MG_setor$uf==31)
  saldo_MG_setor<- data.frame(rename(saldo_MG_setor, !!paste("saldo_", meses[i], sep = ""):="x", "setor_nomes"="Group.2"))
  export(saldo_MG_setor, file = paste("caged_", meses[i], "_MG_setor.xlsx", sep = ""))
  
}
```
