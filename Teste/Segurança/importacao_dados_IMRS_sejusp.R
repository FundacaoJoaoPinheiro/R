#' ---
#' title: "Importação dos dados IMRS dimensão Segurança"
#' author: "Michel Alves - michel.alves@fjp.mg.gov.br"
#' date: "janeiro de 2022"
#' output: github_document 
#' ---
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
pacotes <- c("readxl", "tidyverse", "janitor", "writexl", "hablar", "RSelenium", "XML", "rvest", "rio")

#' Verifica se alguma das bibliotecas necessárias ainda não foi instalada
pacotes_instalados <- pacotes %in% rownames(installed.packages())
if (any(pacotes_instalados == FALSE)) {
  install.packages(pacotes[!pacotes_instalados])
}

#' carrega as bibliotecas
#+ results = "hide"
lapply(pacotes, library, character.only=TRUE)

#' Ano
ano <- 2020

#' ### Dados população
#' Realiza a leitura dos arquivos excel
dados_pop <- as_tibble(readxl::read_excel("IMRS2021 - BASE DEMOGRAFIA 2000 a 2020.xlsx", sheet =1))

#' Filtra os dados para os municípios de Minas Gerais
dados_pop <- dados_pop %>% subset(dados_pop$ANO == as.numeric(ano)) %>% #seleciona as linhas para o ano de interesse
  select(c(IBGE6, D_POPTA)) # seleciona as colunas com o código e a população

#' Dados SEJUSP

pag_sejusp <- read_html("http://www.seguranca.mg.gov.br/2018-08-22-13-39-06/dados-abertos")
url <- pag_sejusp %>% html_element(xpath = "//a[preceding-sibling::*[text()[contains(., '2012 a 2017')]]]") %>% html_attr(name = 'href')
dados_sejusp <- import(paste0("http://www.seguranca.mg.gov.br", url) )


dados_sejusp_cv <- dados_sejusp %>% group_by(Ano,`Cod IBGE`) %>% summarise(total = sum(Registros), .groups = "keep")
colnames(dados_sejusp_cv) <- c("Ano", "IBGE6", "total")

indicadores <- dados_sejusp_cv %>% subset(dados_sejusp_cv$Ano == ano)

#' Faz a união da tabela de indicadores com a de população
indicadores <- merge(indicadores, dados_pop, by="IBGE6")

#' Atualiza o indicador calculando a taxa de homicídio por 100 mil habitantes
indicadores <- indicadores %>% mutate(P_CV = round((total / D_POPTA) * 100000, digits = 2)) %>% select(-total)

dados_sejusp_cvpa <- dados_sejusp %>% group_by(Ano,`Cod IBGE`) %>% 
                                      subset(Ano == ano) %>%
                                      subset(Natureza == "Roubo Consumado" | Natureza == "Extorsão Mediante Sequestro Consumado") %>% 
                                      summarise(total = sum(Registros), .groups = "keep")
colnames(dados_sejusp_cvpa) <- c("Ano", "IBGE6", "total")

#' Faz a união da tabela de indicadores com a 
indicadores <- merge(indicadores, dados_sejusp_cvpa[, -c(1)], by="IBGE6")

indicadores <- indicadores %>% mutate(P_CVPA = round((total / D_POPTA) * 100000, digits = 2)) %>% select(-total)

dados_sejusp_cvpe <- dados_sejusp %>% group_by(Ano,`Cod IBGE`) %>% 
                                      subset(Ano == ano) %>%
                                      subset(Natureza == "Homicídio Consumado (Registros)" | Natureza == "Homicídio Tentado" | Natureza == "Estupro Consumado" | Natureza == "Estupro Tentado" | Natureza == "Estupro de Vulnerável Consumado" | Natureza == "Estupro de Vulnerável Tentado") %>% 
                                      summarise(total = sum(Registros), .groups = "keep")
colnames(dados_sejusp_cvpe) <- c("Ano", "IBGE6", "total")

#' Faz a união da tabela de indicadores com a 
indicadores <- merge(indicadores, dados_sejusp_cvpe[, -c(1)], by="IBGE6")

indicadores <- indicadores %>% mutate(P_CVPE = round((total / D_POPTA) * 100000, digits = 2)) %>% select(-total)

dados_sejusp_homtx <- dados_sejusp %>% group_by(Ano,`Cod IBGE`) %>% 
                                       subset(Ano == ano) %>%
                                       subset(Natureza == "Homicídio Consumado (Registros)") %>% 
                                       summarise(total = sum(Registros), .groups = "keep")
colnames(dados_sejusp_homtx) <- c("Ano", "IBGE6", "total")

#' Faz a união da tabela de indicadores com a 
indicadores <- merge(indicadores, dados_sejusp_homtx[, -c(1)], by="IBGE6")

indicadores <- indicadores %>% mutate(P_HOM_TX = round((total / D_POPTA) * 100000, digits = 2)) %>%
                               mutate(P_HOMI = round(total, digits = 2)) %>% 
                               select(-total)

dados_sejusp_tenhom <- dados_sejusp %>% group_by(Ano,`Cod IBGE`) %>% 
                                        subset(Ano == ano) %>%
                                        subset(Natureza == "Homicídio Tentado") %>% 
                                        summarise(total = sum(Registros), .groups = "keep")
colnames(dados_sejusp_tenhom) <- c("Ano", "IBGE6", "total")

#' Faz a união da tabela de indicadores com a 
indicadores <- merge(indicadores, dados_sejusp_tenhom[, -c(1)], by="IBGE6")

indicadores <- indicadores %>% mutate(P_TEN_HOM = round(total, digits = 2)) %>%
                               select(-total)


dados_sejusp_roubo <- dados_sejusp %>% group_by(Ano,`Cod IBGE`) %>% 
                                      subset(Ano == ano) %>%
                                      subset(Natureza == "Roubo Consumado") %>% 
                                      summarise(total = sum(Registros), .groups = "keep")
colnames(dados_sejusp_roubo) <- c("Ano", "IBGE6", "total")

#' Faz a união da tabela de indicadores com a 
indicadores <- merge(indicadores, dados_sejusp_roubo[, -c(1)], by="IBGE6")

indicadores <- indicadores %>% mutate(P_ROUBO = round(total, digits = 2)) %>%
                               select(-total)

dados_sejusp_estupro <- dados_sejusp %>% group_by(Ano,`Cod IBGE`) %>% 
                                        subset(Ano == ano) %>%
                                        subset(Natureza == "Estupro Consumado" | Natureza == "Estupro de Vulnerável Consumado" | Natureza == "Estupro de Vulnerável Tentado" | Natureza == "Estupro Tentado") %>%
                                        summarise(total = sum(Registros), .groups = "keep")
colnames(dados_sejusp_estupro) <- c("Ano", "IBGE6", "total")

#' Faz a união da tabela de indicadores com a 
indicadores <- merge(indicadores, dados_sejusp_estupro[, -c(1)], by="IBGE6")

indicadores <- indicadores %>% mutate(P_ESTUPRO = round(total, digits = 2)) %>%
  select(-total)


