#Limpando a memória do R
rm(list = ls())
#Limpando o console
cat("\014")
#Configurando a pasta para importar e exportar arquivos do computador
setwd("H://FJP//scripts//pnadc")
#Carregando as bibliotecas
library(plyr)
library(readr)
library(dplyr)
library(questionr)
library(PNADcIBGE)
library(survey)
library(tidyverse)
library(srvyr)
library(csv)
library(data.table)
library(openxlsx)
library(PnadcTidy)
library(rio)
library(dplyr)
library(tidyverse)
library(srvyr)
library(csv)
library(data.table)
library(openxlsx)
library(rio)

#Importação da PNADC offline, com pacote PnadcTidy

#Importando a PNADC com a seleção de variáveis
pnadc20201 <- PnadcTidy(inputSAS="input_PNADC_trimestral.txt", 
                        arquivoPnad="PNADC_012020.txt", 
                        variaveis=c( "UF", "V1023", "Capital", "VD4002", "V2007", "V2009", "VD3004", "VD3005", "V2010", "V1027", "V1028" ))

#Filtrando RMBH
pnadc20201 <- filter(pnadc20201, pnadc20201$UF == 31)
pnadc20201 <- filter(pnadc20201, pnadc20201$V1023 == 1 | pnadc20201$V1023 == 2)

#Declarando as variáveis categóricas 

pnadc20201$VD4002 <- factor(pnadc20201$VD4002, label=c("Pessoas ocupadas", "Pessoas desocupadas"), levels=1:2)
pnadc20201$V2010 <- factor(pnadc20201$V2010, label=c("Branca", "Preta", "Amarela", "Parda","Indígena", "Ignorado"), lev = c(1,2,3,4,5,9))


pnadc202012 <-     
  svydesign(            
    ids = ~ UPA ,        
    strata = ~ Estrato , 
    weights = ~ V1028 ,  
    data = pnadc20201 ,  
    nest = TRUE)

#Taxa de desocupação por cor ou raça 
Desocupacao_cor<- data.frame(svytable(~V2010+VD4002, pnadc202012))
Desocupacao_cor<- pivot_wider(Desocupacao_cor, names_from = "VD4002", values_from = "Freq")
Desocupacao_cor$PEA = Desocupacao_cor$`Pessoas ocupadas`+  Desocupacao_cor$`Pessoas desocupadas`
Desocupacao_cor$'Taxa de desocupação' = ((Desocupacao_cor$`Pessoas desocupadas`/ Desocupacao_cor$PEA)*100)
Desocupacao_cor<- rename(Desocupacao_cor, "Cor ou raça" = "V2010")
view(Desocupacao_cor)



#Importação online da PNADC com o pacote PNADcIBGE
#https://rpubs.com/leobarone/pnadc_srvyr

pnad_df <- get_pnadc(year = 2020, 
                     quarter = 1,
                     vars=c("UF", "V1023", "Capital", "VD4002", "V2007", "V2009", "VD3004", "VD3005", "V2010", "V1027", "V1028"),
                     design = TRUE)

pnad_srvyr <- as_survey(pnad_df)
pnad_df2 <- pnad_srvyr %>% 
  filter(UF == "Minas Gerais" & (V1023 == "Capital" | V1023 == "Resto da RM (Região Metropolitana, excluindo a capital)"))


Desocupacao_cor2<- data.frame(svytable(~V2010+VD4002, pnad_df2))
Desocupacao_cor2<- pivot_wider(Desocupacao_cor2, names_from = "VD4002", values_from = "Freq")
Desocupacao_cor2$PEA = Desocupacao_cor2$`Pessoas ocupadas`+  Desocupacao_cor2$`Pessoas desocupadas`
Desocupacao_cor2$'Taxa de desocupação' = ((Desocupacao_cor2$`Pessoas desocupadas`/ Desocupacao_cor2$PEA)*100)
Desocupacao_cor2<- rename(Desocupacao_cor2, "Cor ou raça" = "V2010")
view(Desocupacao_cor2)

