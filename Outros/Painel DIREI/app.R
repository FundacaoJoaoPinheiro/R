#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

source("functions.R")

library(shiny)
library(shinydashboard)
library(highcharter)
library(readxl)
library(tibble)
library(tidyverse)
library(shinythemes)
library(httr)
library(jsonlite)
library(here)
library(dplyr)
library(promises)
library(future)


options(OutDec= ".") 

dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(dir)

dados_painel <- read_excel(path = "Ctrl_Gerencial_Direi _MAI 22 (1).xlsx", sheet = 1)
dados <- read_excel(path = "Ctrl_Gerencial_Direi _MAI 22 (1).xlsx", sheet = 3, col_types = 'numeric')
dados_videos <- read_excel(path = "Ctrl_Gerencial_Direi _MAI 22 (1).xlsx", sheet = 4)

user_key <- dados_videos$user_key[1]
id_canal <- dados_videos$canal_id[1]
id_videos <- dados_videos$videos_id
nomes_videos <- dados_videos$nomes

anos <- unique(dados$ano)
meses <- unique(dados$mes)
meses_sigla <- c("JAN", "FEV", "MAR", "ABR", "MAI", "JUN", "JUL", "AGO", "SET", "OUT", "NOV", "DEZ")

plan(multisession)


# Define UI for application that draws a histogram
ui <- dashboardPage(
  
    title = "Controle Gerencial",
    
    
    dashboardHeader(disable = TRUE),
        
    dashboardSidebar(disable = TRUE),
    
        
       
    dashboardBody(
   
        fluidRow(
          div(style="background-color:White;padding:25px; height:130px",
            column(
              width = 2,
              img(src="logo_fjp.png", weight = 100, height = 100)
            ),
            column(
              width = 10,
              div( style="text-align: center; ",
                   span("Painel de Controle Gerencial - DIREI", style='font-size:30px;padding:25px' ),
                   br(),
                   span(textOutput(outputId = 'mes_ano_titulo', inline = TRUE ), style='font-size:24px')
              )
            )
          ),
        ),
        br(),
        fluidRow(
          column(width = 12,
                 tabBox(width = 12,
                   tabPanel("Painel Mensal",
                            fluidRow(
                              column(width = 3,
                                     dateInput2(inputId = 'mes_ano',
                                                label = "Escolha o mês e o ano:",
                                                format = "mm-yyyy",
                                                startview = "year",
                                                language = "pt-BR",
                                                minview = 'months')
                              )
                              
                            ),
                            fluidRow(
                              tags$head(tags$style(HTML("
                                div.box-header {
                                  text-align: center;
                                  font-size:16px;
                                  height: 50px;
                                }"))),
                              box(
                                title = div("Previsão Arrecadação Anual"), 
                                status = "primary",
                                solidHeader = TRUE,
                                width = 3,
                                height = 120,
                                div( style="text-align: center;",
                                     span("R$", textOutput(outputId = 'previsao_arrecadacao_anual', inline = TRUE), style='font-size:24px;' )
                                )
                                
                              ),
                              box(
                                title = div("Arrecadação ", textOutput(outputId = 'ano_titulo_box', inline = TRUE)),
                                status = "primary",
                                solidHeader = TRUE,
                                width = 3,
                                height = 120,
                                div( style="text-align: center;",
                                     span("R$", textOutput(outputId = 'arrecadacao_anual', inline = TRUE), style='font-size:24px;' )
                                )
                              ),
                              box(
                                title = div("Média Mensal Arrecadação", textOutput(outputId = 'ano_titulo_box2', inline = TRUE)),
                                status = "primary",
                                solidHeader = TRUE,
                                width = 3,
                                height = 120,
                                div( style="text-align: center;",
                                     span("R$", textOutput(outputId = 'media_mensal_arrecadacao', inline = TRUE), style='font-size:24px;' )
                                ),
                                p("dados consolidados até ", textOutput(outputId = 'mes_media_mensal_arrecadacao', inline = TRUE), style='font-size:12px;')
                              ),
                              box(
                                title = div("Arrecadação", textOutput(outputId = 'ano_anterior_titulo_box', inline = TRUE)),
                                status = "primary",
                                solidHeader = TRUE,
                                width = 3,
                                height = 120,
                                div( style="text-align: center;",
                                     span("R$", textOutput(outputId = 'arrecadacao_anual_ano_anterior', inline = TRUE), style='font-size:24px;' )
                                )
                              )
                            ),
                            fluidRow(
                              column(width = 4,
                                     box(
                                       title = div("Cumprimento Meta Arrecadação 2022"),
                                       status = "primary",
                                       solidHeader = TRUE,
                                       width = 12,
                                       #height = 250,
                                       highchartOutput(outputId = 'cumprimento_meta_arrecadacao')
                                     )
                                   ),
                              column(width = 4,
                                     box(
                                       title = div("Arrecadação Distritos"),
                                       status = "primary",
                                       solidHeader = TRUE,
                                       width = 12,
                                       #height = 250,
                                       highchartOutput(outputId = 'arrecadacao_distritos')
                                     )
                              ),
                              column(width = 4,
                                    box(
                                      title = div("Visualizações Webnários Youtube"),
                                      status = "primary",
                                      solidHeader = TRUE,
                                      width = 12,
                                      box(
                                        shinycssloaders::withSpinner(highchartOutput(outputId = 'grafico_visualizacoes')),                                   
                                        width = 12
                                      )
                                      
                                    )
                              )
                            ),
                            fluidRow(
                              column(width = 6,
                                     box(
                                       title = div( style="text-align: center;",
                                                    span("Emissão CPM", textOutput(outputId = 'anos_emissao_cpm', inline = TRUE), style='font-size:24px;' )
                                       ),
                                       status = "primary",
                                       solidHeader = TRUE,
                                       width = 12,
                                       #height = 250,
                                       highchartOutput(outputId = 'emissao_cpm')
                                     )
                               ),
                              column(width = 6,
                                     box(
                                       title = div( style="text-align: center;",
                                                    span("Arrecadação com CPM", textOutput(outputId = 'ano_arrecadacao_cpm', inline = TRUE), style='font-size:24px;' )
                                       ),
                                       status = "primary",
                                       solidHeader = TRUE,
                                       width = 12,
                                       #height = 250,
                                       highchartOutput(outputId = 'grafico_arrecadacao_cpm')
                                     )
                              )
                            ), 
                            fluidRow(
                              column(width = 6,
                                     box(
                                       title = div( style="text-align: center;",
                                                    span("Metas de Publicação - Vale Alimentação", textOutput(outputId = 'ano_metas_publicacao', inline = TRUE), style='font-size:24px;' )
                                       ),
                                       status = "primary",
                                       solidHeader = TRUE,
                                       width = 12,
                                       #height = 250,
                                       highchartOutput(outputId = 'grafico_metas_publicacao')
                                     )
                                     )
                            )
                   ), 
                   tabPanel("Série Histórica")
                 )
               )
        )
        
        
        
    ),

       
           

)

# Define server logic required to draw a histogram
server <- function(input, output) {
    options(OutDec=",")
  
    dados_futuros <- reactiveValues()
  
    mes <- eventReactive(input$mes_ano, {
      stringr::str_to_upper(format(input$mes_ano, format="%b"))
    })
    
    mes_numero <- eventReactive(input$mes_ano, {
      as.numeric(format(input$mes_ano, format="%m"))
    })
    
    ano <- eventReactive(input$mes_ano, {
      as.numeric(format(input$mes_ano, format="%Y"))
    })
    
    previsao_arrecadacao_anual <- eventReactive(input$mes_ano, {
      previsao <- dados |> select(previsao_arrecadacao, ano, mes) |> subset(ano == 2022 & mes == 7)
      #print(previsao[1])
      as.numeric(previsao[1])
      
    })
  
    output$mes_ano_titulo <- renderText({
      
      stringr::str_to_sentence(format(input$mes_ano, format="%B de %Y"))
     
    })
    
    output$ano_titulo_box <- renderText({
      ano()
    })
    
    output$ano_titulo_box2 <- renderText({
      ano()
    })
    
    output$anos_emissao_cpm <- renderText({
      paste(ano()-2, " x ", ano()-1, " x ", ano())
    })
    
    output$ano_arrecadacao_cpm <- renderText({
      ano()
    })
    
    output$ano_metas_publicacao <- renderText({
      ano()
    })
    
    output$ano_anterior_titulo_box <- renderText({
      ano()-1 
    })
    
    output$mes_media_mensal_arrecadacao <- renderText({
      stringr::str_to_sentence(format(input$mes_ano, format="%B"))
    })

    output$previsao_arrecadacao_anual <- renderText({
        previsao <- dados |> select(previsao_arrecadacao, ano, mes) |> subset(ano == ano() & mes == mes_numero())
        as.character(format(round(previsao$previsao_arrecadacao, 2), nsmall = 2, big.mark = "."))
    })
    
    output$arrecadacao_anual <- renderText({

        
        arrecadacao <- dados |> select(receita_arrecadada, ano, mes) |>
                            subset(ano == ano() & mes <= mes_numero()) 
        #glimpse(arrecadacao[, 1])
        arrecadacao <- sum(arrecadacao[, 1])
        as.character(format(round(arrecadacao, 2), nsmall = 2, big.mark = "."))
        
    })
    
    output$arrecadacao_anual_ano_anterior <- renderText({
      
      arrecadacao <- dados |> select(receita_arrecadada, ano) |>
        subset(ano == ano()-1) 
      arrecadacao <- sum(arrecadacao[, 1])
      as.character(format(round(arrecadacao, 2), nsmall = 2, big.mark = "."))
      
    })
    
    output$media_mensal_arrecadacao <- renderText({
      
      arrecadacao <- dados |> select(receita_arrecadada, ano, mes) |>
        subset(ano == ano() & mes <= mes_numero()) 
      
      arrecadacao <- mean(arrecadacao$receita_arrecadada, na.rm = TRUE)
      as.character(format(round(arrecadacao, 2), nsmall = 2, big.mark = "."))
      
    })
    
    output$cumprimento_meta_arrecadacao <- renderHighchart({
      
      dados1 <-  dados |> select(receita_arrecadada, ano, mes) |>
        subset(ano == ano() & mes <= mes_numero()) 
      dados1 <- sum(dados1[, 1])
      
      h <- highchart() |>
           hc_chart(type = 'bar') |>
           #hc_title(text = 'Cumprimento da meta') |>
           hc_add_series(data = dados1, name="Realizado") |>
           hc_add_series(data = previsao_arrecadacao_anual(), name= "Meta") |>
           hc_plotOptions(bar=list(dataLabels=list(enabled=TRUE, 
                                                   format='R$ {point.y:.2f}',
                                                   align = 'left'))) |>
           hc_yAxis(labels = list(enabled=FALSE), gridLineWidth = 0) |>
           hc_xAxis(labels = list(enabled=FALSE)) 
            
           
      
      h
        
           
    })
    
    output$arrecadacao_distritos <- renderHighchart({
      
      dados1 <-  dados |> select(distritos, ano, mes) |>
                      subset(ano == ano()) 
      dados1[is.na(dados1)] <- 0
      
      
      h <- highchart() |>
        hc_chart(type = 'column') |>
        hc_add_series(data = dados1$distritos, showInLegend = FALSE, name = "Arrecadaçao") |>
        hc_yAxis(title = list(text = "Valor (R$)")) |>
        hc_xAxis(categories = meses_sigla, crosshair = TRUE) |>
        hc_tooltip(crosshairs = TRUE,
                   borderWidth = 5,
                   sort = FALSE,
                   table = TRUE, 
                   headerFormat = '{point.x}<br>',
                   pointFormat = "{series.name}: R${point.y:.1f}<br>") |>
        hc_plotOptions(column = list(colorByPoint = TRUE)) |>
        hc_colors(c("#e60049", "#0bb4ff", "#50e991", "#e6d800"))
      
      
      
      h
      
      
    })
    
    data_to_plot <- reactiveVal()
    
    observe({
      future_promise({ get_visualizacoes(user_key = user_key, channel_id = id_canal, videos_id = id_videos) }) %...>%
        data_to_plot() %...!%  # Assign to data
        (function(e) {
          data(NULL)
          warning(e)
          session$close()
        }) # error handling
      
      # Hide the async operation from Shiny by not having the promise be
      # the last expression.
      NULL
    }) 
    
    output$grafico_visualizacoes <- renderHighchart({
      
      req(data_to_plot())
      
      vis <- data_to_plot()
      
      h <- highchart() |>

        hc_chart(type = "column") |>
        hc_yAxis(title = list(text = "Nº de visualizações")) |>
        #hc_title(text = "Visualizações") |>
        hc_xAxis(labels = list(enabled=FALSE), max = length(nomes_videos)+1, min = 0) |>
        hc_tooltip(crosshairs = TRUE,
                   borderWidth = 5,
                   sort = FALSE,
                   table = TRUE, 
                   headerFormat = '{series.name}<br>',
                   pointFormat = "{point.y:.0f} visualizações<br>") 

      for (k in 1:length(nomes_videos)) {
        dados1 <- data.frame(x= k ,
                            y= as.numeric(vis$statistics.viewCount[k]))
        
        h <- h |>
          hc_add_series(data = dados1, name = nomes_videos[k])
      }
      
      h
      
    })
    
    output$emissao_cpm <- renderHighchart({
      cpm <- dados |> select(ano, mes, producao) |>
                      subset(ano >= ano()-2 & ano <= ano() )
      
      h <- highchart() |>
        
        hc_chart(type = "column") |>
        hc_yAxis(title = list(text = "Nº de emissões"), max = max(cpm$producao, na.rm = TRUE)+5) |>
        #hc_title(text = "Visualizações") |>
        hc_xAxis(categories = c("JAN", meses_sigla)) |>
        hc_tooltip(crosshairs = TRUE,
                   borderWidth = 5,
                   sort = FALSE,
                   table = TRUE, 
                   headerFormat = 'Emissões {point.x}<br>',
                   pointFormat = "{series.name}:{point.y} <br>") 
      
        
      anos <- unique(cpm$ano)
      for (k in 1:length(anos)) {
        dados1 <- data.frame(x= subset(cpm, ano == anos[k])$mes ,
                             y= subset(cpm, ano == anos[k])$producao)
       
        h <- h |>
          hc_add_series(data = dados1, name = anos[k])
      }
      
      h
      
    })
    
    output$grafico_arrecadacao_cpm <- renderHighchart({
      arrecadacao_cpm <- dados |> select(ano, mes, cpm) |>
                      subset(ano == ano())
      dados1 <- data.frame(x= arrecadacao_cpm$mes ,
                           y= arrecadacao_cpm$cpm)
      
      h <- highchart() |>
        
        hc_chart(type = "column") |>
        hc_yAxis(title = list(text = "Valor (R$)"), max = max(arrecadacao_cpm$cpm, na.rm = TRUE)+5) |>
        #hc_title(text = "Visualizações") |>
        hc_xAxis(categories = c("JAN", meses_sigla)) |>
        hc_tooltip(crosshairs = TRUE,
                   borderWidth = 5,
                   sort = FALSE,
                   table = TRUE, 
                   headerFormat = '{point.x} de {series.name}<br>',
                   pointFormat = "R$ {point.y} <br>") |>
        hc_add_series(data = dados1, name = ano(), showInLegend = FALSE) #|>
        # hc_plotOptions(column=list(dataLabels=list(enabled=TRUE, 
        #                                       format='R$ {point.y:.2f}',
        #                                       align = 'center' #,rotation = 270
        #                                       ))) 
        # 
      
     
      
      
      h
      
    })
    
    output$grafico_metas_publicacao <- renderHighchart({
      metas <- dados |> select(ano, mes, 
                               pva_boletim_caged, 
                               pva_estudos_tecnicos, 
                               pva_pib_trimestral, 
                               pva_texto_discussao, 
                               pva_boletim_tematico,
                               pva_relatorio_nota_tecnica,
                               publicado) |>
                        subset(ano == ano())
      metas <- metas |> mutate(previsao = rowSums(metas[3:7])) 
      
      
      
      a <- metas |> mutate(mes_sigla = meses_sigla)#subset(ano == 2022)|>
        
      
      c <- a |> select(-ano) |>
                select(-publicado) #|>
                #pivot_longer(cols = c(2:7),
                #             names_to = "tipo")
      b <- c |> group_nest(mes_sigla) |>
                mutate(id = mes_sigla,
                       type = 'column',
                       data = map(data, list_parse))
      
      
      publicado <- data.frame(x = metas$mes,
                              y = metas$publicado)
      previsao <- data.frame(x = metas$mes,
                             y = metas$previsao)
      
      tipos_publicacoes = c("Estudos técnicos",
                            "PIB Trimestral MG", 
                            "Texto p/ discussão", 
                            "Boletim/Informativo CAGED",
                            "Boletins temáticos",
                            "Relatório/Nota técnica")
      x <- tipos_publicacoes
      y <- c("{point.pva_estudos_tecnicos}", 
             "{point.pva_pib_trimestral}", 
             "{point.pva_texto_discussao}",
             "{point.pva_boletim_caged}",
             "{point.pva_boletim_tematico}",
             "{point.pva_relatorio_nota_tecnica}")
      
      tt <- tooltip_table(x, y)
      
      h <- hchart(a, 
             "column",
             hcaes(x = mes_sigla, y = previsao, name = mes_sigla, drilldown = mes_sigla ),
             name = "Publicações",
             colorByPoint = TRUE) |>
        hc_drilldown(
          allowPointDrilldown = TRUE,
          series = list_parse(b)
        ) |>
        hc_tooltip(headerFormat = "Total {point.x}: {point.y}",
                    pointFormat = tt,
                   valueDecimals = 0,
                   useHTML = TRUE)
      #https://jkunst.com/highcharter/articles/drilldown.html
      
      # h <- highchart() |>
      #   
      #   hc_chart(type = "column") |>
      #   hc_yAxis(title = list(text = "Nº de publicações")) |>
      #   #hc_title(text = "Visualizações") |>
      #   hc_xAxis(categories = c("JAN", meses_sigla)) |>
      #   hc_tooltip(crosshairs = TRUE,
      #              borderWidth = 5,
      #              sort = FALSE,
      #              table = TRUE, 
      #              headerFormat = '{point.x} de {series.name}<br>',
      #              pointFormat = "R$ {point.y} <br>") |>
      #   hc_add_series(data = publicado, name = 'Publicado')|>
      #   hc_add_series(data = previsao, name = 'Previsão') |>
      #   hc_drilldown(allowPointDrilldown = TRUE,
      #                series = list_parse(b)) |>
      #   hc_tooltip(pointFormat = tt)
      
      
      # |>
      #   hc_tooltip(shared = TRUE, formatter = JS(paste0('function(){
      #     return "Estudos técnicos: <br> PIB trimestral MG:";
      # 
      #   }')))
      #  
       
      # tooltip: {
      #   formatter: function() {
      #     return 'The value for <b>' + this.x + '</b> is <b>' + this.y + '</b>, in series '+ this.series.name;
      #   }
      # }
      
      
      h
      
      
    })
    
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)

#https://www.yuichiotsuka.com/youtube-data-extract-r/#Step_4_Sample_Code_for_Extracting_YouTube_Data_in_R
