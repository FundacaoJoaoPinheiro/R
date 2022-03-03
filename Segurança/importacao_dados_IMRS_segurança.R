#' ---
#' title: "Importação dos dados IMRS dimensão Segurança"
#' author: "Michel Alves - michel.alves@fjp.mg.gov.br"
#' date: "março de 2022"
#' output: github_document 
#' ---
#' 
#' 
options(warn=-1)

#' # Estrutura do script
#' 
#' ## Limpa a memória e console
cat("\014")  
rm(list = ls())


#' ## Configura o diretório de trabalho
#' Altera a pasta de trabalho para a mesma onde o script está salvo
dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(dir)

#' ## Carrega as bibliotecas
pacotes <- c("readxl", "tidyverse", "janitor", "writexl", "hablar",  "devtools", "XML", "rvest", "rio")

#' Verifica se alguma das bibliotecas necessárias ainda não foi instalada
pacotes_instalados <- pacotes %in% rownames(installed.packages())
if (any(pacotes_instalados == FALSE)) {
  install.packages(pacotes[!pacotes_instalados])
}

#' carrega as bibliotecas
#+ results = "hide"
lapply(pacotes, library, character.only=TRUE)

#' Busca a função que faz a extração dos dados do datasus diretamente do github
source("https://gist.githubusercontent.com/michelrodrigo/d51d98305590f99be1453e7d2424f504/raw/be383ae28291df2a66710868232112c2ae12595b/sim_obt10_prel_mun_mg.R")

#' Ano (o ano relativo aos dados)
ano <- 2020

#' Realiza a leitura dos arquivos excel 
dados_pop <- as_tibble(readxl::read_excel("IMRS2021 - BASE DEMOGRAFIA 2000 a 2020.xlsx", sheet =1))
dados_imrs <- as_tibble(readxl::read_excel("IMRS2021 - BASE SEGURANCA.xlsx", sheet =1))

#' Cria uma cópia dos indicadores do último ano disponível no imrs em seguida atualiza o ano e os valores dos indicadores
indicadores <- dados_imrs |> subset(ANO == ano)
indicadores[, 5:63] <- NA
indicadores <- indicadores |> mutate(ANO = ano+1)

#' ## Extração dos dados Datasus
#' 
#' Para cada um dos indicadores que são obtidos por meio dos dados disponíveis no datasus, realiza-se a consulta, 
#' faz-se a união dos dados obtidos com a tabela de indicadores pelo código do ibge, faz-se a transformação do valor
#' para o formato numérico e finalmente faz-se a atualização da coluna correspondente ao indicador.
#' 

#' P_SUICIDIOS_SIM
dados <- sim_obt10_prel_mun_mg(linha = "Município",
                         grande_grupo_cid10 = "X60-X84 Lesões autoprovocadas voluntariamente",
                         periodo = ano,
                         coluna = "Ano do Óbito")
dados <- dados |> mutate(IBGE6 = apply(dados, 1, function(x) substr(x["Município"], 1, 6) ))
dados[, c(3, 4)] <- sapply(dados[, c(3, 4)], as.numeric)

indicadores <- indicadores |> merge(dados[, c(3, 4)], by="IBGE6") |>  mutate(P_SUICIDIOS_SIM = Total) |> select(-c("Total"))

#' P_MORTESTRAN_SIM
dados <- sim_obt10_prel_mun_mg(linha = "Município",
                               grande_grupo_cid10 = "V01-V99 Acidentes de transporte",
                               periodo = ano,
                               coluna = "Ano do Óbito")
dados <- dados |> mutate(IBGE6 = apply(dados, 1, function(x) substr(x["Município"], 1, 6) ))
dados[, c(3, 4)] <- sapply(dados[, c(3, 4)], as.numeric)

indicadores <- indicadores |> merge(dados[, c(3, 4)], by="IBGE6") |>  mutate(P_MORTESTRAN_SIM = Total) |> select(-c("Total"))

#' P_HOMI_SIM
dados <- sim_obt10_prel_mun_mg(linha = "Município",
                               grande_grupo_cid10 = "X85-Y09 Agressões",
                               periodo = ano,
                               coluna = "Ano do Óbito")
dados <- dados |> mutate(IBGE6 = apply(dados, 1, function(x) substr(x["Município"], 1, 6) ))
dados[, c(3, 4)] <- sapply(dados[, c(3, 4)], as.numeric)

indicadores <- indicadores |> merge(dados[, c(3, 4)], by="IBGE6") |>  mutate(P_HOMI_SIM = Total) |> select(-c("Total"))

#' P_HOMITX_SIM
dados_pop <- dados_pop |> subset(dados_pop$ANO == as.numeric(ano)) |> #seleciona as linhas para o ano de interesse
select(c(IBGE6, D_POPTA)) # seleciona as colunas com o código e a população

#' Faz a união da tabela de indicadores com a de população
indicadores <- merge(indicadores, dados_pop, by="IBGE6")

#' Atualiza o indicador calculando a taxa de homicídio por 100 mil habitantes
indicadores <- indicadores |> mutate(P_HOMITX_SIM = round((P_HOMI_SIM / D_POPTA) * 100000, digits = 2)) 

#' P_HOMMENOR15_SIM
dados <- sim_obt10_prel_mun_mg(linha = "Município",
                               grande_grupo_cid10 = "X85-Y09 Agressões",
                               periodo = ano,
                               coluna = "Ano do Óbito",
                               faixa_etaria_det = c("0 a 6 dias", "7 a 27 dias", "28 a 364 dias", "Menor 1 ano (ign)", "1 a 4 anos", "5 a 9 anos", "10 a 14 anos"))
dados <- dados |> mutate(IBGE6 = apply(dados, 1, function(x) substr(x["Município"], 1, 6) ))
dados[, c(3, 4)] <- sapply(dados[, c(3, 4)], as.numeric)

indicadores <- indicadores |> merge(dados[, c(3, 4)], by="IBGE6") |>  mutate(P_HOMMENOR15_SIM = Total) |> select(-c("Total"))

#' P_HOM15A24_SIM
dados <- sim_obt10_prel_mun_mg(linha = "Município",
                               grande_grupo_cid10 = "X85-Y09 Agressões",
                               periodo = ano,
                               coluna = "Ano do Óbito",
                               faixa_etaria_det = c("15 a 19 anos", "20 a 24 anos"))
dados <- dados |> mutate(IBGE6 = apply(dados, 1, function(x) substr(x["Município"], 1, 6) ))
dados[, c(3, 4)] <- sapply(dados[, c(3, 4)], as.numeric)

indicadores <- indicadores |> merge(dados[, c(3, 4)], by="IBGE6") |>  mutate(P_HOM15A24_SIM = Total) |> select(-c("Total"))

#' P_HOM25A29_SIM
dados <- sim_obt10_prel_mun_mg(linha = "Município",
                               grande_grupo_cid10 = "X85-Y09 Agressões",
                               periodo = ano,
                               coluna = "Ano do Óbito",
                               faixa_etaria_det = c("25 a 29 anos"))
dados <- dados |> mutate(IBGE6 = apply(dados, 1, function(x) substr(x["Município"], 1, 6) ))
dados[, c(3, 4)] <- sapply(dados[, c(3, 4)], as.numeric)

indicadores <- indicadores |> merge(dados[, c(3, 4)], by="IBGE6") |>  mutate(P_HOM25A29_SIM = Total) |> select(-c("Total"))

#' P_HOMMAIOR30_SIM
dados <- sim_obt10_prel_mun_mg(linha = "Município",
                               grande_grupo_cid10 = "X85-Y09 Agressões",
                               periodo = ano,
                               coluna = "Ano do Óbito",
                               faixa_etaria_det = c("30 a 34 anos", "35 a 39 anos", "40 a 44 anos", "45 a 49 anos", "50 a 54 anos", "55 a 59 anos", "60 a 64 anos", "65 a 69 anos", "70 a 74 anos", "75 a 79 anos", "80 anos e mais"))
dados <- dados |> mutate(IBGE6 = apply(dados, 1, function(x) substr(x["Município"], 1, 6) ))
dados[, c(3, 4)] <- sapply(dados[, c(3, 4)], as.numeric)

indicadores <- indicadores |> merge(dados[, c(3, 4)], by="IBGE6") |>  mutate(P_HOMMAIOR30_SIM = Total) |> select(-c("Total"))

#' P_HOMBRANCA_SIM
dados <- sim_obt10_prel_mun_mg(linha = "Município",
                               grande_grupo_cid10 = "X85-Y09 Agressões",
                               periodo = ano,
                               coluna = "Ano do Óbito",
                               cor_raca = "Branca")
dados <- dados |> mutate(IBGE6 = apply(dados, 1, function(x) substr(x["Município"], 1, 6) ))
dados[, c(3, 4)] <- sapply(dados[, c(3, 4)], as.numeric)

indicadores <- indicadores |> merge(dados[, c(3, 4)], by="IBGE6") |>  mutate(P_HOMBRANCA_SIM = Total) |> select(-c("Total"))

#' P_HOMPRETA_SIM
dados <- sim_obt10_prel_mun_mg(linha = "Município",
                               grande_grupo_cid10 = "X85-Y09 Agressões",
                               periodo = ano,
                               coluna = "Ano do Óbito",
                               cor_raca = "Preta")
dados <- dados |> mutate(IBGE6 = apply(dados, 1, function(x) substr(x["Município"], 1, 6) ))
dados[, c(3, 4)] <- sapply(dados[, c(3, 4)], as.numeric)

indicadores <- indicadores |> merge(dados[, c(3, 4)], by="IBGE6") |>  mutate(P_HOMPRETA_SIM = Total) |> select(-c("Total"))

#' P_HOMPARDA_SIM
dados <- sim_obt10_prel_mun_mg(linha = "Município",
                               grande_grupo_cid10 = "X85-Y09 Agressões",
                               periodo = ano,
                               coluna = "Ano do Óbito",
                               cor_raca = "Parda")
dados <- dados |> mutate(IBGE6 = apply(dados, 1, function(x) substr(x["Município"], 1, 6) ))
dados[, c(3, 4)] <- sapply(dados[, c(3, 4)], as.numeric)

indicadores <- indicadores |> merge(dados[, c(3, 4)], by="IBGE6") |>  mutate(P_HOMPARDA_SIM = Total) |> select(-c("Total"))

#' P_HOMOUTROS_SIM
dados <- sim_obt10_prel_mun_mg(linha = "Município",
                               grande_grupo_cid10 = "X85-Y09 Agressões",
                               periodo = ano,
                               coluna = "Ano do Óbito",
                               cor_raca = c("Indígena", "Amarela", "Ignorado"))
dados <- dados |> mutate(IBGE6 = apply(dados, 1, function(x) substr(x["Município"], 1, 6) ))
dados[, c(3, 4)] <- sapply(dados[, c(3, 4)], as.numeric)

indicadores <- indicadores |> merge(dados[, c(3, 4)], by="IBGE6") |>  mutate(P_HOMOUTROS_SIM = Total) |> select(-c("Total"))

#' P_HOMHOMEM_SIM
dados <- sim_obt10_prel_mun_mg(linha = "Município",
                               grande_grupo_cid10 = "X85-Y09 Agressões",
                               periodo = ano,
                               coluna = "Ano do Óbito",
                               sexo = "Masc")
dados <- dados |> mutate(IBGE6 = apply(dados, 1, function(x) substr(x["Município"], 1, 6) ))
dados[, c(3, 4)] <- sapply(dados[, c(3, 4)], as.numeric)

indicadores <- indicadores |> merge(dados[, c(3, 4)], by="IBGE6") |>  mutate(P_HOMHOMEM_SIM = Total) |> select(-c("Total"))

#' P_HOMMULHER_SIM
dados <- sim_obt10_prel_mun_mg(linha = "Município",
                               grande_grupo_cid10 = "X85-Y09 Agressões",
                               periodo = ano,
                               coluna = "Ano do Óbito",
                               sexo = "Fem")
dados <- dados |> mutate(IBGE6 = apply(dados, 1, function(x) substr(x["Município"], 1, 6) ))
dados[, c(3, 4)] <- sapply(dados[, c(3, 4)], as.numeric)

indicadores <- indicadores |> merge(dados[, c(3, 4)], by="IBGE6") |>  mutate(P_HOMMULHER_SIM = Total) |> select(-c("Total"))

#' ## Extração dos dados SEJUSP

#' Obtém os dados disponiveis na página de dados abertos
#pag_sejusp <- read_html("http://www.seguranca.mg.gov.br/2018-08-22-13-39-06/dados-abertos")
#url <- pag_sejusp %>% html_element(xpath = "//a[preceding-sibling::*[text()[contains(., '2012 a 2017')]]]") %>% html_attr(name = 'href')
#dados_sejusp <- import(paste0("http://www.seguranca.mg.gov.br", url) )

dados_sejusp <- as_tibble(read.csv("Banco Crimes Violentos - Atualizado Dezembro 2021.csv", sep = ";" ))


#' P_CV
dados <- dados_sejusp |> subset(Ano == ano) |> group_by(Ano,`Cod.IBGE`) |> summarise(Total = sum(Registros), .groups = "keep") 
colnames(dados) <- c("Ano", "IBGE6", "Total")
indicadores <- indicadores |> merge(dados[, c(2, 3)], by="IBGE6") |>  mutate(P_CV = round((Total / D_POPTA) * 100000, digits = 2)) |> select(-c("Total"))

#' P_CVPA
dados <- dados_sejusp %>% group_by(Ano,`Cod.IBGE`) %>% 
                          subset(Ano == ano) %>%
                          subset(Natureza == "Roubo Consumado" | Natureza == "Extorsão Mediante Sequestro Consumado") %>% 
                          summarise(Total = sum(Registros), .groups = "keep") 
colnames(dados) <- c("Ano", "IBGE6", "Total")
indicadores <- indicadores |> merge(dados[, c(2, 3)], by="IBGE6") |>  mutate(P_CVPA = round((Total / D_POPTA) * 100000, digits = 2)) |> select(-c("Total"))

#' P_CVPE
dados <- dados_sejusp %>% group_by(Ano,`Cod.IBGE`) %>% 
                          subset(Ano == ano) %>%
                          subset(Natureza == "Homicídio Consumado (Registros)" | Natureza == "Homicídio Tentado" | Natureza == "Estupro Consumado" | Natureza == "Estupro Tentado" | Natureza == "Estupro de Vulnerável Consumado" | Natureza == "Estupro de Vulnerável Tentado") %>% 
                          summarise(Total = sum(Registros), .groups = "keep") 
colnames(dados) <- c("Ano", "IBGE6", "Total")
indicadores <- indicadores |> merge(dados[, c(2, 3)], by="IBGE6") |>  mutate(P_CVPA = round((Total / D_POPTA) * 100000, digits = 2)) |> select(-c("Total"))

#' P_HOM_TX e P_HOMI
dados <- dados_sejusp %>% group_by(Ano,`Cod.IBGE`) %>% 
                          subset(Ano == ano) %>%
                          subset(Natureza == "Homicídio Consumado (Registros)") %>%
                          summarise(Total = sum(Registros), .groups = "keep") 
colnames(dados) <- c("Ano", "IBGE6", "Total")
indicadores <- indicadores |> merge(dados[, c(2, 3)], by="IBGE6") |>  mutate(P_HOM_TX = round((Total / D_POPTA) * 100000, digits = 2)) |>
                                                                      mutate(P_HOMI = round(Total, digits = 2)) |> select(-c("Total"))

#' P_TEN_HOM
dados <- dados_sejusp %>% group_by(Ano,`Cod.IBGE`) %>% 
                          subset(Ano == ano) %>%
                          subset(Natureza == "Homicídio Tentado") %>% 
                          summarise(Total = sum(Registros), .groups = "keep") 
colnames(dados) <- c("Ano", "IBGE6", "Total")
indicadores <- indicadores |> merge(dados[, c(2, 3)], by="IBGE6") |> mutate(P_TEN_HOM = round(Total, digits = 2)) |> select(-c("Total"))

#' P_ROUBO
dados <- dados_sejusp %>% group_by(Ano,`Cod.IBGE`) %>% 
                          subset(Ano == ano) %>%
                          subset(Natureza == "Roubo Consumado") %>%
                          summarise(Total = sum(Registros), .groups = "keep") 
colnames(dados) <- c("Ano", "IBGE6", "Total")
indicadores <- indicadores |> merge(dados[, c(2, 3)], by="IBGE6") |> mutate(P_ROUBO = round(Total, digits = 2)) |> select(-c("Total"))

#' P_ESTUPRO
dados <- dados_sejusp %>% group_by(Ano,`Cod.IBGE`) %>% 
                          subset(Ano == ano) %>%
                          subset(Natureza == "Estupro Consumado" | Natureza == "Estupro de Vulnerável Consumado" | Natureza == "Estupro de Vulnerável Tentado" | Natureza == "Estupro Tentado") %>%
                          summarise(Total = sum(Registros), .groups = "keep") 
colnames(dados) <- c("Ano", "IBGE6", "Total")
indicadores <- indicadores |> merge(dados[, c(2, 3)], by="IBGE6") |> mutate(P_ESTUPRO = round(Total, digits = 2)) |> select(-c("Total", "D_POPTA"))



