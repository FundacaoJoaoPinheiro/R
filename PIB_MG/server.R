# Define server logic required to draw a histogram



source('global.R')

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  
  #read_excel("H:\\FJP\\scripts\\Anexo-estatistico-PIB-MG-anual-2010-2018.xlsx")
  
  
  
  #desabilita a opção de Participação das atividades no VAB do Brasil caso VAB não seja selecionado
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
  
  #desabilita as opções VBP e CI quando partipação no Brasil é selecionado, opção 2
  observeEvent(input$aspectos_setor_fixo, {
    if(input$aspectos_setor_fixo == "pbr"){
      shinyjs::disable(selector = "#tipo_resultado_2 input[value='VBP']")
      shinyjs::disable(selector = "#tipo_resultado_2 input[value='CI']")
      if(input$tipo_resultado_2 == 'VBP' || input$tipo_resultado_2 == 'CI'){
        updateCheckboxGroupInput(inputId = "tipo_resultado_2", selected = tipoResutados[3])
      }
      
    }
    else{
      shinyjs::enable(selector = "#tipo_resultado_2 input[value='VBP']")
      shinyjs::enable(selector = "#tipo_resultado_2 input[value='CI']")
    }
  })
  
  #faz com que o tipo de gráfico selecionado seja o de linha quando o usuário selecionou o gráfico de barra empilhado ou pizza e escolheu um
  #aspecto que não comporta esse tipo de gráfico
  observeEvent(input$aspectos_aspecto_fixo, {
    if(input$aspectos_aspecto_fixo == "vv" || input$aspectos_aspecto_fixo == "vc" || input$aspectos_aspecto_fixo == "vp" || input$aspectos_aspecto_fixo == "pbr"){
      if(input$tipo_grafico_aspecto_fixo == 'barra_empilhado' || input$tipo_grafico_aspecto_fixo == 'pizza'){
        updateRadioButtons(inputId = "tipo_grafico_aspecto_fixo", selected = tiposGraficos[1])
      }
    }
    
  })
  
  #habilita as opções de gráfico barra empilhado e pizza quando o usuário seleciona participação em minas
  observeEvent(input$aspectos_aspecto_fixo, {
    if(input$aspectos_aspecto_fixo == "vc" || input$aspectos_aspecto_fixo == "vv" || input$aspectos_aspecto_fixo == "vp" || input$aspectos_aspecto_fixo == "pbr"){
      shinyjs::disable(selector = "#tipo_grafico_aspecto_fixo input[value= 'barra_empilhado']")
      shinyjs::disable(selector = "#tipo_grafico_aspecto_fixo input[value= 'pizza']")
    }
    else{
      shinyjs::enable(selector = "#tipo_grafico_aspecto_fixo input[value = 'barra_empilhado']")
      shinyjs::enable(selector = "#tipo_grafico_aspecto_fixo input[value = 'pizza']")
    }
  })
  
  #muda a opção de ano quando o usuário escolhe o gráfico de pizza
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
  
  
  #seleciona o primeiro setor quando o usuário desmarca a opção de selecionar todos
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
      
      #Contas é uma coluna da tabela contas_economicas
      
      h <- highchart() %>% 
        hc_size(width = 600, height = 400) %>%
        hc_xAxis(title = list(text = "Ano"), allowDecimals = FALSE) %>%
        hc_exporting(enabled = T, fallbackToExportServer = F, 
                     menuItems = export)   
      
      
      ds <- lapply(espec_prod, function(x){
        d <- subset(contas_economicas, contas %in% x & (ano >= input$anos_lineplot_prod[1] & ano <= input$anos_lineplot_prod[2]))
        data = data.frame(x = d$ano,
                          y = d$valor)
      })   
      
      
      h <- h %>% hc_yAxis(title = list(text = "Valor a preços correntes (1.000.000 R$) "))  %>%
        hc_title(text = list("Contas da Econômicas - ótica da produção"))
      
      for (k in 1:length(ds)) {
        h <- h %>%
          hc_add_series(ds[[k]], name = espec_prod[k])
      }
      h 
      
    }
    
    
  })
  
  output$comp_prod_renda <- renderHighchart({
    if(input$barra_lateral == 'contas_economicas'){
      h <-highchart() %>% 
        hc_chart(type = "column") %>%
        hc_plotOptions(column = list(stacking = "normal")) %>%
        hc_xAxis(categories = c(input$anos_columplot_prod[1] : input$anos_columplot_prod[2]), title = list(text = "Ano")) %>%
        hc_yAxis(title = list(text = "Valor a preços correntes (1.000.000 R$) ")) %>%
        hc_title(text = list("Composição do PIB - ótica da produção")) %>%
        hc_add_series(name= nomes_producao[1],
                      data = subset(contas_economicas, contas %in% nomes_producao[1] & (ano >= input$anos_columplot_prod[1] & ano <= input$anos_columplot_prod[2]))$valor,
                      stack = "Produção", color = '#800000') %>%
        hc_add_series(name=nomes_producao[2],
                      data = subset(contas_economicas, contas %in% nomes_producao[2] & (ano >= input$anos_columplot_prod[1] & ano <= input$anos_columplot_prod[2]))$valor,
                      stack = "Produção", color = '#FF0000') %>%
        hc_add_series(name=nomes_producao[3],
                      data = subset(contas_economicas, contas %in% nomes_producao[3] & (ano >= input$anos_columplot_prod[1] & ano <= input$anos_columplot_prod[2]))$valor,
                      stack = "PIB_prod", color = '#CD5C5C') %>%
        hc_add_series(name= "PIB produção",
                      data = subset(contas_economicas, contas %in% nomes_producao[4] & (ano >= input$anos_columplot_prod[1] & ano <= input$anos_columplot_prod[2]))$valor,
                      stack = "PIB_prod", color = '#FA8072') %>%
        hc_add_series(name="PIB renda",
                      data = subset(contas_economicas, contas %in% nomes_renda[6] & (ano >= input$anos_columnplot_renda[1] & ano <= input$anos_columnplot_renda[2]))$valor,
                      stack = "PIB_renda", color = '#8A2BE2' ) %>%
        hc_add_series(name= nomes_renda[2],
                      data = subset(contas_economicas, contas %in% nomes_renda[2] & (ano >= input$anos_columnplot_renda[1] & ano <= input$anos_columnplot_renda[2]))$valor,
                      stack = "Salarios", color = '#000080') %>%
        hc_add_series(name= nomes_renda[3],
                      data = subset(contas_economicas, contas %in% nomes_renda[3] & (ano >= input$anos_columnplot_renda[1] & ano <= input$anos_columnplot_renda[2]))$valor,
                      stack = "Salarios", color = '#0000FF') %>%
        hc_add_series(name=nomes_renda[4],
                      data = subset(contas_economicas, contas %in% nomes_renda[4] & (ano >= input$anos_columnplot_renda[1] & ano <= input$anos_columnplot_renda[2]))$valor,
                      stack = "Salarios", color = '#7B68EE') %>%
        hc_add_series(name=nomes_renda[5],
                      data = subset(contas_economicas, contas %in% nomes_renda[5] & (ano >= input$anos_columnplot_renda[1] & ano <= input$anos_columnplot_renda[2]))$valor,
                      stack = "Salarios", color = '#00BFFF') %>%
        hc_tooltip(crosshairs = TRUE, formatter= JS(paste0 ('function () {
                  var string = "";
                  if(this.series.name == "Produção" || this.series.name == "Impostos produtos" || this.series.name == "Consumo Intermediário" || this.series.name == "PIB produção"){
                    string += "<br>Ótica da produção </br>";
                  } 
                  else if(this.series.name == "PIB renda" || this.series.name == "Salários" || this.series.name == "Contribuições" || this.series.name == "Impostos produção" || this.series.name == "Excedente"){
                    string += "<br>Ótica da renda </br>";
                  } 
                  string += this.series.name + ": <b>" + Highcharts.numberFormat(this.y, 1) + " mi R$ </b> em " + this.x
                  
                  return string;
                }'))) %>%
        hc_exporting(
          enabled = TRUE, # always enabled
          filename = "custom-file-name"
        )
      #hc_add_theme(hc_theme_ft())
      h
      
    }
  })
  
  output$piePlot_prod <- renderHighchart({
    if(input$barra_lateral == 'contas_economicas'){
      h <-highchart() %>% 
        hc_chart(type = "column") %>%
        hc_plotOptions(column = list(stacking = "normal")) %>%
        hc_xAxis(categories = c(input$anos_columplot_prod[1] : input$anos_columplot_prod[2]), title = list(text = "Ano")) %>%
        hc_yAxis(title = list(text = "Valor a preços correntes (1.000.000 R$) ")) %>%
        hc_title(text = list("Composição do PIB - ótica da produção")) %>%
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
      
      ds <- lapply(espec_renda, function(x){
        d <- subset(contas_economicas, contas %in% x & (ano >= input$anos_lineplot_renda[1] & ano <= input$anos_lineplot_renda[2]))
        data = data.frame(x = d$ano,
                          y = d$valor)
        
        
      })
      
      h <- highchart() %>% 
        hc_size(width = 600, height = 400) %>%
        hc_yAxis(title = list(text = "Valor a preços correntes (1.000.000 R$) ")) %>%
        hc_title(text = list("Contas da Econômicas - ótica da renda")) %>%
        hc_xAxis(title = list(text = "Ano"), allowDecimals = FALSE) %>%
        hc_exporting(enabled = T, fallbackToExportServer = F, 
                     menuItems = export)   
      for (k in 1:length(ds)) {
        h <- h %>%
          hc_add_series(ds[[k]], name = espec_renda[k])
      }
      h
      
    }
  })
  output$piePlot_renda <- renderHighchart({
    if(input$barra_lateral == 'contas_economicas'){
      h <-highchart() %>% 
        hc_chart(type = "column") %>%
        hc_plotOptions(column = list(stacking = "normal")) %>%
        hc_xAxis(categories = c(input$anos_columnplot_renda[1] : input$anos_columnplot_renda[2]), title = list(text = "Ano")) %>%
        hc_yAxis(title = list(text = "Valor a preços correntes (1.000.000 R$) ")) %>%
        hc_title(text = list("Composição - ótica da renda")) %>%
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
    
    
  })
  
  output$linePlot_pib_percapita2 <- renderHighchart({
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
  })
  
  output$linePlot_pib_percapita3 <- renderHighchart({
    
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
    
    
  })
  
  output$linePlot_pib_percapita4 <- renderHighchart({
    
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
    if(input$tipo_graf_lineplot_pib_percapita == "Linha"){
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
    
    
  })
  
  output$linePlot_pib_percapita5 <- renderHighchart({
    
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
    
    
    if(input$tipo_graf_lineplot_pib_percapita == "Linha"){
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
    
    
  })
  
  output$linePlot_pib_percapita6 <- renderHighchart({
    
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
    
    
    if(input$tipo_graf_lineplot_pib_percapita == "Linha"){
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
    
    
  })
  
  output$linePlot_pib_percapita8 <- renderHighchart({
    
    espec <- c("PIB","PIB per capita", "População")
    ds <- lapply(espec, function(x){
      d <- subset(pib_percapita, especificacao %in% x & (ano >= input$anos_lineplot_pib_percapita8[1] & ano <= input$anos_lineplot_pib_percapita8[2]))
      data = data.frame(x = d$ano,
                        y = d$valor)
      
    })
    
    hc <- highchart()%>%
      hc_xAxis(categories = c(2010: ultimo_ano), title = list(text = "Ano")) %>%
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
                 table = TRUE) %>%
      hc_exporting(enabled = T, fallbackToExportServer = F, 
                   menuItems = export) 
    hc
    
  })
  
  ## Resultados -----------------------------------------------------------------------------    
  
  
  
  
  output$plot_vbp_ci_vab_aspecto_fixo <- renderHighchart({
    
    anos <- c(input$anos_resultados_aspecto_fixo[1], input$anos_resultados_aspecto_fixo[2])
    
    h <- highchart() %>%
      hc_exporting(enabled = T, fallbackToExportServer = F, menuItems = export) %>%
      hc_xAxis(title = list(text = "Ano"), allowDecimals = FALSE)
    
    if(input$tipo_resultado == 'VBP'){
      
      h <- h %>%
        hc_title(text = list("Valor Bruto da Produção - MG")) %>%
        hc_tooltip(crosshairs = TRUE,
                   borderWidth = 5,
                   sort = FALSE,
                   table = TRUE, 
                   headerFormat = 'Ano: {point.x}<br>',
                   pointFormat = "{series.name}: {point.y:.1f} mi R$ <br>")
      
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
            h <- h %>% hc_yAxis(title = list(text = "Variação em volume (%)")) %>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
          }
          else if(input$aspectos_aspecto_fixo == "vp"){
            ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
              d <- subset(vbp, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
              data = data.frame(x = d$ano,
                                y = d$var_preco)
              
            })
            h <- h %>% hc_yAxis(title = list(text = "Variação de preço (%)")) %>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
            
          }
          else if(input$aspectos_aspecto_fixo == "pmg"){
            ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
              d <- subset(vbp, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
              data = data.frame(x = d$ano,
                                y = d$particip)
              
            })
            
            
            h <- h %>% hc_yAxis(title = list(text = "Part. das atividades no Valor Bruto da Produção (%)")) %>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
            
          }
          
          if(input$tipo_grafico_aspecto_fixo == "barra_empilhado"){
            ds2 <- subset(vbp[c(1,2, 6)], (ano >= anos[1] & ano <= anos[2]) & !(setor %in% input$spec_setores_aspecto_fixo) & !(setor %in% c("Agropecuária", "Indústria", "Serviços")))
            ds2 <- ds2 %>% 
              group_by(ano) %>% 
              summarise(particip = sum(particip)) 
            names(ds2) <- c('x', 'y')
            
            
            for (k in 1:length(ds)) {
              h <- h %>%  
                hc_add_series(data = ds[[k]], name = input$spec_setores_aspecto_fixo[k], stack = "Valor") #, dataLabels = list(enabled = TRUE,
              #                 format = '{point.name}: {point.percentage:.1f} %'))
            }
            h <- h %>%hc_plotOptions(column = list(stacking = "normal"))
            
            
            if(!setequal(input$spec_setores_aspecto_fixo, setor)){ #verifica se todas as opções estão selecionadas
              h <- h %>% hc_add_series(data = ds2, name = "Outros", stack = "Valor")
              
            }
            
            
            
            
          }
          else if(input$tipo_grafico_aspecto_fixo == "pizza"){
            
            ano_pie_chart <-  input$anos_resultados_aspecto_fixo_pizza
            
            if(!setequal(input$spec_setores_aspecto_fixo, setor)){ #verifica se todas as opções estão selecionadas
              d <- subset(vbp[c(1,2, 6)], !(setor %in% c("Agropecuária", "Indústria", "Serviços")) & ano %in% ano_pie_chart & !(setor %in% input$spec_setores_aspecto_fixo))
              demais <- sum(d$particip )
              labels_pi_chart <- c(input$spec_setores_aspecto_fixo, "Outros")
              valores_pi_chart <- c(subset(vbp[c(1, 2, 6)], setor %in% input$spec_setores_aspecto_fixo & ano %in% ano_pie_chart)$particip, demais)
            }
            else{
              d <- subset(vbp[c(1,2, 6)], !(setor %in% c("Agropecuária", "Indústria", "Serviços")) & ano %in% ano_pie_chart & !(setor %in% input$spec_setores_aspecto_fixo))
              labels_pi_chart <- c(input$spec_setores_aspecto_fixo)
              valores_pi_chart <- c(subset(vbp[c(1, 2, 6)], setor %in% input$spec_setores_aspecto_fixo & ano %in% ano_pie_chart)$particip)
            }
            
            
            h <- h %>% 
              hc_chart(type = "pie") %>% 
              hc_subtitle(text = (paste("Part. das atividades no Valor Bruto da Produção - ", toString(ano_pie_chart)))) %>%
              myhc_add_series_labels_values(labels = labels_pi_chart, values = valores_pi_chart, text = labels_pi_chart, 
                                            dataLabels = list(enabled = TRUE,
                                                              format = '{point.name}: {point.percentage:.1f} %'))%>%
              hc_tooltip(pointFormat = "{point.name}: {point.y:.1f} % <br>")
            
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
            h <- h %>% hc_yAxis(title = list(text = "Valor corrente (1.000.000 R$)")) %>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} mi R$ <br>")
            
            
          }
          if(input$aspectos_aspecto_fixo == "vv"){
            ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
              d <- subset(vbp, setor %in% x & (ano >= 2011 & ano <= ultimo_ano))
              data = data.frame(x = d$ano,
                                y = d$var_volume)
              
            }) 
            h <- h %>% hc_yAxis(title = list(text = "Variação em volume (%)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
          }
          if(input$aspectos_aspecto_fixo == "vp"){
            ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
              d <- subset(vbp, setor %in% x & (ano >= 2011 & ano <= ultimo_ano))
              data = data.frame(x = d$ano,
                                y = d$var_preco)
              
            })
            h <- h %>% hc_yAxis(title = list(text = "Variação de preço (%)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
            
          }
          if(input$aspectos_aspecto_fixo == "pmg"){
            ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
              d <- subset(vbp, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
              data = data.frame(x = d$ano,
                                y = d$particip)
              
            }) 
            h <- h %>% hc_yAxis(title = list(text = "Part. das atividades no Valor Bruto da Produção (%)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
            
            
          }
          
          if(input$tipo_grafico_aspecto_fixo == "barra_empilhado"){
            ds2 <- subset(vbp[c(1,2, 6)], (ano >= anos[1] & ano <= anos[2]) & !(setor %in% input$spec_areas_aspecto_fixo) & (setor %in% c("Agropecuária", "Indústria", "Serviços")))
            ds2 <- ds2 %>% 
              group_by(ano) %>% 
              summarise(particip = sum(particip)) 
            names(ds2) <- c('x', 'y')
            
            
            for (k in 1:length(ds)) {
              h <- h %>%    
                hc_add_series(data = ds[[k]], name = input$spec_areas_aspecto_fixo[k], stack = "Valor")
            }
            h <- h %>%hc_plotOptions(column = list(stacking = "normal"))
            
            if(!setequal(input$spec_areas_aspecto_fixo, area)){ #verifica se todas as opções estão selecionadas
              h <- h %>% hc_add_series(data = ds2, name = "Outros", stack = "Valor")
            }
            
          }
          else if(input$tipo_grafico_aspecto_fixo == "pizza"){
            
            ano_pie_chart <-  input$anos_resultados_aspecto_fixo_pizza
            
            if(!setequal(input$spec_areas_aspecto_fixo, area)){ #verifica se todas as opções estão selecionadas
              d <- subset(vbp[c(1,2, 6)], (setor %in% c("Agropecuária", "Indústria", "Serviços")) & ano %in% ano_pie_chart & !(setor %in% input$spec_areas_aspecto_fixo))
              demais <- sum(d$particip )
              labels_pi_chart <- c(input$spec_areas_aspecto_fixo, "Outros")
              valores_pi_chart <- c(subset(vbp[c(1, 2, 6)], setor %in% input$spec_areas_aspecto_fixo & ano %in% ano_pie_chart)$particip, demais)
            }
            else{
              d <- subset(vbp[c(1,2, 6)], (setor %in% c("Agropecuária", "Indústria", "Serviços")) & ano %in% ano_pie_chart & !(setor %in% input$spec_areas_aspecto_fixo))
              labels_pi_chart <- c(input$spec_areas_aspecto_fixo)
              valores_pi_chart <- c(subset(vbp[c(1, 2, 6)], setor %in% input$spec_areas_aspecto_fixo & ano %in% ano_pie_chart)$particip)
            }
            
            h <- h %>% 
              hc_chart(type = "pie") %>% 
              hc_subtitle(text = (paste("Part. das atividades no Valor Bruto da Produção - ", toString(ano_pie_chart)))) %>%
              myhc_add_series_labels_values(labels = labels_pi_chart, values = valores_pi_chart, text = labels_pi_chart, 
                                            dataLabels = list(enabled = TRUE,
                                                              format = '{point.name}: {point.percentage:.1f} %'))%>%
              hc_tooltip(pointFormat = "{point.name}: {point.y:.1f} % <br>")
            
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
        hc_title(text = list("Consumo Intermediário - MG")) %>%
        hc_tooltip(crosshairs = TRUE,
                   borderWidth = 5,
                   sort = FALSE,
                   table = TRUE, 
                   headerFormat = 'Ano: {point.x}<br>',
                   pointFormat = "{series.name}: {point.y:.1f} mi R$ <br>")
      
      if(input$tipo_grafico_aspecto_fixo == "barra" || input$tipo_grafico_aspecto_fixo == "barra_empilhado"){
        h <- h %>% hc_chart(type = "column")
      }
      
      if(input$area_ou_setor_aspecto_fixo == "Setores"){
        if(!is_empty(input$spec_setores_aspecto_fixo)){
          if(input$aspectos_aspecto_fixo == 'vc'){
            ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
              d <- subset(ci, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
              data = data.frame(x = d$ano,
                                y = d$corrente)
              
            }) 
            h <- h %>% hc_yAxis(title = list(text = "Valor corrente (1.000.000 R$)"))
          }
          else if(input$aspectos_aspecto_fixo == "vv"){
            ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
              d <- subset(ci, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
              data = data.frame(x = d$ano,
                                y = d$var_volume)
              
            }) 
            h <- h %>% hc_yAxis(title = list(text = "Variação em volume (%)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
          }
          else if(input$aspectos_aspecto_fixo == "vp"){
            ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
              d <- subset(ci, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
              data = data.frame(x = d$ano,
                                y = d$var_preco)
              
            })
            h <- h %>% hc_yAxis(title = list(text = "Variação de preço (%)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
            
          }
          else if(input$aspectos_aspecto_fixo == "pmg"){
            ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
              d <- subset(ci, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
              data = data.frame(x = d$ano,
                                y = d$particip)
              
            })
            
            
            h <- h %>% hc_yAxis(title = list(text = "Part. das atividades no Consumo Intermediário (%)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
            
          }
          
          if(input$tipo_grafico_aspecto_fixo == "barra_empilhado"){
            ds2 <- subset(ci[c(1,2, 6)], (ano >= anos[1] & ano <= anos[2]) & !(setor %in% input$spec_setores_aspecto_fixo) & !(setor %in% c("Agropecuária", "Indústria", "Serviços")))
            ds2 <- ds2 %>% 
              group_by(ano) %>% 
              summarise(particip = sum(particip)) 
            names(ds2) <- c('x', 'y')
            
            
            for (k in 1:length(ds)) {
              h <- h %>%  
                hc_add_series(data = ds[[k]], name = input$spec_setores_aspecto_fixo[k], stack = "Valor") #, dataLabels = list(enabled = TRUE,
              #                 format = '{point.name}: {point.percentage:.1f} %'))
            }
            h <- h %>%hc_plotOptions(column = list(stacking = "normal"))
            
            if(!setequal(input$spec_setores_aspecto_fixo, setor)){ #verifica se todas as opções estão selecionadas
              h <- h %>% hc_add_series(data = ds2, name = "Outros", stack = "Valor")
              
            }
            
            
            
            
          }
          else if(input$tipo_grafico_aspecto_fixo == "pizza"){
            
            ano_pie_chart <-  input$anos_resultados_aspecto_fixo_pizza
            
            if(!setequal(input$spec_setores_aspecto_fixo, setor)){ #verifica se todas as opções estão selecionadas
              d <- subset(ci[c(1,2, 6)], !(setor %in% c("Agropecuária", "Indústria", "Serviços")) & ano %in% ano_pie_chart & !(setor %in% input$spec_setores_aspecto_fixo))
              demais <- sum(d$particip )
              labels_pi_chart <- c(input$spec_setores_aspecto_fixo, "Outros")
              valores_pi_chart <- c(subset(ci[c(1, 2, 6)], setor %in% input$spec_setores_aspecto_fixo & ano %in% ano_pie_chart)$particip, demais)
            }
            else{
              d <- subset(ci[c(1,2, 6)], !(setor %in% c("Agropecuária", "Indústria", "Serviços")) & ano %in% ano_pie_chart & !(setor %in% input$spec_setores_aspecto_fixo))
              labels_pi_chart <- c(input$spec_setores_aspecto_fixo)
              valores_pi_chart <- c(subset(ci[c(1, 2, 6)], setor %in% input$spec_setores_aspecto_fixo & ano %in% ano_pie_chart)$particip)
            }
            
            
            h <- h %>% 
              hc_chart(type = "pie") %>% 
              hc_subtitle(text = (paste("Part. das atividades no Consumo Intermediário - ", toString(ano_pie_chart)))) %>%
              myhc_add_series_labels_values(labels = labels_pi_chart, values = valores_pi_chart, text = labels_pi_chart, 
                                            dataLabels = list(enabled = TRUE,
                                                              format = '{point.name}: {point.percentage:.1f} %'))%>%
              hc_tooltip(pointFormat = "{point.name}: {point.y:.1f} % <br>")
            
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
              d <- subset(ci, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
              data = data.frame(x = d$ano,
                                y = d$corrente)
              
            }) 
            h <- h %>% hc_yAxis(title = list(text = "Valor corrente (1.000.000 R$)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} mi R$ <br>")
            
            
          }
          if(input$aspectos_aspecto_fixo == "vv"){
            ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
              d <- subset(ci, setor %in% x & (ano >= 2011 & ano <= ultimo_ano))
              data = data.frame(x = d$ano,
                                y = d$var_volume)
              
            }) 
            h <- h %>% hc_yAxis(title = list(text = "Variação em volume (%)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
          }
          if(input$aspectos_aspecto_fixo == "vp"){
            ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
              d <- subset(ci, setor %in% x & (ano >= 2011 & ano <= ultimo_ano))
              data = data.frame(x = d$ano,
                                y = d$var_preco)
              
            })
            h <- h %>% hc_yAxis(title = list(text = "Variação de preço (%)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
            
          }
          if(input$aspectos_aspecto_fixo == "pmg"){
            ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
              d <- subset(ci, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
              data = data.frame(x = d$ano,
                                y = d$particip)
              
            }) 
            h <- h %>% hc_yAxis(title = list(text = "Part. das atividades no Consumo Intermediário (%)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
            
          }
          
          if(input$tipo_grafico_aspecto_fixo == "barra_empilhado"){
            ds2 <- subset(ci[c(1,2, 6)], (ano >= anos[1] & ano <= anos[2]) & !(setor %in% input$spec_areas_aspecto_fixo) & (setor %in% c("Agropecuária", "Indústria", "Serviços")))
            ds2 <- ds2 %>% 
              group_by(ano) %>% 
              summarise(particip = sum(particip)) 
            names(ds2) <- c('x', 'y')
            
            
            for (k in 1:length(ds)) {
              h <- h %>%    
                hc_add_series(data = ds[[k]], name = input$spec_areas_aspecto_fixo[k], stack = "Valor")
            }
            h <- h %>%hc_plotOptions(column = list(stacking = "normal"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
            
            if(!setequal(input$spec_areas_aspecto_fixo, area)){ #verifica se todas as opções estão selecionadas
              h <- h %>% hc_add_series(data = ds2, name = "Outros", stack = "Valor")
            }
            
          }
          else if(input$tipo_grafico_aspecto_fixo == "pizza"){
            
            ano_pie_chart <-  input$anos_resultados_aspecto_fixo_pizza
            
            if(!setequal(input$spec_areas_aspecto_fixo, area)){ #verifica se todas as opções estão selecionadas
              d <- subset(ci[c(1,2, 6)], (setor %in% c("Agropecuária", "Indústria", "Serviços")) & ano %in% ano_pie_chart & !(setor %in% input$spec_areas_aspecto_fixo))
              demais <- sum(d$particip )
              labels_pi_chart <- c(input$spec_areas_aspecto_fixo, "Outros")
              valores_pi_chart <- c(subset(ci[c(1, 2, 6)], setor %in% input$spec_areas_aspecto_fixo & ano %in% ano_pie_chart)$particip, demais)
            }
            else{
              d <- subset(ci[c(1,2, 6)], (setor %in% c("Agropecuária", "Indústria", "Serviços")) & ano %in% ano_pie_chart & !(setor %in% input$spec_areas_aspecto_fixo))
              labels_pi_chart <- c(input$spec_areas_aspecto_fixo)
              valores_pi_chart <- c(subset(ci[c(1, 2, 6)], setor %in% input$spec_areas_aspecto_fixo & ano %in% ano_pie_chart)$particip)
            }
            
            h <- h %>% 
              hc_chart(type = "pie") %>% 
              hc_subtitle(text = (paste("Part. das atividades no Consumo Intermediário - ", toString(ano_pie_chart)))) %>%
              myhc_add_series_labels_values(labels = labels_pi_chart, values = valores_pi_chart, text = labels_pi_chart, 
                                            dataLabels = list(enabled = TRUE,
                                                              format = '{point.name}: {point.percentage:.1f} %'))%>%
              hc_tooltip(pointFormat = "{point.name}: {point.y:.1f} % <br>")
            
            
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
    else if(input$tipo_resultado == 'VAB'){
      
      
      h <- h %>%
        hc_title(text = list("Valor Adicionado Bruto - MG")) %>%
        hc_tooltip(crosshairs = TRUE,
                   borderWidth = 5,
                   sort = FALSE,
                   table = TRUE, 
                   headerFormat = 'Ano: {point.x}<br>',
                   pointFormat = "{series.name}: {point.y:.1f} % <br>")
      if(input$tipo_grafico_aspecto_fixo == "barra" || input$tipo_grafico_aspecto_fixo == "barra_empilhado"){
        h <- h %>% hc_chart(type = "column")
      }
      
      if(input$area_ou_setor_aspecto_fixo == "Setores"){
        if(!is_empty(input$spec_setores_aspecto_fixo)){
          if(input$aspectos_aspecto_fixo == 'vc'){
            ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
              d <- subset(vab, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
              data = data.frame(x = d$ano,
                                y = d$corrente)
              
            }) 
            h <- h %>% hc_yAxis(title = list(text = "Valor corrente (1.000.000 R$)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} mi R$ <br>")
          }
          if(input$aspectos_aspecto_fixo == "vv"){
            ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
              d <- subset(vab, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
              data = data.frame(x = d$ano,
                                y = d$var_volume)
              
            }) 
            h <- h %>% hc_yAxis(title = list(text = "Variação em volume (%)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
          }
          if(input$aspectos_aspecto_fixo == "vp"){
            ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
              d <- subset(vab, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
              data = data.frame(x = d$ano,
                                y = d$var_preco)
              
            })
            h <- h %>% hc_yAxis(title = list(text = "Variação de preço (%)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
            
          }
          if(input$aspectos_aspecto_fixo == "pmg"){
            ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
              d <- subset(vab, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
              data = data.frame(x = d$ano,
                                y = d$particip)
              
            })
            
            
            h <- h %>% hc_yAxis(title = list(text = "Part. das atividades no Valor Adicionado Bruto (%)"))
            
            if(input$tipo_grafico_aspecto_fixo == "barra_empilhado"){
              ds2 <- subset(vab[c(1,2, 6)], (ano >= anos[1] & ano <= anos[2]) & !(setor %in% input$spec_setores_aspecto_fixo) & !(setor %in% c("Agropecuária", "Indústria", "Serviços")))
              ds2 <- ds2 %>% 
                group_by(ano) %>% 
                summarise(particip = sum(particip)) 
              names(ds2) <- c('x', 'y')
              
              
              for (k in 1:length(ds)) {
                h <- h %>%  
                  hc_add_series(data = ds[[k]], name = input$spec_setores_aspecto_fixo[k], stack = "Valor") #, dataLabels = list(enabled = TRUE,
                #                 format = '{point.name}: {point.percentage:.1f} %'))
              }
              h <- h %>%hc_plotOptions(column = list(stacking = "normal"))%>%
                hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
              
              if(!setequal(input$spec_setores_aspecto_fixo, setor)){ #verifica se todas as opções estão selecionadas
                h <- h %>% hc_add_series(data = ds2, name = "Outros", stack = "Valor")
                
              }
              
              
              
              
            }
            else if(input$tipo_grafico_aspecto_fixo == "pizza"){
              
              ano_pie_chart <-  input$anos_resultados_aspecto_fixo_pizza
              
              if(!setequal(input$spec_setores_aspecto_fixo, setor)){ #verifica se todas as opções estão selecionadas
                d <- subset(vab[c(1,2, 6)], !(setor %in% c("Agropecuária", "Indústria", "Serviços")) & ano %in% ano_pie_chart & !(setor %in% input$spec_setores_aspecto_fixo))
                demais <- sum(d$particip )
                labels_pi_chart <- c(input$spec_setores_aspecto_fixo, "Outros")
                valores_pi_chart <- c(subset(vab[c(1, 2, 6)], setor %in% input$spec_setores_aspecto_fixo & ano %in% ano_pie_chart)$particip, demais)
              }
              else{
                d <- subset(vab[c(1,2, 6)], !(setor %in% c("Agropecuária", "Indústria", "Serviços")) & ano %in% ano_pie_chart & !(setor %in% input$spec_setores_aspecto_fixo))
                labels_pi_chart <- c(input$spec_setores_aspecto_fixo)
                valores_pi_chart <- c(subset(vab[c(1, 2, 6)], setor %in% input$spec_setores_aspecto_fixo & ano %in% ano_pie_chart)$particip)
              }
              
              
              h <- h %>% 
                hc_chart(type = "pie") %>% 
                hc_subtitle(text = (paste("Part. das atividades no Consumo Intermediário - ", toString(ano_pie_chart)))) %>%
                myhc_add_series_labels_values(labels = labels_pi_chart, values = valores_pi_chart, text = labels_pi_chart, 
                                              dataLabels = list(enabled = TRUE,
                                                                format = '{point.name}: {point.percentage:.1f} %'))%>%
                hc_tooltip(pointFormat = "{point.name}: {point.y:.1f} % <br>")
              
            }
            
          }
          if(input$aspectos_aspecto_fixo == "pbr"){
            ds <- lapply(input$spec_setores_aspecto_fixo, function(x){
              d <- subset(vab, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
              data = data.frame(x = d$ano,
                                y = d$particip_br)
              
            })
            h <- h %>% hc_yAxis(title = list(text = "Participação no Valor Adicionado Bruto do Brasil (%)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
            
            
          }
          
          if(!(input$tipo_grafico_aspecto_fixo == "barra_empilhado") && !(input$tipo_grafico_aspecto_fixo == "pizza")){
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
              d <- subset(vab, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
              data = data.frame(x = d$ano,
                                y = d$corrente)
              
            }) 
            h <- h %>% hc_yAxis(title = list(text = "Valor corrente (1.000.000 R$)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} mi R$ <br>")
            
            
          }
          if(input$aspectos_aspecto_fixo == "vv"){
            ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
              d <- subset(vab, setor %in% x & (ano >= 2011 & ano <= ultimo_ano))
              data = data.frame(x = d$ano,
                                y = d$var_volume)
              
            }) 
            h <- h %>% hc_yAxis(title = list(text = "Variação em volume (%)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
          }
          if(input$aspectos_aspecto_fixo == "vp"){
            ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
              d <- subset(vab, setor %in% x & (ano >= 2011 & ano <= ultimo_ano))
              data = data.frame(x = d$ano,
                                y = d$var_preco)
              
            })
            h <- h %>% hc_yAxis(title = list(text = "Variação de preço (%)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
            
          }
          if(input$aspectos_aspecto_fixo == "pmg"){
            ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
              d <- subset(vab, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
              data = data.frame(x = d$ano,
                                y = d$particip)
              
            }) 
            h <- h %>% hc_yAxis(title = list(text = "Part. das atividades no Valor Adicionado Bruto (%)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
            
          }
          
          if(input$tipo_grafico_aspecto_fixo == "barra_empilhado"){
            ds2 <- subset(vab[c(1,2, 6)], (ano >= anos[1] & ano <= anos[2]) & !(setor %in% input$spec_areas_aspecto_fixo) & (setor %in% c("Agropecuária", "Indústria", "Serviços")))
            ds2 <- ds2 %>% 
              group_by(ano) %>% 
              summarise(particip = sum(particip)) 
            names(ds2) <- c('x', 'y')
            
            
            for (k in 1:length(ds)) {
              h <- h %>%    
                hc_add_series(data = ds[[k]], name = input$spec_areas_aspecto_fixo[k], stack = "Valor")
            }
            h <- h %>%hc_plotOptions(column = list(stacking = "normal"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
            
            if(!setequal(input$spec_areas_aspecto_fixo, area)){ #verifica se todas as opções estão selecionadas
              h <- h %>% hc_add_series(data = ds2, name = "Outros", stack = "Valor")
            }
            
          }
          else if(input$tipo_grafico_aspecto_fixo == "pizza"){
            
            ano_pie_chart <-  input$anos_resultados_aspecto_fixo_pizza
            
            if(!setequal(input$spec_areas_aspecto_fixo, area)){ #verifica se todas as opções estão selecionadas
              d <- subset(vab[c(1,2, 6)], (setor %in% c("Agropecuária", "Indústria", "Serviços")) & ano %in% ano_pie_chart & !(setor %in% input$spec_areas_aspecto_fixo))
              demais <- sum(d$particip )
              labels_pi_chart <- c(input$spec_areas_aspecto_fixo, "Outros")
              valores_pi_chart <- c(subset(vab[c(1, 2, 6)], setor %in% input$spec_areas_aspecto_fixo & ano %in% ano_pie_chart)$particip, demais)
            }
            else{
              d <- subset(vab[c(1,2, 6)], (setor %in% c("Agropecuária", "Indústria", "Serviços")) & ano %in% ano_pie_chart & !(setor %in% input$spec_areas_aspecto_fixo))
              labels_pi_chart <- c(input$spec_areas_aspecto_fixo)
              valores_pi_chart <- c(subset(vab[c(1, 2, 6)], setor %in% input$spec_areas_aspecto_fixo & ano %in% ano_pie_chart)$particip)
            }
            
            h <- h %>% 
              hc_chart(type = "pie") %>% 
              hc_subtitle(text = (paste("Part. das atividades no Valor Adicionado Bruto - ", toString(ano_pie_chart)))) %>%
              myhc_add_series_labels_values(labels = labels_pi_chart, values = valores_pi_chart, text = labels_pi_chart, 
                                            dataLabels = list(enabled = TRUE,
                                                              format = '{point.name}: {point.percentage:.1f} %'))%>%
              hc_tooltip(pointFormat = "{point.name}: {point.y:.1f} % <br>")
            
          }
          if(input$aspectos_aspecto_fixo == "pbr"){
            ds <- lapply(input$spec_areas_aspecto_fixo, function(x){
              d <- subset(vab, setor %in% x & (ano >= anos[1] & ano <= anos[2]))
              data = data.frame(x = d$ano,
                                y = d$particip_br)
              
            })
            h <- h %>% hc_yAxis(title = list(text = "Participação no Valor Adicionado Bruto do Brasil (%)"))%>%
              hc_tooltip(pointFormat = "{series.name}: {point.y:.1f} % <br>")
            
            
          }
          
          if(!(input$tipo_grafico_aspecto_fixo == "barra_empilhado") && !(input$tipo_grafico_aspecto_fixo == "pizza")){
            for (k in 1:length(ds)) {
              h <- h %>%
                hc_add_series(ds[[k]], name = input$spec_areas_aspecto_fixo[k])
            }
          }
          
          
        }
      }
      h 
      
      
      
    }
  })
  
  output$plot_vbp_ci_vab_setor_fixo <- renderHighchart({
    
    anos <- c(input$anos_resultados_setor_fixo[1], input$anos_resultados_setor_fixo[2])
    
    h <- highchart() %>%
      hc_exporting(enabled = T, fallbackToExportServer = F, menuItems = export) %>%
      hc_xAxis(title = list(text = "Ano"), allowDecimals = FALSE)
    
    if(input$aspectos_setor_fixo == 'vc'){
      
      h <- h %>%
        hc_title(text = list("Valor Corrente - MG")) %>%
        hc_yAxis(title = list(text = "Valor corrente (1.000.000 R$)")) %>%
        hc_tooltip(crosshairs = TRUE,
                   borderWidth = 5,
                   sort = FALSE,
                   table = TRUE, 
                   headerFormat = 'Ano: {point.x}<br>',
                   pointFormat = "{series.name}: {point.y:.1f} mi R$ <br>")
      
      if(input$tipo_grafico_setor_fixo == "barra"){
        h <- h %>% hc_chart(type = "column")
      }
      
      if(input$area_ou_setor_setor_fixo == "Setores"){
        if(!is_empty(input$tipo_resultado_2)){
          ds <- lapply(input$tipo_resultado_2, function(x){
            d <- subset(valor_corrente, setor %in% input$spec_setores_setor_fixo & resultado %in% x & (ano >= anos[1] & ano <= anos[2]))
            data = data.frame(x = d$ano,
                              y = d$valor)
            
          })
          
          for (k in 1:length(ds)) {
            h <- h %>%
              hc_add_series(ds[[k]], name = input$tipo_resultado_2[k])
          } 
          h <- h %>% hc_subtitle(text = input$spec_setores_setor_fixo)
        }
      }
      else{
        if(!is_empty(input$tipo_resultado_2)){
          ds <- lapply(input$tipo_resultado_2, function(x){
            d <- subset(valor_corrente, setor %in% input$spec_areas_setor_fixo & resultado %in% x & (ano >= anos[1] & ano <= anos[2]))
            data = data.frame(x = d$ano,
                              y = d$valor)
            
          })
          for (k in 1:length(ds)) {
            h <- h %>%
              hc_add_series(ds[[k]], name = input$tipo_resultado_2[k])
            
          }
          h <- h %>% hc_subtitle(text = input$spec_areas_setor_fixo)
          
        }
      }
      
      h
    }
    else if(input$aspectos_setor_fixo == 'vv'){
      
      h <- h %>%
        hc_title(text = list("Variação de Volume - MG")) %>%
        hc_yAxis(title = list(text = "Variação Volume (%)")) %>%
        hc_tooltip(crosshairs = TRUE,
                   borderWidth = 5,
                   sort = FALSE,
                   table = TRUE, 
                   headerFormat = 'Ano: {point.x}<br>',
                   pointFormat = "{series.name}: {point.y:.1f} mi R$ <br>")
      
      if(input$tipo_grafico_setor_fixo == "barra"){
        h <- h %>% hc_chart(type = "column")
      }
      
      if(input$area_ou_setor_setor_fixo == "Setores"){
        if(!is_empty(input$tipo_resultado_2)){
          ds <- lapply(input$tipo_resultado_2, function(x){
            d <- subset(var_volume, setor %in% input$spec_setores_setor_fixo & resultado %in% x & (ano >= anos[1] & ano <= anos[2]))
            data = data.frame(x = d$ano,
                              y = d$valor)
            
          })
          
          for (k in 1:length(ds)) {
            h <- h %>%
              hc_add_series(ds[[k]], name = input$tipo_resultado_2[k])
          } 
          h <- h %>% hc_subtitle(text = input$spec_setores_setor_fixo)
        }
      }
      else{
        if(!is_empty(input$tipo_resultado_2)){
          ds <- lapply(input$tipo_resultado_2, function(x){
            d <- subset(var_volume, setor %in% input$spec_areas_setor_fixo & resultado %in% x & (ano >= anos[1] & ano <= anos[2]))
            data = data.frame(x = d$ano,
                              y = d$valor)
            
          })
          for (k in 1:length(ds)) {
            h <- h %>%
              hc_add_series(ds[[k]], name = input$tipo_resultado_2[k])
            
          }
          h <- h %>% hc_subtitle(text = input$spec_areas_setor_fixo)
          
        }
      }
      
      h 
    }
    else if(input$aspectos_setor_fixo == 'vp'){
      
      h <- h %>%
        hc_title(text = list("Variação de Preço - MG")) %>%
        hc_yAxis(title = list(text = "Variação Preço (%)")) %>%
        hc_tooltip(crosshairs = TRUE,
                   borderWidth = 5,
                   sort = FALSE,
                   table = TRUE, 
                   headerFormat = 'Ano: {point.x}<br>',
                   pointFormat = "{series.name}: {point.y:.1f} mi R$ <br>")
      
      if(input$tipo_grafico_setor_fixo == "barra"){
        h <- h %>% hc_chart(type = "column")
      }
      
      if(input$area_ou_setor_setor_fixo == "Setores"){
        if(!is_empty(input$tipo_resultado_2)){
          ds <- lapply(input$tipo_resultado_2, function(x){
            d <- subset(var_preco, setor %in% input$spec_setores_setor_fixo & resultado %in% x & (ano >= anos[1] & ano <= anos[2]))
            data = data.frame(x = d$ano,
                              y = d$valor)
            
          })
          
          for (k in 1:length(ds)) {
            h <- h %>%
              hc_add_series(ds[[k]], name = input$tipo_resultado_2[k])
          } 
          h <- h %>% hc_subtitle(text = input$spec_setores_setor_fixo)
        }
      }
      else{
        if(!is_empty(input$tipo_resultado_2)){
          ds <- lapply(input$tipo_resultado_2, function(x){
            d <- subset(var_preco, setor %in% input$spec_areas_setor_fixo & resultado %in% x & (ano >= anos[1] & ano <= anos[2]))
            data = data.frame(x = d$ano,
                              y = d$valor)
            
          })
          for (k in 1:length(ds)) {
            h <- h %>%
              hc_add_series(ds[[k]], name = input$tipo_resultado_2[k])
            
          }
          h <- h %>% hc_subtitle(text = input$spec_areas_setor_fixo)
          
        }
      }
      
      h 
      
      
    }
    else if(input$aspectos_setor_fixo == 'pmg'){
      
      h <- h %>%
        hc_title(text = list("Participação do Valor Corrente - MG")) %>%
        hc_yAxis(title = list(text = "Participação (%)")) %>%
        hc_tooltip(crosshairs = TRUE,
                   borderWidth = 5,
                   sort = FALSE,
                   table = TRUE, 
                   headerFormat = 'Ano: {point.x}<br>',
                   pointFormat = "{series.name}: {point.y:.1f} mi R$ <br>")
      
      if(input$tipo_grafico_setor_fixo == "barra"){
        h <- h %>% hc_chart(type = "column")
      }
      
      if(input$area_ou_setor_setor_fixo == "Setores"){
        if(!is_empty(input$tipo_resultado_2)){
          ds <- lapply(input$tipo_resultado_2, function(x){
            d <- subset(participacao_mg, setor %in% input$spec_setores_setor_fixo & resultado %in% x & (ano >= anos[1] & ano <= anos[2]))
            data = data.frame(x = d$ano,
                              y = d$valor)
            
          })
          
          for (k in 1:length(ds)) {
            h <- h %>%
              hc_add_series(ds[[k]], name = input$tipo_resultado_2[k])
          } 
          h <- h %>% hc_subtitle(text = input$spec_setores_setor_fixo)
        }
      }
      else{
        if(!is_empty(input$tipo_resultado_2)){
          ds <- lapply(input$tipo_resultado_2, function(x){
            d <- subset(participacao_mg, setor %in% input$spec_areas_setor_fixo & resultado %in% x & (ano >= anos[1] & ano <= anos[2]))
            data = data.frame(x = d$ano,
                              y = d$valor)
            
          })
          for (k in 1:length(ds)) {
            h <- h %>%
              hc_add_series(ds[[k]], name = input$tipo_resultado_2[k])
            
          }
          h <- h %>% hc_subtitle(text = input$spec_areas_setor_fixo)
          
        }
      }
      
      h 
      
      
    }
    else if(input$aspectos_setor_fixo == 'pbr'){
      
      h <- h %>%
        hc_title(text = list("Participação do Valor Corrente - Brasil")) %>%
        hc_yAxis(title = list(text = "Participação (%)")) %>%
        hc_tooltip(crosshairs = TRUE,
                   borderWidth = 5,
                   sort = FALSE,
                   table = TRUE, 
                   headerFormat = 'Ano: {point.x}<br>',
                   pointFormat = "{series.name}: {point.y:.1f} mi R$ <br>")
      
      if(input$tipo_grafico_setor_fixo == "barra"){
        h <- h %>% hc_chart(type = "column")
      }
      
      if(input$area_ou_setor_setor_fixo == "Setores"){
        if(!is_empty(input$tipo_resultado_2)){
          ds <- lapply(input$tipo_resultado_2, function(x){
            d <- subset(participacao_br, setor %in% input$spec_setores_setor_fixo & resultado %in% x & (ano >= anos[1] & ano <= anos[2]))
            data = data.frame(x = d$ano,
                              y = d$valor)
            
          })
          
          for (k in 1:length(ds)) {
            h <- h %>%
              hc_add_series(ds[[k]], name = input$tipo_resultado_2[k])
          } 
          h <- h %>% hc_subtitle(text = input$spec_setores_setor_fixo)
        }
      }
      else{
        if(!is_empty(input$tipo_resultado_2)){
          ds <- lapply(input$tipo_resultado_2, function(x){
            d <- subset(participacao_br, setor %in% input$spec_areas_setor_fixo & resultado %in% x & (ano >= anos[1] & ano <= anos[2]))
            data = data.frame(x = d$ano,
                              y = d$valor)
            
          })
          for (k in 1:length(ds)) {
            h <- h %>%
              hc_add_series(ds[[k]], name = input$tipo_resultado_2[k])
            
          }
          h <- h %>% hc_subtitle(text = input$spec_areas_setor_fixo)
          
        }
      }
      
      h 
      
      
    }
    
  })
  
  
}