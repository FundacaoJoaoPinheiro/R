library(tidyverse)
library(readxl)
library(openxlsx)



# Limpar pasta bases limpas -----------------------------------------------

unlink("./bases_limpas/*", recursive = TRUE, force = TRUE)

# Limpeza planilha ICMS ---------------------------------------------------

caminho_icms <- str_c("./entradas", list.files("./entradas", "ICMS", ignore.case = TRUE), sep = "/")


icms <- read_excel(caminho_icms,
                   col_names = TRUE, skip = 17)[-1:-2, ] #17 linhas para pular até os dados
                                                          #removendo linhas 1 e 2 de NA

colnames(icms) <- c("SEF", "Município", "Índice",
                    str_to_title(colnames(icms)[4]), str_to_title(colnames(icms)[5]),
                    "FUNDEB", "Saúde", "Compensações", "Líquido")
icms <- icms %>%
          mutate(Ano = str_split(colnames(icms)[5], " ")[[1]][3],
                 Mês = str_split(colnames(icms)[5], " ")[[1]][2])

portaria_ICMS <- icms[1:853, ] %>%
                    mutate(across(.cols = !c(Município, Mês), .fns = as.numeric))

write.xlsx(portaria_ICMS, "./bases_limpas/Portaria_ICMS.xlsx", overwrite = TRUE)



# Limpeza planilha do IPI -------------------------------------------------

caminho_ipi <- str_c("./entradas", list.files("./entradas", "IPI", ignore.case = TRUE), sep = "/")


ipi <- read_excel(caminho_ipi,
                  col_names = TRUE, skip = 15)[-1, 1:8]

mes_ano_ipi <- str_to_title(str_split(colnames(ipi)[3], " ")[[1]]) 
  
colnames(ipi) <- c("SEF", "Município", "Índice", "Bruto", "FUNDEB",
                   "PASEP", "Saúde", "Líquido")

ipi <- ipi %>% 
        mutate(Ano = mes_ano_ipi[3],
               Mês = mes_ano_ipi[2])

portaria_IPI <- ipi[1:853, ] %>%
                  mutate(across(.cols = !c(Município, Mês), .fns = as.numeric))


write.xlsx(portaria_IPI, "./bases_limpas/Portaria_IPI.xlsx", overwrite = TRUE)

# Limpeza planilha IDX ----------------------------------------------------


caminhos_idx <- str_c("./entradas", list.files("./entradas", "Idx", ignore.case = TRUE) , sep = "/")

lista_idx <- list()

for (i in caminhos_idx) {


lista_idx[[i]] <- read.xlsx(i,
                   sheet = "IDX",
                   startRow = 6,
                   sep.names = " ")

}

colunas_escolhidas <- c("IBGE1",	"IBGE2",	"SEF",	"Municípios",	"Mês",	"Ano",	"População",
                        "População dos 50 + Populosos",	"Área Geográfica",	"Educação",
                        "Patrimônio Cultural",	"Receita Própria",	"Cota Mínima",	"Mineradores",
                        "Saúde per capita",	"VAF",	"Esportes",	"Turismo",	"Penitenciárias",
                        "Recursos Hídricos",	"Produção de Alimentos",	"Unidades de Conservação (IC i)",
                        "Saneamento",	"Mata Seca",	"Meio Ambiente", "PSF", "ICMS Solidário",
                        "Índice Mínimo per capita", "Índice de participação")
exportar_idx <- list()

for (i in names(lista_idx)) {

exportar_idx[[i]] <- lista_idx[[i]][1:853, ] %>% #selecionando apenas linhas 1 até 853 (municípios). 
  select(all_of(colunas_escolhidas)) %>% #Restantes são desnecessárias
  mutate(across(.cols = -c("Municípios", "Mês"), .fns = as.numeric)) 
}



for (i in names(exportar_idx)) {

write.xlsx(exportar_idx[[i]], str_c("./bases_limpas/Idx ", as.character(exportar_idx[[i]]$`Mês`)[1], ".xlsx"), overwrite = TRUE)

}

print("Bases limpas e salvas na pasta \"bases_limpas")
# -------------------------------------------------------------------------
