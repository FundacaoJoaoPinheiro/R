library(shiny)
library(shinydashboard)
library(readxl)


dados <- read_excel("dados_curso1.xlsx") 
dados <- dados |> select(-1)

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
  tabItem(tabName = 'indicadores_grafico', "Indicadores"),
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
}

shinyApp(ui = ui, server = server)
