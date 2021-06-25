

library("pdftools")
library("dplyr")

pdf_file <- "relatorio.pdf"

relatorio <- data.frame()

for(pagina in c(2:9)){

  pos <- pdf_data(pdf_file)[[pagina]]
  
  ranking_pos <- pos[pos[,"text"] == 'RANKING',]
  municipio_pos <- pos[pos[,"text"] == 'MUNICÍPIO',]
  nota_final_pos <- pos[pos[,"text"] == "NOTA",]
  percentual_pos <- pos[pos[,"text"] == 'PERCENTUAL',]
  
  ranking <- subset(pos[, 6], pos$y > ranking_pos$y & pos$x >= ranking_pos$x & pos$x < municipio_pos$x)
  
  cidades <- subset(pos[, c(4, 6)], pos$y > municipio_pos$y & pos$y < 810 & pos$x >= municipio_pos$x & pos$x < nota_final_pos$x)
  
  cidades <- cidades %>% 
    group_by(y) %>% 
    summarise(nomes_cidades = paste(text, collapse = " ")) %>%
    select(nomes_cidades)
   
  nota_final <- subset(pos[, 6], pos$y > nota_final_pos$y & pos$x >= nota_final_pos$x & pos$x < percentual_pos$x)
  nota_final <- lapply(nota_final, as.numeric)
  
  percentual <- subset(pos[,  6], pos$y > percentual_pos$y & pos$x >= percentual_pos$x)
  percentual <- data.frame(sub('%', '', percentual$text))
  percentual <- lapply(percentual, as.numeric)
  relatorio_parcial <- cbind(ranking, cidades, nota_final, percentual)
  relatorio <- rbind(relatorio, relatorio_parcial)

}


colnames(relatorio) <- c('Ranking', 'Municipio', 'Nota final', 'Percentual')


