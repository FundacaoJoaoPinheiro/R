# "Extração de séries do Google Trends"
# author: "Caio Gonçalves - caio.goncalves@fjp.mg.gov.br"
# date: "26-maio-2023"

# Extração de séries

if (!require("gtrendsR")){
  install.packages("gtrendsR")
  library(gtrendsR)
}

?gtrends

# Exemplo 1
serie01 <- gtrends(keyword ="Minas Gerais",
                   geo = "BR",
                   time =  "today 3-m")
head(serie01$interest_over_time)

# Exemplo 2
serie02 <- gtrends(keyword ="currículo",
                   geo = "BR",
                   time =  "2012-01-01 2023-04-30")
head(serie02$interest_over_time)
# gráfico
plot(serie02)

# Exemplo 3
serie03 <- gtrends(keyword ="curriculo",
                   geo = "BR",
                   time =  "2012-01-01 2023-04-30")
# gráfico
plot(ts.union(ts(serie02$interest_over_time$hits,start = c(2012,1), frequency = 12),
              ts(serie03$interest_over_time$hits,start = c(2012,1), frequency = 12)),
     plot.type = "single",col = c(1,2), ylab="", xlab="Mês")
legend("bottomright", legend = c("currículo","curriculo"),col = c(1,2), bty = 'n',lty = c(1,1))


# Aplicando filtro geográfico
serie04 <- gtrends(keyword ="vaga de emprego",
                   geo = "BR-MG",
                   time =  "2012-01-01 2023-04-30")
# gráfico
plot(serie04)


serie05 <- gtrends(keyword ="vaga de emprego",
                   geo = c("BR-MG","BR-SP"),
                   time =  "2012-01-01 2023-04-30")
head(serie05$interest_over_time)

# Extraindo uma categoria
data("categories")
View(categories)

serie06a <- gtrends(keyword ="vaga",
                    geo = "BR-MG",
                    time =  "2012-01-01 2023-04-30",
                    category = 0)
serie06b <- gtrends(keyword ="vaga",
                    geo = "BR-MG",
                    time =  "2012-01-01 2023-04-30",
                    category = 60)
head(serie06a$interest_over_time)
head(serie06b$interest_over_time)

# gráfico
plot(ts.union(ts(serie06a$interest_over_time$hits,start = c(2012,1), frequency = 12),
              ts(serie06b$interest_over_time$hits,start = c(2012,1), frequency = 12)),
     plot.type = "single",col = c(1,2), ylab="", xlab="Mês")
legend("topleft", legend = c("sem categoria","com categoria"),col = c(1,2), bty = 'n',lty = c(1,1))

serie07 <- gtrends(geo = "BR-MG",
                   time =  "2012-01-01 2023-04-30",
                   category = 60)
# gráfico
plot(serie07)

# Comparando séries
serie08 <- gtrends(keyword =  c("currículo","curriculo","vaga de emprego","vaga","sine"),
                   geo = "BR-MG",
                   time =  "2012-01-01 2023-04-30",
                   category = 60)
head(serie08$interest_over_time)
# gráfico
plot(serie08)

#Extraindo palavras relacionadas
serie09 <- gtrends(keyword =  c("currículo"),
                   geo = "BR-MG",
                   time =  "2012-01-01 2023-04-30",
                   category = 0)
serie09$related_queries$value

palavras <- unique(c("currículo",serie09$related_queries$value)) #conjunto de palavras únicas
length(palavras)

# Computação paralela
start_time <- Sys.time()
data01 <- sapply(palavras[1:25], function(i) gtrends(keyword =  i,
                                                     geo = "BR-MG",
                                                     time =  "2012-01-01 2023-04-30",
                                                     category = 60,
                                                     onlyInterest = TRUE)$interest_over_time$hits)
end_time <- Sys.time()
end_time - start_time

if (!require("parallel")){
  install.packages("parallel")
  library(parallel)
}

numCores<-detectCores()
numCores

# criando clusters
cl<- makeCluster(numCores-1)

# salva imagem
save.image("partial.Rdata")

# envia dados para cada um dos cluster
clusterEvalQ(cl,{load("partial.Rdata")
  library(gtrendsR)
})

start_time <- Sys.time()
data02 <- parSapply(cl,palavras[1:25], function(i) gtrends(keyword =  i,
                                                           geo = "BR-MG",
                                                           time =  "2012-01-01 2023-04-30",
                                                           category = 60,
                                                           onlyInterest = TRUE)$interest_over_time$hits)
end_time <- Sys.time()
end_time - start_time

# stop cluster
stopCluster(cl)

# Extras
# Construindo um ranking relativo

f.ranking <- function(palavra, palavra_rel, geo, time, category){
  # extrai o par de séries
  data = gtrends(keyword =  c(palavra,palavra_rel),
                 geo = geo,
                 time =  time,
                 category = category,
                 onlyInterest = TRUE)$interest_over_time$hits
  # seleciona a série apenas da palavra em estudo
  data = data[1:(length(data)/2)]
  # substitui na base os menores que 1 por zero
  data[data=="<1"]=0
  # transforma em numérico
  data = as.numeric(data)
  # computa uma médida síntese
  media = mean(data,na.rm=TRUE)
  return(media)
}


# criando clusters
cl<- makeCluster(numCores-1)

# salva imagem
save.image("partial.Rdata")

# envia dados para cada um dos cluster
clusterEvalQ(cl,{load("partial.Rdata")
  library(gtrendsR)
})

ranking <- parSapply(cl,palavras, function(i) f.ranking(palavra = i,
                                                        palavra_rel = "currículo",
                                                        geo = "BR-MG",
                                                        time = "2012-01-01 2023-04-30",
                                                        category = 60))  
# ordena
ranking <- data.frame(média = sort(ranking, decreasing = TRUE))
ranking

if (!require("wordcloud")){
  install.packages("wordcloud")
  library(wordcloud)
}

set.seed(32)  #para reproduzir a mesma núvem

wordcloud(words = rownames(ranking),
          freq = ranking$média,
          scale = c(4, 1),  min.freq=0, max.words = 50,
          random.order = FALSE,
          color = 1:nrow(ranking))