# Abrindo a base do Max

library(openxlsx)

dados <- read.xlsx(xlsxFile = "C://DPP esportes Max.xlsx", sheet = 2)

# L_PROGE

dados_conselho <- subset(dados, dados$`Conselho.de.esportes?`=="Sim")

l_proge <- dados_conselho$Pontuação.Município.soma.das.atividades.do.município/dados_conselho$Peso.da.RCL

l_proge <- as.data.frame(cbind(dados_conselho$municipios, l_proge))

names(l_proge)[names(l_proge)=="V1"] <- "Município"

# L_CONSESP

l_consesp <- as.data.frame(cbind(dados$municipios,dados$`Conselho.de.esportes?`))

l_consesp[is.na(l_consesp)] = "Não"

names(l_consesp)[names(l_consesp)=="V1"] <- "Município"
names(l_consesp)[names(l_consesp)=="V2"] <- "l_consesp"

# L_ILRHE

options(scipen = 9999999)

l_ilrhe <- dados_conselho$Pontuação.Município.soma.das.atividades.do.município/386402

l_ilrhe <- as.data.frame(cbind(dados_conselho$municipios, l_ilrhe))

names(l_ilrhe)[names(l_ilrhe)=="V1"] <- "Município"

