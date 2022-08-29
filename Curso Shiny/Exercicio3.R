
library(shiny)
library(shinydashboard)

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
                                       column(width = 6,
                                              selectInput(inputId = 'municipios',
                                                          label = "Escolha o município:",
                                                          choices = c("Belo Horizonte", "Betim", "Contagem"))),
                                       column(width = 6,
                                              selectInput(inputId = 'ano_tabela',
                                                          label = "Escolha o ano:",
                                                          choices = c(2019, 2020)))))),
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
  
}

shinyApp(ui = ui, server = server)
