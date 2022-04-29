#' Scrapes general mortality data from  Minas Gerais cities
#'
#' This function allows the user to retrieve data from
#' the general mortality database much in the same way that is done
#' by the online portal. The argument options refer to
#' data focused on Minas Gerais cities.
#'
#' 
#' @usage mortalidade_geral_mun_mg <- function(linha = "Munic%EDpio", coluna = "--N%E3o-Ativa--", conteudo = 1, periodo = "last", municipio = "all",
#' regiao_de_saudecir = "all", divisao_administ_estadual = "all", macrorregiao_de_saude = "all", territorio_desenv_mg = "all", 
#' ride = "all", capitulo_cid10 = "all", grupo_cid10 = "all", causa_cidbr10 = "all", categoria_cid10 = "all", causas_mal_definidas = "all", causas_evit_lista_0_4_anos = "all", 
#' causas_evit_lista_5_74_anos = "all", mes_do_obito = "all", mes_ano_do_obito = "all", faixa_etaria = "all", faixa_etaria_detalhada = "all", idade_detalhada = "all", faixa_etaria_oms_ops = "all", 
#' faixa_etaria_menor_1a = "all", faixa_etaria_infancia_menor_6a = "all", sexo = "all", cor_raca = "all", escolaridade = "all", estado_civil = "all", ocupacao_grande_grupo = "all", ocupacao_subgrupo_principal = "all", 
#' ocupacao_subgrupo_3d = "all", ocupacao_familia_4d = "all", ocupacao = "all", local_ocorrencia = "all", assitencia_medica = "all", atestante = "all") 
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
#' @param capitulo_cid10 "all" or a or a character vector with the ICD-10 chapter (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param grupo_cid10 "all" or a character vector with the ICD-10 group (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param causa_cidbr10  "all" or a character vector with the ICD-10 causes (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param categoria_cid10 "all" or a character vector with the ICD-10 group (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param causas_mal_definidas "all" or a character vector with not well defined causes (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param causas_evit_lista_0_4_anos "all" or a character vector of avoidable causes (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param causas_evit_lista_5_74_anos "all" or a character vector of avoidable causes (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param mes_do_obito "all" or a character vector with the months (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param mes_ano_do_obito "all" or a character vector with the months/years (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param faixa_etaria "all" or a character vector with the age range (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param faixa_etaria_detalhada "all" or a character vector with the age range (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param idade_detalhada "all" or a character vector with the age range (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param faixa_etaria_oms_ops "all" or a character vector with the age range (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param faixa_etaria_menor_1a "all" or a character vector with the age range (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param faixa_etaria_infancia_menor_6a "all" or a character vector with the age range (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param sexo "all" or a character vector with the gender (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param cor_raca "all" or a character vector with the color/race (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param escolaridade "all" or a character vector with the years of instruction (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all". 
#' @param estado_civil "all" or a character vector with the marital status (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param ocupacao_grande_grupo "all" or a character vector of ocupation group (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param ocupacao_subgrupo_principal "all" or a character vector of ocupation group (written in the same way, with the digits and name) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param ocupacao_subgrupo_3d "all" or a character vector of ocupation group (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param ocupacao_familia_4d "all" or a character vector of ocupation group (written in the same way, with the digits and name) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param ocupacao "all" or a character vector of ocupation group (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' @param local_ocorrencia "all" or a character vector with the place of ocurrence to filter the data. Defaults to "all".
#' @param assitencia_medica "all" or a character vector with "Sim", "Não", "Ign" or "N Inf" to filter the data. Defaults to "all".
#' @param atestante "all" or a character vector of declarer (written in the same way) or the number corresponding to the order of the option in the online layout to filter the data. Defaults to "all".
#' 
#'
#' @return The function returns a data frame printed by parameters input.
#' @author Michel Alves \email{<michel.alves@fjp.mg.gov.br>}
#' @seealso \code{\link{sinasc_nv_uf}}
#' @examples
#' \dontrun{
#' ## Requesting data related to male deaths caused by Hanseniase of all cities in Minas Gerais 
#' mortalidade_geral_mun_mg(categoria_cid10 = "30", sexo="Masc")
#' }
#'
#' @keywords SIM datasus
#' @importFrom magrittr |>
#' @importFrom utils head
#' @export


mortalidade_geral_mun_mg <- function(linha = "Munic%EDpio", coluna = "--N%E3o-Ativa--", conteudo = 1, periodo = "last", municipio = "all",
                             regiao_de_saudecir = "all", divisao_administ_estadual = "all", macrorregiao_de_saude = "all", territorio_desenv_mg = "all", 
                             ride = "all", capitulo_cid10 = "all", grupo_cid10 = "all", causa_cidbr10 = "all", categoria_cid10 = "all", causas_mal_definidas = "all", causas_evit_lista_0_4_anos = "all", 
                             causas_evit_lista_5_74_anos = "all", mes_do_obito = "all", mes_ano_do_obito = "all", faixa_etaria = "all", faixa_etaria_detalhada = "all", idade_detalhada = "all", faixa_etaria_oms_ops = "all", 
                             faixa_etaria_menor_1a = "all", faixa_etaria_infancia_menor_6a = "all", sexo = "all", cor_raca = "all", escolaridade = "all", estado_civil = "all", ocupacao_grande_grupo = "all", ocupacao_subgrupo_principal = "all", 
                             ocupacao_subgrupo_3d = "all", ocupacao_familia_4d = "all", ocupacao = "all", local_ocorrencia = "all", assitencia_medica = "all", atestante = "all") {
  
  
  url <- "http://tabnet.saude.mg.gov.br/tabcgi.exe?def/obitos/geralr.def"
  
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
                            id2 = c("Frequ%EAncia"),
                            value = c("Frequ%EAncia"))
  
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
  
  capitulo_cid10.df <- suppressWarnings(data.frame(id = page |> rvest::html_nodes("#S7 option") |> rvest::html_text() |> trimws(),
                                                   value = page |> rvest::html_nodes("#S7 option") |> rvest::html_attr("value")))
  
  grupo_cid10.df <- suppressWarnings(data.frame(id = page |> rvest::html_nodes("#S8 option") |> rvest::html_text() |> trimws(),
                                                value = page |> rvest::html_nodes("#S8 option") |> rvest::html_attr("value")))
  
  causa_cidbr10.df <- suppressWarnings(data.frame(id = page |> rvest::html_nodes("#S9 option") |> rvest::html_text() |> trimws(),
                                                  value = page |> rvest::html_nodes("#S9 option") |> rvest::html_attr("value")))
  
  categoria_cid10.df <- suppressWarnings(data.frame(id = page |> rvest::html_nodes("#S10 option") |> rvest::html_text() |> readr::parse_number(),
                                                    value = page |> rvest::html_nodes("#S10 option") |> rvest::html_attr("value")))
  
  causas_mal_definidas.df <- suppressWarnings(data.frame(id = page |> rvest::html_nodes("#S11 option") |> rvest::html_text() |> trimws(),
                                                         value = page |> rvest::html_nodes("#S11 option") |> rvest::html_attr("value")))
  
  causas_evit_lista_0_4_anos.df <- suppressWarnings(data.frame(id = page |> rvest::html_nodes("#S12 option") |> rvest::html_text() |> trimws(),
                                                               value = page |> rvest::html_nodes("#S12 option") |> rvest::html_attr("value")))
  
  causas_evit_lista_5_74_anos.df <- suppressWarnings(data.frame(id = page |> rvest::html_nodes("#S13 option") |> rvest::html_text() |> trimws(),
                                                                value = page |> rvest::html_nodes("#S13 option") |> rvest::html_attr("value")))
  
  mes_do_obito.df <- suppressWarnings(data.frame(id = page |> rvest::html_nodes("#S14 option") |> rvest::html_text() |> trimws(),
                                                 value = page |> rvest::html_nodes("#S14 option") |> rvest::html_attr("value")))
  
  mes_ano_do_obito.df <- suppressWarnings(data.frame(id = page |> rvest::html_nodes("#S15 option") |> rvest::html_text() |> trimws(),
                                                     value = page |> rvest::html_nodes("#S15 option") |> rvest::html_attr("value")))
  
  faixa_etaria.df <- data.frame(id = page |> rvest::html_nodes("#S16 option") |> rvest::html_text() |> trimws(),
                                value = page |> rvest::html_nodes("#S16 option") |> rvest::html_attr("value"))
  faixa_etaria.df[] <- lapply(faixa_etaria.df, as.character)
  
  faixa_etaria_detalhada.df <- data.frame(id = page |> rvest::html_nodes("#S17 option") |> rvest::html_text() |> trimws(),
                                          value = page |> rvest::html_nodes("#S17 option") |> rvest::html_attr("value"))
  faixa_etaria_detalhada.df[] <- lapply(faixa_etaria_detalhada.df, as.character)
  
  idade_detalhada.df <- data.frame(id = page |> rvest::html_nodes("#S18 option") |> rvest::html_text() |> trimws(),
                                   value = page |> rvest::html_nodes("#S18 option") |> rvest::html_attr("value"))
  idade_detalhada.df[] <- lapply(idade_detalhada.df, as.character)
  
  faixa_etaria_oms_ops.df <- data.frame(id = page |> rvest::html_nodes("#S19 option") |> rvest::html_text() |> trimws(),
                                        value = page |> rvest::html_nodes("#S19 option") |> rvest::html_attr("value"))
  faixa_etaria_oms_ops.df[] <- lapply(faixa_etaria_oms_ops.df, as.character)
  
  faixa_etaria_menor_1a.df <- data.frame(id = page |> rvest::html_nodes("#S20 option") |> rvest::html_text() |> trimws(),
                                         value = page |> rvest::html_nodes("#S20 option") |> rvest::html_attr("value"))
  faixa_etaria_menor_1a.df[] <- lapply(faixa_etaria_menor_1a.df, as.character)
  
  faixa_etaria_infancia_menor_6a.df <- data.frame(id = page |> rvest::html_nodes("#S21 option") |> rvest::html_text() |> trimws(),
                                                  value = page |> rvest::html_nodes("#S21 option") |> rvest::html_attr("value"))
  faixa_etaria_infancia_menor_6a.df[] <- lapply(faixa_etaria_infancia_menor_6a.df, as.character)
  
  sexo.df <- data.frame(id = page |> rvest::html_nodes("#S22 option") |> rvest::html_text() |> trimws(),
                        value = page |> rvest::html_nodes("#S22 option") |> rvest::html_attr("value"))
  sexo.df[] <- lapply(sexo.df, as.character)
  
  cor_raca.df <- data.frame(id = page |> rvest::html_nodes("#S23 option") |> rvest::html_text() |> trimws(),
                            value = page |> rvest::html_nodes("#S23 option") |> rvest::html_attr("value"))
  cor_raca.df[] <- lapply(cor_raca.df, as.character)
  
  escolaridade.df <- data.frame(id = page |> rvest::html_nodes("#S24 option") |> rvest::html_text() |> trimws(),
                                value = page |> rvest::html_nodes("#S24 option") |> rvest::html_attr("value"))
  escolaridade.df[] <- lapply(escolaridade.df, as.character)
  
  estado_civil.df <- data.frame(id = page |> rvest::html_nodes("#S25 option") |> rvest::html_text() |> trimws(),
                                value = page |> rvest::html_nodes("#S25 option") |> rvest::html_attr("value"))
  estado_civil.df[] <- lapply(estado_civil.df, as.character)
  
  ocupacao_grande_grupo.df <- data.frame(id = page |> rvest::html_nodes("#S26 option") |> rvest::html_text() |> trimws(),
                                         value = page |> rvest::html_nodes("#S26 option") |> rvest::html_attr("value"))
  ocupacao_grande_grupo.df[] <- lapply(ocupacao_grande_grupo.df, as.character)
  
  ocupacao_subgrupo_principal.df <- data.frame(id = page |> rvest::html_nodes("#S27 option") |> rvest::html_text() |> trimws(),
                                               value = page |> rvest::html_nodes("#S27 option") |> rvest::html_attr("value"))
  ocupacao_subgrupo_principal.df[] <- lapply(ocupacao_subgrupo_principal.df, as.character)
  
  ocupacao_subgrupo_3d.df <- data.frame(id = page |> rvest::html_nodes("#S28 option") |> rvest::html_text() |> trimws(),
                                        value = page |> rvest::html_nodes("#S28 option") |> rvest::html_attr("value"))
  ocupacao_subgrupo_3d.df[] <- lapply(ocupacao_subgrupo_3d.df, as.character)
  
  ocupacao_familia_4d.df <- data.frame(id = page |> rvest::html_nodes("#S29 option") |> rvest::html_text() |> trimws(),
                                       value = page |> rvest::html_nodes("#S29 option") |> rvest::html_attr("value"))
  ocupacao_familia_4d.df[] <- lapply(ocupacao_familia_4d.df, as.character)
  
  ocupacao.df <- data.frame(id = page |> rvest::html_nodes("#S30 option") |> rvest::html_text() |> trimws(),
                            value = page |> rvest::html_nodes("#S30 option") |> rvest::html_attr("value"))
  ocupacao.df[] <- lapply(ocupacao.df, as.character)
  
  local_ocorrencia.df <- data.frame(id = page |> rvest::html_nodes("#S31 option") |> rvest::html_text() |> trimws(),
                                    value = page |> rvest::html_nodes("#S31 option") |> rvest::html_attr("value"))
  local_ocorrencia.df[] <- lapply(local_ocorrencia.df, as.character)
  
  assitencia_medica.df <- data.frame(id = page |> rvest::html_nodes("#S32 option") |> rvest::html_text() |> trimws(),
                                     value = page |> rvest::html_nodes("#S32 option") |> rvest::html_attr("value"))
  assitencia_medica.df[] <- lapply(assitencia_medica.df, as.character)
  
  atestante.df <- data.frame(id = page |> rvest::html_nodes("#S33 option") |> rvest::html_text() |> trimws(),
                             value = page |> rvest::html_nodes("#S33 option") |> rvest::html_attr("value"))
  atestante.df[] <- lapply(atestante.df, as.character)
  
  municipios.df$id[1] <- regiao_de_saudecir.df$id[1] <- divisao_administ_estadual.df$id[1] <- macrorregiao_de_saude.df$id[1] <-  territorio_desenv_mg.df$id[1] <- "all"
  ride.df$id[1] <-  capitulo_cid10.df$id[1] <- grupo_cid10.df$id[1] <-  causa_cidbr10.df$id[1] <- categoria_cid10.df$id[1] <- causas_mal_definidas.df$id[1] <- causas_evit_lista_0_4_anos.df$id[1] <- "all"
  causas_evit_lista_5_74_anos.df$id[1] <- mes_do_obito.df$id[1] <- mes_ano_do_obito.df$id[1] <- faixa_etaria.df$id[1] <- faixa_etaria_detalhada.df$id[1] <- idade_detalhada.df$id[1] <- faixa_etaria_oms_ops.df$id[1] <- "all"
  faixa_etaria_menor_1a.df$id[1] <- faixa_etaria_infancia_menor_6a.df$id[1] <- sexo.df$id[1] <- cor_raca.df$id[1] <- escolaridade.df$id[1] <- estado_civil.df$id[1] <- ocupacao_grande_grupo.df$id[1] <- ocupacao_subgrupo_principal.df$id[1] <- "all"
  ocupacao_subgrupo_3d.df$id[1] <- ocupacao_familia_4d.df$id[1] <- ocupacao.df$id[1] <- local_ocorrencia.df$id[1] <- assitencia_medica.df$id[1] <- atestante.df$id[1] <- "all"
  
  
  
  
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
  
  if (any(capitulo_cid10 != "all")) {
    
    capitulo_cid10 <- as.character(capitulo_cid10)
    
    if (!(all(capitulo_cid10 %in% capitulo_cid10.df$id))) stop("Some element in 'capitulo_cid10' argument is wrong")
    
  }
  
  if (any(grupo_cid10 != "all")) {
    
    grupo_cid10 <- as.character(grupo_cid10)
    
    if (!(all(grupo_cid10 %in% grupo_cid10.df$id))) stop("Some element in 'grupo_cid10' argument is wrong")
    
  }
  
  if (any(causa_cidbr10 != "all")) {
    
    causa_cidbr10 <- as.character(causa_cidbr10)
    
    if (!(all(causa_cidbr10 %in% causa_cidbr10.df$id))) stop("Some element in 'causa_cidbr10' argument is wrong")
    
  }
  
  if (any(categoria_cid10 != "all")) {
    
    categoria_cid10 <- as.character(categoria_cid10)
    
    if (!(all(categoria_cid10 %in% categoria_cid10.df$id))) stop("Some element in 'categoria_cid10' argument is wrong")
    
  }
  
  
  if (any(causas_mal_definidas != "all")) {
    
    causas_mal_definidas <- as.character(causas_mal_definidas)
    
    if (!(all(causas_mal_definidas %in% causas_mal_definidas.df$id))) stop("Some element in 'causas_mal_definidas' argument is wrong")
    
  }
  
  if (any(causas_mal_definidas != "all")) {
    
    causas_mal_definidas <- as.character(causas_mal_definidas)
    
    if (!(all(causas_mal_definidas %in% causas_mal_definidas.df$id))) stop("Some element in 'causas_mal_definidas' argument is wrong")
    
  }
  
  if (any(causas_evit_lista_0_4_anos != "all")) {
    
    causas_evit_lista_0_4_anos <- as.character(causas_evit_lista_0_4_anos)
    
    if (!(all(causas_evit_lista_0_4_anos %in% causas_evit_lista_0_4_anos.df$id))) stop("Some element in 'causas_evit_lista_0_4_anos' argument is wrong")
    
  }
  
  if (any(causas_evit_lista_5_74_anos != "all")) {
    
    causas_evit_lista_5_74_anos <- as.character(causas_evit_lista_5_74_anos)
    
    if (!(all(causas_evit_lista_5_74_anos %in% causas_evit_lista_5_74_anos.df$id))) stop("Some element in 'causas_evit_lista_5_74_anos' argument is wrong")
    
  }
  
  if (any(mes_do_obito != "all")) {
    
    mes_do_obito <- as.character(mes_do_obito)
    
    if (!(all(mes_do_obito %in% mes_do_obito.df$id))) stop("Some element in 'mes_do_obito' argument is wrong")
    
  }
  
  if (any(mes_ano_do_obito != "all")) {
    
    mes_ano_do_obito <- as.character(mes_ano_do_obito)
    
    if (!(all(mes_ano_do_obito %in% mes_ano_do_obito.df$id))) stop("Some element in 'mes_ano_do_obito' argument is wrong")
    
  }
  
  
  
  if (any(faixa_etaria != "all")) {
    
    if (!(all(faixa_etaria %in% faixa_etaria.df$id))) {
      
      faixa_etaria <- as.character(faixa_etaria)
      
      if (!(all(faixa_etaria %in% faixa_etaria.df$value))) {
        
        stop("Some element in 'faixa_etaria' argument is wrong")
        
      }
      
    }
    
  }
  
  
  if (any(faixa_etaria_detalhada != "all")) {
    
    if (!(all(faixa_etaria_detalhada %in% faixa_etaria_detalhada.df$id))) {
      
      faixa_etaria_detalhada <- as.character(faixa_etaria_detalhada)
      
      if (!(all(faixa_etaria_detalhada %in% faixa_etaria_detalhada.df$value))) {
        
        stop("Some element in 'faixa_etaria_detalhada' argument is wrong")
        
      }
      
    }
    
  }
  
  
  if (any(faixa_etaria_oms_ops != "all")) {
    
    if (!(all(faixa_etaria_oms_ops %in% faixa_etaria_oms_ops.df$id))) {
      
      faixa_etaria_oms_ops <- as.character(faixa_etaria_oms_ops)
      
      if (!(all(faixa_etaria_oms_ops %in% faixa_etaria_oms_ops.df$value))) {
        
        stop("Some element in 'faixa_etaria_oms_ops' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(faixa_etaria_menor_1a != "all")) {
    
    if (!(all(faixa_etaria_menor_1a %in% faixa_etaria_menor_1a.df$id))) {
      
      faixa_etaria_menor_1a <- as.character(faixa_etaria_menor_1a)
      
      if (!(all(faixa_etaria_menor_1a %in% faixa_etaria_menor_1a.df$value))) {
        
        stop("Some element in 'faixa_etaria_menor_1a' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(faixa_etaria_infancia_menor_6a != "all")) {
    
    if (!(all(faixa_etaria_infancia_menor_6a %in% faixa_etaria_infancia_menor_6a.df$id))) {
      
      faixa_etaria_infancia_menor_6a <- as.character(faixa_etaria_infancia_menor_6a)
      
      if (!(all(faixa_etaria_infancia_menor_6a %in% faixa_etaria_infancia_menor_6a.df$value))) {
        
        stop("Some element in 'faixa_etaria_infancia_menor_6a' argument is wrong")
        
      }
      
    }
    
  }
  
  
  
  if (any(sexo != "all")) {
    
    if (!(all(sexo %in% sexo.df$id))) {
      
      sexo <- as.character(sexo)
      
      if (!(all(sexo %in% sexo.df$value))) {
        
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
  
  if (any(escolaridade != "all")) {
    
    if (!(all(escolaridade %in% escolaridade.df$id))) {
      
      escolaridade <- as.character(escolaridade)
      
      if (!(all(escolaridade %in% escolaridade.df$value))) {
        
        stop("Some element in 'escolaridade' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(estado_civil != "all")) {
    
    if (!(all(estado_civil %in% estado_civil.df$id))) {
      
      estado_civil <- as.character(estado_civil)
      
      if (!(all(estado_civil %in% estado_civil.df$value))) {
        
        stop("Some element in 'estado_civil' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(ocupacao_grande_grupo != "all")) {
    
    if (!(all(ocupacao_grande_grupo %in% ocupacao_grande_grupo.df$id))) {
      
      ocupacao_grande_grupo <- as.character(ocupacao_grande_grupo)
      
      if (!(all(ocupacao_grande_grupo %in% ocupacao_grande_grupo.df$value))) {
        
        stop("Some element in 'ocupacao_grande_grupo' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(ocupacao_subgrupo_principal != "all")) {
    
    if (!(all(ocupacao_subgrupo_principal %in% ocupacao_subgrupo_principal.df$id))) {
      
      ocupacao_subgrupo_principal <- as.character(ocupacao_subgrupo_principal)
      
      if (!(all(ocupacao_subgrupo_principal %in% ocupacao_subgrupo_principal.df$value))) {
        
        stop("Some element in 'ocupacao_subgrupo_principal' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(ocupacao_subgrupo_3d != "all")) {
    
    if (!(all(ocupacao_subgrupo_3d %in% ocupacao_subgrupo_3d.df$id))) {
      
      ocupacao_subgrupo_3d <- as.character(ocupacao_subgrupo_3d)
      
      if (!(all(ocupacao_subgrupo_3d %in% ocupacao_subgrupo_3d.df$value))) {
        
        stop("Some element in 'ocupacao_subgrupo_3d' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(ocupacao_familia_4d != "all")) {
    
    if (!(all(ocupacao_familia_4d %in% ocupacao_familia_4d.df$id))) {
      
      ocupacao_familia_4d <- as.character(ocupacao_familia_4d)
      
      if (!(all(ocupacao_familia_4d %in% ocupacao_familia_4d.df$value))) {
        
        stop("Some element in 'ocupacao_familia_4d' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(ocupacao != "all")) {
    
    if (!(all(ocupacao %in% ocupacao.df$id))) {
      
      ocupacao <- as.character(ocupacao)
      
      if (!(all(ocupacao %in% ocupacao.df$value))) {
        
        stop("Some element in 'ocupacao' argument is wrong")
        
      }
      
    }
    
  }
  
  
  
  if (any(local_ocorrencia != "all")) {
    
    if (!(all(local_ocorrencia %in% local_ocorrencia$id))) {
      
      local_ocorrencia <- as.character(local_ocorrencia)
      
      if (!(all(local_ocorrencia %in% local_ocorrencia.df$value))) {
        
        stop("Some element in 'local_ocorrencia' argument is wrong")
        
      }
      
    }
    
  }
  
  
  if (any(assitencia_medica != "all")) {
    
    if (!(all(assitencia_medica %in% assitencia_medica.df$id))) {
      
      assitencia_medica <- as.character(assitencia_medica)
      
      if (!(all(assitencia_medica %in% assitencia_medica.df$value))) {
        
        stop("Some element in 'assitencia_medica' argument is wrong")
        
      }
      
    }
    
  }
  
  if (any(atestante != "all")) {
    
    if (!(all(atestante %in% atestante.df$id))) {
      
      atestante <- as.character(atestante)
      
      if (!(all(atestante %in% atestante.df$value))) {
        
        stop("Some element in 'atestante' argument is wrong")
        
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
  
  # capitulo_cid10
  form_capitulo_cid10 <- dplyr::filter(capitulo_cid10.df, capitulo_cid10.df$id %in% capitulo_cid10)
  form_capitulo_cid10 <- paste0("SCap%EDtulo_CID-10=", form_capitulo_cid10$value, collapse = "&")
  
  form_pesqmes8 <- "pesqmes8=Digite+o+texto+e+ache+f%E1cil"
  
  # grupo_cid10
  form_grupo_cid10 <- dplyr::filter(grupo_cid10.df, grupo_cid10.df$id %in% grupo_cid10)
  form_grupo_cid10 <- paste0("SGrupo_CID-10=", form_grupo_cid10$value, collapse = "&")
  
  form_pesqmes9 <- "pesqmes9=Digite+o+texto+e+ache+f%E1cil"
  
  # causa_cidbr10
  form_causa_cidbr10 <- dplyr::filter(causa_cidbr10.df, causa_cidbr10.df$id %in% causa_cidbr10)
  form_causa_cidbr10 <- paste0("SCausa_-_CID-BR-10=", form_causa_cidbr10$value, collapse = "&")
  
  form_pesqmes10 <- "pesqmes10=Digite+o+texto+e+ache+f%E1cil"
  
  # categoria_cid10
  form_categoria_cid10 <- dplyr::filter(categoria_cid10.df, categoria_cid10.df$id %in% categoria_cid10)
  form_categoria_cid10 <- paste0("SCategoria_CID-10=", form_categoria_cid10$value, collapse = "&")
  
  #causas_mal_definidas
  if (causas_mal_definidas %in% causas_mal_definidas.df$id) {
    causas_mal_definidas <- dplyr::filter(causas_mal_definidas.df, causas_mal_definidas.df$id %in% causas_mal_definidas)
    causas_mal_definidas <- causas_mal_definidas$value
  }
  if (!stringi::stri_enc_isascii(causas_mal_definidas)) {
    form_causas_mal_definidas <- paste0("SCausas_mal_definidas=", stringi::stri_escape_unicode(causas_mal_definidas))
  } else {
    form_causas_mal_definidas <- paste0("SCausas_mal_definidas=", causas_mal_definidas)
  }
  
  #causas_evit_lista_0_4_anos
  if (causas_evit_lista_0_4_anos %in% causas_evit_lista_0_4_anos.df$id) {
    causas_evit_lista_0_4_anos <- dplyr::filter(causas_evit_lista_0_4_anos.df, causas_evit_lista_0_4_anos.df$id %in% causas_evit_lista_0_4_anos)
    causas_evit_lista_0_4_anos <- causas_evit_lista_0_4_anos$value
  }
  if (!stringi::stri_enc_isascii(causas_evit_lista_0_4_anos)) {
    form_causas_evit_lista_0_4_anos <- paste0("SCausas_evit.-Lista_0_a_4_anos=", stringi::stri_escape_unicode(causas_evit_lista_0_4_anos))
  } else {
    form_causas_evit_lista_0_4_anos <- paste0("SCausas_evit.-Lista_0_a_4_anos=", causas_evit_lista_0_4_anos)
  }
  
  #causas_evit_lista_5_74_anos
  if (causas_evit_lista_5_74_anos %in% causas_evit_lista_5_74_anos.df$id) {
    causas_evit_lista_5_74_anos <- dplyr::filter(causas_evit_lista_5_74_anos.df, causas_evit_lista_5_74_anos.df$id %in% causas_evit_lista_5_74_anos)
    causas_evit_lista_5_74_anos <- causas_evit_lista_5_74_anos$value
  }
  if (!stringi::stri_enc_isascii(causas_evit_lista_5_74_anos)) {
    form_causas_evit_lista_5_74_anos <- paste0("SCausas_evit.-Lista_5_a_74_anos=", stringi::stri_escape_unicode(causas_evit_lista_5_74_anos))
  } else {
    form_causas_evit_lista_5_74_anos <- paste0("SCausas_evit.-Lista_5_a_74_anos=", causas_evit_lista_5_74_anos)
  }
  
  form_pesqmes14 <- "pesqmes14=Digite+o+texto+e+ache+f%E1cil"
  
  # mes_do_obito
  form_mes_do_obito <- dplyr::filter(mes_do_obito.df, mes_do_obito.df$id %in% mes_do_obito)
  form_mes_do_obito <- paste0("SM%EAs_do_%D3bito=", form_mes_do_obito$value, collapse = "&")
  
  form_pesqmes15 <- "pesqmes15=Digite+o+texto+e+ache+f%E1cil"
  
  # mes_ano_do_obito
  form_mes_ano_do_obito <- dplyr::filter(mes_ano_do_obito.df, mes_ano_do_obito.df$id %in% mes_ano_do_obito)
  form_mes_ano_do_obito <- paste0("SM%EAs%2FAno_do_%D3bito=", form_mes_ano_do_obito$value, collapse = "&")
  
  form_pesqmes16 <- "pesqmes16=Digite+o+texto+e+ache+f%E1cil"
  
  # faixa_etaria
  form_faixa_etaria <- dplyr::filter(faixa_etaria.df, faixa_etaria.df$id %in% faixa_etaria)
  form_faixa_etaria <- paste0("SFaixa_Et%E1ria=", form_faixa_etaria$value, collapse = "&")
  
  form_pesqmes17 <- "pesqmes17=Digite+o+texto+e+ache+f%E1cil"
  
  # faixa_etaria_detalhada
  form_faixa_etaria_detalhada <- dplyr::filter(faixa_etaria_detalhada.df, faixa_etaria_detalhada.df$id %in% faixa_etaria_detalhada)
  form_faixa_etaria_detalhada <- paste0("SFx.Et%E1ria_Detalhada=", form_faixa_etaria_detalhada$value, collapse = "&")
  
  form_pesqmes18 <- "pesqmes18=Digite+o+texto+e+ache+f%E1cil"
  
  # idade_detalhada
  form_idade_detalhada <- dplyr::filter(idade_detalhada.df, idade_detalhada.df$id %in% idade_detalhada)
  form_idade_detalhada <- paste0("SIdade_detalhada=", form_idade_detalhada$value, collapse = "&")
  
  form_pesqmes19 <- "pesqmes19=Digite+o+texto+e+ache+f%E1cil"
  
  # faixa_etaria_oms_ops
  form_faixa_etaria_oms_ops <- dplyr::filter(faixa_etaria_oms_ops.df, faixa_etaria_oms_ops.df$id %in% faixa_etaria_oms_ops)
  form_faixa_etaria_oms_ops <- paste0("SFx.Et%E1ria_OMS%2FOPS=", form_faixa_etaria_oms_ops$value, collapse = "&")
  
  
  #faixa_etaria_menor_1a
  if (faixa_etaria_menor_1a %in% faixa_etaria_menor_1a.df$id) {
    faixa_etaria_menor_1a <- dplyr::filter(faixa_etaria_menor_1a.df, faixa_etaria_menor_1a.df$id %in% faixa_etaria_menor_1a)
    faixa_etaria_menor_1a <- faixa_etaria_menor_1a$value
  }
  if (!stringi::stri_enc_isascii(faixa_etaria_menor_1a)) {
    form_faixa_etaria_menor_1a <- paste0("SFx.Et%E1ria_Menor_1A=", stringi::stri_escape_unicode(faixa_etaria_menor_1a))
  } else {
    form_faixa_etaria_menor_1a <- paste0("SFx.Et%E1ria_Menor_1A=", faixa_etaria_menor_1a)
  }
  
  #faixa_etaria_infancia_menor_6a
  if (faixa_etaria_infancia_menor_6a %in% faixa_etaria_infancia_menor_6a.df$id) {
    faixa_etaria_infancia_menor_6a <- dplyr::filter(faixa_etaria_infancia_menor_6a.df, faixa_etaria_infancia_menor_6a.df$id %in% faixa_etaria_infancia_menor_6a)
    faixa_etaria_infancia_menor_6a <- faixa_etaria_infancia_menor_6a$value
  }
  if (!stringi::stri_enc_isascii(faixa_etaria_infancia_menor_6a)) {
    form_faixa_etaria_infancia_menor_6a <- paste0("SFx.Et%E1ria_Inf%E2ncia_Menor_6A=", stringi::stri_escape_unicode(faixa_etaria_infancia_menor_6a))
  } else {
    form_faixa_etaria_infancia_menor_6a <- paste0("SFx.Et%E1ria_Inf%E2ncia_Menor_6A=", faixa_etaria_infancia_menor_6a)
  }
  
  #sexo
  if (sexo %in% sexo.df$id) {
    sexo <- dplyr::filter(sexo.df, sexo.df$id %in% sexo)
    sexo <- sexo$value
  }
  if (!stringi::stri_enc_isascii(sexo)) {
    form_sexo <- paste0("SSexo=", stringi::stri_escape_unicode(sexo))
  } else {
    form_sexo <- paste0("SSexo=", sexo)
  }
  
  #cor_raca
  if (cor_raca %in% cor_raca.df$id) {
    cor_raca <- dplyr::filter(cor_raca.df, cor_raca.df$id %in% cor_raca)
    cor_raca <- cor_raca$value
  }
  if (!stringi::stri_enc_isascii(cor_raca)) {
    form_cor_raca <- paste0("SRa%E7a%2Fcor=", stringi::stri_escape_unicode(cor_raca))
  } else {
    form_cor_raca <- paste0("SRa%E7a%2Fcor=", cor_raca)
  }
  
  #escolaridade
  if (escolaridade %in% escolaridade.df$id) {
    escolaridade <- dplyr::filter(escolaridade.df, escolaridade.df$id %in% escolaridade)
    escolaridade <- escolaridade$value
  }
  if (!stringi::stri_enc_isascii(escolaridade)) {
    form_escolaridade <- paste0("SEscolaridade=", stringi::stri_escape_unicode(escolaridade))
  } else {
    form_escolaridade <- paste0("SEscolaridade=", escolaridade)
  }
  
  #estado_civil
  if (estado_civil %in% estado_civil.df$id) {
    estado_civil <- dplyr::filter(estado_civil.df, estado_civil.df$id %in% estado_civil)
    estado_civil <- estado_civil$value
  }
  if (!stringi::stri_enc_isascii(estado_civil)) {
    form_estado_civil <- paste0("SEstado_Civil=", stringi::stri_escape_unicode(estado_civil))
  } else {
    form_estado_civil <- paste0("SEstado_Civil=", estado_civil)
  }
  
  
  form_pesqmes26 <- "pesqmes26=Digite+o+texto+e+ache+f%E1cil"
  
  # ocupacao_grande_grupo
  form_ocupacao_grande_grupo <- dplyr::filter(ocupacao_grande_grupo.df, ocupacao_grande_grupo.df$id %in% ocupacao_grande_grupo)
  form_ocupacao_grande_grupo <- paste0("SOcupa%E7%E3o-Grande_grupo=", form_ocupacao_grande_grupo$value, collapse = "&")
  
  form_pesqmes27 <- "pesqmes27=Digite+o+texto+e+ache+f%E1cil"
  
  # ocupacao_subgrupo_principal
  form_ocupacao_subgrupo_principal <- dplyr::filter(ocupacao_subgrupo_principal.df, ocupacao_subgrupo_principal.df$id %in% ocupacao_subgrupo_principal)
  form_ocupacao_subgrupo_principal <- paste0("SOcupa%E7%E3o-Subgrupo_principal=", form_ocupacao_subgrupo_principal$value, collapse = "&")
  
  form_pesqmes28 <- "pesqmes28=Digite+o+texto+e+ache+f%E1cil"
  
  # ocupacao_subgrupo_principal
  form_ocupacao_subgrupo_3d <- dplyr::filter(ocupacao_subgrupo_3d.df, ocupacao_subgrupo_3d.df$id %in% ocupacao_subgrupo_3d)
  form_ocupacao_subgrupo_3d <- paste0("SOcupa%E7%E3o-Subgrupo_3d=", form_ocupacao_subgrupo_3d$value, collapse = "&")
  
  form_pesqmes29 <- "pesqmes29=Digite+o+texto+e+ache+f%E1cil"
  
  # ocupacao_familia_4d
  form_ocupacao_familia_4d <- dplyr::filter(ocupacao_familia_4d.df, ocupacao_familia_4d.df$id %in% ocupacao_familia_4d)
  form_ocupacao_familia_4d <- paste0("SOcupa%E7%E3o_Fam%EDlia_4d=", form_ocupacao_familia_4d$value, collapse = "&")
  
  form_pesqmes30 <- "pesqmes30=Digite+o+texto+e+ache+f%E1cil"
  
  # ocupacao
  form_ocupacao <- dplyr::filter(ocupacao.df, ocupacao.df$id %in% ocupacao)
  form_ocupacao <- paste0("SOcupa%E7%E3o=", form_ocupacao$value, collapse = "&")
  
  #local_ocorrencia
  if (local_ocorrencia %in% local_ocorrencia.df$id) {
    local_ocorrencia <- dplyr::filter(local_ocorrencia.df, local_ocorrencia.df$id %in% local_ocorrencia)
    local_ocorrencia <- local_ocorrencia$value
  }
  if (!stringi::stri_enc_isascii(local_ocorrencia)) {
    form_local_ocorrencia <- paste0("SLocal_Ocorr%EAncia=", stringi::stri_escape_unicode(local_ocorrencia))
  } else {
    form_local_ocorrencia <- paste0("SLocal_Ocorr%EAncia=", local_ocorrencia)
  }
  
  #assitencia_medica
  if (assitencia_medica %in% assitencia_medica.df$id) {
    assitencia_medica <- dplyr::filter(assitencia_medica.df, assitencia_medica.df$id %in% assitencia_medica)
    assitencia_medica <- assitencia_medica$value
  }
  if (!stringi::stri_enc_isascii(assitencia_medica)) {
    form_assitencia_medica <- paste0("SAssist%EAncia_M%E9dica=", stringi::stri_escape_unicode(assitencia_medica))
  } else {
    form_assitencia_medica <- paste0("SAssist%EAncia_M%E9dica=", assitencia_medica)
  }
  
  #atestante
  if (atestante %in% atestante.df$id) {
    atestante <- dplyr::filter(atestante.df,atestante.df$id %in% atestante)
    atestante <- atestante$value
  }
  if (!stringi::stri_enc_isascii(atestante)) {
    form_atestante <- paste0("SAtestante=", stringi::stri_escape_unicode(atestante))
  } else {
    form_atestante <- paste0("SAtestante=", atestante)
  }
  
  
  
  
  
  
  form_data <- paste(form_linha, form_coluna, form_conteudo, form_periodo, 
                     form_pesqmes1, form_municipio, form_pesqmes2, form_cir, form_pesqmes3, form_divisao_administ_estadual,
                     form_pesqmes4, form_macrorregiao_de_saude, form_pesqmes5, form_territorio_desenv_mg, form_ride,
                     form_pesqmes7, form_capitulo_cid10, form_pesqmes8, form_grupo_cid10, form_pesqmes9, form_causa_cidbr10, 
                     form_pesqmes10, form_categoria_cid10, form_causas_mal_definidas, form_causas_evit_lista_0_4_anos, 
                     form_causas_evit_lista_5_74_anos, form_pesqmes14, form_mes_do_obito, form_pesqmes15, form_mes_ano_do_obito,
                     form_pesqmes16, form_faixa_etaria, form_pesqmes17, form_faixa_etaria_detalhada, form_pesqmes18, form_idade_detalhada, 
                     form_pesqmes19, form_faixa_etaria_oms_ops, form_faixa_etaria_menor_1a, form_faixa_etaria_infancia_menor_6a, 
                     form_sexo, form_cor_raca, form_escolaridade, form_estado_civil, form_pesqmes26, form_ocupacao_grande_grupo,
                     form_pesqmes27, form_ocupacao_subgrupo_principal, form_pesqmes28, form_ocupacao_subgrupo_3d, form_pesqmes29, 
                     form_ocupacao_familia_4d, form_pesqmes30, form_ocupacao, form_local_ocorrencia, form_assitencia_medica, form_atestante,
                     "formato=table&zeradas=exibirlz&mostre=Mostra", sep = "&")
  
  
  form_data <- gsub("\\\\u00", "%", form_data)
  
  
  
  ##### REQUEST FORM AND DATA WRANGLING ####
  site <- httr::POST(url = "http://tabnet.saude.mg.gov.br/tabcgi.exe?def/obitos/geralr.def",
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