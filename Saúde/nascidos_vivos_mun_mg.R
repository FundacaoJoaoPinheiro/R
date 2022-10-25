#' Scrapes general live birth data from  Minas Gerais cities
#'
#' This function allows the user to retrieve data from
#' the live birth database much in the same way that is done
#' by the online portal. The argument options refer to
#' data focused on Minas Gerais cities.
#'
#' 
#' @usage nascidos_vivos_mun_mg <- function(linha = "Munic%EDpio", coluna = "--N%E3o-Ativa--", conteudo = 1, periodo = "last", municipio = "all",
#'         regiao_de_saudecir = "all", divisao_administ_estadual = "all", macrorregiao_de_saude = "all", territorio_desenv_mg = "all", 
#'         ride = "all", mes_nascimento = "all", ano_nascimento = "all", idade_mae = "all", idade_mae_detalhada = "all", 
#'         escolaridade_mae = "all", estado_civil_mae = "all", duracao_gestacao = "all",  tipo_gravidez = "all", tipo_parto = "all",
#'         consulta_pre_natal = "all", apgar_1_minuto = "all", apgar_5_minuto = "all", sexo_RN = "all", cor_raca = "all", peso_ao_nascer = "all",
#'         anomalia_congenita = "all", local_nascimento = "all", estabelecimento_saude = "all") 
#' 
#' @param linha A character describing which element will be displayed in the rows of the data.frame. Defaults to "Município".
#' @param coluna A character describing which element will be displayed in the columns of the data.frame. Defaults to "Não ativa".
#' @param conteudo A character of length = 1 (1 for Frequência). Defaults to 1
#' @param periodo A character vector describing the period of data. Defaults to the last available.
#' @param municipio "all" or a numeric vector with the IBGE's city codes codes to filter the data. Defaults to "all".
#' @param regiao_de_saudecir "all" or a numeric vector with the CIR's codes to filter the data. Defaults to "all".
#' @param divisao_administ_estadual "all" or a numeric vector with the code of the administrative regions to filter the data. Defaults to "all".
#' @param macrorregiao_de_saude "all" or a numeric vector with the Health macro-region's codes to filter the data. Defaults to "all".
#' @param territorio_desenv_mg "all" or a numeric vector with the development territories codes to filter the data. Defaults to "all".
#' @param ride "all" or a numeric vector with the IBGE's metropolitan-region codes to filter the data. Defaults to "all".
#' @param mes_nascimento "all" or a or a character vector with the month of birth (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param ano_nascimento "all" or a character vector with the year of birth (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param idade_mae  "all" or a character vector with the age of the mother (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param idade_mae_detalhada "all" or a character vector with the age of the mother (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param escolaridade_mae "all" or a character vector with the years of instruction (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all". 
#' @param estado_civil_mae "all" or a character vector with the marital status (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param duracao_gestacao "all" or a character vector with the duration of pregnancy in weeks (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param tipo_gravidez "all" or a character vector with the type of pregnancy (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param tipo_parto "all" or a character vector with the type of delivery (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param consulta_pre_natal "all" or a character vector with the number of prenatal appoitments (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param apgar_1_minuto "all" or a character vector with the apgar score at 1 minute (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param apgar_5_minuto "all" or a character vector with the apgar score at 5 minutes (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param sexo_RN "all" or a character vector with the gender of the newborn (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param cor_raca "all" or a character vector with the color/race of the newborn (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param peso_ao_nascer "all" or a character vector with the weigth at birth (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param anomalia_congenita "all" or a character vector with the congenital anomaly  (written in the same way, with the digits and name) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param local_nascimento "all" or a character vector with the place of birth (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param estabelecimento_saude "all" or a character vector with the name of the health establishment (written in the same way, with the digits and name) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#'
#' @return The function returns a data frame printed by parameters input.
#' @authors Gregory Moraes \email{<gregory.moraes@fjp.mg.gov.br>} and Michel Alves \email{<michel.alves@fjp.mg.gov.br>}
#' @seealso \code{\link{sinasc_nv_uf}}
#' @examples
#' \dontrun{
#' ## Requesting data related to white male births in January at all cities in Minas Gerais in 2021
#' mortalidade_geral_mun_mg(periodo = 2021, sexo_RN = "Masculino", raca_cor = "Branca", mes_nascimento="Janeiro")
#' }
#'
#' @keywords SIM datasus
#' @importFrom magrittr |>
#' @importFrom utils head
#' @export


nascidos_vivos_mun_mg <- function(linha = "Munic%EDpio", coluna = "--N%E3o-Ativa--", conteudo = 1, periodo = "last", municipio = "all",
                                  regiao_de_saudecir = "all", divisao_administ_estadual = "all", macrorregiao_de_saude = "all", territorio_desenv_mg = "all", 
                                  ride = "all", mes_nascimento = "all", ano_nascimento = "all", idade_mae = "all", idade_mae_detalhada = "all", 
                                  escolaridade_mae = "all", estado_civil_mae = "all", duracao_gestacao = "all",  tipo_gravidez = "all", tipo_parto = "all",
                                  consulta_pre_natal = "all", apgar_1_minuto = "all", apgar_5_minuto = "all", sexo_RN = "all", cor_raca = "all", peso_ao_nascer = "all",
                                  anomalia_congenita = "all", local_nascimento = "all", estabelecimento_saude = "all") {
  
  
  url <- "http://tabnet.saude.mg.gov.br/tabcgi.exe?def/nasc/nascr.def"
  
  #verifies if the data base is available
  p <- curlGetHeaders(url)
  status <- attr(p, "status")
  if(status == 503){
    stop("A página do DATASUS está fora do ar")
  }
  
  page <- xml2::read_html(url)
  
  #### DF ####
  linha.df <- data.frame(id = page |> rvest::html_nodes("#L option") |> rvest::html_text() |> trimws(),
                         value = page |> rvest::html_nodes("#L option") |> rvest::html_attr("value"))
  linha.df[] <- lapply(linha.df, as.character)
  
  coluna.df <- data.frame(id = page |> rvest::html_nodes("#C option") |> rvest::html_text() |> trimws(),
                          value = page |> rvest::html_nodes("#C option") |> rvest::html_attr("value"))
  coluna.df[] <- lapply(coluna.df, as.character)
  
  conteudo.df <- data.frame(id1 = c(1),
                            id2 = c("Nascimentos_p%2Fresid%EAncia"),
                            value = c("Nascimentos_p%2Fresid%EAncia"))
  
  periodos.df <- data.frame(id = page |> rvest::html_nodes("#A option") |> rvest::html_text() |> as.numeric(),
                            value = page |> rvest::html_nodes("#A option") |> rvest::html_attr("value"))
  
  municipios.df <- suppressWarnings(data.frame(id = page |> rvest::html_nodes("#S1 option") |> rvest::html_text() |> readr::parse_number(),
                                               value = page |> rvest::html_nodes("#S1 option") |> rvest::html_attr("value")))
  
  regiao_de_saudecir.df <- suppressWarnings(data.frame(id = page |> rvest::html_nodes("#S2 option") |> rvest::html_text() |> readr::parse_number(),
                                                       value = page |> rvest::html_nodes("#S2 option") |> rvest::html_attr("value")))
  
  divisao_administ_estadual.df <- suppressWarnings(data.frame(id = page |> rvest::html_nodes("#S3 option") |> rvest::html_text() |> readr::parse_number(),
                                                              value = page |> rvest::html_nodes("#S3 option") |> rvest::html_attr("value")))
  
  macrorregiao_de_saude.df <- suppressWarnings(data.frame(id = page |> rvest::html_nodes("#S4 option") |> rvest::html_text() |> readr::parse_number(),
                                                          value = page |> rvest::html_nodes("#S4 option") |> rvest::html_attr("value")))
  
  territorio_desenv_mg.df <- suppressWarnings(data.frame(id = page |> rvest::html_nodes("#S5 option") |> rvest::html_text() |> readr::parse_number(),
                                                         value = page |> rvest::html_nodes("#S5 option") |> rvest::html_attr("value")))
  
  ride.df <- suppressWarnings(data.frame(id = page |> rvest::html_nodes("#S6 option") |> rvest::html_text() |> readr::parse_number(),
                                         value = page |> rvest::html_nodes("#S6 option") |> rvest::html_attr("value")))
  
  mes_nascimento.df <- data.frame(id = page |> rvest::html_nodes("#S7 option") |> rvest::html_text() |> trimws(),
                                  value = page |> rvest::html_nodes("#S7 option") |> rvest::html_attr("value"))
  mes_nascimento.df[] <- lapply(mes_nascimento.df, as.character)
  
  ano_nascimento.df <- data.frame(id = page |> rvest::html_nodes("#S8 option") |> rvest::html_text() |> trimws(),
                                  value = page |> rvest::html_nodes("#S8 option") |> rvest::html_attr("value"))
  ano_nascimento.df[] <- lapply(ano_nascimento.df, as.character)
  
  idade_mae.df <- data.frame(id = page |> rvest::html_nodes("#S9 option") |> rvest::html_text() |> trimws(),
                             value = page |> rvest::html_nodes("#S9 option") |> rvest::html_attr("value"))
  idade_mae.df[] <- lapply(idade_mae.df, as.character)
  
  idade_mae_detalhada.df <- data.frame(id = page |> rvest::html_nodes("#S10 option") |> rvest::html_text() |> trimws(),
                                       value = page |> rvest::html_nodes("#S10 option") |> rvest::html_attr("value"))
  idade_mae_detalhada.df[] <- lapply(idade_mae_detalhada.df, as.character)
  
  escolaridade_mae.df <- data.frame(id = page |> rvest::html_nodes("#S11 option") |> rvest::html_text() |> trimws(),
                                    value = page |> rvest::html_nodes("#S11 option") |> rvest::html_attr("value"))
  escolaridade_mae.df[] <- lapply(escolaridade_mae.df, as.character)
  
  estado_civil_mae.df <- data.frame(id = page |> rvest::html_nodes("#S12 option") |> rvest::html_text() |> trimws(),
                                    value = page |> rvest::html_nodes("#S12 option") |> rvest::html_attr("value"))
  estado_civil_mae.df[] <- lapply(estado_civil_mae.df, as.character)
  
  duracao_gestacao.df <- data.frame(id = page |> rvest::html_nodes("#S13 option") |> rvest::html_text() |> trimws(),
                                    value = page |> rvest::html_nodes("#S13 option") |> rvest::html_attr("value"))
  duracao_gestacao.df[] <- lapply(duracao_gestacao.df, as.character)
  
  tipo_gravidez.df <- data.frame(id = page |> rvest::html_nodes("#S14 option") |> rvest::html_text() |> trimws(),
                                 value = page |> rvest::html_nodes("#S14 option") |> rvest::html_attr("value"))
  tipo_gravidez.df[] <- lapply(tipo_gravidez.df, as.character)
  
  tipo_parto.df <- data.frame(id = page |> rvest::html_nodes("#S15 option") |> rvest::html_text() |> trimws(),
                              value = page |> rvest::html_nodes("#S15 option") |> rvest::html_attr("value"))
  tipo_parto.df[] <- lapply(tipo_parto.df, as.character)
  
  consulta_pre_natal.df <- data.frame(id = page |> rvest::html_nodes("#S16 option") |> rvest::html_text() |> trimws(),
                                      value = page |> rvest::html_nodes("#S16 option") |> rvest::html_attr("value"))
  consulta_pre_natal.df[] <- lapply(consulta_pre_natal.df, as.character)
  
  apgar_1_minuto.df <- data.frame(id = page |> rvest::html_nodes("#S17 option") |> rvest::html_text() |> trimws(),
                                  value = page |> rvest::html_nodes("#S17 option") |> rvest::html_attr("value"))
  apgar_1_minuto.df[] <- lapply(apgar_1_minuto.df, as.character)
  
  apgar_5_minuto.df <- data.frame(id = page |> rvest::html_nodes("#S18 option") |> rvest::html_text() |> trimws(),
                                  value = page |> rvest::html_nodes("#S18 option") |> rvest::html_attr("value"))
  apgar_5_minuto.df[] <- lapply(apgar_5_minuto.df, as.character)
  
  sexo_RN.df <- data.frame(id = page |> rvest::html_nodes("#S19 option") |> rvest::html_text() |> trimws(),
                           value = page |> rvest::html_nodes("#S19 option") |> rvest::html_attr("value"))
  sexo_RN.df[] <- lapply(sexo_RN.df, as.character)
  
  cor_raca.df <- data.frame(id = page |> rvest::html_nodes("#S20 option") |> rvest::html_text() |> trimws(),
                            value = page |> rvest::html_nodes("#S20 option") |> rvest::html_attr("value"))
  cor_raca.df[] <- lapply(cor_raca.df, as.character)
  
  peso_ao_nascer.df <- data.frame(id = page |> rvest::html_nodes("#S21 option") |> rvest::html_text() |> trimws(),
                                  value = page |> rvest::html_nodes("#S21 option") |> rvest::html_attr("value"))
  peso_ao_nascer.df[] <- lapply(peso_ao_nascer.df, as.character)
  
  anomalia_congenita.df <- data.frame(id = page |> rvest::html_nodes("#S22 option") |> rvest::html_text() |> trimws(),
                                      value = page |> rvest::html_nodes("#S22 option") |> rvest::html_attr("value"))
  anomalia_congenita.df[] <- lapply(anomalia_congenita.df, as.character)
  
  
  local_nascimento.df <- data.frame(id = page |> rvest::html_nodes("#S23 option") |> rvest::html_text() |> trimws(),
                                    value = page |> rvest::html_nodes("#S23 option") |> rvest::html_attr("value"))
  local_nascimento.df[] <- lapply(local_nascimento.df, as.character)
  
  
  
  estabelecimento_saude.df <- data.frame(id = page |> rvest::html_nodes("#S24 option") |> rvest::html_text() |> trimws(),
                                         value = page |> rvest::html_nodes("#S24 option") |> rvest::html_attr("value"))
  estabelecimento_saude.df[] <- lapply(estabelecimento_saude.df, as.character)
  
  
  
  municipios.df$id[1] <- regiao_de_saudecir.df$id[1] <- divisao_administ_estadual.df$id[1] <- macrorregiao_de_saude.df$id[1] <-  territorio_desenv_mg.df$id[1] <- "all"
  ride.df$id[1] <- mes_nascimento.df$id[1] <- ano_nascimento.df$id[1] <- idade_mae.df$id[1] <- idade_mae_detalhada.df$id[1] <- escolaridade_mae.df$id[1] <- "all"
  estado_civil_mae.df$id[1] <- duracao_gestacao.df$id[1] <- tipo_gravidez.df$id[1] <- tipo_parto.df$id[1] <- consulta_pre_natal.df$id[1] <- apgar_1_minuto.df$id[1] <- apgar_5_minuto.df$id[1] <- "all"
  sexo_RN.df$id[1] <- cor_raca.df$id[1] <- peso_ao_nascer.df$id[1] <- anomalia_congenita.df$id[1] <- local_nascimento.df$id[1] <- estabelecimento_saude.df$id[1] <- "all"
  
  
  #### ERROR HANDLING ####
  if (linha != "Munic%EDpio") {
    
    if (!is.character(linha)) stop("The 'linha' argument must be a character element")
    
    if(length(linha) != 1) stop("The 'linha' argument must have only one element")
    
    if (!(all(linha %in% linha.df$id))) {
      
      if (!(all(linha %in% linha.df$value))) {
        
        stop("The 'linha' argument is misspecified")
        
      }
      
    }
    
  }
  
  if (coluna != "--N%E3o-Ativa--") {
    
    if (!is.character(coluna)) stop("The 'coluna' argument must be a character element")
    
    if(length(coluna) != 1) stop("The 'coluna' argument must have only one element")
    
    if (!(all(coluna %in% coluna.df$id))) {
      
      if (!(all(coluna %in% coluna.df$value))) {
        
        stop("The 'coluna' argument is misspecified")
        
      }
      
    }
    
  }
  
  if (conteudo != 1) {
    
    if (is.numeric(conteudo)) stop("The only numeric elements allowed is 1")
    
    if(length(conteudo) != 1) stop("The 'coluna' argument must have only one element")
    
    if (!(all(conteudo %in% conteudo.df$id2))) {
      
      if (!(all(conteudo %in% conteudo.df$value))) {
        
        stop("The 'conteudo' argument is misspecified")
        
      }
      
    }
    
  }
  
  if (periodo[1] != "last") {
    
    if (is.character(periodo)) {
      periodo <- as.numeric(periodo)
    }
    
    if (!(all(periodo %in% periodos.df$id))) stop("The 'periodo' argument is misspecified")
    
  }
  
  if (any(municipio != "all")) {
    
    municipio <- as.character(municipio)
    
    if (!(all(municipio %in% municipios.df$id))) stop("Some element in 'municipio' argument is wrong")
    
  }
  
  if (any(regiao_de_saudecir != "all")) {
    
    regiao_de_saudecir <- as.character(regiao_de_saudecir)
    
    if (!(all(regiao_de_saudecir %in% regiao_de_saudecir.df$id))) stop("Some element in 'regiao_de_saudecir' argument is wrong")
    
  }
  
  if (any(divisao_administ_estadual != "all")) {
    
    divisao_administ_estadual <- as.character(divisao_administ_estadual)
    
    if (!(all(divisao_administ_estadual %in% divisao_administ_estadual.df$id))) stop("Some element in 'divisao_administ_estadual' argument is wrong")
    
  }
  
  if (any(macrorregiao_de_saude != "all")) {
    
    macrorregiao_de_saude <- as.character(macrorregiao_de_saude)
    
    if (!(all(macrorregiao_de_saude %in% macrorregiao_de_saude.df$id))) stop("Some element in 'macrorregiao_de_saude' argument is wrong")
    
  }
  
  if (any(territorio_desenv_mg != "all")) {
    
    territorio_desenv_mg <- as.character(territorio_desenv_mg)
    
    if (!(all(territorio_desenv_mg %in% territorio_desenv_mg.df$id))) stop("Some element in 'territorio_desenv_mg' argument is wrong")
    
  }
  
  if (any(ride != "all")) {
    
    ride <- as.character(ride)
    
    if (!(all(ride %in% ride.df$id))) stop("Some element in 'ride' argument is wrong")
    
  }
  
  if (any(mes_nascimento != "all")) {
    
    if (!(all(mes_nascimento %in% mes_nascimento.df$id))) {
      
      mes_nascimento <- as.character(mes_nascimento)
      
      if (!(all(mes_nascimento %in% mes_nascimento.df$value))) {
        
        stop("Some element in 'mes_nascimento' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(ano_nascimento != "all")) {
    
    if (!(all(ano_nascimento %in% ano_nascimento.df$id))) {
      
      ano_nascimento <- as.character(ano_nascimento)
      
      if (!(all(ano_nascimento %in% ano_nascimento.df$value))) {
        
        stop("Some element in 'mes_nascimento' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(idade_mae != "all")) {
    
    if (!(all(idade_mae %in% idade_mae.df$id))) {
      
      idade_mae <- as.character(idade_mae)
      
      if (!(all(idade_mae %in% idade_mae.df$value))) {
        
        stop("Some element in 'idade_mae' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(idade_mae_detalhada != "all")) {
    
    if (!(all(idade_mae_detalhada %in% idade_mae_detalhada.df$id))) {
      
      idade_mae_detalhada <- as.character(idade_mae_detalhada)
      
      if (!(all(idade_mae_detalhada %in% idade_mae_detalhada.df$value))) {
        
        stop("Some element in 'idade_mae_detalhada' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(escolaridade_mae != "all")) {
    
    if (!(all(escolaridade_mae %in% escolaridade_mae.df$id))) {
      
      escolaridade_mae <- as.character(escolaridade_mae)
      
      if (!(all(escolaridade_mae %in% escolaridade_mae.df$value))) {
        
        stop("Some element in 'escolaridade' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(estado_civil_mae != "all")) {
    
    if (!(all(estado_civil_mae %in% estado_civil_mae.df$id))) {
      
      estado_civil_mae <- as.character(estado_civil_mae)
      
      if (!(all(estado_civil_mae %in% estado_civil_mae.df$value))) {
        
        stop("Some element in 'estado_civil_mae' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(duracao_gestacao != "all")) {
    
    if (!(all(duracao_gestacao %in% duracao_gestacao.df$id))) {
      
      duracao_gestacao <- as.character(duracao_gestacao)
      
      if (!(all(duracao_gestacao %in% duracao_gestacao.df$value))) {
        
        stop("Some element in 'duracao_gestacao' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(tipo_gravidez != "all")) {
    
    if (!(all(tipo_gravidez %in% tipo_gravidez.df$id))) {
      
      tipo_gravidez <- as.character(tipo_gravidez)
      
      if (!(all(tipo_gravidez %in% tipo_gravidez.df$value))) {
        
        stop("Some element in 'tipo_gravidez' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(tipo_parto != "all")) {
    
    if (!(all(tipo_parto %in% tipo_parto.df$id))) {
      
      tipo_parto <- as.character(tipo_parto)
      
      if (!(all(tipo_parto %in% tipo_parto.df$value))) {
        
        stop("Some element in 'tipo_parto' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(consulta_pre_natal != "all")) {
    
    if (!(all(consulta_pre_natal %in% consulta_pre_natal.df$id))) {
      
      consulta_pre_natal <- as.character(consulta_pre_natal)
      
      if (!(all(consulta_pre_natal %in% consulta_pre_natal.df$value))) {
        
        stop("Some element in 'consulta_pre_natal' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(apgar_1_minuto != "all")) {
    
    if (!(all(apgar_1_minuto %in% apgar_1_minuto.df$id))) {
      
      apgar_1_minuto <- as.character(apgar_1_minuto)
      
      if (!(all(apgar_1_minuto %in% apgar_1_minuto.df$value))) {
        
        stop("Some element in 'apgar_1_minuto' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(apgar_5_minuto != "all")) {
    
    if (!(all(apgar_5_minuto %in% apgar_5_minuto.df$id))) {
      
      apgar_5_minuto <- as.character(apgar_5_minuto)
      
      if (!(all(apgar_5_minuto %in% apgar_5_minuto.df$value))) {
        
        stop("Some element in 'apgar_5_minuto' argument is wrong")
        
      }
      
    }
    
  }
  
  
  if (any(sexo_RN != "all")) {
    
    if (!(all(sexo_RN %in% sexo_RN.df$id))) {
      
      sexo <- as.character(sexo)
      
      if (!(all(sexo %in% sexo_RN.df$value))) {
        
        stop("Some element in 'sexo' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(cor_raca != "all")) {
    
    if (!(all(cor_raca %in% cor_raca.df$id))) {
      
      cor_raca <- as.character(cor_raca)
      
      if (!(all(cor_raca %in% cor_raca.df$value))) {
        
        stop("Some element in 'cor_raca' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(peso_ao_nascer != "all")) {
    
    if (!(all(peso_ao_nascer %in% peso_ao_nascer.df$id))) {
      
      peso_ao_nascer <- as.character(peso_ao_nascer)
      
      if (!(all(peso_ao_nascer %in% peso_ao_nascer.df$value))) {
        
        stop("Some element in 'peso_ao_nascer' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(anomalia_congenita != "all")) {
    
    if (!(all(anomalia_congenita %in% anomalia_congenita.df$id))) {
      
      anomalia_congenita <- as.character(anomalia_congenita)
      
      if (!(all(anomalia_congenita %in% anomalia_congenita.df$value))) {
        
        stop("Some element in 'anomalia_congenita' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(local_nascimento != "all")) {
    
    if (!(all(local_nascimento %in% local_nascimento.df$id))) {
      
      local_nascimento <- as.character(local_nascimento)
      
      if (!(all(local_nascimento %in% local_nascimento.df$value))) {
        
        stop("Some element in 'local_nascimento' argument is wrong")
        
      }
      
    }
    
  }
  
  
  if (any(estabelecimento_saude != "all")) {
    
    if (!(all(estabelecimento_saude %in% estabelecimento_saude.df$id))) {
      
      estabelecimento_saude <- as.character(estabelecimento_saude)
      
      if (!(all(estabelecimento_saude %in% estabelecimento_saude.df$value))) {
        
        stop("Some element in 'estabelecimento_saude' argument is wrong")
        
      }
      
    }
    
  }
  
  
  
  #### FILTERS APPLICATIONS ####
  
  #linha
  if (linha %in% linha.df$id) {
    linha <- dplyr::filter(linha.df, linha.df$id %in% linha)
    linha <- linha$value
  }
  
  if (!stringi::stri_enc_isascii(linha)) {
    form_linha <- paste0("Linha=", stringi::stri_escape_unicode(linha))
  } else {
    form_linha <- paste0("Linha=", linha)
  }
  
  #coluna
  if (coluna %in% coluna.df$id) {
    coluna <- dplyr::filter(coluna.df, coluna.df$id %in% coluna)
    coluna <- coluna$value
  }
  
  if (!stringi::stri_enc_isascii(coluna)) {
    form_coluna <- paste0("Coluna=", stringi::stri_escape_unicode(coluna))
  } else {
    form_coluna <- paste0("Coluna=", coluna)
  }
  
  #conteudo
  form_conteudo <- conteudo.df$value[conteudo]
  if (!stringi::stri_enc_isascii(form_conteudo)) {
    form_conteudo <- paste0("Incremento=", stringi::stri_escape_unicode(form_conteudo))
  } else {
    form_conteudo <- paste0("Incremento=", form_conteudo)
  }
  
  #periodo
  suppressWarnings( if (periodo == "last") {periodo <- utils::head(periodos.df$id, 1)} )
  form_periodo <- dplyr::filter(periodos.df, periodos.df$id %in% periodo)
  form_periodo <- paste0("Arquivos=", form_periodo$value, collapse = "&")
  
  form_pesqmes1 <- "pesqmes1=Digite+o+texto+e+ache+f%E1cil"
  
  #municipio
  form_municipio <- dplyr::filter(municipios.df, municipios.df$id %in% municipio)
  form_municipio <- paste0("SMunic%EDpio=", form_municipio$value, collapse = "&")
  
  form_pesqmes2 <- "pesqmes2=Digite+o+texto+e+ache+f%E1cil"
  
  #região de saúde (CIR)
  form_cir <- dplyr::filter(regiao_de_saudecir.df, regiao_de_saudecir.df$id %in% regiao_de_saudecir)
  form_cir <- paste0("SRegi%E3o_de_Sa%FAde_%28CIR%29=", form_cir$value, collapse = "&")
  
  form_pesqmes3 <- "pesqmes3=Digite+o+texto+e+ache+f%E1cil"
  
  #Divisão adiministrativa estadual
  form_divisao_administ_estadual <- dplyr::filter(divisao_administ_estadual.df, divisao_administ_estadual.df$id %in% divisao_administ_estadual)
  form_divisao_administ_estadual <- paste0("SDivis%E3o_administ_estadual=", form_divisao_administ_estadual$value, collapse = "&")
  
  form_pesqmes4 <- "pesqmes4=Digite+o+texto+e+ache+f%E1cil"
  
  #macrorregiao_de_saude
  form_macrorregiao_de_saude <- dplyr::filter(macrorregiao_de_saude.df, macrorregiao_de_saude.df$id %in% macrorregiao_de_saude)
  form_macrorregiao_de_saude <- paste0("SMacrorreg_de_Sa%FAde=", form_macrorregiao_de_saude$value, collapse = "&")
  
  form_pesqmes5 <- "pesqmes5=Digite+o+texto+e+ache+f%E1cil"
  
  #territorio_desenv_mg
  form_territorio_desenv_mg <- dplyr::filter(territorio_desenv_mg.df, territorio_desenv_mg.df$id %in% territorio_desenv_mg)
  form_territorio_desenv_mg <- paste0("STerrit._Desenvolvimento_MG=", form_territorio_desenv_mg$value, collapse = "&")
  
  #ride
  if (ride %in% ride.df$id) {
    ride <- dplyr::filter(ride.df, ride.df$id %in% ride)
    ride <- ride$value
  }
  if (!stringi::stri_enc_isascii(ride)) {
    form_ride <- paste0("SRegi%E3o_Metropolitana_-_RIDE=", stringi::stri_escape_unicode(ride))
  } else {
    form_ride <- paste0("SRegi%E3o_Metropolitana_-_RIDE=", ride)
  }
  
  form_pesqmes7 <- "pesqmes7=Digite+o+texto+e+ache+f%E1cil"
  
  # mes_nascimento
  form_mes_nascimento <- dplyr::filter(mes_nascimento.df, mes_nascimento.df$id %in% mes_nascimento)
  form_mes_nascimento <- paste0("SM%EAs_do_Nascimento=", form_mes_nascimento$value, collapse = "&")
  
  form_pesqmes8 <- "pesqmes8=Digite+o+texto+e+ache+f%E1cil"
  
  # ano_nascimento
  form_ano_nascimento <- dplyr::filter(ano_nascimento.df, ano_nascimento.df$id %in% ano_nascimento)
  form_ano_nascimento <- paste0("SM%EAs%2FAno=", form_ano_nascimento$value, collapse = "&")
  
  form_pesqmes9 <- "pesqmes9=Digite+o+texto+e+ache+f%E1cil"
  
  # idade da mãe
  form_idade_mae <- dplyr::filter(idade_mae.df, idade_mae.df$id %in% idade_mae)
  form_idade_mae <- paste0("SIdade_da_M%E3e=", form_idade_mae$value, collapse = "&")
  
  form_pesqmes10 <- "pesqmes10=Digite+o+texto+e+ache+f%E1cil"
  
  # idade da mãe
  form_idade_mae_detalhada <- dplyr::filter(idade_mae_detalhada.df, idade_mae_detalhada.df$id %in% idade_mae_detalhada)
  form_idade_mae_detalhada <- paste0("SIdade_M%E3e__detalhada=", form_idade_mae_detalhada$value, collapse = "&")
  
  # escolaridade
  if (escolaridade_mae %in% escolaridade_mae.df$id) {
    escolaridade_mae <- dplyr::filter(escolaridade_mae.df, escolaridade_mae.df$id %in% escolaridade_mae)
    escolaridade_mae <- escolaridade_mae$value
  }
  if (!stringi::stri_enc_isascii(escolaridade_mae)) {
    form_escolaridade_mae <- paste0("SEscolaridade_m%E3e=", stringi::stri_escape_unicode(escolaridade_mae))
  } else {
    form_escolaridade_mae <- paste0("SEscolaridade_m%E3e=", escolaridade_mae)
  }
  
  # estado civil
  if (estado_civil_mae %in% estado_civil_mae.df$id) {
    estado_civil_mae <- dplyr::filter(estado_civil_mae.df, estado_civil_mae.df$id %in% estado_civil_mae)
    estado_civil_mae <- estado_civil_mae$value
  }
  if (!stringi::stri_enc_isascii(estado_civil_mae)) {
    form_estado_civil_mae <- paste0("SEstado_civil_m%E3e=", stringi::stri_escape_unicode(estado_civil_mae))
  } else {
    form_estado_civil_mae <- paste0("SEstado_civil_m%E3e=", estado_civil_mae)
  }
  
  # duracao_gestacao
  if (duracao_gestacao %in% duracao_gestacao.df$id) {
    duracao_gestacao <- dplyr::filter(duracao_gestacao.df, duracao_gestacao.df$id %in% duracao_gestacao)
    duracao_gestacao <- duracao_gestacao$value
  }
  if (!stringi::stri_enc_isascii(duracao_gestacao)) {
    form_duracao_gestacao <- paste0("SDura%E7%E3o_da_Gesta%E7%E3o=", stringi::stri_escape_unicode(duracao_gestacao))
  } else {
    form_duracao_gestacao <- paste0("SDura%E7%E3o_da_Gesta%E7%E3o=", duracao_gestacao)
  }
  
  # tipo_gravidez
  if (tipo_gravidez %in% tipo_gravidez.df$id) {
    tipo_gravidez <- dplyr::filter(tipo_gravidez.df, tipo_gravidez.df$id %in% tipo_gravidez)
    tipo_gravidez <- tipo_gravidez$value
  }
  if (!stringi::stri_enc_isascii(tipo_gravidez)) {
    form_tipo_gravidez <- paste0("STipo_de_gravidez=", stringi::stri_escape_unicode(tipo_gravidez))
  } else {
    form_tipo_gravidez <- paste0("STipo_de_gravidez=", tipo_gravidez)
  }
  
  # tipo_parto
  if (tipo_parto %in% tipo_parto.df$id) {
    tipo_parto <- dplyr::filter(tipo_parto.df, tipo_parto.df$id %in% tipo_parto)
    tipo_parto <- tipo_parto$value
  }
  if (!stringi::stri_enc_isascii(tipo_parto)) {
    form_tipo_parto <- paste0("STipo_de_Parto=", stringi::stri_escape_unicode(tipo_parto))
  } else {
    form_tipo_parto <- paste0("STipo_de_Parto=", tipo_parto)
  }
  
  # consulta_pre_natal
  if (consulta_pre_natal %in% consulta_pre_natal.df$id) {
    consulta_pre_natal <- dplyr::filter(consulta_pre_natal.df, consulta_pre_natal.df$id %in% consulta_pre_natal)
    consulta_pre_natal <- consulta_pre_natal$value
  }
  if (!stringi::stri_enc_isascii(consulta_pre_natal)) {
    form_consulta_pre_natal <- paste0("SConsulta_Pr%E9-Natal=", stringi::stri_escape_unicode(consulta_pre_natal))
  } else {
    form_consulta_pre_natal <- paste0("SConsulta_Pr%E9-Natal=", consulta_pre_natal)
  }
  
  form_pesqmes17 <- "pesqmes17=Digite+o+texto+e+ache+f%E1cil"
  
  # apgar 1º minuto
  form_apgar_1_minuto <- dplyr::filter(apgar_1_minuto.df, apgar_1_minuto.df$id %in% apgar_1_minuto)
  form_apgar_1_minuto <- paste0("SApgar_1%BA_minuto=", form_apgar_1_minuto$value, collapse = "&")
  
  form_pesqmes18 <- "pesqmes18=Digite+o+texto+e+ache+f%E1cil"
  
  # apgar 5º minuto
  form_apgar_5_minuto <- dplyr::filter(apgar_5_minuto.df, apgar_5_minuto.df$id %in% apgar_5_minuto)
  form_apgar_5_minuto <- paste0("SApgar_5%BA_minuto=", form_apgar_5_minuto$value, collapse = "&")
  
  # sexo_RN
  if (sexo_RN %in% sexo_RN.df$id) {
    sexo_RN <- dplyr::filter(sexo_RN.df, sexo_RN.df$id %in% sexo_RN)
    sexo_RN <- sexo_RN$value
  }
  if (!stringi::stri_enc_isascii(sexo_RN)) {
    form_sexo_RN <- paste0("SSexo_do_RN=", stringi::stri_escape_unicode(sexo_RN))
  } else {
    form_sexo_RN<- paste0("SSexo_do_RN=", sexo_RN)
  }
  
  #cor_raca
  if (cor_raca %in% cor_raca.df$id) {
    cor_raca <- dplyr::filter(cor_raca.df, cor_raca.df$id %in% cor_raca)
    cor_raca <- cor_raca$value
  }
  if (!stringi::stri_enc_isascii(cor_raca)) {
    form_cor_raca <- paste0("SRa%E7a%2Fcor=", stringi::stri_escape_unicode(cor_raca))
  } else {
    form_cor_raca <- paste0("SRa%E7a%2FCor=", cor_raca)
  }
  
  #peso ao nascer
  if (peso_ao_nascer %in% peso_ao_nascer.df$id) {
    peso_ao_nascer <- dplyr::filter(peso_ao_nascer.df, peso_ao_nascer.df$id %in% peso_ao_nascer)
    peso_ao_nascer <- peso_ao_nascer$value
  }
  if (!stringi::stri_enc_isascii(peso_ao_nascer)) {
    form_peso_ao_nascer <- paste0("SPeso_ao_nascer_do_RN=", stringi::stri_escape_unicode(cor_raca))
  } else {
    form_peso_ao_nascer <- paste0("SPeso_ao_nascer_do_RN=", peso_ao_nascer)
  }
  
  
  # anomalia_congenita
  if (anomalia_congenita %in% anomalia_congenita.df$id) {
    anomalia_congenita <- dplyr::filter(anomalia_congenita.df, anomalia_congenita.df$id %in% anomalia_congenita)
    anomalia_congenita <- anomalia_congenita$value
  }
  if (!stringi::stri_enc_isascii(anomalia_congenita)) {
    form_anomalia_congenita <- paste0("SAnomalia_cong%EAnita=", stringi::stri_escape_unicode(anomalia_congenita))
  } else {
    form_anomalia_congenita <- paste0("SAnomalia_cong%EAnita=", anomalia_congenita)
  }
  
  # local nascimento
  if (local_nascimento %in% local_nascimento.df$id) {
    local_nascimento <- dplyr::filter(local_nascimento.df, local_nascimento.df$id %in% local_nascimento)
    local_nascimento <- local_nascimento$value
  }
  if (!stringi::stri_enc_isascii(local_nascimento)) {
    form_local_nascimento <- paste0("SLocal_Nascimento=", stringi::stri_escape_unicode(local_nascimento))
  } else {
    form_local_nascimento <- paste0("SLocal_Nascimento=", local_nascimento)
  }
  
  form_pesqmes24 <- "pesqmes24=Digite+o+texto+e+ache+f%E1cil"
  
  # estabelecimento de saude
  form_estabelecimento_saude <- dplyr::filter(estabelecimento_saude.df, estabelecimento_saude.df$id %in% estabelecimento_saude)
  form_estabelecimento_saude <- paste0("SEstabelecimento_de_Sa%FAde=", form_estabelecimento_saude$value, collapse = "&")
  
  
  form_data <- paste(form_linha, form_coluna, form_conteudo, form_periodo, 
                     form_pesqmes1, form_municipio, form_pesqmes2, form_cir, form_pesqmes3, form_divisao_administ_estadual,
                     form_pesqmes4, form_macrorregiao_de_saude, form_pesqmes5, form_territorio_desenv_mg, form_ride,
                     form_pesqmes7, form_mes_nascimento, form_pesqmes8, form_ano_nascimento, form_pesqmes9, form_idade_mae,
                     form_pesqmes10, form_idade_mae_detalhada, form_escolaridade_mae, form_estado_civil_mae, form_duracao_gestacao,
                     form_tipo_gravidez, form_tipo_parto, form_consulta_pre_natal, form_pesqmes17, form_apgar_1_minuto, 
                     form_pesqmes18, form_apgar_5_minuto, form_sexo_RN, form_cor_raca, form_peso_ao_nascer, form_anomalia_congenita,
                     form_local_nascimento, form_pesqmes24, form_estabelecimento_saude,
                     "formato=table&zeradas=exibirlz&mostre=Mostra", sep = "&")
  
  
  
  form_data <- gsub("\\\\u00", "%", form_data)
  
  
  
  ##### REQUEST FORM AND DATA WRANGLING ####
  site <- httr::POST(url = "http://tabnet.saude.mg.gov.br/tabcgi.exe?def/nasc/nascr.def",
                     body = form_data)
  
  tabdados <- httr::content(site, encoding = "Latin1") |>
    rvest::html_nodes(".tabdados tbody td") |>
    rvest::html_text() |>
    trimws()
  
  col_tabdados <- httr::content(site, encoding = "Latin1") |>
    rvest::html_nodes("th") |>
    rvest::html_text() |>
    trimws()
  
  f1 <- function(x) x <- gsub("\\.", "", x)
  f2 <- function(x) x <- as.numeric(as.character(x))
  
  tabela_final <- as.data.frame(matrix(data = tabdados, nrow = length(tabdados)/length(col_tabdados),
                                       ncol = length(col_tabdados), byrow = TRUE))
  
  names(tabela_final) <- col_tabdados
  
  tabela_final[-1] <- lapply(tabela_final[-1], f1)
  tabela_final[-1] <- suppressWarnings(lapply(tabela_final[-1], f2))
  
  tabela_final
  
}
