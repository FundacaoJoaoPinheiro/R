#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


source('global.R')


ui <- dashboardPage(
  
  #Título
  header <- dashboardHeader(title =  loadingLogo('http://fjp.mg.gov.br/',
                                                 'logo_fjp.png',
                                                 'loader.gif', 
                                                 40,40)),
  
  
  #Barra lateral    
  dashboardSidebar(
    sidebarMenu( id = "barra_lateral",
                 menuItem("Contas Econômicas", tabName = "contas_economicas"), 
                 menuItem("PIB per capita", tabName = "pib_per_capita"),
                 menuItem("Resultados", tabName = "resultados")
    ) 
    
    
    
  ),
  
  #Corpo    
  dashboardBody(
    #altera a cor do cabeçalho e coloca o título
    tags$head(tags$style(HTML(
      '.myClass { 
        font-size: 20px;
        line-height: 50px;
        text-align: left;
        font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;
        padding: 0 15px;
        overflow: hidden;
        color: white;
        }
        '))),
    tags$script(HTML('
        $(document).ready(function() {
          $("header").find("nav").append(\'<span class="myClass"> PIB MG </span>\');
        })
       ')),
    
    tags$head(tags$style(HTML('
        /* logo */
        .skin-blue .main-header .logo {
                              background-color: #c3c3c3;
                              }
        /* logo when hovered */
        .skin-blue .main-header .logo:hover {
                              background-color: #c3c3c3;
                              }'))),
    
    tabItems(
      tabItem(tabName = 'contas_economicas',
              fluidRow( 
                box(
                  title = "PIB segundo a ótica da Produção e da Renda", status = "primary", solidHeader = TRUE,
                  width = 10,
                  collapsible = FALSE,
                  box(
                    title = NULL, status = "success", solidHeader = FALSE, width = 12,
                    collapsible = FALSE,
                    fluidRow(box(highchartOutput('comp_prod_renda'), height=400,width = 12)),#,background='white')),
                    #box(
                    #  status = "info", solidHeader = FALSE, width = 12, collapsed = TRUE, collapsible = TRUE,
                    #  sliderInput("anos_lineplot_prod", "Escolha o ano:", min=2010, max=ultimo_ano, value=c(2010, ultimo_ano),animate=T)
                    #)
                    
                  )
                ),
                box(
                  title = "Informações",  status = "primary", solidHeader = TRUE, width = 2
                )
                
              ),    
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
                      sliderInput("anos_lineplot_prod", "Escolha o ano:", min=2010, max=ultimo_ano, value=c(2010, ultimo_ano),animate=T)
                    )
                    
                  ),
                  box(
                    title = NULL, status = "success", solidHeader = FALSE, width = 6,
                    collapsible = FALSE,
                    fluidRow(box(highchartOutput('piePlot_prod'), height=400 ,width = 12)),#,background='white')),
                    box(
                      status = "info", solidHeader = FALSE, width = 12, collapsed = TRUE, collapsible = TRUE,
                      sliderInput("anos_columplot_prod", "Escolha o ano:", min=2010, max=ultimo_ano, value=c(2010, ultimo_ano),animate=T)
                    )
                  )
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
                      sliderInput("anos_lineplot_renda", "Escolha o ano:", min=2010, max=ultimo_ano, value=c(2010, ultimo_ano),animate=T)
                    )
                  ),
                  box(
                    title = NULL, status = "success", solidHeader = FALSE,
                    collapsible = FALSE, width = 6,
                    fluidRow(box(highchartOutput('piePlot_renda'), height=400 ,width = 12)),#,background='white')),
                    box(
                      status = "info", solidHeader = FALSE, width = 12, collapsed = TRUE, collapsible = TRUE,
                      sliderInput("anos_columnplot_renda", "Escolha o ano:", min=2010, max=ultimo_ano, value=c(2010, ultimo_ano),animate=T)
                    )
                  )
                )
              )
      ),
      tabItem(tabName = 'pib_per_capita',
              fluidRow( 
                tabBox(
                  title = NULL, width = 12,
                  id = "tab_opcoes_pib_per_capta", height = "250px",
                  tabPanel("Gráficos lado a lado", 
                           fluidRow( 
                             box(
                               title = "PIB", status = "primary", solidHeader = TRUE,
                               width = 4,
                               box(
                                 title = NULL, status = "success", solidHeader = FALSE, width = 12,
                                 collapsible = FALSE,
                                 fluidRow(box(highchartOutput('linePlot_pib_percapita4'), height=400,width = 12)),#,background='white')),
                               ),
                             ),
                             box(
                               title = "População", status = "primary", solidHeader = TRUE,
                               width = 4,
                               box(
                                 title = NULL, status = "success", solidHeader = FALSE, width = 12,
                                 collapsible = FALSE,
                                 fluidRow(box(highchartOutput('linePlot_pib_percapita5'), height=400,width = 12)),#,background='white')),
                               ),
                             ),
                             box(
                               title = "PIB per capita", status = "primary", solidHeader = TRUE,
                               width = 4,
                               box(
                                 title = NULL, status = "success", solidHeader = FALSE, width = 12,
                                 collapsible = FALSE,
                                 fluidRow(box(highchartOutput('linePlot_pib_percapita6'), height=400,width = 12)),#,background='white')),
                               )
                             ),
                             fluidRow(
                               box(
                                 status = "info", solidHeader = FALSE, width = 6, collapsed = FALSE, collapsible = FALSE,
                                 sliderInput("anos_lineplot_pib_percapita7", "Escolha o ano:", min=2010, max=ultimo_ano, value=c(2010, ultimo_ano),animate=T)
                               ), 
                               box(
                                 status = "info", solidHeader = FALSE, width = 3, collapsed = FALSE, collapsible = FALSE,
                                 radioButtons(inputId = "tipo_graf_lineplot_pib_percapita", choices = c("Linha", "Barra"), label = "Escolha o tipo de gráfico:", inline = TRUE)
                               )
                             )
                           )
                  ),
                  tabPanel("Gráfico único",
                           fluidRow( 
                             box(
                               title = "PIB", status = "primary", solidHeader = TRUE,
                               width = 10,
                               box(
                                 title = NULL, status = "success", solidHeader = FALSE, width = 12,
                                 collapsible = FALSE,
                                 fluidRow(box(highchartOutput('linePlot_pib_percapita8'), height=400,width = 12)),#,background='white')),
                                 box(
                                   status = "info", solidHeader = FALSE, width = 12, collapsed = FALSE, collapsible = TRUE,
                                   sliderInput("anos_lineplot_pib_percapita8", "Escolha o ano:", min=2010, max=ultimo_ano, value=c(2010, ultimo_ano),animate=T)
                                 )
                               ),
                             )
                           ),        
                  ),
                  tabPanel("Um gráfico por linha",
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
                                   sliderInput("anos_lineplot_pib_percapita1", "Escolha o ano:", min=2010, max=ultimo_ano, value=c(2010, ultimo_ano),animate=T)
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
                                   sliderInput("anos_lineplot_pib_percapita2", "Escolha o ano:", min=2010, max=ultimo_ano, value=c(2010, ultimo_ano),animate=T)
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
                                   sliderInput("anos_lineplot_pib_percapita3", "Escolha o ano:", min=2010, max=ultimo_ano, value=c(2010, ultimo_ano),animate=T)
                                 )
                               ),
                             )
                           )     
                  ),
                  tabPanel("Informações",
                           fluidRow( 
                             box(
                               title = "PIB", status = "primary", solidHeader = TRUE,
                               width = 10,
                             )
                           )
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
                               sliderInput("anos_resultados_aspecto_fixo", "Escolha o ano:", min=2010, max=ultimo_ano, value=c(2010, ultimo_ano),animate=T),
                               sliderInput("anos_resultados_aspecto_fixo_pizza", "Escolha o ano:", min=2010, max=ultimo_ano, value=c(ultimo_ano),animate=T)
                             ),
                             
                           )        
                  ),
                  tabPanel("Opção 2", 
                           fluidRow(
                             box(
                               status = "info", solidHeader = FALSE, width = 12, collapsible = FALSE,
                               radioButtons(inputId = "aspectos_setor_fixo", label = "Escolha:", choices = aspectos2, selected = aspectos2[1], inline = TRUE)
                               
                             )
                           ),
                           fluidRow(
                             box(
                               status = "warning", solidHeader = FALSE, width = 3, collapsible = FALSE,
                               radioButtons(inputId = "area_ou_setor_setor_fixo", label = NULL, choices = c("Setores", "Áreas"), selected = "Setores", inline = TRUE),
                               conditionalPanel(
                                 condition = "input.area_ou_setor_setor_fixo == 'Setores'",
                                 radioButtons(inputId = "spec_setores_setor_fixo", label = NULL, choices = setor, selected = setor[1])
                               ),
                               conditionalPanel(
                                 condition = "input.area_ou_setor_setor_fixo == 'Áreas'", 
                                 radioButtons(inputId = "spec_areas_setor_fixo", label = NULL, choices = area, selected = area[1])
                               )
                             ),
                             box(
                               status = "warning", solidHeader = FALSE, width = 3, collapsible = FALSE,
                               checkboxGroupInput(inputId = "tipo_resultado_2", label = NULL, choices = tipoResutados, selected = c("VBP", "CI", "VAB"))
                             ),
                             box(
                               status = "info", solidHeader = FALSE, width = 6, collapsible = FALSE,
                               fluidRow(box(highchartOutput('plot_vbp_ci_vab_setor_fixo'), height=400,width = 12)),#,background='white')),
                               
                             ),
                           ),
                           fluidRow(
                             box(
                               status = "warning", solidHeader = FALSE, width = 6, collapsible = FALSE,
                               radioButtons(inputId = "tipo_grafico_setor_fixo", label = "Tipo de gráfico", choices = tiposGraficos2, selected = 'linha', inline = TRUE)
                             ),
                             box(
                               status = "warning", solidHeader = FALSE, width = 6, collapsible = FALSE,
                               sliderInput("anos_resultados_setor_fixo", "Escolha o ano:", min=2010, max=ultimo_ano, value=c(2010, ultimo_ano),animate=T),
                               
                             ),
                             
                           )
                  )
                )
              )
      )
    )
    
  ),
  
  
  shinyjs::useShinyjs(),           
  
  
  
  
)