
library(shiny)
library(shinydashboard)

ui <-  dashboardPage(
  dashboardHeader(title = "IMRS Demografia"),
  
  dashboardSidebar(),
  
  dashboardBody(a(href = "http://fjp.mg.gov.br/", img(src = "logo_fjp.png", weight = 150, height = 150)),
                br(),
                h1("IMRS Demografia"),
                p("Esse dashboard permite a visualização de dados referentes à dimensão Demografia do IMRS", style = "font-size:16pt"),
                br(),
                p("Para acessar a plataforma do IMRS, clique", a("aqui", href="http://imrs.fjp.mg.gov.br/"), ".", style = "color: red; font-size:16pt")
                
  )
  
  
  
  
  
)

server <- function(input, output) {
  
}

shinyApp(ui = ui, server = server)
