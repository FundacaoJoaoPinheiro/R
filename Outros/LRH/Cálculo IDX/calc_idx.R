# -------------------------------------------------------------------------
# SCRIPT PARA CALCULO DO IDX ----------------------------------------------
# -------------------------------------------------------------------------


# Pacotes necessários -----------------------------------------------------


library(tidyverse)
library(readxl)


# Importando base  --------------------------------------------------------



base <- read_excel("entradas/base.xlsx",
                      sheet = "IDX",
                      skip = 5,
                      col_names = TRUE)[-1, ] # Removendo linha 1 (em branco/NA)


colunas_escolhidas <- c("IBGE1",	"IBGE2",	"SEF",	"Municípios",	"Mês",	"Ano",	"População bruto",
                        "População dos 50 + Populosos",	"Área Geográfica",	"Educação",
                        "Patrimônio Cultural",	"Receita Própria",	"Cota Mínima",	"Mineradores",
                        "Saúde per capita",	"VAF",	"Esportes",	"Turismo",	"Penitenciárias",
                        "Recursos Hídricos",	"Produção de Alimentos",	"Unidades de Conservação (IC i)",
                        "Saneamento",	"Mata Seca",	"Número Equipes de Saúde")


idx <- base[1:853, ] %>% #selecionando apenas linhas 1 até 853 (municípios). 
          select(all_of(colunas_escolhidas)) #Restantes são desnecessárias
              #seleciona apenas as colunas necessárias.



# Verificação de critério que podem somar 1 (sendo necessário que seja 100) --------


colunas_verificar_soma <- c("Unidades de Conservação (IC i)", "Saneamento", "Mata Seca")


for (i in colunas_verificar_soma) {
  if (near(sum(idx[i], na.rm = TRUE), 1) == 1) {
    idx[i] = idx[i] * 100
  }
} #se soma dos critérios = 1, multiplicar por 100.



# Conferência 1: colunas critérios do idx --------------------------------------


pesos_idx <- read_csv2("entradas/pesos.csv")

colunas_corretas <- c("Mês", "Ano", "IBGE1", "IBGE2", "SEF", "Municípios", "População bruto", 
                      "População dos 50 + Populosos", "Área Geográfica", "Educação", 
                      "Patrimônio Cultural", "Receita Própria", "Mineradores", 
                      "Saúde per capita", "VAF", "Esportes", "Turismo", "Penitenciárias", 
                      "Recursos Hídricos", "Produção de Alimentos", "Unidades de Conservação (IC i)", 
                      "Saneamento", "Mata Seca", "Número Equipes de Saúde")


nomes_do_Idx <- colnames(idx)

teste <- all(colunas_corretas %in% nomes_do_Idx) #verifica se todas as colunas necessárias
                                                 #estão no data frame idx

if(!teste){
  print(as.character(colunas_corretas[!colunas_corretas %in% nomes_do_Idx], "\n"))
  stop("A sua planilha base do Idx, não possui as colunas definidas acima. Confirme se a ortografia dos nomes de cada coluna estão corretas. Caso queira ver a lista completa com os nomes corretos das colunas, que o seu Idx deveria possuir, execute o seguinte comando:\n\nprint(colunas_corretas)")
} 
    #Para o script se houverem colunas faltando.



# Adicionar colunas faltantes, se necessário ------------------------------


colunas <- colnames(idx)

colunas_geralmente_faltantes <- c("Meio Ambiente", "População", "Cota Mínima")

if(!all(colunas_geralmente_faltantes %in% colunas)){
  
idx <- idx %>% 
    mutate(
      "Meio Ambiente" = 0.4545 * Saneamento + 0.4545 * `Unidades de Conservação (IC i)` + 0.091 * `Mata Seca`,
      "População" = `População bruto` * 100 / sum(`População bruto`, na.rm = T),
      "Cota Mínima" = (1/853) * 100
    )
  
}



# Conferência 2: Soma dos indices (colunas) = 100 -------------------------



colunas_criterios <- c("População dos 50 + Populosos", "Área Geográfica", "Educação", 
                       "Patrimônio Cultural", "Receita Própria", "Cota Mínima", "Mineradores", 
                       "Saúde per capita", "VAF", "Esportes", "Turismo", "Penitenciárias", 
                       "Recursos Hídricos", "Produção de Alimentos", "Unidades de Conservação (IC i)", 
                       "Saneamento", "Mata Seca")


somatorios <- map_dbl(                       #map funciona como um loop; pacote purrr tidyverse
  idx %>% select(all_of(colunas_criterios)),
  sum
)

if(!all(near(somatorios, 100))){
  
  print(somatorios[!near(somatorios, 100)])
  stop("Os índices dos critérios acima não somam 100%, por favor, reajuste essas colunas para que elas somem 100%.")
} 
#para o script caso pelo menos um dos índices não somem 100



# Cálculo consolidados ----------------------------------------------------


calc_consolidado <- function(x){
  
  criterios <- x
  
  pesos <- pesos_idx$Peso[pesos_idx$Critério %in% x]
  
  formula <- paste(
    "idx[[",
    "'",
    criterios,
    "']]",
    " * ",
    pesos,
    sep = "",
    collapse = " + "
  )
  
  expression <- parse(text = formula)
  
  resultado <- eval(expression) / 100
  
  return(resultado)
  
}



criterios_anuais <- pesos_idx$Critério[pesos_idx$Periodicidade == "Anual"]

criterios_semestrais <- pesos_idx$Critério[pesos_idx$Periodicidade == "Semestral"]

criterios_trimestrais <- pesos_idx$Critério[pesos_idx$Periodicidade == "Trimestral"]


consolidado_anual <- calc_consolidado(criterios_anuais)

consolidado_semestral <- calc_consolidado(criterios_semestrais)

consolidado_trimestral <- calc_consolidado(criterios_trimestrais)




# Cálculo de índices de PSF -----------------------------------------------


total_equipes_PSF <- sum(idx[["Número Equipes de Saúde"]], na.rm = TRUE)

calc_PSF <- function(x){
  
  indice_por_equipe <- if_else(x == 0, 0, 100 / total_equipes_PSF)
  
  indice_atendimento <- x * indice_por_equipe
  
  sobra_total <- 100 - sum(indice_atendimento)
  
  sobras <- sobra_total * x / total_equipes_PSF
  
  primeiro_ajuste <- indice_atendimento + sobras
  
  sobra_total <- 100 - sum(primeiro_ajuste)
  
  sobras <- sobra_total * x / total_equipes_PSF
  
  segundo_ajuste <- primeiro_ajuste + sobras
  
  
  return(segundo_ajuste)
  
}

idx$PSF <- calc_PSF(idx[["Número Equipes de Saúde"]])




# Cálculo dos consolidados do ART 1 ---------------------------------------


consolidado1_art1 <- consolidado_anual + consolidado_semestral + consolidado_trimestral + (idx$PSF / 100)

ICMS_per_capita <- consolidado1_art1 / idx[["População bruto"]]

media <- sum(consolidado1_art1) / sum(idx[["População bruto"]])

media_40_por_cento <- 1.4 * media

pop_selecionada <- tibble(
    "População bruto" = idx[["População bruto"]],
    ICMS_per_capita
  ) %>% 
  mutate(
    Pop_selecionada = case_when(
      ICMS_per_capita < media_40_por_cento ~ `População bruto`,
      ICMS_per_capita > media_40_por_cento & ICMS_per_capita < 6 * media & `População bruto` < 10188 ~ `População bruto`,
      ICMS_per_capita > media_40_por_cento & ICMS_per_capita < 2 * media & `População bruto` > 100000 ~ `População bruto`,
      TRUE ~ 0
    )
  )


pop_selecionada <- pop_selecionada[["Pop_selecionada"]]

pop_selecionada_total <- sum(pop_selecionada)

ICMS_Solidario <- pop_selecionada * 100 / pop_selecionada_total

consolidado2_art1 <- ((ICMS_Solidario * 4.14) / 100) + consolidado1_art1



# Cálculo do mínimo per capita --------------------------------------------


minimo_per_capita <- consolidado2_art1 / idx[["População bruto"]]

media <- (sum(consolidado2_art1) / sum(idx[["População bruto"]])) * 1/3

pop_selecionada <- tibble(
    "População bruto" = idx[["População bruto"]],
    minimo_per_capita
  ) %>% 
  mutate(
    Pop_selecionada = if_else(minimo_per_capita < media, `População bruto`, 0)
  )

pop_selecionada <- pop_selecionada[["Pop_selecionada"]]

ind_minimo_per_capita <- pop_selecionada / sum(pop_selecionada) * 100




# Adicionar últimos índices e cálculo do índice de participação final ---------


ind_final <- round(((ind_minimo_per_capita * 0.1 / 100) + consolidado2_art1), 8)

ind_final <- ind_final + ((100 - sum(ind_final)) / 853)


idx <- idx %>% 
  mutate(
    "ICMS Solidário" = ICMS_Solidario,
    "Índice Mínimo per capita" = ind_minimo_per_capita,
    "Índice de participação" = ind_final
  )


# Exportando resultados para a pasta saídas -------------------------------


# Colunas para exportar:

colunas <- c("População dos 50 + Populosos", "Área Geográfica", "Educação", 
             "Patrimônio Cultural", "Receita Própria", "Cota Mínima", "Mineradores", 
             "Saúde per capita", "VAF", "Esportes", "Turismo", "Penitenciárias", 
             "Recursos Hídricos", "Produção de Alimentos", "Unidades de Conservação (IC i)", 
             "Saneamento", "Mata Seca", "Meio Ambiente", "População", "PSF", 
             "ICMS Solidário", "Índice Mínimo per capita", "Índice de participação")

idx_formatado <- idx %>% 
  pivot_longer(
    cols = all_of(colunas),
    names_to = "Critério",
    values_to = "Valor"
  ) %>% 
  select(Ano, `Mês`, IBGE2, Critério, Valor)


codigos_site <- read_csv2(
  "entradas/Cod_indices_site.csv",
  locale = locale(encoding = "Latin1")
)


idx_formatado <- idx_formatado %>% 
  left_join(
    codigos_site,
    by = c("Critério" = "Variavel")
  ) %>% 
  select(Ano, `Mês`, IBGE2, `Cód índ`, Valor)


meses <-  1:12
names(meses) <- c("Janeiro", "Fevereiro", "Março", "Abril", 
                  "Maio", "Junho", "Julho", "Agosto", "Setembro",
                  "Outubro", "Novembro", "Dezembro")


idx_formatado$Mês <- unname(meses[idx_formatado$Mês])


colnames(idx_formatado) <- c("ano",	"mês", "Cod", "Cód índ", "Valor índ") 


write.csv2(idx_formatado, "saidas/Idx_para_site.csv", row.names = FALSE)

write.csv2(idx, "saidas/Idx_resultado.csv", row.names = FALSE)

print("Cálculo do IDX efetuado com sucesso - Arquivos de IDX_resultado e IDX_para_site  gerados, pasta saídas")

# -----------------------------------------------------