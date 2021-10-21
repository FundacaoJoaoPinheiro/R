#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library("readxl")
library("dplyr")
library(highcharter)
library(tidyverse)
library("xlsx")
library("shinyjs")



# Importação dos dados e pré-processamento ------------------------------------------------------------------------------

#temp = tempfile(fileext = ".xlsx")
#dataURL <- "http://fjp.mg.gov.br/wp-content/uploads/2020/09/Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx"
#download.file(dataURL, destfile=temp, mode='wb')
#file_tab1 <- read.xlsx(temp, sheet= 1)
file_tab1 <- read.xlsx("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx", sheetIndex = 1)
file_tab4 <- read.xlsx("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx", sheetIndex = 4)
file_tab5 <- read.xlsx("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx", sheetIndex = 5)
file_tab6 <- read.xlsx("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx", sheetIndex = 6)
file_tab7 <- read.xlsx("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx", sheetIndex = 7)
file_tab8 <- read.xlsx("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx", sheetIndex = 8)
file_tab10 <- read.xlsx("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx", sheetIndex = 10)


contas_economicas <- file_tab1[c(7,8,10,17,18,19,20,21,11), c(1:10)]
nomes <- c("Produção", "Impostos produtos", "Consumo Intermediário", "Remuneração", "Salários", "Contribuições", "Impostos produção", "Excedente", "Valor adicionado bruto")
nomes_producao <- c("Produção", "Impostos produtos", "Consumo Intermediário", "Valor adicionado bruto")
nomes_renda <- c("Remuneração", "Salários", "Contribuições", "Impostos produção", "Excedente", "Valor adicionado bruto")
contas_economicas[, 1] <-  nomes
colnames(contas_economicas)[c(1:10)] <- c("contas", as.character(c(2010:2018)))
contas_economicas <- contas_economicas %>% gather(key = 'ano', value = 'valor', -contas)
contas_economicas[, -1] <- lapply(contas_economicas[, -1], as.numeric) # make all columns numeric


pib_percapita <- file_tab4[c(5,9,12), c(1:10)]
nomes <- c("PIB", "População", "PIB per capita")
pib_percapita[, 1] <-  nomes
colnames(pib_percapita)[c(1:10)] <- c("especificacao", as.character(c(2010:2018)))
pib_percapita <- pib_percapita %>% gather(key = 'ano', value = 'valor', -especificacao)
pib_percapita[, -1] <- lapply(pib_percapita[, -1], as.numeric) # make all columns numeric


vbp_corrente <- file_tab5[c(7:27), c(1,2, 6, 10, 14, 18, 22, 26, 30, 34)]
vbp_var_volume <- file_tab5[c(7:27), c(1, 3, 7, 11, 15, 19, 23, 27, 31)]
vbp_var_preco <- file_tab5[c(7:27), c(1, 5, 9, 13, 17, 21, 25, 29, 33)]
vbp_particip <- file_tab8[c(6:26), c(1:10)]
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

tipoResutados <- c("Valor Bruto da Produção" = 'VBP', "Consumo Intermediário" = 'CI', "Valor Adicionado Bruto" = 'VAB')
aspectos2 <- c("Valor corrente" = 'vc', "Var. volume" = 'vv', "Var. preço" = 'vp', "Part. valor corrente em MG" = 'pmg' , "Part. valor corrente no Brasil" = 'pbr')
tiposGraficos <- c("Linha" = 'linha', "Barra"= 'barra', "Barra Empilhado" = 'barra_empilhado', "Pizza" = 'pizza')
vbp_corrente[, 1] <-  setores
colnames(vbp_corrente)[c(1:10)] <- c("setor", as.character(c(2010:2018)))
vbp_corrente <- vbp_corrente %>% gather(key = 'ano', value = 'valor', -setor)
vbp_corrente[, -1] <- lapply(vbp_corrente[, -1], as.numeric) # make all columns numeric

vbp_var_volume[, 1] <-  setores
colnames(vbp_var_volume)[c(1:9)] <- c("setor", as.character(c(2011:2018)))
vbp_var_volume <- vbp_var_volume %>% gather(key = 'ano', value = 'valor', -setor)
vbp_var_volume[, -1] <- lapply(vbp_var_volume[, -1], as.numeric) # make all columns numeric
aux <- data.frame(setores, 2010, NA)
names(aux) <- c("setor", "ano", "valor")
vbp_var_volume <- rbind(aux, vbp_var_volume)

vbp_var_preco[, 1] <-  setores
colnames(vbp_var_preco)[c(1:9)] <- c("setor", as.character(c(2011:2018)))
vbp_var_preco <- vbp_var_preco %>% gather(key = 'ano', value = 'valor', -setor)
vbp_var_preco[, -1] <- lapply(vbp_var_preco[, -1], as.numeric) # make all columns numeric
aux <- data.frame(setores, 2010, NA)
names(aux) <- c("setor", "ano", "valor")
vbp_var_preco <- rbind(aux, vbp_var_preco)

vbp_particip[, 1] <-  setores
colnames(vbp_particip)[c(1:10)] <- c("setor", as.character(c(2010:2018)))
vbp_particip <- vbp_particip %>% gather(key = 'ano', value = 'valor', -setor)
vbp_particip[, -1] <- lapply(vbp_particip[, -1], as.numeric) # make all columns numeric

vbp <- cbind(vbp_corrente, vbp_var_volume[3], vbp_var_preco[3],  vbp_particip[, 3])
colnames(vbp) <- c("setor", "ano", "corrente", "var_volume", "var_preco", "particip")


ci_corrente <- file_tab6[c(7:27), c(1,2, 6, 10, 14, 18, 22, 26, 30, 34)]
ci_var_volume <- file_tab6[c(7:27), c(1, 3, 7, 11, 15, 19, 23, 27, 31)]
ci_var_preco <- file_tab6[c(7:27), c(1, 5, 9, 13, 17, 21, 25, 29, 33)]
ci_particip <- file_tab8[c(6:26), c(1, 11:19)]

ci_corrente[, 1] <-  setores
colnames(ci_corrente)[c(1:10)] <- c("setor", as.character(c(2010:2018)))
ci_corrente <- ci_corrente %>% gather(key = 'ano', value = 'valor', -setor)
ci_corrente[, -1] <- lapply(ci_corrente[, -1], as.numeric) # make all columns numeric

ci_var_volume[, 1] <-  setores
colnames(ci_var_volume)[c(1:9)] <- c("setor", as.character(c(2011:2018)))
ci_var_volume <- ci_var_volume %>% gather(key = 'ano', value = 'valor', -setor)
ci_var_volume[, -1] <- lapply(ci_var_volume[, -1], as.numeric) # make all columns numeric
aux <- data.frame(setores, 2010, NA)
names(aux) <- c("setor", "ano", "valor")
ci_var_volume <- rbind(aux, ci_var_volume)

ci_var_preco[, 1] <-  setores
colnames(ci_var_preco)[c(1:9)] <- c("setor", as.character(c(2011:2018)))
ci_var_preco <- ci_var_preco %>% gather(key = 'ano', value = 'valor', -setor)
ci_var_preco[, -1] <- lapply(ci_var_preco[, -1], as.numeric) # make all columns numeric
aux <- data.frame(setores, 2010, NA)
names(aux) <- c("setor", "ano", "valor")
ci_var_preco <- rbind(aux, ci_var_preco)

ci_particip[, 1] <-  setores
colnames(ci_particip)[c(1:10)] <- c("setor", as.character(c(2010:2018)))
ci_particip <- ci_particip %>% gather(key = 'ano', value = 'valor', -setor)
ci_particip[, -1] <- lapply(ci_particip[, -1], as.numeric) # make all columns numeric

ci <- cbind(ci_corrente, ci_var_volume[3], ci_var_preco[3],  ci_particip[, 3])
colnames(ci) <- c("setor", "ano", "corrente", "var_volume", "var_preco", "particip")


vab_corrente <- file_tab7[c(7:27), c(1,2, 6, 10, 14, 18, 22, 26, 30, 34)]
vab_var_volume <- file_tab7[c(7:27), c(1, 3, 7, 11, 15, 19, 23, 27, 31)]
vab_var_preco <- file_tab7[c(7:27), c(1, 5, 9, 13, 17, 21, 25, 29, 33)]
vab_particip <- file_tab8[c(6:26), c(1, 20:28)]
vab_particip_br <- file_tab10[c(6:26), c(1:10)]

vab_corrente[, 1] <-  setores
colnames(vab_corrente)[c(1:10)] <- c("setor", as.character(c(2010:2018)))
vab_corrente <- vab_corrente %>% gather(key = 'ano', value = 'valor', -setor)
vab_corrente[, -1] <- lapply(vab_corrente[, -1], as.numeric) # make all columns numeric

vab_var_volume[, 1] <-  setores
colnames(vab_var_volume)[c(1:9)] <- c("setor", as.character(c(2011:2018)))
vab_var_volume <- vab_var_volume %>% gather(key = 'ano', value = 'valor', -setor)
vab_var_volume[, -1] <- lapply(vab_var_volume[, -1], as.numeric) # make all columns numeric
aux <- data.frame(setores, 2010, NA)
names(aux) <- c("setor", "ano", "valor")
vab_var_volume <- rbind(aux, vab_var_volume)

vab_var_preco[, 1] <-  setores
colnames(vab_var_preco)[c(1:9)] <- c("setor", as.character(c(2011:2018)))
vab_var_preco <- vab_var_preco %>% gather(key = 'ano', value = 'valor', -setor)
vab_var_preco[, -1] <- lapply(vab_var_preco[, -1], as.numeric) # make all columns numeric
aux <- data.frame(setores, 2010, NA)
names(aux) <- c("setor", "ano", "valor")
vab_var_preco <- rbind(aux, vab_var_preco)

vab_particip[, 1] <-  setores
colnames(vab_particip)[c(1:10)] <- c("setor", as.character(c(2010:2018)))
vab_particip <- vab_particip %>% gather(key = 'ano', value = 'valor', -setor)
vab_particip[, -1] <- lapply(vab_particip[, -1], as.numeric) # make all columns numeric

vab_particip_br[, 1] <-  setores
colnames(vab_particip_br)[c(1:10)] <- c("setor", as.character(c(2010:2018)))
vab_particip_br <- vab_particip_br %>% gather(key = 'ano', value = 'valor', -setor)
vab_particip_br[, -1] <- lapply(vab_particip_br[, -1], as.numeric) # make all columns numeric

vab <- cbind(vab_corrente, vab_var_volume[3], vab_var_preco[3],  vab_particip[3], vab_particip_br[3] )
colnames(vab) <- c("setor", "ano", "corrente", "var_volume", "var_preco", "particip", "particip_br")


export <- list(
    list(text="PNG",
         onclick=JS("function () {
                this.exportChartLocal(); }")),
    list(text="JPEG",
         onclick=JS("function () {
                this.exportChartLocal({ type: 'image/jpeg' }); }"))
    
)

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

ui <- dashboardPage(
   
    
    header <- dashboardHeader(title =  loadingLogo('http://fjp.mg.gov.br/',
                                                       'H://FJP//cripts//Shiny//PIB//logo_fjp2.png',
                                                       'H://FJP//cripts//Shiny//PIB//loader.gif', 
                                                       200,200)),
                                      
                                      
                                     # tags$a(href='http://fjp.mg.gov.br/',
                                      #           tags$img(src='H://FJP//cripts//Shiny//PIB//logo_fjp.png', )), 
                                  #),      
       
        dashboardSidebar(
            sidebarMenu( id = "barra_lateral",
                menuItem("Contas Econômicas", tabName = "contas_economicas"), 
                menuItem("PIB per capita", tabName = "pib_per_capita"),
                menuItem("PIB per capita2", tabName = "pib_per_capita2"),
                menuItem("Resultados", tabName = "resultados")
            ), 
            
            conditionalPanel(
                condition = "input.barra_lateral == 'contas_economicas'",  
                checkboxGroupInput("espec_prod", "Ótica da Produção", c('Produção', 'Impostos produtos', 'Consumo Intermediário', 'Valor adicionado bruto'), 
                                   selected = c('Produção', 'Impostos produtos', 'Consumo Intermediário', 'Valor adicionado bruto')),
                checkboxGroupInput("espec_renda", "Ótica da Renda", c("Salários", "Contribuições", "Impostos produção", "Excedente", "Valor adicionado bruto"), 
                                   selected =  c("Salários", "Contribuições", "Impostos produção", "Excedente", "Valor adicionado bruto"))
            )
            
        ),
                
        
        dashboardBody(
            tabItems(
                tabItem(tabName = 'contas_economicas',
                    fluidRow( 
                        box(
                            title = "Ótica da Produção", status = "primary", solidHeader = TRUE,
                            width = 10,
                            collapsible = FALSE,
                            box(
                                title = NULL, status = "success", solidHeader = FALSE, width = 6,
                                collapsible = FALSE,
                                fluidRow(box(highchartOutput('linePlot_prod'), height=400,width = 12)),#,background='white')),
                                box(
                                    status = "info", solidHeader = FALSE, width = 12, collapsed = TRUE, collapsible = TRUE,
                                    radioButtons(inputId = "valor_absoluto_lineplot_prod",choices = c("Valores absolutos", "valores relativos"), label = NULL, inline = TRUE),
                                    sliderInput("anos_lineplot_prod", "Escolha o ano:", min=2010, max=2018, value=c(2010, 2018),animate=T)
                                )
                                
                            ),
                            box(
                                title = NULL, status = "success", solidHeader = FALSE, width = 6,
                                collapsible = FALSE,
                                fluidRow(box(highchartOutput('piePlot_prod'), height=400 ,width = 12)),#,background='white')),
                                box(
                                    status = "info", solidHeader = FALSE, width = 12, collapsed = TRUE, collapsible = TRUE,
                                    sliderInput("anos_columplot_prod", "Escolha o ano:", min=2010, max=2018, value=c(2010, 2018),animate=T)
                                )
                            )
                        ),
                        box(
                            title = "Informações",  status = "primary", solidHeader = TRUE, width = 2
                        )
                        
                    ),
                    fluidRow( 
                        box(
                            title = "Ótica da Renda", status = "primary", solidHeader = TRUE,
                            width = 10,
                            collapsible = FALSE,
                            box(
                                title = NULL, status = "success", solidHeader = FALSE,
                                collapsible = FALSE, width = 6,
                                fluidRow(box(highchartOutput('linePlot_renda'), height=400,width = 12)),#,background='white')),
                                box(
                                    status = "info", solidHeader = FALSE, width = 12, collapsed = TRUE, collapsible = TRUE,
                                    sliderInput("anos_lineplot_renda", "Escolha o ano:", min=2010, max=2018, value=c(2010, 2018),animate=T)
                                )
                            ),
                            box(
                                title = NULL, status = "success", solidHeader = FALSE,
                                collapsible = FALSE, width = 6,
                                fluidRow(box(highchartOutput('piePlot_renda'), height=400 ,width = 12)),#,background='white')),
                                box(
                                    status = "info", solidHeader = FALSE, width = 12, collapsed = TRUE, collapsible = TRUE,
                                    sliderInput("anos_columnplot_renda", "Escolha o ano:", min=2010, max=2018, value=c(2010, 2018),animate=T)
                                )
                            )
                        )
                    )
                ),
                tabItem(tabName = 'pib_per_capita',
                    fluidRow( 
                        box(
                            title = "PIB", status = "primary", solidHeader = TRUE,
                            width = 10,
                            box(
                                title = NULL, status = "success", solidHeader = FALSE, width = 12,
                                collapsible = FALSE,
                                fluidRow(box(highchartOutput('linePlot_pib_percapita8'), height=400,width = 12)),#,background='white')),
                                box(
                                    status = "info", solidHeader = FALSE, width = 12, collapsed = TRUE, collapsible = TRUE,
                                    radioButtons(inputId = "tipo_graf_lineplot_pib_percapita8",choices = c("Linha", "Barra"), label = NULL, inline = TRUE),
                                    sliderInput("anos_lineplot_pib_percapita8", "Escolha o ano:", min=2010, max=2018, value=c(2010, 2018),animate=T)
                                )
                                
                            ),
                            
                        )
                    ), 
                    fluidRow( 
                        box(
                            title = "PIB", status = "primary", solidHeader = TRUE,
                            width = 10,
                            box(
                                title = NULL, status = "success", solidHeader = FALSE, width = 12,
                                collapsible = FALSE,
                                fluidRow(box(highchartOutput('linePlot_pib_percapita1'), height=400,width = 12)),#,background='white')),
                                box(
                                    status = "info", solidHeader = FALSE, width = 12, collapsed = TRUE, collapsible = TRUE,
                                    radioButtons(inputId = "tipo_graf_lineplot_pib_percapita1",choices = c("Linha", "Barra"), label = NULL, inline = TRUE),
                                    sliderInput("anos_lineplot_pib_percapita1", "Escolha o ano:", min=2010, max=2018, value=c(2010, 2018),animate=T)
                                )
                                
                            ),
                                   
                        )
                    ), 
                    fluidRow( 
                        box(
                            title = "População", status = "primary", solidHeader = TRUE,
                            width = 10,
                            box(
                                title = NULL, status = "success", solidHeader = FALSE, width = 12,
                                collapsible = FALSE,
                                fluidRow(box(highchartOutput('linePlot_pib_percapita2'), height=400,width = 12)),#,background='white')),
                                box(
                                    status = "info", solidHeader = FALSE, width = 12, collapsed = TRUE, collapsible = TRUE,
                                    radioButtons(inputId = "tipo_graf_lineplot_pib_percapita2",choices = c("Linha", "Barra"), label = NULL, inline = TRUE),
                                    sliderInput("anos_lineplot_pib_percapita2", "Escolha o ano:", min=2010, max=2018, value=c(2010, 2018),animate=T)
                                )
                                
                            ),
                            
                        )
                    ),
                    fluidRow( 
                        box(
                            title = "PIB per capita", status = "primary", solidHeader = TRUE,
                            width = 10,
                            box(
                                title = NULL, status = "success", solidHeader = FALSE, width = 12,
                                collapsible = FALSE,
                                fluidRow(box(highchartOutput('linePlot_pib_percapita3'), height=400,width = 12)),#,background='white')),
                                box(
                                    status = "info", solidHeader = FALSE, width = 12, collapsed = TRUE, collapsible = TRUE,
                                    radioButtons(inputId = "tipo_graf_lineplot_pib_percapita3",choices = c("Linha", "Barra"), label = NULL, inline = TRUE),
                                    sliderInput("anos_lineplot_pib_percapita3", "Escolha o ano:", min=2010, max=2018, value=c(2010, 2018),animate=T)
                                )
                                
                            ),
                            
                        )
                    )
                ),
                tabItem(tabName = 'pib_per_capita2',
                    fluidRow( 
                        box(
                            title = "PIB", status = "primary", solidHeader = TRUE,
                            width = 4,
                            box(
                                title = NULL, status = "success", solidHeader = FALSE, width = 12,
                                collapsible = FALSE,
                                fluidRow(box(highchartOutput('linePlot_pib_percapita4'), height=400,width = 12)),#,background='white')),
                                box(
                                    status = "info", solidHeader = FALSE, width = 12, collapsed = TRUE, collapsible = TRUE,
                                    radioButtons(inputId = "tipo_graf_lineplot_pib_percapita4",choices = c("Linha", "Barra"), label = NULL, inline = TRUE)
                                )
                                
                            ),
                            
                        ), 
                        box(
                            title = "População", status = "primary", solidHeader = TRUE,
                            width = 4,
                            box(
                                title = NULL, status = "success", solidHeader = FALSE, width = 12,
                                collapsible = FALSE,
                                fluidRow(box(highchartOutput('linePlot_pib_percapita5'), height=400,width = 12)),#,background='white')),
                                box(
                                    status = "info", solidHeader = FALSE, width = 12, collapsed = TRUE, collapsible = TRUE,
                                    radioButtons(inputId = "tipo_graf_lineplot_pib_percapita5",choices = c("Linha", "Barra"), label = NULL, inline = TRUE)
                                )
                                
                            ),
                            
                        ), 
                        box(
                            title = "PIB per capita", status = "primary", solidHeader = TRUE,
                            width = 4,
                            box(
                                title = NULL, status = "success", solidHeader = FALSE, width = 12,
                                collapsible = FALSE,
                                fluidRow(box(highchartOutput('linePlot_pib_percapita6'), height=400,width = 12)),#,background='white')),
                                box(
                                    status = "info", solidHeader = FALSE, width = 12, collapsed = TRUE, collapsible = TRUE,
                                    radioButtons(inputId = "tipo_graf_lineplot_pib_percapita6",choices = c("Linha", "Barra"), label = NULL, inline = TRUE)
                                )
                                
                            )
                            
                        ),
                        fluidRow(
                            box(
                                status = "info", solidHeader = FALSE, width = 3, collapsed = FALSE, collapsible = TRUE,
                                sliderInput("anos_lineplot_pib_percapita7", "Escolha o ano:", min=2010, max=2018, value=c(2010, 2018),animate=T)
                            )
                        )
                        
                    ) 
                        
                ),
                tabItem(tabName = 'resultados',
                        fluidRow( 
                            tabBox(
                                title = NULL, width = 12,
                                id = "tab_opcoes", height = "250px",
                                tabPanel("Opção 1", 
                                     fluidRow(
                                         box(
                                             status = "info", solidHeader = FALSE, width = 12, collapsible = FALSE,
                                             radioButtons(inputId = "tipo_resultado", label = "Escolha:", choices = tipoResutados, selected = "VBP", inline = TRUE)
                                         )
                                     ),
                                    fluidRow(
                                        box(
                                            status = "warning", solidHeader = FALSE, width = 3, collapsible = FALSE,
                                            radioButtons(inputId = "area_ou_setor_aspecto_fixo", label = NULL, choices = c("Setores", "Áreas"), selected = "Setores", inline = TRUE),
                                            conditionalPanel(
                                                condition = "input.area_ou_setor_aspecto_fixo == 'Setores'",
                                                checkboxInput(inputId = "spec_setores_aspecto_fixo_tudo", label = "Selecionar Tudo", value = FALSE),
                                                checkboxGroupInput(inputId = "spec_setores_aspecto_fixo", label = NULL, choices = setor, selected = setor[1])
                                            ),
                                            conditionalPanel(
                                                condition = "input.area_ou_setor_aspecto_fixo == 'Áreas'", 
                                                checkboxGroupInput(inputId = "spec_areas_aspecto_fixo", label = NULL, choices = area, selected = area[1])
                                            )
                                        ),
                                        box(
                                            status = "warning", solidHeader = FALSE, width = 3, collapsible = FALSE,
                                            radioButtons(inputId = "aspectos_aspecto_fixo", label = NULL, choices = aspectos2, selected = aspectos2[1])
                                        ),
                                        box(
                                            status = "info", solidHeader = FALSE, width = 6, collapsible = FALSE,
                                            fluidRow(box(highchartOutput('plot_vbp_ci_vab_aspecto_fixo'), height=400,width = 12)),#,background='white')),
                                            
                                        ),
                                    ),
                                    fluidRow(
                                        box(
                                            status = "warning", solidHeader = FALSE, width = 6, collapsible = FALSE,
                                            radioButtons(inputId = "tipo_grafico_aspecto_fixo", label = "Tipo de gráfico", choices = tiposGraficos, selected = 'linha', inline = TRUE)
                                        ),
                                        box(
                                            status = "warning", solidHeader = FALSE, width = 6, collapsible = FALSE,
                                            sliderInput("anos_resultados_aspecto_fixo", "Escolha o ano:", min=2010, max=2018, value=c(2010, 2018),animate=T),
                                            sliderInput("anos_resultados_aspecto_fixo_pizza", "Escolha o ano:", min=2010, max=2018, value=c(2018),animate=T)
                                        ),
                                        
                                    )        
                                ),
                                tabPanel("Opção 2", "Trafficker tab", 
                                         
                                     box(
                                         status = "info", solidHeader = FALSE, width = 6, collapsible = FALSE,
                                         fluidRow(box(highchartOutput('plot_vbp_ci_vab_setor_fixo'), height=400,width = 12)),#,background='white')),
                                         box(
                                             status = "warning", solidHeader = FALSE, width = 6, collapsible = FALSE,
                                             radioButtons(inputId = "grande_area_ou_setor_setor_fixo", label = NULL, choices = c("Setores", "Áreas"), selected = "Setores", inline = TRUE),
                                             conditionalPanel(
                                                 condition = "input.grande_area_ou_setor_setor_fixo == 'Setores'", 
                                                 radioButtons(inputId = "espec_setores", label = NULL, choices = setores[setor])
                                             ),
                                             conditionalPanel(
                                                 condition = "input.grande_area_ou_setor_setor_fixo == 'Áreas'", 
                                                 radioButtons(inputId = "espec_setores", label = NULL, choices = setores[area])
                                             )
                                         ),
                                         box(
                                             status = "warning", solidHeader = FALSE, width = 6, collapsible = FALSE,
                                             checkboxGroupInput(inputId = "aspectos_2", label = NULL, choices = aspectos2, selected = aspectos2[1])
                                         )
                                         
                                     )
                                )
                            )
                        )
                )
            )
           
        ),
                
               
    useShinyjs(),           
             
       
              
        
)



# Define server logic required to draw a histogram
server <- function(input, output, session) {

   
    #read_excel("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx")
    
    output$result <- renderText({
        paste("You chose", input$state)
    })
    
    observeEvent(input$tipo_resultado, {
        if(input$tipo_resultado == "VBP" || input$tipo_resultado == "CI"){
            shinyjs::disable(selector = "#aspectos_aspecto_fixo input[value='pbr']")
            if(input$aspectos_aspecto_fixo == 'pbr'){
                updateRadioButtons(inputId = "aspectos_aspecto_fixo", selected = aspectos2[4])
            }
        }
        else{
            shinyjs::enable(selector = "#aspectos_aspecto_fixo input[value='pbr']")
        }
    })
    
    observeEvent(input$aspectos_aspecto_fixo, {
        if(input$aspectos_aspecto_fixo == "vv" || input$aspectos_aspecto_fixo == "vc" || input$aspectos_aspecto_fixo == "vp"){
            if(input$tipo_grafico_aspecto_fixo == 'barra_empilhado' || input$tipo_grafico_aspecto_fixo == 'pizza'){
                updateRadioButtons(inputId = "tipo_grafico_aspecto_fixo", selected = tiposGraficos[1])
            }
        }
        
    })
    
    
    observeEvent(input$aspectos_aspecto_fixo, {
        if(input$aspectos_aspecto_fixo == "vc" || input$aspectos_aspecto_fixo == "vv" || input$aspectos_aspecto_fixo == "vp"){
            shinyjs::disable(selector = "#tipo_grafico_aspecto_fixo input[value= 'barra_empilhado']")
            shinyjs::disable(selector = "#tipo_grafico_aspecto_fixo input[value= 'pizza']")
        }
        else{
            shinyjs::enable(selector = "#tipo_grafico_aspecto_fixo input[value = 'barra_empilhado']")
            shinyjs::enable(selector = "#tipo_grafico_aspecto_fixo input[value = 'pizza']")
        }
    })
    
    
    observeEvent(input$tipo_grafico_aspecto_fixo, {
        if(input$tipo_grafico_aspecto_fixo == "pizza"){
            shinyjs::hide(id = "anos_resultados_aspecto_fixo")
            shinyjs::show(id = "anos_resultados_aspecto_fixo_pizza")
        }
        else{
            shinyjs::show(id = "anos_resultados_aspecto_fixo")
            shinyjs::hide(id = "anos_resultados_aspecto_fixo_pizza")
        }
    })
    
    
    observe({
        updateCheckboxGroupInput(
            session, 'spec_setores_aspecto_fixo', choices = setor,
            selected = {if(input$spec_setores_aspecto_fixo_tudo) setor
                        else setor[1]} 
        )
    })
   
    output$titulo1<-renderText("Ótica da Produção")
    output$titulo2<-renderText("Ótica da Renda")
    output$linePlot_prod <- renderHighchart({
        if(input$barra_lateral == 'contas_economicas'){
            if(!is_empty(input$espec_prod)){
                h <- highchart() %>% 
                    hc_size(width = 600, height = 400) %>%
                    hc_xAxis(title = list(text = "Ano"), allowDecimals = FALSE) %>%
                    hc_exporting(enabled = T, fallbackToExportServer = F, 
                                 menuItems = export)   
                
                if(input$valor_absoluto_lineplot_prod == "Valores absolutos"){
                    ds <- lapply(input$espec_prod, function(x){
                        
                        d <- subset(contas_economicas, contas %in% x & (ano >= input$anos_lineplot_prod[1] & ano <= input$anos_lineplot_prod[2]))
                        data = data.frame(x = d$ano,
                                          y = d$valor)
                        
                    })
                    h <- h %>% hc_yAxis(title = list(text = "Valor a preços correntes (1.000.000 R$) "))  %>%
                        hc_title(text = list("Título do Gráfico"))
                }
                else{
                    new_df <- contas_economicas
                    prod <- new_df[new_df$contas == 'Produção', 'valor']
                    imp_prod <- new_df[new_df$contas == 'Impostos produtos', 'valor']
                    cons_inter <- new_df[new_df$contas == 'Consumo Intermediário', 'valor']
                    valor_adic <- new_df[new_df$contas == 'Valor adicionado bruto', 'valor']
                    new_df[new_df$contas == 'Produção', 'valor'] <- prod*100/(prod+imp_prod)
                    new_df[new_df$contas == 'Impostos produtos', 'valor'] <- imp_prod*100/(prod+imp_prod)
                    new_df[new_df$contas == 'Consumo Intermediário', 'valor'] <- cons_inter*100/(cons_inter+valor_adic)
                    new_df[new_df$contas == 'Valor adicionado bruto', 'valor'] <- valor_adic*100/(cons_inter+valor_adic)
                    
                    ds <- lapply(input$espec_prod, function(x){
                        d <- subset(new_df, contas %in% x & (ano >= input$anos_lineplot_prod[1] & ano <= input$anos_lineplot_prod[2]))
                        data = data.frame(x = d$ano,
                                          y = d$valor)
                        
                    })
                    h <- h %>% hc_yAxis(title = list(text = "Valor percentual ")) 
                    
                }
                
                for (k in 1:length(ds)) {
                    h <- h %>%
                        hc_add_series(ds[[k]], name = input$espec_prod[k])
                }
                h 
            }
        }
            
        
    })
    
    output$piePlot_prod <- renderHighchart({
        if(input$barra_lateral == 'contas_economicas'){
            h <-highchart() %>% 
                hc_chart(type = "column") %>%
                hc_plotOptions(column = list(stacking = "normal")) %>%
                hc_xAxis(categories = c(input$anos_columplot_prod[1] : input$anos_columplot_prod[2]), title = list(text = "Ano")) %>%
                hc_yAxis(title = list(text = "Valor a preços correntes (1.000.000 R$) ")) %>%
                hc_add_series(name= nomes_producao[1],
                              data = subset(contas_economicas, contas %in% nomes_producao[1] & (ano >= input$anos_columplot_prod[1] & ano <= input$anos_columplot_prod[2]))$valor,
                              stack = "Produção") %>%
                hc_add_series(name=nomes_producao[2],
                              data = subset(contas_economicas, contas %in% nomes_producao[2] & (ano >= input$anos_columplot_prod[1] & ano <= input$anos_columplot_prod[2]))$valor,
                              stack = "Produção") %>%
                hc_add_series(name=nomes_producao[3],
                              data = subset(contas_economicas, contas %in% nomes_producao[3] & (ano >= input$anos_columplot_prod[1] & ano <= input$anos_columplot_prod[2]))$valor,
                              stack = "Consumo") %>%
                hc_add_series(name=nomes_producao[4],
                              data = subset(contas_economicas, contas %in% nomes_producao[4] & (ano >= input$anos_columplot_prod[1] & ano <= input$anos_columplot_prod[2]))$valor,
                              stack = "Consumo") %>%
                hc_exporting(
                    enabled = TRUE, # always enabled
                    filename = "custom-file-name"
                )
                #hc_add_theme(hc_theme_ft())
            h
            
        }
    })
    
    output$linePlot_renda <- renderHighchart({
        if(input$barra_lateral == 'contas_economicas'){
            if(!is_empty(input$espec_renda)){
                ds <- lapply(input$espec_renda, function(x){
                    d <- subset(contas_economicas, contas %in% x & (ano >= input$anos_lineplot_renda[1] & ano <= input$anos_lineplot_renda[2]))
                    data = data.frame(x = d$ano,
                                      y = d$valor)
                    
                })
                h <- highchart() %>% 
                    hc_size(width = 600, height = 400) %>%
                    hc_yAxis(title = list(text = "Valor a preços correntes (1.000.000 R$) ")) %>%
                    hc_xAxis(title = list(text = "Ano"), allowDecimals = FALSE) %>%
                    hc_exporting(enabled = T, fallbackToExportServer = F, 
                                 menuItems = export)   
                for (k in 1:length(ds)) {
                    h <- h %>%
                        hc_add_series(ds[[k]], name = input$espec_renda[k])
                }
                h
            }
        }
    })
    output$piePlot_renda <- renderHighchart({
        if(input$barra_lateral == 'contas_economicas'){
            h <-highchart() %>% 
                hc_chart(type = "column") %>%
                hc_plotOptions(column = list(stacking = "normal")) %>%
                hc_xAxis(categories = c(input$anos_columnplot_renda[1] : input$anos_columnplot_renda[2]), title = list(text = "Ano")) %>%
                hc_yAxis(title = list(text = "Valor a preços correntes (1.000.000 R$) ")) %>%
                hc_add_series(name= nomes_renda[2],
                              data = subset(contas_economicas, contas %in% nomes_renda[2] & (ano >= input$anos_columnplot_renda[1] & ano <= input$anos_columnplot_renda[2]))$valor,
                              stack = "Produção") %>%
                hc_add_series(name= nomes_renda[3],
                              data = subset(contas_economicas, contas %in% nomes_renda[3] & (ano >= input$anos_columnplot_renda[1] & ano <= input$anos_columnplot_renda[2]))$valor,
                              stack = "Produção") %>%
                hc_add_series(name=nomes_renda[4],
                              data = subset(contas_economicas, contas %in% nomes_renda[4] & (ano >= input$anos_columnplot_renda[1] & ano <= input$anos_columnplot_renda[2]))$valor,
                              stack = "Produção") %>%
                hc_add_series(name=nomes_renda[5],
                              data = subset(contas_economicas, contas %in% nomes_renda[5] & (ano >= input$anos_columnplot_renda[1] & ano <= input$anos_columnplot_renda[2]))$valor,
                              stack = "Produção") %>%
                hc_add_series(name=nomes_renda[6],
                              data = subset(contas_economicas, contas %in% nomes_renda[6] & (ano >= input$anos_columnplot_renda[1] & ano <= input$anos_columnplot_renda[2]))$valor,
                              stack = "Valor adicionado") %>%
                
                hc_exporting(
                    enabled = TRUE, # always enabled
                    filename = "custom-file-name"
                )
            #hc_add_theme(hc_theme_ft())
            h
            
        }
    })
    
    ## PIB per capita --------------------------------------------------------------------------------
    
    output$linePlot_pib_percapita1 <- renderHighchart({
        if(input$barra_lateral == 'pib_per_capita'){
            ds <- lapply(c("PIB"), function(x){
                d <- subset(pib_percapita, especificacao %in% x & (ano >= input$anos_lineplot_pib_percapita1[1] & ano <= input$anos_lineplot_pib_percapita1[2]))
                data = data.frame(x = d$ano,
                                  y = d$valor)
                
            })
    
            h <- highchart() %>% 
                #hc_size(width = 600, height = 400) %>%
                hc_yAxis(title = list(text = "Valor a preços correntes (1.000.000 R$) ")) %>%
                hc_title(text = list("PIB")) %>%
                hc_exporting(enabled = T, fallbackToExportServer = F, 
                             menuItems = export) 
            if(input$tipo_graf_lineplot_pib_percapita1 == "Linha"){
                h <- h %>%
                hc_xAxis(title = list(text = "Ano"), allowDecimals = FALSE)
            }
            else{
                h <- h %>% hc_chart(type = "column") %>%
                hc_plotOptions(column = list(stacking = "normal")) %>%
                hc_xAxis(categories = c(input$anos_lineplot_pib_percapita1[1] : input$anos_lineplot_pib_percapita1[2]), title = list(text = "Ano"))
            }
            h <- h %>% hc_add_series(ds[[1]], name = c('PIB'))
            
            h
            
        }
    })
    
    output$linePlot_pib_percapita2 <- renderHighchart({
        if(input$barra_lateral == 'pib_per_capita'){
            ds <- lapply(c("População"), function(x){
                d <- subset(pib_percapita, especificacao %in% x & (ano >= input$anos_lineplot_pib_percapita2[1] & ano <= input$anos_lineplot_pib_percapita2[2]))
                data = data.frame(x = d$ano,
                                  y = d$valor)
                
            })
            
            h <- highchart() %>% 
                #hc_size(width = 600, height = 400) %>%
                hc_yAxis(title = list(text = "População residente (1000 hab) ")) %>%
                hc_title(text = list("População")) %>%
                hc_exporting(enabled = T, fallbackToExportServer = F, 
                         menuItems = export) 
               
            
            if(input$tipo_graf_lineplot_pib_percapita2 == "Linha"){
                h <- h %>%
                    hc_xAxis(title = list(text = "Ano"), allowDecimals = FALSE)
            }
            else{
                h <- h %>% hc_chart(type = "column") %>%
                    hc_plotOptions(column = list(stacking = "normal")) %>%
                    hc_xAxis(categories = c(input$anos_lineplot_pib_percapita2[1] : input$anos_lineplot_pib_percapita2[2]), title = list(text = "Ano"))
            }
            h <- h %>% hc_add_series(ds[[1]], name = c('População'))
            
            h
            
        }
    })
    
    output$linePlot_pib_percapita3 <- renderHighchart({
        if(input$barra_lateral == 'pib_per_capita'){
            ds <- lapply(c("PIB per capita"), function(x){
                d <- subset(pib_percapita, especificacao %in% x & (ano >= input$anos_lineplot_pib_percapita3[1] & ano <= input$anos_lineplot_pib_percapita3[2]))
                data = data.frame(x = d$ano,
                                  y = d$valor)
                
            })
            
            h <- highchart() %>% 
                #hc_size(width = 600, height = 400) %>%
                hc_yAxis(title = list(text = "Valor a preços correntes (R$) ")) %>%
                hc_title(text = list("PIB per capita")) %>%
                hc_exporting(enabled = T, fallbackToExportServer = F, 
                             menuItems = export) 
            
            
            if(input$tipo_graf_lineplot_pib_percapita3 == "Linha"){
                h <- h %>%
                    hc_xAxis(title = list(text = "Ano"), allowDecimals = FALSE)
            }
            else{
                h <- h %>% hc_chart(type = "column") %>%
                    hc_plotOptions(column = list(stacking = "normal")) %>%
                    hc_xAxis(categories = c(input$anos_lineplot_pib_percapita3[1] : input$anos_lineplot_pib_percapita3[2]), title = list(text = "Ano"))
            }
            h <- h %>% hc_add_series(ds[[1]], name = c('PIB per capita'))
            
            h
            
        }
    })
    
    output$linePlot_pib_percapita4 <- renderHighchart({
        if(input$barra_lateral == 'pib_per_capita2'){
            ds <- lapply(c("PIB"), function(x){
                d <- subset(pib_percapita, especificacao %in% x & (ano >= input$anos_lineplot_pib_percapita7[1] & ano <= input$anos_lineplot_pib_percapita7[2]))
                data = data.frame(x = d$ano,
                                  y = d$valor)
                
            })
            
            h <- highchart() %>% 
                #hc_size(width = 600, height = 400) %>%
                hc_yAxis(title = list(text = "Valor a preços correntes (1.000.000 R$) ")) %>%
                hc_title(text = list("PIB")) %>%
                hc_exporting(enabled = T, fallbackToExportServer = F, 
                             menuItems = export) 
            if(input$tipo_graf_lineplot_pib_percapita4 == "Linha"){
                h <- h %>%
                    hc_xAxis(title = list(text = "Ano"), allowDecimals = FALSE)
            }
            else{
                h <- h %>% hc_chart(type = "column") %>%
                    hc_plotOptions(column = list(stacking = "normal")) %>%
                    hc_xAxis(categories = c(input$anos_lineplot_pib_percapita7[1] : input$anos_lineplot_pib_percapita7[2]), title = list(text = "Ano"))
            }
            h <- h %>% hc_add_series(ds[[1]], name = c('PIB'))
            
            h
            
        }
    })
    
    output$linePlot_pib_percapita5 <- renderHighchart({
        if(input$barra_lateral == 'pib_per_capita2'){
            ds <- lapply(c("População"), function(x){
                d <- subset(pib_percapita, especificacao %in% x & (ano >= input$anos_lineplot_pib_percapita7[1] & ano <= input$anos_lineplot_pib_percapita7[2]))
                data = data.frame(x = d$ano,
                                  y = d$valor)
                
            })
            
            h <- highchart() %>% 
                #hc_size(width = 600, height = 400) %>%
                hc_yAxis(title = list(text = "População residente (1000 hab) ")) %>%
                hc_title(text = list("População")) %>%
                hc_exporting(enabled = T, fallbackToExportServer = F, 
                             menuItems = export) 
            
            
            if(input$tipo_graf_lineplot_pib_percapita5 == "Linha"){
                h <- h %>%
                    hc_xAxis(title = list(text = "Ano"), allowDecimals = FALSE)
            }
            else{
                h <- h %>% hc_chart(type = "column") %>%
                    hc_plotOptions(column = list(stacking = "normal")) %>%
                    hc_xAxis(categories = c(input$anos_lineplot_pib_percapita7[1] : input$anos_lineplot_pib_percapita7[2]), title = list(text = "Ano"))
            }
            h <- h %>% hc_add_series(ds[[1]], name = c('População'))
            
            h
            
        }
    })
    
    output$linePlot_pib_percapita6 <- renderHighchart({
        if(input$barra_lateral == 'pib_per_capita2'){
            ds <- lapply(c("PIB per capita"), function(x){
                d <- subset(pib_percapita, especificacao %in% x & (ano >= input$anos_lineplot_pib_percapita7[1] & ano <= input$anos_lineplot_pib_percapita7[2]))
                data = data.frame(x = d$ano,
                                  y = d$valor)
                
            })
            
            h <- highchart() %>% 
                #hc_size(width = 600, height = 400) %>%
                hc_yAxis(title = list(text = "Valor a preços correntes (R$) ")) %>%
                hc_title(text = list("PIB per capita")) %>%
                hc_exporting(enabled = T, fallbackToExportServer = F, 
                             menuItems = export) 
            
            
            if(input$tipo_graf_lineplot_pib_percapita6 == "Linha"){
                h <- h %>%
                    hc_xAxis(title = list(text = "Ano"), allowDecimals = FALSE)
            }
            else{
                h <- h %>% hc_chart(type = "column") %>%
                    hc_plotOptions(column = list(stacking = "normal")) %>%
                    hc_xAxis(categories = c(input$anos_lineplot_pib_percapita7[1] : input$anos_lineplot_pib_percapita7[2]), title = list(text = "Ano"))
            }
            h <- h %>% hc_add_series(ds[[1]], name = c('PIB per capita'))
            
            h
            
        }
    })
    
    output$linePlot_pib_percapita8 <- renderHighchart({
        if(input$barra_lateral == 'pib_per_capita'){
            espec <- c("PIB","PIB per capita", "População")
            ds <- lapply(espec, function(x){
                d <- subset(pib_percapita, especificacao %in% x & (ano >= input$anos_lineplot_pib_percapita8[1] & ano <= input$anos_lineplot_pib_percapita8[2]))
                data = data.frame(x = d$ano,
                                  y = d$valor)
                
            })
            
            hc <- highchart()%>%
                hc_xAxis(categories = c(2010: 2018), title = list(text = "Ano")) %>%
                hc_yAxis_multiples(list(title = list(text = "PIB (1000000 R$)"), opposite = FALSE, showEmpty= FALSE),
                                   list(title = list(text = "PIB per capita (R$)"),opposite = FALSE, showEmpty= FALSE),
                                   list(title = list(text = "População"), opposite = TRUE, showEmpty= FALSE )) %>%
                hc_plotOptions(column = list(stacking = "normal")) %>%
                hc_add_series(ds[[3]],type="column", name=espec[3], yAxis=2) %>%
                hc_add_series(ds[[1]],type="line", name=espec[1], yAxis=0) %>%
                hc_add_series(ds[[2]],type="line", name=espec[2], yAxis=1) %>%
                hc_tooltip(crosshairs = TRUE,
                           borderWidth = 5,
                           sort = FALSE,
                           table = TRUE)
            hc
        }
    })
    
## Resultados -----------------------------------------------------------------------------    
   
    
    
    
    output$plot_vbp_ci_vab_aspecto_fixo <- renderHighchart({
        
        anos <- c(input$anos_resultados_aspecto_fixo[1], input$anos_resultados_aspecto_fixo[2])
        
        h <- highchart() %>%
            hc_exporting(enabled = T, fallbackToExportServer = F, menuItems = export) %>%
            hc_xAxis(title = list(text = "Ano"), allowDecimals = FALSE)
        
        if(input$tipo_resultado == 'VBP'){
            
            h <- h %>%
                hc_title(text = list("Valor Bruto da Produção")) 
            if(input$tipo_grafico_aspecto_fixo == "barra" || input$tipo_grafico_aspecto_fixo == "barra_empilhado"){
                h <- h %>% hc_chart(type = "column")
            }
            
            if(input$area_ou_setor_aspecto_fixo == "Setores"){
                if(!is_empty(input$spec_setores_aspecto_fixo)){
                    if(input$aspectos_aspecto_fixo == 'vc'){
                        ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
                            d <- subset(vbp, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
                            data = data.frame(x = d$ano,
                                              y = d$corrente)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Valor corrente (1.000.000 R$)"))
                    }
                    else if(input$aspectos_aspecto_fixo == "vv"){
                        ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
                            d <- subset(vbp, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
                            data = data.frame(x = d$ano,
                                              y = d$var_volume)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Variação em volume (%)"))
                    }
                    else if(input$aspectos_aspecto_fixo == "vp"){
                        ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
                            d <- subset(vbp, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
                            data = data.frame(x = d$ano,
                                              y = d$var_preco)
                            
                        })
                        h <- h %>% hc_yAxis(title = list(text = "Variação de preço (%)"))
                        
                    }
                    else if(input$aspectos_aspecto_fixo == "pmg"){
                        ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
                            d <- subset(vbp, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
                            data = data.frame(x = d$ano,
                                              y = d$particip)
                            
                        })
                        
                        
                        h <- h %>% hc_yAxis(title = list(text = "Part. das atividades no Valor Bruto da Produção (%)"))
                        
                    }
                    
                    if(input$tipo_grafico_aspecto_fixo == "barra_empilhado"){
                        ds2 <- subset(vbp[c(1,2, 6)], (ano >= anos[1] & ano <= anos[2]) & !(setor %in% input$spec_setores_aspecto_fixo) & !(setor %in% c("Agropecuária", "Indústria", "Serviços")))
                        ds2 <- ds2 %>% 
                            group_by(ano) %>% 
                            summarise(particip = sum(particip)) 
                        names(ds2) <- c('x', 'y')
                        
                            
                        for (k in 1:length(ds)) {
                            h <- h %>%    
                            hc_add_series(data = ds[[k]], name = input$spec_setores_aspecto_fixo[k], stack = "Valor")
                            print(ds[[k]])
                        }
                            h <- h %>%hc_plotOptions(column = list(stacking = "normal")) %>%
                                hc_add_series(data = ds2, name = "Outros", stack = "Valor") 
                    }
                    else if(input$tipo_grafico_aspecto_fixo == "pizza"){
                        
                        ano_pie_chart <-  input$anos_resultados_aspecto_fixo_pizza
                        d <- subset(vbp[c(1,2, 6)], !(setor %in% c("Agropecuária", "Indústria", "Serviços")) & ano %in% ano_pie_chart & !(setor %in% input$spec_setores_aspecto_fixo))
                        demais <- sum(d$particip )
                       
                        
                        labels_pi_chart <- c(input$spec_setores_aspecto_fixo, "Outros")
                        valores_pi_chart <- c(subset(vbp[c(1, 2, 6)], setor %in% input$spec_setores_aspecto_fixo & ano %in% ano_pie_chart)$particip, demais)
                       
                        
                        h <- h %>% 
                            hc_chart(type = "pie") %>% 
                            myhc_add_series_labels_values(labels = labels_pi_chart, values = valores_pi_chart, text = labels_pi_chart)
                    }
                    else{
                        for (k in 1:length(ds)) {
                            h <- h %>%
                                hc_add_series(ds[[k]], name = input$spec_setores_aspecto_fixo[k])
                            
                        } 
                    }
                    
                    
                }
                
            }
            else{
                if(!is_empty(input$spec_areas_aspecto_fixo)){
                    if(input$aspectos_aspecto_fixo == 'vc'){
                        ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
                            d <- subset(vbp, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
                            data = data.frame(x = d$ano,
                                              y = d$corrente)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Valor corrente (1.000.000 R$)"))
                        
                        
                    }
                    if(input$aspectos_aspecto_fixo == "vv"){
                        ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
                            d <- subset(vbp, setor %in% x & (ano >= 2011 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$var_volume)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Variação em volume (%)"))
                    }
                    if(input$aspectos_aspecto_fixo == "vp"){
                        ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
                            d <- subset(vbp, setor %in% x & (ano >= 2011 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$var_preco)
                            
                        })
                        h <- h %>% hc_yAxis(title = list(text = "Variação de preço (%)"))
                        
                    }
                    if(input$aspectos_aspecto_fixo == "pmg"){
                        ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
                            d <- subset(vbp, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
                            data = data.frame(x = d$ano,
                                              y = d$particip)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Part. das atividades no Valor Bruto da Produção (%)"))
                        
                        if(input$tipo_grafico_aspecto_fixo == "barra_empilhado"){
                            ds2 <- subset(vbp[c(1,2, 6)], (ano >= anos[1] & ano <= anos[2]) & !(setor %in% input$spec_areas_aspecto_fixo) & (setor %in% c("Agropecuária", "Indústria", "Serviços")))
                            ds2 <- ds2 %>% 
                                group_by(ano) %>% 
                                summarise(particip = sum(particip)) 
                            names(ds2) <- c('x', 'y')
                            
                            
                            for (k in 1:length(ds)) {
                                h <- h %>%    
                                    hc_add_series(data = ds[[k]], name = input$spec_areas_aspecto_fixo[k], stack = "Valor")
                                print(ds[[k]])
                            }
                            h <- h %>%hc_plotOptions(column = list(stacking = "normal")) %>%
                                hc_add_series(data = ds2, name = "Outros", stack = "Valor") 
                        }
                        
                    }
                    else{
                        for (k in 1:length(ds)) {
                            h <- h %>%
                                hc_add_series(ds[[k]], name = input$spec_areas_aspecto_fixo[k])
                            
                        }
                    }
                    
                }
            }
                
                
           

            
            h 
            
                
        }
        else if(input$tipo_resultado == 'CI'){
            
            
            h <- h %>%
                hc_title(text = list("Consumo Intermediário")) 
               
            
            if(input$area_ou_setor_aspecto_fixo == "Setores"){
                if(!is_empty(input$spec_setores_aspecto_fixo)){
                    if(input$aspectos_aspecto_fixo == 'vc'){
                        ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
                            d <- subset(ci, setor %in% x & (ano >= 2010 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$corrente)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Valor corrente (1.000.000 R$)"))
                    }
                    else if(input$aspectos_aspecto_fixo == "vv"){
                        ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
                            d <- subset(ci, setor %in% x & (ano >= 2011 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$var_volume)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Variação em volume (%)"))
                    }
                    else if(input$aspectos_aspecto_fixo == "vp"){
                        ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
                            d <- subset(ci, setor %in% x & (ano >= 2011 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$var_preco)
                            
                        })
                        h <- h %>% hc_yAxis(title = list(text = "Variação de preço (%)"))
                        
                    }
                    else if(input$aspectos_aspecto_fixo == "pmg"){
                        ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
                            d <- subset(ci, setor %in% x & (ano >= 2010 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$particip)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Part. das atividades no Valor Bruto da Produção (%)"))
                        
                    }
                    
                    for (k in 1:length(ds)) {
                        h <- h %>%
                            hc_add_series(ds[[k]], name = input$spec_setores_aspecto_fixo[k])
                        
                    }
                    
                }
                
            }
            else{
                if(!is_empty(input$spec_areas_aspecto_fixo)){
                    if(input$aspectos_aspecto_fixo == 'vc'){
                        ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
                            d <- subset(ci, setor %in% x & (ano >= 2010 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$corrente)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Valor corrente (1.000.000 R$)"))
                        
                        
                    }
                    if(input$aspectos_aspecto_fixo == "vv"){
                        ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
                            d <- subset(ci, setor %in% x & (ano >= 2011 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$var_volume)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Variação em volume (%)"))
                    }
                    if(input$aspectos_aspecto_fixo == "vp"){
                        ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
                            d <- subset(ci, setor %in% x & (ano >= 2011 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$var_preco)
                            
                        })
                        h <- h %>% hc_yAxis(title = list(text = "Variação de preço (%)"))
                        
                    }
                    if(input$aspectos_aspecto_fixo == "pmg"){
                        ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
                            d <- subset(ci, setor %in% x & (ano >= 2010 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$particip)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Part. das atividades no Valor Bruto da Produção (%)"))
                        
                    }
                    for (k in 1:length(ds)) {
                        h <- h %>%
                            hc_add_series(ds[[k]], name = input$spec_areas_aspecto_fixo[k])
                        
                    }
                }
            }
            
            
            
            
            
            h 
            
            
        }
        else if(input$tipo_resultado == 'VAB'){
            
            
            h <- h %>%  
                hc_title(text = list("Valor Adicionado Bruto")) 
                
            
            if(input$area_ou_setor_aspecto_fixo == "Setores"){
                if(!is_empty(input$spec_setores_aspecto_fixo)){
                    if(input$aspectos_aspecto_fixo == 'vc'){
                        ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
                            d <- subset(vab, setor %in% x & (ano >= 2010 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$corrente)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Valor corrente (1.000.000 R$)"))
                    }
                    else if(input$aspectos_aspecto_fixo == "vv"){
                        ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
                            d <- subset(vab, setor %in% x & (ano >= 2011 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$var_volume)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Variação em volume (%)"))
                    }
                    else if(input$aspectos_aspecto_fixo == "vp"){
                        ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
                            d <- subset(vab, setor %in% x & (ano >= 2011 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$var_preco)
                            
                        })
                        h <- h %>% hc_yAxis(title = list(text = "Variação de preço (%)"))
                        
                    }
                    else if(input$aspectos_aspecto_fixo == "pmg"){
                        ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
                            d <- subset(vab, setor %in% x & (ano >= 2010 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$particip)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Part. das atividades no Valor Bruto da Produção (%)"))
                        
                    }
                    else if(input$aspectos_aspecto_fixo == "pbr"){
                        ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
                            d <- subset(vab, setor %in% x & (ano >= 2010 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$particip_br)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Part. das atividades no Valor Bruto da Produção (%)"))
                        
                    }
                    
                    for (k in 1:length(ds)) {
                        h <- h %>%
                            hc_add_series(ds[[k]], name = input$spec_setores_aspecto_fixo[k])
                        
                    }
                    
                }
                
            }
            else{
                if(!is_empty(input$spec_areas_aspecto_fixo)){
                    if(input$aspectos_aspecto_fixo == 'vc'){
                        ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
                            d <- subset(vab, setor %in% x & (ano >= 2010 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$corrente)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Valor corrente (1.000.000 R$)"))
                        
                        
                    }
                    if(input$aspectos_aspecto_fixo == "vv"){
                        ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
                            d <- subset(vab, setor %in% x & (ano >= 2011 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$var_volume)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Variação em volume (%)"))
                    }
                    if(input$aspectos_aspecto_fixo == "vp"){
                        ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
                            d <- subset(vab, setor %in% x & (ano >= 2011 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$var_preco)
                            
                        })
                        h <- h %>% hc_yAxis(title = list(text = "Variação de preço (%)"))
                        
                    }
                    if(input$aspectos_aspecto_fixo == "pmg"){
                        ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
                            d <- subset(vab, setor %in% x & (ano >= 2010 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$particip)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Part. das atividades no Valor Bruto da Produção (%)"))
                        
                    }
                    
                    if(input$aspectos_aspecto_fixo == "pbr"){
                        ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
                            d <- subset(vab, setor %in% x & (ano >= 2010 & ano <= 2018))
                            data = data.frame(x = d$ano,
                                              y = d$particip_br)
                            
                        }) 
                        h <- h %>% hc_yAxis(title = list(text = "Part. das atividades no Valor Bruto da Produção (%)"))
                        
                    }
                    for (k in 1:length(ds)) {
                        h <- h %>%
                            hc_add_series(ds[[k]], name = input$spec_areas_aspecto_fixo[k])
                        
                    }
                }
            }
            
            
            
            
            
            h 
            
            
        }
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
