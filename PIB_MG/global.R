library(shiny)
library(shinydashboard)
library("readxl")
library("dplyr")
library(highcharter)
library(tidyverse)
library("xlsx")
library("shinyjs")
library(shinyBS)
library(rvest)

#dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
#setwd(dir)


# Importação dos dados e pré-processamento ------------------------------------------------------------------------------

temp = tempfile(fileext = ".xlsx")
pag_fjp <- read_html("http://fjp.mg.gov.br/produto-interno-bruto-pib-de-minas-gerais/")
url <- pag_fjp |> html_element(xpath = "//a[contains(text(), 'Base')]/../../../*/div[@id='elementor-tab-content-1429']/*/li[2]/a") |> html_attr(name = 'href')
download.file(url, destfile=temp, mode='wb')
#file_tab1 <- read.xlsx(temp, sheet= 1)
file_tab1 <- read.xlsx(temp, sheetIndex = 1)
file_tab4 <- read.xlsx(temp, sheetIndex = 4)
file_tab5 <- read.xlsx(temp, sheetIndex = 5)
file_tab6 <- read.xlsx(temp, sheetIndex = 6)
file_tab7 <- read.xlsx(temp, sheetIndex = 7)
file_tab8 <- read.xlsx(temp, sheetIndex = 8)
file_tab10 <- read.xlsx(temp, sheetIndex = 10)

#file_tab1 <- read.xlsx("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx", sheetIndex = 1)
#file_tab4 <- read.xlsx("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx", sheetIndex = 4)
#file_tab5 <- read.xlsx("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx", sheetIndex = 5)
#file_tab6 <- read.xlsx("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx", sheetIndex = 6)
#file_tab7 <- read.xlsx("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx", sheetIndex = 7)
#file_tab8 <- read.xlsx("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx", sheetIndex = 8)
#file_tab10 <- read.xlsx("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx", sheetIndex = 10)


ultimo_ano <- file_tab1[4, ]
ultimo_ano <- as.numeric(max(ultimo_ano[!is.na(ultimo_ano)]))

contas_economicas <- file_tab1[c(7,8,10,17,18,19,20,21,11), c(1:(ultimo_ano-2010+2))]
nomes <- c("Produção", "Impostos produtos", "Consumo Intermediário", "Remuneração", "Salários", "Contribuições", "Impostos produção", "Excedente", "PIB")
nomes_producao <- c("Produção", "Impostos produtos", "Consumo Intermediário", "PIB")
nomes_renda <- c("Remuneração", "Salários", "Contribuições", "Impostos produção", "Excedente", "PIB")
contas_economicas[, 1] <-  nomes
colnames(contas_economicas)[c(1:(ultimo_ano-2010+2))] <- c("contas", as.character(c(2010:ultimo_ano)))
contas_economicas <- contas_economicas %>% gather(key = 'ano', value = 'valor', -contas)
contas_economicas[, -1] <- lapply(contas_economicas[, -1], as.numeric) # make all columns numeric


pib_percapita <- file_tab4[c(5,9,12), c(1:(ultimo_ano-2010+2))]
nomes <- c("PIB", "População", "PIB per capita")
pib_percapita[, 1] <-  nomes
colnames(pib_percapita)[c(1:(ultimo_ano-2010+2))] <- c("especificacao", as.character(c(2010:ultimo_ano)))
pib_percapita <- pib_percapita %>% gather(key = 'ano', value = 'valor', -especificacao)
pib_percapita[, -1] <- lapply(pib_percapita[, -1], as.numeric) # make all columns numeric

vbp_corrente <- file_tab5[c(7:27), c(1, seq(2, length=(ultimo_ano-2010+1), by=4))] 
vbp_var_volume <- file_tab5[c(7:27), c(1, seq(3, length=(ultimo_ano-2010), by=4))] 
vbp_var_preco <- file_tab5[c(7:27), c(1, seq(5, length=(ultimo_ano-2010), by=4))]
vbp_particip <- file_tab8[c(6:26), c(1:(ultimo_ano-2010+2))]
setores <- c("Agropecuária",
             "Agricultura",
             "Pecuária",
             "Prod. florestal",
             "Indústria",
             "Ind. extrativa",
             "Ind. transformação",
             "Energia e saneamento",
             "Construção",
             "Serviços",
             "Comércio",
             "Transporte",
             "Alojamento e alimentação",
             "Informação e comunicação",
             "Ativ. financeiras",
             "Ativ. imobiliárias",
             "Serv. pres. empresas",
             "APU",
             "Educação e saúde",
             "Cultura e esporte",
             "Serv. domésticos"
)
setor_index <- c(2:4, 6:9, 11:21)
area_index <- c(1, 5, 10)
setor <- setores[setor_index]
area <- setores[area_index]

espec_prod <- c('Produção', 'Impostos produtos', 'Consumo Intermediário', 'PIB')
espec_renda <- c('Salários', 'Contribuições', 'Impostos produção', 'Excedente', 'PIB')
tipoResutados <- c("Valor Bruto da Produção" = 'VBP', "Consumo Intermediário" = 'CI', "Valor Adicionado Bruto" = 'VAB')
aspectos2 <- c("Valor corrente" = 'vc', "Var. volume" = 'vv', "Var. preço" = 'vp', "Part. valor corrente em MG" = 'pmg' , "Part. valor corrente no Brasil" = 'pbr')
tiposGraficos <- c("Linha" = 'linha', "Barra"= 'barra', "Barra Empilhado" = 'barra_empilhado', "Pizza" = 'pizza')
tiposGraficos2 <- c("Linha" = 'linha', "Barra"= 'barra')
vbp_corrente[, 1] <-  setores
colnames(vbp_corrente)[c(1:(ultimo_ano-2010+2))] <- c("setor", as.character(c(2010:ultimo_ano)))
vbp_corrente <- vbp_corrente %>% gather(key = 'ano', value = 'valor', -setor)
vbp_corrente[, -1] <- lapply(vbp_corrente[, -1], as.numeric) # make all columns numeric

vbp_var_volume[, 1] <-  setores
colnames(vbp_var_volume)[c(1:(ultimo_ano-2010+1))] <- c("setor", as.character(c(2011:ultimo_ano)))
vbp_var_volume <- vbp_var_volume %>% gather(key = 'ano', value = 'valor', -setor)
vbp_var_volume[, -1] <- lapply(vbp_var_volume[, -1], as.numeric) # make all columns numeric
aux <- data.frame(setores, 2010, NA)
names(aux) <- c("setor", "ano", "valor")
vbp_var_volume <- rbind(aux, vbp_var_volume)

vbp_var_preco[, 1] <-  setores
colnames(vbp_var_preco)[c(1:(ultimo_ano-2010+1))] <- c("setor", as.character(c(2011:ultimo_ano)))
vbp_var_preco <- vbp_var_preco %>% gather(key = 'ano', value = 'valor', -setor)
vbp_var_preco[, -1] <- lapply(vbp_var_preco[, -1], as.numeric) # make all columns numeric
aux <- data.frame(setores, 2010, NA)
names(aux) <- c("setor", "ano", "valor")
vbp_var_preco <- rbind(aux, vbp_var_preco)

vbp_particip[, 1] <-  setores
colnames(vbp_particip)[c(1:(ultimo_ano-2010+2))] <- c("setor", as.character(c(2010:ultimo_ano)))
vbp_particip <- vbp_particip %>% gather(key = 'ano', value = 'valor', -setor)
vbp_particip[, -1] <- lapply(vbp_particip[, -1], as.numeric) # make all columns numeric

vbp <- cbind(vbp_corrente, vbp_var_volume[3], vbp_var_preco[3],  vbp_particip[, 3])
colnames(vbp) <- c("setor", "ano", "corrente", "var_volume", "var_preco", "particip")


ci_corrente <- file_tab6[c(7:27), c(1, seq(2, length=(ultimo_ano-2010+1), by=4))]
ci_var_volume <- file_tab6[c(7:27), c(1, seq(3, length=(ultimo_ano-2010), by=4))]
ci_var_preco <- file_tab6[c(7:27), c(1, seq(5, length=(ultimo_ano-2010), by=4))]
ci_particip <- file_tab8[c(6:26), c(1, seq((ultimo_ano-2010+3), length=(ultimo_ano-2010+1), by=1))]

ci_corrente[, 1] <-  setores
colnames(ci_corrente)[c(1:(ultimo_ano-2010+2))] <- c("setor", as.character(c(2010:ultimo_ano)))
ci_corrente <- ci_corrente %>% gather(key = 'ano', value = 'valor', -setor)
ci_corrente[, -1] <- lapply(ci_corrente[, -1], as.numeric) # make all columns numeric

ci_var_volume[, 1] <-  setores
colnames(ci_var_volume)[c(1:(ultimo_ano-2010+1))] <- c("setor", as.character(c(2011:ultimo_ano)))
ci_var_volume <- ci_var_volume %>% gather(key = 'ano', value = 'valor', -setor)
ci_var_volume[, -1] <- lapply(ci_var_volume[, -1], as.numeric) # make all columns numeric
aux <- data.frame(setores, 2010, NA)
names(aux) <- c("setor", "ano", "valor")
ci_var_volume <- rbind(aux, ci_var_volume)

ci_var_preco[, 1] <-  setores
colnames(ci_var_preco)[c(1:(ultimo_ano-2010+1))] <- c("setor", as.character(c(2011:ultimo_ano)))
ci_var_preco <- ci_var_preco %>% gather(key = 'ano', value = 'valor', -setor)
ci_var_preco[, -1] <- lapply(ci_var_preco[, -1], as.numeric) # make all columns numeric
aux <- data.frame(setores, 2010, NA)
names(aux) <- c("setor", "ano", "valor")
ci_var_preco <- rbind(aux, ci_var_preco)

ci_particip[, 1] <-  setores
colnames(ci_particip)[c(1:(ultimo_ano-2010+2))] <- c("setor", as.character(c(2010:ultimo_ano)))
ci_particip <- ci_particip %>% gather(key = 'ano', value = 'valor', -setor)
ci_particip[, -1] <- lapply(ci_particip[, -1], as.numeric) # make all columns numeric

ci <- cbind(ci_corrente, ci_var_volume[3], ci_var_preco[3],  ci_particip[, 3])
colnames(ci) <- c("setor", "ano", "corrente", "var_volume", "var_preco", "particip")


vab_corrente <- file_tab7[c(7:27), c(1, seq(2, length=(ultimo_ano-2010+1), by=4))]
vab_var_volume <- file_tab7[c(7:27), c(1, seq(3, length=(ultimo_ano-2010), by=4))]
vab_var_preco <- file_tab7[c(7:27), c(1, seq(5, length=(ultimo_ano-2010), by=4))]
vab_particip <- file_tab8[c(6:26), c(1, seq((ultimo_ano-2010+2)*2, length=(ultimo_ano-2010+1), by=1))]
vab_particip_br <- file_tab10[c(6:26), c(1:(ultimo_ano-2010+2))]

vab_corrente[, 1] <-  setores
colnames(vab_corrente)[c(1:(ultimo_ano-2010+2))] <- c("setor", as.character(c(2010:ultimo_ano)))
vab_corrente <- vab_corrente %>% gather(key = 'ano', value = 'valor', -setor)
vab_corrente[, -1] <- lapply(vab_corrente[, -1], as.numeric) # make all columns numeric

vab_var_volume[, 1] <-  setores
colnames(vab_var_volume)[c(1:(ultimo_ano-2010+1))] <- c("setor", as.character(c(2011:ultimo_ano)))
vab_var_volume <- vab_var_volume %>% gather(key = 'ano', value = 'valor', -setor)
vab_var_volume[, -1] <- lapply(vab_var_volume[, -1], as.numeric) # make all columns numeric
aux <- data.frame(setores, 2010, NA)
names(aux) <- c("setor", "ano", "valor")
vab_var_volume <- rbind(aux, vab_var_volume)

vab_var_preco[, 1] <-  setores
colnames(vab_var_preco)[c(1:(ultimo_ano-2010+1))] <- c("setor", as.character(c(2011:ultimo_ano)))
vab_var_preco <- vab_var_preco %>% gather(key = 'ano', value = 'valor', -setor)
vab_var_preco[, -1] <- lapply(vab_var_preco[, -1], as.numeric) # make all columns numeric
aux <- data.frame(setores, 2010, NA)
names(aux) <- c("setor", "ano", "valor")
vab_var_preco <- rbind(aux, vab_var_preco)

vab_particip[, 1] <-  setores
colnames(vab_particip)[c(1:(ultimo_ano-2010+2))] <- c("setor", as.character(c(2010:ultimo_ano)))
vab_particip <- vab_particip %>% gather(key = 'ano', value = 'valor', -setor)
vab_particip[, -1] <- lapply(vab_particip[, -1], as.numeric) # make all columns numeric

vab_particip_br[, 1] <-  setores
colnames(vab_particip_br)[c(1:(ultimo_ano-2010+2))] <- c("setor", as.character(c(2010:ultimo_ano)))
vab_particip_br <- vab_particip_br %>% gather(key = 'ano', value = 'valor', -setor)
vab_particip_br[, -1] <- lapply(vab_particip_br[, -1], as.numeric) # make all columns numeric

vab <- cbind(vab_corrente, vab_var_volume[3], vab_var_preco[3],  vab_particip[3], vab_particip_br[3] )
colnames(vab) <- c("setor", "ano", "corrente", "var_volume", "var_preco", "particip", "particip_br")

valor_corrente <- cbind(vbp_corrente, ci_corrente[3], vab_corrente[3])
colnames(valor_corrente) <- c("setor", "ano", "VBP", "CI", "VAB")
valor_corrente <- pivot_longer(valor_corrente, cols = c(3:5), names_to = "resultado", values_to = "valor")

var_volume <- cbind(vbp_var_volume, ci_var_volume[3], vab_var_volume[3])
colnames(var_volume) <- c("setor", "ano", "VBP", "CI", "VAB")
var_volume <- pivot_longer(var_volume, cols = c(3:5), names_to = "resultado", values_to = "valor")

var_preco <- cbind(vbp_var_preco, ci_var_preco[3], vab_var_preco[3])
colnames(var_preco) <- c("setor", "ano", "VBP", "CI", "VAB")
var_preco <- pivot_longer(var_preco, cols = c(3:5), names_to = "resultado", values_to = "valor")

participacao_mg <- cbind(vbp_particip, ci_particip[3], vab_particip[3])
colnames(participacao_mg) <- c("setor", "ano", "VBP", "CI", "VAB")
participacao_mg <- pivot_longer(participacao_mg, cols = c(3:5), names_to = "resultado", values_to = "valor")

participacao_br <- cbind(vab_particip)
colnames(participacao_br) <- c("setor", "ano", "VAB")
participacao_br <- pivot_longer(participacao_br, cols = c(3), names_to = "resultado", values_to = "valor")


#função para exportação de imagens
export <- list(
    list(text="PNG",
         onclick=JS("function () {
                this.exportChartLocal(); }")),
    list(text="JPEG",
         onclick=JS("function () {
                this.exportChartLocal({ type: 'image/jpeg' }); }"))
    
)

#função auxiliar para criar gráfico de pizza
myhc_add_series_labels_values <- function (hc, labels, values, text, colors = NULL, ...) 
{
    assertthat::assert_that(is.highchart(hc), is.numeric(values), 
                            length(labels) == length(values))
    df <- dplyr::data_frame(name = labels, y = values, text=text)
    if (!is.null(colors)) {
        assert_that(length(labels) == length(colors))
        df <- mutate(df, color = colors)
    }
    ds <- list_parse(df)
    hc <- hc %>% hc_add_series(data = ds, ...)
    hc
}


areas <- c("Agropecuária", "Indústria",  "Serviços")
aspectos <- c("Valor Bruto da Produção (%)", "Consumo Intermediário (%)", "Valor Adicionado (%)")	

#função que mostra o logo carregando - não está funcionando
loadingLogo <- function(href, src, loadingsrc, height = NULL, width = NULL, alt = NULL) {
    tagList(
        tags$head(
            tags$script(
                "setInterval(function(){
                     if ($('html').attr('class')=='shiny-busy') {
                     $('div.busy').show();
                     $('div.notbusy').hide();
                     } else {
                     $('div.busy').hide();
                     $('div.notbusy').show();
           }
         },100)")
        ),
        tags$a(href=href,
               div(class = "busy",  
                   img(src=loadingsrc,height = height, width = width, alt = alt)),
               div(class = 'notbusy',
                   img(src = src, height = height, width = width, alt = alt))
        )
    )
}