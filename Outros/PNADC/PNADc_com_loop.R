cat("\014")


rm(list = ls())
gc()
dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(dir)

pacotes <- c(
  "PNADcIBGE",
  "srvyr",
  "survey",
  "dplyr",
  "data.table",
  "stringr",
  "tidyr",
  "xlsx",
  "openxlsx"
)


for(i in pacotes){
  if (!require(i, character.only = TRUE)) {
    install.packages(i)
  } 
  
  library(i, character.only = TRUE)
}
memory.limit(size=9999999999)

tab_PIABR <- tibble()
tab_PIAMG <- tibble()

vetor_anos <- c(2021)
vetor_trimestres <- c(1:4)
ultimoano<-2021
ultimotrimestre<-1
#----------------------------------------------------------------------------------------#

#----------------------------------- ITERACAO (LOOP) ------------------------------------#
# Para cada ano do vetor de anos
for(ano in vetor_anos){
  # Para cada trimestre do vetor de trimestres
  for(trimestre in vetor_trimestres){
    if(ano >= ultimoano & trimestre > ultimotrimestre)
      break
        
    dadospnadc <- get_pnadc (year = ano, quarter = trimestre, vars=c("UF","V2007","VD4001","VD4002", "VD4003"))
    
    pia_br <- as.data.frame(svytotal(~interaction (V2007,VD4001), dadospnadc, na.rm = T))
    pia_br <- mutate(pia_br, variavel = row.names(pia_br))
    pia_br <- pivot_wider(pia_br[, -2], names_from = variavel, values_from = total)
    pia_br <- pia_br |> mutate(total = rowSums(pia_br)/1000) |> mutate(ano = ano  ) |> mutate(trimestre = trimestre)
    
    pia_mg <- as.data.frame(svytotal(~interaction (V2007,VD4001), subset(dadospnadc, UF == "Minas Gerais"), na.rm = T))
    pia_mg <- mutate(pia_mg, variavel = row.names(pia_mg))
    pia_mg <- pivot_wider(pia_mg[, -2], names_from = variavel, values_from = total)
    pia_mg <- pia_mg |> mutate(total = rowSums(pia_mg)/1000) |> mutate(ano = ano  ) |> mutate(trimestre = trimestre)
    
    tab_PIABR <- rbind (tab_PIABR, pia_br) 
    tab_PIAMG <- rbind (tab_PIAMG, pia_mg) 
  }
}

xlsx1 <- createWorkbook()
addWorksheet(xlsx1, "pia_br")
addWorksheet(xlsx1, "pia_mg")
writeData(xlsx1, "pia_br", tab_PIABR)
writeData(xlsx1, "pia_mg", tab_PIAMG)
saveWorkbook(xlsx1, file = "pia.xlsx", overwrite = TRUE)
