### script para acompanhamento dos dados da Covid

### Pacote que importa dados da John Hopkins feito pela EST/UFMG
install.packages("covid19br")

library(covid19br)
library(tidyverse)
library(dplyr) 
library(ggplot2) 
library(zoo)

brazil <- downloadCovid19(level = "brazil")
regions <- downloadCovid19(level = "regions")
states <- downloadCovid19(level = "states")
cities <- downloadCovid19(level = "cities")


#selecionando os dados de MG

mg <- filter(states, state == "MG" & date >= "2020-04-01")

# Preciso inserir os dados de média móvel no data frame. A solução inicial foi usar
# a função rollmean do pacote zoo

mm_mg <- rollmean(mg$newDeaths,14)

# Solução para resolver o problema de diferença de dimensão quando gero o vetor média movel (mm_mg)
mm_mg_full <- c(rep(0,13),mm_mg)

mg$mm <- mm_mg_full

table(cities$city)

# Fazendo o mesmo para Belo Horizonte

bh <- filter(cities, city == "Belo Horizonte" & date >= "2020-04-01")

mm <- rollmean(bh$newDeaths,14)

mm_full <- c(rep(0,13),mm)

bh$mm <- mm_full

ggplot(mg, aes(y = newDeaths, x = date)) +
  geom_line() +
  geom_line(aes(y = mm)) +
  theme_classic(base_size = 18) 

ggplot(bh, aes(y = newDeaths, x = date)) +
  geom_line() +
  geom_line(aes(y = mm)) +
    theme_classic(base_size = 17) 



