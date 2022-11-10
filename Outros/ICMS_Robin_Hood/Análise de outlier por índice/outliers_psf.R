
# Script procurador outliers PSF. V2 - 22/06/2022 -------------------------

library(tidyverse)
library(openxlsx)
library(tseries)

psf <- read.xlsx("serie_psf.xlsx")

psfc <- psf %>%
        filter(!is.na(IBGE) & IBGE != 620) %>%
        select(IBGE, Municipio, Média.arred, `Var.(%)`) %>%
        mutate(Média.arred = round(Média.arred),
               `Var.(%)` = round(x = 100*`Var.(%)`,2))


# Função para agrupar SS
tot_withinss <- map_dbl(1:10,  function(k){
  model <- kmeans(x = psfc$Média.arred, centers = k)
  model$tot.withinss
})

elbow_df <- data.frame(
  k = 1:10,
  tot_withinss = tot_withinss
)


# elbow plot
ggplot(elbow_df, aes(x = k, y = tot_withinss)) +
  geom_line() + geom_point()+
  scale_x_continuous(breaks = 1:10)




#### 5 Centros 

clusters <- kmeans(psfc$Média.arred, centers = 5)

## Agregando valores

psf_x <- psfc %>%
        mutate(cluster = clusters$cluster)

n_clusters <- 1:5

filtrados <- list()

for (i in n_clusters) {
  
  filtrados[[i]] <- psf_x %>%
                    filter(cluster == i)
}

for (i in n_clusters) {
  
  filtrados[[i]] <- filtrados[[i]] %>%
                    mutate(`var_media_grupo(%)` = round(mean(`Var.(%)`),2),
                           estatistica = round((`Var.(%)` - mean(`Var.(%)`))/sd(`Var.(%)`),2)) %>%
                    filter(abs(estatistica) >= 3)
}

psf_exp <- bind_rows(filtrados)

write.xlsx(psf_exp, "outliers_psf.xlsx")
