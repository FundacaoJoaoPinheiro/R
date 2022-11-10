#### PACOTES NECESSÁRIOS PARA O SERVIÇO -------------------------
## install.packages("readxl")
library(readxl)
library(tidyverse)



#### Defina nesta linha, qual o nome do arquivo que
#### contém os valores transferidos de ICMS.
arquivo_transferencias <- "./resultados/Resultado_final.xlsx"



### IMPORTANDO OS DADOS --------------

Cod_indices_site <- read_csv2(
  "./parametros/Cod_indices_site.csv", 
  locale = locale(encoding = "Latin1")
)

codigos_IBGE <- read_csv2("./parametros/codigos.csv")

dados <- read_excel(arquivo_transferencias)[1:853, ] %>%
         mutate(Ano = as.numeric(Ano),
                IBGE2 = as.numeric(IBGE2),
                IBGE1 = as.numeric(IBGE1))


#### CONFERINDO OS NOMES DAS COLUNAS
## NA TABELA DE TRANSFERÊNCIAS.

source("./scripts/conferir_transferencias.R", encoding = "UTF-8")


#### Selecionando as colunas dos critérios

colunas_de_identificacao <- c(
  "Ano",
  "Mês",
  "IBGE1",
  "IBGE2",
  "SEF",
  "Município"
)

colunas <- colunas_corretas[!colunas_corretas %in% colunas_de_identificacao]

tabela <- dados %>% 
  pivot_longer(
    cols = all_of(colunas),
    names_to = "Variavel",
    values_to = "Valor"
  ) %>% 
  left_join(
    codigos_IBGE,
    by = "IBGE2"
  )



tabela <- tabela %>% 
  left_join(
    Cod_indices_site,
    by = "Variavel"
  ) %>% 
  select(Ano, `Mês`, SEF, Variavel, Valor, `Cód índ`)

mes <- unique(tabela$Mês)

ano <- unique(tabela$Ano)

anoxx <- ano - 2000

tabela <- tabela %>%
                   mutate(Mês = case_when(Mês == "Janeiro" ~ 1,
                                          Mês == "Fevereiro" ~ 2,
                                          Mês == "Março" ~ 3,
                                          Mês == "Abril" ~ 4,
                                          Mês == "Maio" ~ 5,
                                          Mês == "Junho" ~ 6,
                                          Mês == "Julho" ~ 7,
                                          Mês == "Agosto" ~ 8,
                                          Mês == "Setembro" ~ 9,
                                          Mês == "Outubro" ~ 10,
                                          Mês == "Novembro" ~ 11,
                                          Mês == "Dezembro" ~ 12),
                          Índice = case_when(`Cód índ` == 1 ~ "Pop",
                                             `Cód índ` == 2 ~ "Pop 50+",
                                             `Cód índ` == 3 ~ "Área",
                                             `Cód índ` == 4 ~ "Educ",
                                             `Cód índ` == 5 ~ "Patr",
                                             `Cód índ` == 6 ~ "Rec Prop",
                                        
                                             `Cód índ` == 8 ~ "Meio Ambiente",
                                             `Cód índ` == 9 ~ "Prod Alimentos",
                                             `Cód índ` == 10 ~ "VAF",
                                             `Cód índ` == 11 ~ "Cota Min",
                                             `Cód índ` == 12 ~ "Mun Miner",

                                             `Cód índ` == 15 ~ "Saúde PSF",
                                             `Cód índ` == 16 ~ "Saúde Hab",
                                             `Cód índ` == 17 ~ "Subtotal",
                                             `Cód índ` == 18 ~ "Compensação Financeira",
                                             `Cód índ` == 19 ~ "Total",
                                             
                                             `Cód índ` == 22 ~ "Esportes",
                                             
                                             `Cód índ` == 24 ~ "ICMS Solidário",
                                             `Cód índ` == 25 ~ "Mínimo per capita",
                                             `Cód índ` == 26 ~ "Penitenciárias",
                                             `Cód índ` == 27 ~ "Recursos hídricos",
                                             `Cód índ` == 28 ~ "Turismo",
                                             
                                             `Cód índ` == 30 ~ "UC",
                                             `Cód índ` == 31 ~ "Saneam",
                                             `Cód índ` == 32 ~ "Mata Seca")
                          ) %>%
  relocate(`Cód índ`, .after = SEF) %>%
  select(-Variavel)



#### EXPORTANDO OS DADOS ------------------

filename <- str_c("Transf", mes, anoxx, ".csv")

write.csv2(tabela, file = str_c("./resultados/", filename), row.names = FALSE)


print("Cálculo das transferências para o site efetuado com sucesso - Arquivo Transf.csv gerado na pasta saídas.")


