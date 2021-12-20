


install.packages("RSelenium")
install.packages('Rcpp') 

library("RSelenium")
library("Rcpp")
library("curl")

dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(dir)


rD <- rsDriver(browser="firefox", port=4551L, verbose=F)
remDr <- rD[["client"]]



remDr$navigate("http://robin-hood.fjp.mg.gov.br/index.php/transferencias/pesquisacriterio")
ano <- "2020"
remDr$findElement(using = "xpath", value = "//select[@name='ano']//option[@value='2020']")$clickElement()
remDr$findElement(using = "xpath", value = "//select[@name='indice']//option[contains(text(), 'Patrimônio Cultural')]")$clickElement()
remDr$findElement(using = "xpath", value = "//input[@name='pesquisar']")$clickElement()

url_arquivo <- remDr$findElement(using = "xpath", value = "//a[contains(text(), 'Patrimônio Cultural')]")$getElementAttribute('href')

destfile <- paste0(dir, "/icms_pat_cult.xlsx")

download.file(url_arquivo[[1]], destfile, method = "curl")

