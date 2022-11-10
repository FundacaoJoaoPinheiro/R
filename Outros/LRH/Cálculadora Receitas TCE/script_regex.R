# -------------------------------------------------------------------------
# SCRIPT PARA CALCULO DE RECEITAS/BASE TCE --------------------------------
# -------------------------------------------------------------------------



# Pacotes necessários -----------------------------------------------------



library(tidyverse) 
library(readxl)   #funciona melhor que o opnexlsx para ler planilhas.
library(openxlsx) #readxl não cria arquivos xlsx. Não depende de Java.
library(janitor)


# Parâmetros  -------------------------------------------------------------



setwd(".")    #diretório automático

ano <- 2020    #ano do cálculo
linhas_pular <- 10   #linhas de cabeçalho, imagens, etc. para pular até os dados
num_planilha <- 1    #numero da planilha

local_base_tce <- "entradas/base_tce.xlsx"    #base tribunal de contas
local_planilha_municipios <- "entradas/municipios.xlsx"   #municipios para conferir
local_planilha_receitas <- "entradas/receitas.xlsx"   #receitas a serem usadas
local_planilha_final <- "resultado/resultado_script_regex.xlsx"  #nome da planilha a ser feita



# Planilhas a serem importadas --------------------------------------------



tce <- read_excel(local_base_tce, sheet = num_planilha, skip = linhas_pular)
#planilha do TCE. Configurar parâmetros acima.

conf_municipios <- read_excel(local_planilha_municipios)
#planilha com o nome e código de cada municipio, para conferência:

receitas <- read_excel(local_planilha_receitas)
#planilha com a sigla e nome de cada receita a ser calculada:



# Limpeza da planilha base do TCE -----------------------------------------



#selecionar e renomear colunas relevantes

tce_m <- tce %>%
  clean_names() %>%
  select(codigo_ibge, municipio, descricao_da_receita, receita_liquida) 



# Função para conferir ausência de municípios -----------------------------



conferir <- function() {
  confere <- conf_municipios %>%             #confere é uma tibble auxiliar, com os 
    anti_join(tce_m, by = "codigo_ibge")      #municipios faltando, se houverem.
  if (nrow(confere) != 0) {
    print("Atenção: municipios abaixo ausentes")
    print(confere)
  } else {
    print("todos os municipios presentes")
  }
}



# Cálculo do total de cada receita: ---------------------------------------



calcular <- function(x) {  #função para calcular receita (x) específica
  tce_m %>% 
    group_by(codigo_ibge) %>% 
    filter(str_detect(descricao_da_receita, regex(x, ignore_case = TRUE)) == TRUE) %>%
    summarise(!!x := sum(receita_liquida))
}   #agrupa por municipio e filtra se receita = x. !! = programação dplyr.


lista_calculados <- map(receitas$regex, calcular)

#map é uma função que gera uma lista aplicando um loop em uma função)



# Agrupar valores calculados: ---------------------------------------------



tce_final <- reduce(lista_calculados, left_join, by = "codigo_ibge") %>%
  mutate_all(~replace(., is.na(.), 0)) %>%
  inner_join(conf_municipios, by = "codigo_ibge") %>%
  relocate(municipio, .after = codigo_ibge)

#junta todas as tibbles retornadas pela map acima, troca NAs por 0 


colnames(tce_final) <- c("codigo_ibge", "municipio", receitas$sigla) 

#define nomes de colunas melhores para a tibble final.


tce_final <- tce_final %>%
  #cria uma coluna com a soma de todos os valores numéricos de cada linha e soma total         
  adorn_totals("row") %>%
  rowwise() %>%
  mutate(TotalGeral = sum(across(where(is.numeric)), na.rm = TRUE)) %>% 
  #mudança de 20/09/2022: cria colunas da soma de impostos e da soma de transferencias
  mutate(TotalImpostos = iptu + irrf + iss + itbi,
         TotalTransferencias = fpm + icms + ipi + ipva + itr + kandir) %>%
  relocate(TotalImpostos, .after = contribuições) %>%
  relocate(TotalTransferencias, .after = TotalImpostos)

#cria uma coluna com a soma de todos os valores numéricos de cada linha.



# Exportar planilha com os totais de cada receita: ------------------------



write.xlsx(
  tce_final,
  file = local_planilha_final,
  sheetName = str_c("receitas regex", as.character(ano)),
  colNames = TRUE,
  rowNames = FALSE,
  colWidths = "auto",
  overwrite = TRUE
)



# Conferência de municipios e encerramento do script ----------------------



conferir() #confere se todos os municípios estão presentes

writeLines("Script encerrado com sucesso - arquivo salvo")



# -------------------------------------------------------------------------