# Abrindo a base do Max

library(openxlsx) # Abrindo o pacote 

dados <- read.xlsx(xlsxFile = "C://DPP esportes Max.xlsx", sheet = 2) # Abrindo os dados, lembrando de trocar
# \ por /

dados_conselho <- dados$`Conselho.de.esportes?` # Separando a varável de conselho de esportes 
dados_conselho <- as.data.frame(dados_conselho)
dados_conselho[is.na(dados_conselho)] = "Não" # Assinalando não para os valores ausentes, lembrando que na abse do max 
# municipios que não tem conselho de esporte aparecem como missing
dados <- cbind(dados_conselho, dados) # Combinando a nova variável de conselho de esportes com a base original 

# L_PROGE

l_proge <- ifelse(dados$dados_conselho=="Sim",
                   dados$Pontuação.Município.soma.das.atividades.do.município/dados$Peso.da.RCL,NA) # Cálculo
# do indicador: dado as cidades que tem conselho de esportes (primeira linha), dividir a pontuação pelos pesos


l_proge <- as.data.frame(cbind(dados$municipios, l_proge)) # combinando o indicador com o nome dos municipios

names(l_proge)[names(l_proge)=="V1"] <- "Município" # Mudando o nome da variável para "municipios"

# L_CONSESP

l_consesp <- as.data.frame(cbind(dados$municipios,dados$dados_conselho)) # Como já criamos esse indicador, agora
# apenas separamos o nome do municipio da variável conselho de esportes


names(l_consesp)[names(l_consesp)=="V1"] <- "Município"
names(l_consesp)[names(l_consesp)=="V2"] <- "l_consesp" # Renomenado as variáveis 

# L_ILRHE

options(scipen = 9999999) # Default do R é apresentar números em notação cinentífica,
# aqui eliminamos essa possibilidade.

l_ilrhe <-ifelse(dados$dados_conselho == "Sim",dados$Pontuação.Município.soma.das.atividades.do.município/386402,
                 NA)
# Mesmo raciocínio do l_proge, dividimos pela soma já calculada pelo max apresentada na coluna 
# Soma.Pontuação.municípios.MG

l_ilrhe <- as.data.frame(cbind(dados$municipios, l_ilrhe)) # Combinando com o nome dos municipios

names(l_ilrhe)[names(l_ilrhe)=="V1"] <- "Município" # Renomeando a primeira coluna

# Exportando a base

dados_com_indicadores <- cbind(dados, l_proge, l_consesp, l_ilrhe) # Juntando a base original com os indicadores

install.packages("writexl") # instação do pacote para exportação, fazer apenas uma vez!
library(writexl) # Carregando o pacote

write_xlsx(dados_com_indicadores,"C://dados_com_indicadores.xlsx") # exportando a base, entre "" colocar o destino
# do arquivo, como por exemplo repetir o caminho colocado para a abertura dos dados 



