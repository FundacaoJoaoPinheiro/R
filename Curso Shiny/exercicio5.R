
library(shiny)
library(shinydashboard)
library(readxl)


dados <- read_excel("dados_curso1.xlsx") 
dados <- dados |> select(-1)

#função para exportação de imagens
export <- list(
  list(text="PNG",
       onclick=JS("function () {
                this.exportChartLocal(); }")),
  list(text="JPEG",
       onclick=JS("function () {
                this.exportChartLocal({ type: 'image/jpeg' }); }"))
  
)

ui <-  dashboardPage(
  dashboardHeader(title = "IMRS Demografia"),
  
  dashboardSidebar(sidebarMenu(id = 'barra_lateral',
                               menuItem("Indicadores - Tabela", tabName = 'indicadores_tabela'),
                               menuItem("Indicadores - Gráfico", tabName = 'indicadores_grafico'),
                               menuItem("Outras informações", tabName = 'outras_infos'),
                               menuItem("Sobre", tabName = 'sobre')
  )
  ),
  
  dashboardBody(tabItems(tabItem(tabName = 'indicadores_tabela',
                                 fluidRow(
                                   box(width = 12,
                                       column(width = 4,
                                              selectInput(inputId = 'municipios',
                                                          label = "Escolha o município:",
                                                          choices = unique(dados$MUNICÍPIO),
                                                          multiple = TRUE,
                                                          selected = NULL)),
                                       column(width = 4,
                                              selectInput(inputId = 'indicadores',
                                                          label = "Escolha o indicador",
                                                          choices = c("AREA", "D_POPTA", "HOMEMTOT", "MULHERTOT"),
                                                          multiple = TRUE,
                                                          selected = NULL)),
                                       column(width = 4,
                                              selectInput(inputId = 'ano_tabela',
                                                          label = "Escolha o ano:",
                                                          choices = unique(dados$ANO),
                                                          multiple = TRUE)))),
                                 
                                 dataTableOutput(outputId = 'tabela')
                                 
  ),
  tabItem(tabName = 'indicadores_grafico', 
          fluidRow(
            box(width = 12,
                column(width = 4,
                       selectInput(inputId = 'municipios_grafico',
                                   label = "Escolha o município:",
                                   choices = unique(dados$MUNICÍPIO),
                                   multiple = TRUE,
                                   selected = NULL)),
                column(width = 4,
                       selectInput(inputId = 'indicadores_grafico',
                                   label = "Escolha o indicador",
                                   choices = c("AREA", "D_POPTA", "HOMEMTOT", "MULHERTOT"),
                                   multiple = FALSE,
                                   selected = "D_POPTA")),
                column(width = 4,
                       sliderInput(inputId = 'ano_grafico',
                                   label = "Escolha o intervalo:",
                                   min = min(dados$ANO),
                                   max = max(dados$ANO),
                                   value = c(min(dados$ANO), max(dados$ANO)))))),
          
          fluidRow(
            box(width = 12,
                highchartOutput(outputId = 'grafico')
            ))),
  tabItem(tabName = 'outras_infos', "Outras informações"),
  tabItem(tabName = 'sobre',
          a(href = "http://fjp.mg.gov.br/", img(src = "logo_fjp.png", weight = 150, height = 150)),
          br(),
          h1("IMRS Demografia"),
          p("Esse dashboard permite a visualização de dados referentes à dimensão Demografia do IMRS", style = "font-size:16pt"),
          br(),
          p("Para acessar a plataforma do IMRS, clique", a("aqui", href="http://imrs.fjp.mg.gov.br/"), ".", style = "color: red; font-size:16pt")
          
  )
  
  )
  )
  
  
)

server <- function(input, output) {
  
  output$tabela <- renderDataTable({
    req(input$indicadores, input$municipios, input$ano_tabela)
    dados |> select(c(MUNICÍPIO, ANO, input$indicadores)) |>
      subset(MUNICÍPIO %in% input$municipios & ANO %in% input$ano_tabela)
  })
  
  output$grafico <- renderHighchart({
    
    req(input$municipios_grafico)
    req(input$indicadores_grafico)
    
    dados_final <- lapply(input$municipios_grafico, function(x){
      dados_selecionados <- dados |>  
        subset(MUNICÍPIO %in% x & (ANO >= input$ano_grafico[1]) & (ANO <= input$ano_grafico[2])) |>  
        select(c(MUNICÍPIO, ANO, input$indicadores_grafico)) 
      colnames(dados_selecionados) <- c("MUNICÍPIO", "ANO", "INDICADOR")
      
      dados <- data.frame(x = dados_selecionados$ANO, 
                          y = dados_selecionados$INDICADOR)
      
    })  
    
    h <- highchart() |>
      
      hc_xAxis(title = list(text = "Ano"), allowDecimals = FALSE) |>
      hc_chart(type = "line") |>
      hc_exporting(enabled = T, fallbackToExportServer = F, 
                   menuItems = export)  |>
      hc_yAxis(title = list(text = "Valor do indicador ")) |>
      hc_title(text = paste("Indicador: ", input$indicadores_grafico))
    
    
    for (k in 1:length(dados_final)) {
      h <- h |> 
        hc_add_series(data = dados_final[[k]], name = input$municipios_grafico[k])
    }
    
    h
    
  })
}

shinyApp(ui = ui, server = server)
