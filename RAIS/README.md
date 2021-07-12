# RAIS - Relação Anual de Informações Sociais 

## Importação online de dados

No site do [Ministério do Trabalho](http://pdet.mte.gov.br/microdados-rais-e-caged), onde é disponibilizado as bases com os microdados da RAIS e CAGED é indicado um [site](http://cemin.wikidot.com/raisr), o qual tem instruções para baixar e importar os microdados da RAIS, usando o R.

A seguir serão mostrados os passos que devem ser seguidos para realizar tal importação de dados. O script que deverá ser executado é mostrado a seguir.

```{r}
cat("\014")
rm(list = ls())

library(rio)
library(openxlsx)
library(csv)

source('http://cemin.wikidot.com/local--files/raisr/rais.r')

```

![rais1](https://user-images.githubusercontent.com/12836843/125288090-1eb4e000-e2f4-11eb-86d3-22812a7260c1.JPG)
