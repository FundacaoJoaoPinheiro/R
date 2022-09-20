
# Inclui o arquivo com funções auxiliares
source("functions.R")


# Carrega as bibliotecas necessárias
library(shiny)
library(shinydashboard)
library(highcharter)
library(readxl)
library(tibble)
library(tidyverse)
library(httr)
library(jsonlite)
library(dplyr)
library(promises)
library(future)
library(shinyjs)

# Realiza a leitura da planilha compartilhada
url <- "https://drive.google.com/uc?export=download&id=1qBeKtxV5MKAdo1CzG7gqYpD1ne8_XhdX"
GET(url, write_disk(tf <- tempfile(fileext = ".xlsx")))
dados <- read_excel(tf, 3L)
dados_videos <- read_excel(tf, 4L)
options(OutDec= ".") 

# Obtém as informações sobre os vídeos do youtube
user_key <- dados_videos$user_key[1]
id_canal <- dados_videos$canal_id[1]
id_videos <- dados_videos$videos_id
nomes_videos <- dados_videos$nomes

# Inicializa os vetores com os nomes dos meses
anos <- unique(dados$ano)
meses <- unique(dados$mes)
meses_sigla <- c("JAN", "FEV", "MAR", "ABR", "MAI", "JUN", "JUL", "AGO", "SET", "OUT", "NOV", "DEZ")
meses_nomes <- c("Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro")

plan(multisession)

#função para exportação de imagens
export <- list(
  list(text="PNG",
       onclick=JS("function () {
                this.exportChartLocal(); }")),
  list(text="JPEG",
       onclick=JS("function () {
                this.exportChartLocal({ type: 'image/jpeg' }); }"))
  
)

#Define a interface de usuário
# UI ------
ui <- dashboardPage(
    
    
    title = "Controle Gerencial",
    
    dashboardHeader(disable = TRUE),
        
    dashboardSidebar(disable = TRUE,
                     tags$head(tags$script('
                                var dimension = [0, 0];
                                $(document).on("shiny:connected", function(e) {
                                    dimension[0] = window.innerWidth;
                                    dimension[1] = window.innerHeight;
                                    Shiny.onInputChange("dimension", dimension);
                                });
                                $(window).resize(function(e) {
                                    dimension[0] = window.innerWidth;
                                    dimension[1] = window.innerHeight;
                                    Shiny.onInputChange("dimension", dimension);
                                });
                            ')),
                     tags$style(HTML('
                      .my_table .table>tbody>tr>td, .table>tbody>tr>th, .table>tfoot>tr>td, .table>tfoot>tr>th, .table>thead>tr>td, .table>thead>tr>th {
                        padding: 10px;
                        column-width: 5%;
                        border-spacing: 1px;
                        line-height: 1.42857143;
                        text-align:center;
                        
                      }'
                      ))
                     ),
       
    dashboardBody(
      useShinyjs(), 
   
        fluidRow(
          div(style="background-color:White;padding:25px; height:10%",
              div( style="text-align: center; ",
                   img(src="logo_fjp.png", weight = 50, height = 50),
                   htmlOutput(outputId = 'titulo'),
                   htmlOutput(outputId = 'mes_ano_titulo', inline = TRUE )
              
            )
          ),
        ),
        br(),
        #fluidRow(verbatimTextOutput("dimension_display")),
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
                                ),
                                p("dados consolidados até ", textOutput(outputId = 'mes_media_mensal_arrecadacao3', inline = TRUE), style='font-size:12px;')
                                
                              ),
                              box(
                                title = div("Arrecadação ", textOutput(outputId = 'ano_titulo_box', inline = TRUE)),
                                status = "primary",
                                solidHeader = TRUE,
                                width = 3,
                                height = 120,
                                div( style="text-align: center;",
                                     span("R$", textOutput(outputId = 'arrecadacao_anual', inline = TRUE), style='font-size:24px;' )
                                ),
                                p("dados consolidados até ", textOutput(outputId = 'mes_media_mensal_arrecadacao2', inline = TRUE), style='font-size:12px;')
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
                                ),
                                p("dados consolidados até ", textOutput(outputId = 'mes_media_mensal_arrecadacao4', inline = TRUE), style='font-size:12px;')
                              )
                            ),
                            fluidRow(
                               box(
                                 #title = div("Cumprimento Meta Arrecadação", textOutput(outputId = 'ano_titulo_cumprimento_meta_arrecadacao')),
                                 status = "primary",
                                 solidHeader = FALSE,
                                 width = 4,
                                 #height = 250,
                                 highchartOutput(outputId = 'cumprimento_meta_arrecadacao', height = 230)
                               ),
                               box(
                                 #title = div("Arrecadação Distritos"),
                                 status = "primary",
                                 solidHeader = FALSE,
                                 width = 4,
                                 #height = 250,
                                 highchartOutput(outputId = 'arrecadacao_distritos', height = 230)
                               ),
                               box(
                                 #title = div( style="text-align: center;",
                                #              span("Comparação acumulado CPM")#, style='font-size:24px;' )
                                 #),
                                 status = "primary",
                                 solidHeader = FALSE,
                                 width = 4,
                                 #height = 250,
                                 highchartOutput(outputId = 'grafico_comparacao_cpm', height = 230)
                               )
                            ),
                            fluidRow(
                               box(
                                 title = div( style="text-align: center;",
                                              span("Emissão CPM", textOutput(outputId = 'anos_emissao_cpm', inline = TRUE) )
                                 ),
                                 status = "primary",
                                 solidHeader = TRUE,
                                 width = 6,
                                 #height = 250,
                                 highchartOutput(outputId = 'emissao_cpm', height = 250),
                                 tags$div(class = 'my_table', align = 'center',
                                                tableOutput(outputId = 'tabela_emissao_cpm'), style = 'font-size:80%;'
                                                    
                                          )
                                   
                               ),
                               box(
                                 title = div( style="text-align: center;",
                                              span("Arrecadação com CPM", textOutput(outputId = 'ano_arrecadacao_cpm', inline = TRUE) )
                                 ),
                                 status = "primary",
                                 solidHeader = TRUE,
                                 width = 6,
                                 #height = 250,
                                 highchartOutput(outputId = 'grafico_arrecadacao_cpm')
                               )
                              ),
                            fluidRow(
                              column(width = 6,
                                     box(
                                       title = div( style="text-align: center;",
                                                    span("Metas de Publicação - Vale Alimentação", textOutput(outputId = 'ano_metas_publicacao', inline = TRUE) )
                                       ),
                                       status = "primary",
                                       solidHeader = TRUE,
                                       width = 12,
                                       #height = 250,
                                       highchartOutput(outputId = 'grafico_metas_publicacao')
                                     )
                                  ),
                              column(width = 6,
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
                          )
                   ), 
                   tabPanel("Série Histórica")
                 )
               )
        )
    )


# Define a função server
# Server ----
server <- function(input, output) {
    
    options(OutDec=",")
  
    # cria uma lista de valores reativos
    dados_futuros <- reactiveValues()
    
    # output$dimension_display <- renderText({
    #   paste(input$dimension[1], input$dimension[2], input$dimension[2]/input$dimension[1])
    # })
  
    # Mês atual ----
    mes <- eventReactive(input$mes_ano, {
      #stringr::str_to_upper(format(input$mes_ano, format="%b"))
      meses_nomes[mes_numero()]
    })
    
    # Mês atual número ----
    mes_numero <- eventReactive(input$mes_ano, {
      as.numeric(format(input$mes_ano, format="%m"))
    })
    
    # Ano atual ----
    ano <- eventReactive(input$mes_ano, {
      as.numeric(format(input$mes_ano, format="%Y"))
    })
    
    
    # Título painel ----
    # Atualiza o tamanho da fonte do título do painel de acordo com as dimensões da tela
    output$titulo <- renderText({
      tamanho_fonte <- round(input$dimension[1]/50)+10;
      paste0('<span style="font-size:', tamanho_fonte, 'px"> Painel de Controle Gerencial - DIREI </span>') 
    })
  
    ## Mês e ano título ----
    # Atualiza o mês e o ano do título 
    output$mes_ano_titulo <- renderText({
      tamanho_fonte <- round(input$dimension[1]/50)+5;
      paste0('<span style="font-size:', tamanho_fonte, 'px">', 
             stringr::str_to_sentence(paste(meses_nomes[mes_numero()], 
                                            ' de ', 
                                            format(input$mes_ano, format="%Y"))), 
             '</span>')
    })
    
    ## Títulos caixas ----
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
    
    output$ano_titulo_cumprimento_meta_arrecadacao <- renderText({
      ano()
    })
    
    output$ano_metas_publicacao <- renderText({
      ano()
    })
    
    output$ano_anterior_titulo_box <- renderText({
      ano()-1 
    })
    
    output$mes_media_mensal_arrecadacao <- renderText({
      meses_nomes[mes_numero()]
    })
    
    output$mes_media_mensal_arrecadacao2 <- renderText({
      meses_nomes[mes_numero()]
    })
    
    output$mes_media_mensal_arrecadacao3 <- renderText({
      meses_nomes[mes_numero()]
    })
    
    output$mes_media_mensal_arrecadacao4 <- renderText({
      meses_nomes[mes_numero()]
    })
    
    output$mes_acumulado <- renderText({
      #stringr::str_to_sentence(format(input$mes_ano, format="%B"))
      meses_nomes[mes_numero()]
    })
    
    output$mes_acumulado2 <- renderText({
      meses_nomes[mes_numero()]
    })
    
    output$mes_acumulado3 <- renderText({
      meses_nomes[mes_numero()]
    })

    # Valores ----
    ## Previsão arrecadação anual ----
    # Obtém o dado para o mês e anos atuais a partir da tabela
    previsao_arrecadacao_anual <- eventReactive(input$mes_ano, {
      previsao <- dados |> select(previsao_arrecadacao, ano, mes) |> 
                           subset(ano == ano() & mes == mes_numero())
      as.numeric(previsao[1])
      
    })
    output$previsao_arrecadacao_anual <- renderText({
        previsao <- dados |> select(previsao_arrecadacao, ano, mes) |> 
                             subset(ano == ano() & mes == mes_numero())
        as.character(format(round(previsao$previsao_arrecadacao, 2), nsmall = 2, big.mark = "."))
    })
    
    ## Arrecadação anual ----
    output$arrecadacao_anual <- renderText({
        arrecadacao <- dados |> select(receita_arrecadada, ano, mes) |>
                                subset(ano == ano() & mes <= mes_numero()) 
        arrecadacao <- sum(arrecadacao[, 1])
        as.character(format(round(arrecadacao, 2), nsmall = 2, big.mark = "."))
    })
    
    ## Media mensal arrecadação ----
    output$media_mensal_arrecadacao <- renderText({
      arrecadacao <- dados |> select(receita_arrecadada, ano, mes) |>
                              subset(ano == ano() & mes <= mes_numero()) 
      arrecadacao <- mean(arrecadacao$receita_arrecadada, na.rm = TRUE)
      as.character(format(round(arrecadacao, 2), nsmall = 2, big.mark = "."))
      
    })
    
    
    
    ## Arrecadação ano anterior ----
    output$arrecadacao_anual_ano_anterior <- renderText({
      arrecadacao <- dados |> select(receita_arrecadada, ano) |>
                              subset(ano == ano()-1) 
      arrecadacao <- sum(arrecadacao[, 1])
      as.character(format(round(arrecadacao, 2), nsmall = 2, big.mark = "."))
      
    })
    
    # Gráficos ----
      ## Cumprimento meta arrecadação ----
    output$cumprimento_meta_arrecadacao <- renderHighchart({
      
      dados1 <-  dados |> select(receita_arrecadada, previsao_arrecadacao, ano, mes) |>
                          subset(ano == ano() & mes <= mes_numero()) 
      #dados1 <- sum(dados1[, 1])
      
      
      
      lang <- getOption("highcharter.lang")
      lang$decimalPoint <- ","
      lang$numericSymbols <- highcharter::JS("null") # optional: remove the SI prefixes
      options(highcharter.lang = lang)
      
      previsao <- subset(dados1, mes == mes_numero())$previsao_arrecadacao 
      
      percentuais <- c((sum(dados1$receita_arrecadada)/previsao)* 100, 100)
      
      h <- highchart() |>
           hc_chart(type = 'bar') |>
           hc_size(height = 200) |>
           hc_title(text = paste('Cumprimento Meta Arrecadação', ano())) |>
           hc_subtitle(text = paste("acumulado até", meses_nomes[mes_numero()])) |>
           hc_add_series(data = data.frame(x= 1, y= sum(dados1$receita_arrecadada)), name="Realizado", extra = percentuais[1]) |>
           hc_add_series(data = data.frame(x= 2, y= subset(dados1, mes == mes_numero())$previsao_arrecadacao), name= "Meta", extra = percentuais[2]) |>
           hc_plotOptions(bar=list(dataLabels=list(enabled=TRUE, 
                                                   format=paste('R$ {point.y:,.2f}', '({point.series.options.extra:,.2f} %)'),
                                                   align = 'left'),
                                    pointWidth=30)) |>
           hc_tooltip(headerFormat = '') |>
           hc_exporting(enabled = T, fallbackToExportServer = F, 
                     menuItems = export)  |>  
           hc_yAxis(labels = list(enabled=FALSE), gridLineWidth = 0) |>
           hc_xAxis(labels = list(enabled=FALSE), min = 0, max = 4)
      
      
      
      h
        
           
    })
    
    ## Arrecadação distritos----
    output$arrecadacao_distritos <- renderHighchart({
      
      dados1 <-  dados |> select(distritos, ano, mes) |>
                      subset(ano == ano()) 
      dados1[is.na(dados1)] <- 0
      
      
      h <- highchart() |>
        hc_chart(type = 'column') |>
        hc_title(text = paste('Arrecadação Distritos', ano())) |>
        hc_subtitle(text = paste("acumulado até", meses_nomes[mes_numero()])) |>
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
        hc_colors(c("#e60049", "#0bb4ff", "#50e991", "#e6d800")) |>
        hc_exporting(enabled = T, fallbackToExportServer = F, 
                     menuItems = export)
      
      
      
      h
      
      
    })
    
    
    
    ## Comparação CPM----
    output$grafico_comparacao_cpm <- renderHighchart({
      
      dados1 <-  dados |> select(cpm, ano, mes) |>
                          subset((ano == ano() | ano == ano()-1 | ano == ano()-2) & mes <= mes_numero()) 
      
      h <- highchart() |>
        hc_chart(type = 'bar') |>
        hc_title(text = paste('Comparação Acumulado CPM', ano())) |>
        hc_subtitle(text = paste("acumulado até", meses_nomes[mes_numero()])) |>
        hc_plotOptions(bar=list(dataLabels=list(enabled=TRUE,
                                                format='R$ {point.y:,.2f}',
                                                align = 'left'),
                                pointWidth = 30)) |>
        hc_tooltip(headerFormat = '') |>
        hc_yAxis(labels = list(enabled=FALSE), gridLineWidth = 0) |>
        hc_xAxis(labels = list(enabled=FALSE), min = 0, max = 4) |>
        hc_exporting(enabled = T, fallbackToExportServer = F, 
                     menuItems = export)  
      
      anos <- unique(dados1$ano)
      for (k in 1:length(anos)) {
        dados2 <- data.frame(x= k,
                             y= sum(subset(dados1, ano == anos[k] & mes <= mes_numero())$cpm))
        h <- h |>
          hc_add_series(data = dados2, name = anos[k])
      }
      
      h
      
      
    })
    
    ## Emissão CPM ----
    output$emissao_cpm <- renderHighchart({
      cpm <- dados |> select(ano, mes, producao) |>
        subset(ano >= ano()-2 & ano <= ano())
      
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
    
    # output$dimension_display <- renderText({
    #   paste(input$dimension[1], input$dimension[2], input$dimension[2]/input$dimension[1])
    # })
    
    
    
    output$tabela_emissao_cpm <- renderTable({
      
      # cpm <- dados |> select(ano, mes, producao) |>
      #   subset(ano >= 2020 & ano <= 2022)
      # cpm$producao <- sprintf("%i", cpm$producao)
      # cpm <- cpm |> pivot_wider(names_from = mes, values_from = producao)
      
      #print(paste(input$dimension[1], input$dimension[2], input$dimension[2]/input$dimension[1]))
      
      
      
      if(input$dimension[1] > 1300){
        cpm <- dados |> select(ano, mes, producao) |>
          subset(ano >= ano()-2 & ano <= ano()) 
        cpm$producao <- sprintf("%i", cpm$producao) 
        cpm$ano <- sprintf("%i", cpm$ano) 
        cpm <- cpm |> pivot_wider(names_from = mes, values_from = producao)
        colnames(cpm) <- c(" ", meses_sigla)
        cpm
      }
      
      
      
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
