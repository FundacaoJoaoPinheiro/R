
library("rvest")
library("RSelenium")
library(tidyverse)

# Programa bolsa família - quantidade
url <- "https://aplicacoes.mds.gov.br/sagi/vis/data3/data-explorer.php"

dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(dir)
file_path <- getwd() %>% str_replace_all("/", "\\\\\\\\")
fprof <- makeFirefoxProfile(list(browser.download.dir = file_path,
                                 browser.download.folderList = 2L,
                                 browser.download.manager.showWhenStarting = FALSE,
                                 browser.helperApps.neverAsk.openFile = "text/csv",
                                 browser.helperApps.neverAsk.saveToDisk = "text/csv")
)
rD <- rsDriver(browser = "firefox", extraCapabilities = fprof, port = 4444L)
remDr <- rD[["client"]]

remDr$navigate("https://aplicacoes.mds.gov.br/sagi/vis/data3/data-explorer.php")

#aceita os cookies
remDr$executeScript('return document.querySelector("#btnAccepptLgpdSagi").click()')

dados <- list("Programa Bolsa Família - quantidade de famílias e valores", 
              "Pessoas com deficiência (PCD) que recebem o Benefício de Prestação Continuada (BPC) por Município pagador",
              "Idosos que recebem o Benefício de Prestação Continuada (BPC) por Município pagador",
              "Valor repassado às pessoas com deficiência (PCD) via Benefício de Prestação Continuada (BPC) por município pagador",
              "Valor repassado aos idosos via Benefício de Prestação Continuada (BPC) por município pagador"
              )

tempo_espera <- 2
i <- 1
for(i in c(1:length(dados))){
  
  remDr$navigate("https://aplicacoes.mds.gov.br/sagi/vis/data3/data-explorer.php")
  Sys.sleep(tempo_espera)
  
  remDr$findElement(using = 'xpath', value = paste("//h5[contains(text(),", dados[i], ")]", sep='\''))$clickElement()
  Sys.sleep(tempo_espera)
  
  remDr$findElement(using = 'xpath', value = "//button/*[contains(text(), 'Brasil')]")$clickElement()
  
  remDr$findElement(using = 'xpath', value = "//button[contains(text(), 'SELECIONAR')]")$clickElement()
  Sys.sleep(tempo_espera)
  
  #a <- remDr$findElements(using = 'xpath', value = "//span[@class = 'selection']")
  #unlist(sapply(a, function(x) {x$getElementText()}))
  
  remDr$findElement(using = 'xpath', value = "//select[@id = 'dtInicialFiltro']/../span")$clickElement()
  campo1 <-remDr$findElement(using = 'xpath', value = "//span[@class = 'select2-search select2-search--dropdown']/input")
  campo1$sendKeysToElement(list('01/2020\n')) # '\n' serve pra simular o enter após ter digitado o texto
  
  
  remDr$findElement(using = 'xpath', value = "//select[@id = 'dtFinalFiltro']/../span")$clickElement()
  campo2 <-remDr$findElement(using = 'xpath', value = "//span[@class = 'select2-search select2-search--dropdown']/input")
  campo2$sendKeysToElement(list('12/2020\n')) # '\n' serve pra simular o enter após ter digitado o texto
  
  remDr$findElement(using = 'xpath', value = "//button[@class='btn btn-outline-secondary']")$clickElement()
  Sys.sleep(tempo_espera)
  
  remDr$findElement(using = 'xpath', value = "//button/*[contains(text(), 'Baixar CSV')]")$clickElement()
  Sys.sleep(tempo_espera)
  
  #encontra o último arquivo que foi baixado
  lsfiles <- file.info(dir())
  nome_arquivo <- row.names(lsfiles[order(lsfiles$mtime, decreasing = TRUE),])[1]
 
  d <- read.csv(nome_arquivo) 
  
  e <- d |> subset(UF == "MG")
  
  
}


#unlist(sapply(a, function(x) {x$getElementText()}))

#remDr$findElement(using = 'xpath', value = "//select[@id = 'dtInicialFiltro']/option[contains(text(), '01/2020')]")$clickElement()
#unlist(sapply(a, function(x) {x$getElementText()}))


# para encerrar o server
remDr$close()
rD$server$stop()
rm(rD, remDr)
gc()

system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)
