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
library("googleVis")
library(ggplot2)
library(highcharter)
library(tidyverse)




# Importação dos dados e pré-processamento ------------------------------------------------------------------------------

#temp = tempfile(fileext = ".xlsx")
#dataURL <- "http://fjp.mg.gov.br/wp-content/uploads/2020/09/Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx"
#download.file(dataURL, destfile=temp, mode='wb')
#file_tab1 <- read.xlsx(temp, sheet= 1)
file_tab1 <- read.xlsx("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx", sheet = 1)


contas_economicas <- file_tab1[c(4, 5, 7, 12, 13, 14, 15, 16, 8), c(1:10)]
nomes <- c("Produção", "Impostos produtos", "Consumo Intermediário", "Remuneração", "Salários", "Contribuições", "Impostos produção", "Excedente", "Valor adicionado bruto")
nomes_producao <- c("Produção", "Impostos produtos", "Consumo Intermediário", "Valor adicionado bruto")
nomes_renda <- c("Remuneração", "Salários", "Contribuições", "Impostos produção", "Excedente", "Valor adicionado bruto")
contas_economicas[, 1] <-  nomes
colnames(contas_economicas)[c(1:10)] <- c("contas", as.character(c(2010:2018)))
contas_economicas <- contas_economicas %>% gather(key = 'ano', value = 'valor', -contas)
contas_economicas[, -1] <- lapply(contas_economicas[, -1], as.numeric) # make all columns numeric



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

choice <- c("Contas Econômicas", "Consumo intermediário", "Valor adicionado", "Participação das atividades")
setores <- c("Agricultura",
             "Pecuária",
             "Prod. florestal, pesca e aquicultura",
             "Indústria extrativa",
             "Indústrias de transformação",
             "Eletricidade e gás, água, esgoto",
             "Construção",
             "Comércio de veículos automotores",
             "Transporte, armazenagem e correio",
             "Serviços de alojamento e alimentação",
             "Serviços de informação e comunicação",
             "Atividades financeiras",
             "Atividades imobiliárias",
             "Atividades profissionais",
             "Administração, educação, saúde",
             "Educação e saúde mercantis",
             "Artes, cultura, esporte",
             "Serviços domésticos"
)
areas <- c("Agropecuária", "Indústria",  "Serviços")
aspectos <- c("Valor Bruto da Produção (%)", "Consumo Intermediário (%)", "Valor Adicionado (%)")								

ui <- dashboardPage(
        dashboardHeader(title = "PIB MG"),
        dashboardSidebar(
            sidebarMenu(
                menuItem("Gráfico", tabName = "grafico")
            ), 
            selectizeInput("selected",
                           "Selecione os dados para exibição",
                           choice, selected="Contas Econômicas"),
            conditionalPanel(
                condition = "input.selected == 'Contas Econômicas'",  
                checkboxGroupInput("espec_prod", "Ótica da Produção", c('Produção', 'Impostos produtos', 'Consumo Intermediário', 'Valor adicionado bruto')),
                checkboxGroupInput("espec_renda", "Ótica da Renda", c("Salários", "Contribuições", "Impostos produção", "Excedente", "Valor adicionado bruto"))
            ),
            
            sliderInput("escolha_anos", "Escolha o ano:", min=2010, max=2018, value=c(2010, 2018),animate=T)
        ),
                
        
        dashboardBody(
           fluidRow( 
               box(
                   title = "Ótica da Produção", status = "primary", solidHeader = TRUE,
                   width = 10,
                   collapsible = TRUE,
                   box(
                       title = "Gráfico Linha", status = "success", solidHeader = FALSE, width = 6,
                       collapsible = TRUE,
                       fluidRow(box(highchartOutput('linePlot_prod'), height=400,width = 12)),#,background='white')),
                       sliderInput("anos_lineplot_prod", "Escolha o ano:", min=2010, max=2018, value=c(2010, 2018),animate=T)
                       
                   ),
                   box(
                       title = "Gráfico Pizza", status = "success", solidHeader = FALSE, width = 6,
                       collapsible = TRUE,
                       fluidRow(box(highchartOutput('piePlot_prod'), height=400 ,width = 12)),#,background='white')),
                       sliderInput("anos_columplot_prod", "Escolha o ano:", min=2010, max=2018, value=c(2010, 2018),animate=T)
                   )
               )
               
           ),
           fluidRow( 
               box(
                   title = "Ótica da Produção", status = "primary", solidHeader = TRUE,
                   width = 10,
                   collapsible = TRUE,
                   box(
                       title = "Gráfico Linha", status = "success", solidHeader = FALSE,
                       collapsible = TRUE,
                       fluidRow(box(highchartOutput('linePlot_renda'), height=400,width = 12)),#,background='white')),
                       width = 6
                   ),
                   box(
                       title = "Gráfico Pizza", status = "success", solidHeader = FALSE,
                       collapsible = TRUE,
                       fluidRow(box(highchartOutput('piePlot_renda'), height=400 ,width = 12)),#,background='white')),
                       width = 6
                   )
               )
           )
        )
                
               
                   
             
       
              
        
)
    

# Define server logic required to draw a histogram
server <- function(input, output) {

   
    read_excel("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx")
    
    output$result <- renderText({
        paste("You chose", input$state)
    })
    
   
    output$titulo1<-renderText("Ótica da Produção")
    output$titulo2<-renderText("Ótica da Renda")
    output$linePlot_prod <- renderHighchart({
        if(input$selected == "Contas Econômicas"){
            if(!is_empty(input$espec_prod)){
               ds <- lapply(input$espec_prod, function(x){
                   
                    d <- subset(contas_economicas, contas %in% x & (ano >= input$anos_lineplot_prod[1] & ano <= input$anos_lineplot_prod[2]))
                    data = data.frame(x = d$ano,
                                      y = d$valor)
                    
                })
                h <- highchart() %>% 
                    hc_size(width = 600, height = 400) %>%
                    hc_yAxis(title = list(text = "Contas ")) %>%
                    hc_xAxis(title = list(text = "Ano")) %>%
                    hc_exporting(enabled = T, fallbackToExportServer = F, 
                                 menuItems = export)   
                for (k in 1:length(ds)) {
                    h <- h %>%
                        hc_add_series(ds[[k]], name = input$espec_prod[k])
                }
                h
            }
        }
            
        
    })
    
    output$piePlot_prod <- renderHighchart({
        if(input$selected == "Contas Econômicas"){
            h <-highchart() %>% 
                hc_chart(type = "column") %>%
                hc_plotOptions(column = list(stacking = "normal")) %>%
                hc_xAxis(categories = c(input$anos_columplot_prod[1] : input$anos_columplot_prod[2])) %>%
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
        if(input$selected == "Contas Econômicas"){
            if(!is_empty(input$espec_renda)){
                ds <- lapply(input$espec_renda, function(x){
                    print(x)
                    d <- subset(contas_economicas, contas %in% x & (ano >= input$escolha_anos[1] & ano <= input$escolha_anos[2]))
                    data = data.frame(x = d$ano,
                                      y = d$valor)
                    
                })
                h <- highchart() %>% 
                    hc_size(width = 600, height = 400) %>%
                    hc_yAxis(title = list(text = "Contas ")) %>%
                    hc_xAxis(title = list(text = "Ano")) %>%
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
        if(input$selected == "Contas Econômicas"){
            if(!is_empty(input$espec_prod)){
                ano_pie_chart <- input$anos_pieplot_prod
                d <- subset(contas_economicas, ano %in% ano_pie_chart & !(contas %in% input$espec_prod) & !(contas %in% nomes_renda))
                demais <- sum(d$valor)
                
                labels_pi_chart <- c(input$espec_prod, "Outros")
                valores_pi_chart <- c(subset(contas_economicas, contas %in% input$espec_prod & ano %in% ano_pie_chart)$valor, demais)
                
                highchart() %>% 
                    hc_chart(type = "pie") %>% 
                    myhc_add_series_labels_values(labels = labels_pi_chart, values = valores_pi_chart, text = labels_pi_chart)
            }
        }
    })
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
