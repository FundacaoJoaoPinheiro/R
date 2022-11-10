# -------------------------------------------------------------------------
# Script para cálculo de transferências. Versão 11. -----------------------
# -------------------------------------------------------------------------


#### Pacotes necessários 

#install.packages("janitor")
#install.packages("Rcpp")
#install.packages("openxlsx)
#library(Rcpp) (integração R e C++)

library(tidyverse)
library(readxl)
library(janitor)
library(openxlsx)

### Limpar arquivos brutos:

source("./scripts/limpar_bases.r", encoding = "UTF-8")

options(warn = -1)


#### Importando os dados das portarias ---------------------------

pesos <- read_csv2("./parametros/Pesos_ICMS_IPI.csv")

portaria_ICMS <- read_excel("./bases_limpas/Portaria_ICMS.xlsx")

portaria_IPI <- read_excel("./bases_limpas/Portaria_IPI.xlsx")



#### Executando o script que confere os nomes das colunas em cada portaria ---------------------------

source("./scripts/conferir_portarias.R", encoding = "UTF-8")




#### Armazenando os meses definidos na portaria de ICMS atual ----------------------
##
## A portaria de ICMS, em geral inclui valores
## brutos transferidos, que dizem respeito a diversos
## meses diferentes do ano.
##
## Abaixo estou olhando para os nomes dessas colunas que
## contém os valores brutos, e extraindo o mês que
## está definido no nome dessa coluna. Pois eu utilizarei
## esses valores mais a frente para renomear corretamente
## essas colunas, em um formato que fique fácil de me referir.

meses_atuais <- list(
  colunas_bruto = grep("Bruto", colnames(portaria_ICMS), value = TRUE)
)

meses_atuais$meses <- str_extract(
  meses_atuais$colunas_bruto,
  pattern = paste(meses_ano$nome_completo, collapse = "|", sep = "")
)

meses_atuais$anos <- str_extract(
  meses_atuais$colunas_bruto,
  pattern = "\\d{4}"
)

meses_atuais$nomes <- str_c(meses_atuais$meses, meses_atuais$anos, sep = "_")


colnames(portaria_ICMS)[str_detect(colnames(portaria_ICMS), "Bruto")] <- meses_atuais$nomes




#### Recalculando os valores das portarias para cada município ----------------------
## Portaria de IPI
portaria_IPI <- portaria_IPI %>% 
  select(-`Líquido`) %>% 
  mutate(
    Liquido_IPI = Bruto - FUNDEB - PASEP
  )

## Portaria de ICMS
portaria_ICMS <- portaria_ICMS %>% 
  select(-`Líquido`) %>% 
  left_join(
    portaria_IPI[,c("SEF", "Liquido_IPI")],
    by = "SEF"
  ) %>% 
  mutate(
    Bruto_ICMS_total = rowSums(
      select(portaria_ICMS, all_of(meses_atuais$nomes)),
      na.rm = TRUE
    ),
    Liquido_ICMS = Bruto_ICMS_total - FUNDEB + `Compensações`,
    ICMS_IPI_Liq = Liquido_ICMS + Liquido_IPI
  )









#### Calculando o valor total de ICMS para cada critério ----------------------

ICMS_total <- map_dbl(
    portaria_ICMS %>% select(all_of(meses_atuais$nomes)),
    ~sum(., na.rm = TRUE)
  )

ICMS_total <- sort(ICMS_total)

lista_pesos <- map(
  names(ICMS_total),
  function(x){
    valor <- ICMS_total[x]
    return(pesos$Pesos_ICMS * valor)
  })

names(lista_pesos) <- names(ICMS_total)

lista_pesos <- bind_cols(pesos, lista_pesos)










#### Importando os dados dos Indices - IDX ---------------------------------

arquivos_idx <- str_c("./bases_limpas", list.files("./bases_limpas")[str_detect(list.files("./bases_limpas"), "Idx")], sep = "/")

lista_idx <- map(arquivos_idx, ~read.xlsx(., sep.names = " ") %>% arrange(IBGE2))


nomes_idx <- function(){
  meses <- map_chr(lista_idx, function(x) unique(x$`Mês`))
  anos <- map_chr(lista_idx, function(x) as.character(unique(x$Ano)))
  
  nomes <- str_c(meses, anos, sep = "_")
  return(nomes)
}



#### Conferindo os nomes das colunas além dos meses definidos nos arquivos de IDX

source("./scripts/conferir_idx.R", encoding = "UTF-8")



## Caso as colunas estejam nomeadas corretamente,
## eu renomeio os elementos da lista que guarda
## as diferentes planilhas de IDX para que eu não
## perca a localização dessas planilhas.

names(lista_idx) <- nomes_idx()

colunas_de_identificacao <- c(
  "Ano",
  "Mês",
  "IBGE1",
  "IBGE2",
  "SEF",
  "Municípios"
)

codigos <- lista_idx[[1]] %>% 
  select(SEF, IBGE2, IBGE1)






#### Conferindo o somatório das colunas do IDX

conferir_100 <- function(nome_idx){
  
  totais <- map_dbl(
      lista_idx[[nome_idx]] %>% select(-all_of(colunas_de_identificacao)) %>%
        mutate(across(.fns = as.numeric)),
      ~sum(., na.rm = TRUE)
    )
  
  totais <- round(totais, digits = 8)
  
  if(any(totais != 100)){
    x <- totais[totais != 100]
    print(x)
    print(nome_idx)
    stop("Os índices dos critérios do Idx definido acima, não somam 100%:")
  }

}

for(i in names(lista_idx)){
  conferir_100(i)
}





#### Conferindo a ordenação das bases de Idx e das portarias da SEF ------------------
portaria_ICMS <- portaria_ICMS %>% 
  left_join(codigos) %>% 
  arrange(IBGE2)

portaria_IPI <- portaria_IPI %>% 
  left_join(codigos) %>% 
  arrange(IBGE2)






### Calculando os valores brutos de ICMS transferidos ---------------------------
##
## Função responsável por calcular os valores de ICMS transferidos

calc_ICMS <- function(x, Idx){
  
  mes <- unique(Idx$`Mês`)
  ano <- unique(Idx$Ano)
  mes_ano <- paste(mes, ano, sep = "_")
  
  valor_total <- lista_pesos %>% 
    select(Indices, all_of(mes_ano)) %>% 
    filter(Indices == x)
    
  n_linhas <- nrow(valor_total)
  
  if(is.null(valor_total)){
    stop(paste("O valor total não foi encontrado para o critério ", x, sep = ""))
  } else
  if(n_linhas > 1){
    stop(paste("Mais de um valor total foi encontrado para o critério ", x, sep = ""))
  }
  
  valor_total <- valor_total[[mes_ano]]
  
  indices <- Idx[c("IBGE2", "Mês", "Ano", x)] %>% arrange(IBGE2)
  
  colnames(indices)[colnames(indices) == x] <- "Indice"
  
  indices$valor <- (indices[["Indice"]]/100) * valor_total
  
  indices$criterio <- x
  
  return(indices)
  
}


## Selecionando as colunas dos critérios sobre as quais os valores
## de ICMS serão calculados

teste <- !colnames(lista_idx[[1]]) %in% colunas_de_identificacao

colunas <- colnames(lista_idx[[1]])[teste]


## Executando a função que irá calcular os valores
## de ICMS bruto para cada mês

lista <- map(
    lista_idx,
    function(idx){map_df(colunas, function(x) calc_ICMS(x, idx))}
  ) 

ICMS_bruto <- lista %>% 
  map(
    ~pivot_wider(
      data = .,
      id_cols = c("IBGE2", "Mês", "Ano"),
      names_from = "criterio",
      values_from = "valor"
    ) %>% 
    arrange(IBGE2)
  )

rm(lista)






#### Ajustando os valores calculados para os primeiros meses --------------------------------
##
## Em geral, pelo menos um dos meses de valores
## brutos descritos na portaria de ICMS, necessitam de
## ajuste no cálculo. Pois pelo menos um dos municípios
## naquele mês, não recebeu nada (ou em outras palavras
## recebeu 0$ de valor bruto naquele mês).

## Identificando quais meses precisam de ajuste

teste <- map_lgl(
    portaria_ICMS %>% select(all_of(meses_atuais$nomes)),
    ~any(`==`(., 0))
  )

meses_que_precisam_ajuste <- teste[teste]



## Definindo a função que irá recalcular os índices do Idx
## nos meses que necessitam de ajuste.

calc_novos_indices_ICMS <- function(mes_a_ajustar){
  
  transf <- data.frame(
    transf = portaria_ICMS[[mes_a_ajustar]],
    IBGE2 = portaria_ICMS[["IBGE2"]]
  )
  
  ICMS_total_do_mes <- sum(transf$transf, na.rm = TRUE)
  
  if(is.null(mes_a_ajustar)){
    cat("Não é necessário nenhum ajuste nos índices.")
    return(NULL)
  } else
  if(!is.null(mes_a_ajustar)){
    transf <- transf %>% 
      mutate(
        novos_indices = transf * 100/ICMS_total_do_mes,
        mes_a_ajustar = mes_a_ajustar
      ) %>% 
      select(IBGE2, novos_indices, mes_a_ajustar)
      
    return(as_tibble(transf))
  }
}



calc_novos_indices_IPI <- function(){
  
  transf <- portaria_IPI[c("Liquido_IPI", "IBGE2")]
  
  IPI_total_do_mes <- sum(transf$Liquido_IPI, na.rm = TRUE)
  
  if(!valores_sao_iguais){
    transf <- transf %>% 
      mutate(
        novos_indices = Liquido_IPI * 100/IPI_total_do_mes,
        mes_a_ajustar = Mes_IPI_Idx
      ) %>% 
      select(IBGE2, novos_indices, mes_a_ajustar)
    
    return(as_tibble(transf))
  }
}





## Definindo a função que irá recalcular os valores de ICMS
## transferidos sobre os novos índices calculados pela
## função calc_novos_indices_ICMS().

ajuste <- function(mes, portaria){
  
  if(portaria == "ICMS"){
    novos_indices <- calc_novos_indices_ICMS(mes_a_ajustar = mes)
  }
  if(portaria == "IPI"){
    novos_indices <- do.call("calc_novos_indices_IPI", args = list())
  }
  
  if(!is.null(novos_indices)){
  
  Idx <- lista_idx[[mes]]
  
  colunas_a_acertar <- colnames(Idx)[
    !colnames(Idx) %in% colunas_de_identificacao &
    !colnames(Idx) %in% "Índice de participação"
  ]
  
  Idx <- Idx %>% 
    left_join(novos_indices, by = "IBGE2")
  
  rescale <- function(x){x * Idx$novos_indices/Idx$`Índice de participação`}
  
  Idx <- Idx %>% 
    mutate(
      dplyr::across(all_of(colunas_a_acertar), rescale)
    ) %>% 
    mutate(
      `Índice de participação` = novos_indices,
      mes_ajustado = mes
    )
  
  return(Idx)
  }
}


## Executando a função de ajuste

valores_ajustados <- map(names(meses_que_precisam_ajuste), ~ajuste(., portaria = "ICMS"))

names(valores_ajustados) <- names(meses_que_precisam_ajuste)



## Caso os valores de mais de um mês precisam
## ser ajustados, fica mais fácil executar essa ação
## de ajuste, através de um for() loop. Mas caso
## apenas um mês necessita deste ajuste, uma função
## map_df() dá conta do recado.

if(length(meses_que_precisam_ajuste) == 1){
  
  ICMS_bruto[[names(meses_que_precisam_ajuste)]] <- map_df(
      colunas,
      function(x) calc_ICMS(x, valores_ajustados[[1]])
    ) %>% 
    pivot_wider(
      id_cols = c("IBGE2", "Ano", "Mês", "criterio"),
      names_from = "criterio",
      values_from = "valor"
    ) %>% 
    arrange(IBGE2) 
  
} else 
  
if(length(meses_que_precisam_ajuste) > 1){
  
   for(i in names(meses_que_precisam_ajuste)){
     ICMS_bruto[[i]] <- map_df(
         colunas,
         function(x) calc_ICMS(x, valores_ajustados[[i]])
       ) %>% 
       pivot_wider(
         id_cols = c("IBGE2", "Ano", "Mês", "criterio"),
         names_from = "criterio",
         values_from = "valor"
       ) %>% 
       arrange(IBGE2) 
   }

}

rm(valores_ajustados)





#### Calculando o somatório dos valores brutos e líquidos de cada mês -------------------------
##
## Agora que temos os valores corretos de ICMS
## bruto para cada mês, podemos, somar os valores
## desses meses, para chegar aos valores de ICMS
## Bruto Total.

ICMS_bruto <- map(ICMS_bruto, ~select(., IBGE2, all_of(colunas)))

ICMS_bruto_total <- purrr::reduce(ICMS_bruto, `+`)

ICMS_bruto_total$IBGE2 <- sort(lista_idx[[1]][["IBGE2"]])


## Vamos aproveitar, e já calcular os valores
## de ICMS Líquido Total.

ICMS_Liq <- 0.8 * ICMS_bruto_total

ICMS_Liq$IBGE2 <- sort(lista_idx[[1]][["IBGE2"]])







#### Calculando os valores líquidos de IPI transferidos ----------------------------

IPI_Liq_total <- sum(portaria_IPI$Liquido_IPI, na.rm = TRUE)

pesos_IPI <- pesos %>% 
  mutate(
    valor_IPI = IPI_Liq_total * Pesos_IPI
  )


## Função responsável por calcular os valores de IPI transferidos

calc_IPI <- function(x, Idx){
  
  mes <- unique(Idx$`Mês`)
  ano <- unique(Idx$Ano)
  mes_ano <- paste(mes, ano, sep = "_")
  
  valor_total <- pesos_IPI %>% 
    select(Indices, valor_IPI) %>% 
    filter(Indices == x)
  
  n_linhas <- nrow(valor_total)
  
  if(is.null(valor_total)){
    stop(paste("O valor total não foi encontrado para o critério ", x, sep = ""))
  } else
  if(n_linhas > 1){
    stop(paste("Mais de um valor total foi encontrado para o critério ", x, sep = ""))
  }
  
  valor_total <- valor_total[["valor_IPI"]]
  
  indices <- Idx[c("IBGE2", "Mês", "Ano", x)] %>% arrange(IBGE2)
  
  colnames(indices)[colnames(indices) == x] <- "Indice"
  
  indices$valor <- (indices[["Indice"]]/100) * valor_total
  
  indices$criterio <- x
  
  return(indices)
  
}



## Definindo as colunas dos critérios

colunas <- colnames(lista_idx[[1]])[!colnames(lista_idx[[1]]) %in% colunas_de_identificacao]


## Definindo o mês que a portaria de IPI se refere

Mes_IPI_Idx <- str_c(
  unique(portaria_IPI$`Mês`),
  unique(portaria_IPI$Ano),
  sep = "_"
)


## Executando a função de cálculo dos valores transferidos de IPI

lista <- map_df(colunas, ~calc_IPI(., lista_idx[[Mes_IPI_Idx]]))

IPI_Liq <- lista %>% 
  pivot_wider(
    id_cols = c("IBGE2", "Mês", "Ano"),
    names_from = "criterio",
    values_from = "valor"
  ) %>% 
  arrange(IBGE2)

rm(lista)









#### Somando os valores líquidos de ICMS e IPI -------------------------------------

ICMS_IPI_Liq <- ICMS_Liq[colunas] + IPI_Liq[colunas]

ICMS_IPI_Liq$IBGE2 <- sort(lista_idx[[1]][["IBGE2"]])

ICMS_IPI_Liq$IBGE1 <- sort(lista_idx[[1]][["IBGE1"]])

ICMS_IPI_Liq <- ICMS_IPI_Liq %>% 
  left_join(
    portaria_ICMS[c("IBGE2", "Compensações")],
    by = "IBGE2"
  ) %>% 
  mutate(
    "Valor Líquido + Compensações" = `Índice de participação` + `Compensações`
  ) %>% 
  select(IBGE2, IBGE1, everything()) %>% 
  as_tibble() %>%
  mutate(across(where(is.numeric), round, digits = 2)) 
  



#### Conferindo os resultados finais e aplicando um método alternativo de cálculo, caso necessário -----------------------------

## Todo o script acima, serve para a maioria
## das ocasiões.
##
## Na maioria das vezes, a portaria de ICMS
## possui diferentes meses de valores brutos.
## Sendo que geralmente os valores brutos de
## vários municípios nos primeiros meses, estão
## zerados, e por isso, um ajuste sobre os índices
## do IDX é necessário na hora de calcular o valor
## bruto de ICMS para esses primeiros meses.
##
## Porém, pode ser que até os meses que
## não possuem nenhum município com o valor zerado,
## necessitem deste ajuste nos índices de IDX. Isso
## vai depender se os valores daquele mês foram distribuídos
## segundo um índice diferente do IDX daquele mês (pode
## ser que a SEF tenha se enganado e distribuído o
## valor total segundo os índices de um mês diferente).
##
## A forma mais fácil de verificar isso, é utilizar os
## índices de participação final de seu IDX sobre o 
## ICMS total bruto daquele mês na portaria de ICMS. Ao
## calcular os valores totais de ICMS bruto para cada
## município segundo esses índices de participação, basta
## comparar esses valores com os valores da portaria e
## verificar se há alguma diferença significativa entre
## eles. Caso haja alguma diferença, é sinal de que
## o ICMS total bruto daquele mês foi distribuído segundo
## índices de participação diferentes do IDX daquele mês.
##
## O script abaixo, irá verificar se o cálculo do script
## anterior (caso geral) foi suficiente. Em outras palavras
## ele irá comparar se os valores totais de ICMS e IPI líquidos
## gerados pelo script anterior, estão de acordo com os
## valores de ICMS e IPI líquidos da portaria de ICMS.
## Caso ele encontre alguma diferença, o método alternativo de
## ajuste abaixo será aplicado.

resultados_finais <- ICMS_IPI_Liq %>% 
  select(IBGE2, `Valor Líquido + Compensações`) %>% 
  left_join(
    portaria_ICMS[c("IBGE2", "ICMS_IPI_Liq")],
    by = "IBGE2"
  ) %>% 
  mutate(
    Diferenca = `Valor Líquido + Compensações` - ICMS_IPI_Liq,
    Igual = abs(Diferenca) < 2
  )


## Caso a diferença entre os todos os valores calculados
## e os valores da portaria não passe de $2, a
## função abaixo irá retornar TRUE. Caso essa situação
## não se sustente para algum município, a função
## irá retornar FALSE, e o método alternativo de ajuste
## será aplicado

valores_sao_iguais <- all(resultados_finais$Igual)


## Caso o script esteja executando o método alternativo
## de cálculo, mas você deseja evitar este comportamento
## sete este objeto para FALSE

voce_quer_utilizar_metodo_alternativo <- TRUE


if(!valores_sao_iguais & voce_quer_utilizar_metodo_alternativo){
  
  warning("Método alternativo de ajuste foi utilizado.")

  valores_nao_respeitam_idx <- function(x){
    
    idx <- x[c("IBGE2", "Índice de participação")]
    
    mes <- unique(x[["Mês"]])
    ano <- unique(x[["Ano"]])
    mes_ano <- str_c(mes, ano, sep = "_")
    
    ICMS_total_do_mes <- ICMS_total[mes_ano]
    
    idx <- idx %>% 
      mutate(
        valores_calculados = (`Índice de participação`/100) * ICMS_total_do_mes
      )
    
    idx <- idx %>% 
      left_join(
        portaria_ICMS %>% select(IBGE2, all_of(mes_ano)),
        by = "IBGE2"
      )
    
    colnames(idx)[str_detect(colnames(idx), mes_ano)] <- "valores_portaria"
    
    teste <- all(
      near(idx$valores_calculados, idx$valores_portaria, tol = 2)
    )
    
    return(teste)
    
  }
  
  
  
  teste <- map_lgl(lista_idx, valores_nao_respeitam_idx)
  
  meses_que_precisam_ajuste <- teste[!teste]
  
  
  
  valores_ajustados <- map(names(meses_que_precisam_ajuste), ~ajuste(., portaria = "ICMS"))
  
  names(valores_ajustados) <- names(meses_que_precisam_ajuste)
  
  
  
  
  for(i in names(meses_que_precisam_ajuste)){
    ICMS_bruto[[i]] <- map_df(
      colunas,
      function(x) calc_ICMS(x, valores_ajustados[[i]])
    ) %>% 
      pivot_wider(
        id_cols = c("IBGE2", "Ano", "Mês", "criterio"),
        names_from = "criterio",
        values_from = "valor"
      ) %>% 
      arrange(IBGE2) 
  }
  
  

  
  
  resultados_finais_IPI <- IPI_Liq %>% 
    select(IBGE2, `Índice de participação`) %>% 
    left_join(
      portaria_IPI[c("IBGE2", "Liquido_IPI")],
      by = "IBGE2"
    ) %>% 
    mutate(
      Diferenca = `Índice de participação` - Liquido_IPI,
      Igual = abs(Diferenca) < 2
    )
  
  valores_sao_iguais <- all(resultados_finais_IPI$Igual)
  
  
  if(!valores_sao_iguais){
  
    valores_ajustados <- ajuste(Mes_IPI_Idx, portaria = "IPI")
    
    lista <- map_df(colunas, ~calc_IPI(., valores_ajustados))
    
    IPI_Liq <- lista %>% 
      pivot_wider(
        id_cols = c("IBGE2", "criterio", "Mês", "Ano"),
        names_from = "criterio",
        values_from = "valor"
      ) %>% 
      arrange(IBGE2)
    
    rm(lista)
    rm(valores_ajustados)
  
  }
  
  
  
  #### Calculando o somatório dos valores brutos e líquidos de cada mês 
  
  ## Agora que temos os valores corretos de ICMS
  ## bruto para cada mês, podemos, somar os valores
  ## desses meses, para chegar aos valores de ICMS
  ## Bruto Total.
  
  ICMS_bruto <- map(ICMS_bruto, ~select(., IBGE2, all_of(colunas)))
  
  ICMS_bruto_total <- purrr::reduce(ICMS_bruto, `+`)
  
  ICMS_bruto_total$IBGE2 <- sort(lista_idx[[1]][["IBGE2"]])
  
  
  ## Vamos aproveitar, e já calcular os valores
  ## de ICMS Líquido Total.
  
  ICMS_Liq <- 0.8 * ICMS_bruto_total
  
  ICMS_Liq$IBGE2 <- sort(lista_idx[[1]][["IBGE2"]])
  
  
  ICMS_IPI_Liq <- ICMS_Liq[colunas] + IPI_Liq[colunas]
  
  ICMS_IPI_Liq$IBGE2 <- sort(lista_idx[[1]][["IBGE2"]])
  
  ICMS_IPI_Liq$IBGE1 <- sort(lista_idx[[1]][["IBGE1"]])
  
  ICMS_IPI_Liq <- ICMS_IPI_Liq %>% 
    left_join(
      portaria_ICMS[c("IBGE2", "Compensações")],
      by = "IBGE2"
    ) %>% 
    mutate(
      "Valor Líquido + Compensações" = `Índice de participação` + `Compensações`
    ) %>% 
    select(IBGE2, IBGE1, everything()) %>% 
    as_tibble()
  
  
}




teste <- meses_ano$nome_completo %in% meses_atuais$meses

mes_mais_recente <- last(meses_ano$meses_factor[teste])

ano_atual <- max(meses_atuais$anos)


if (teste[1] & teste[12] == TRUE){  #Corrige caso especial dezembro/janeiro
  mes_mais_recente <- "Janeiro"
}


ICMS_IPI_Liq <- ICMS_IPI_Liq %>% 
  mutate(
    Ano = ano_atual,
    "Mês" = mes_mais_recente
  ) %>% 
  select(`Mês`, Ano, everything()) %>%
  adorn_totals("row", ... = -c(`Mês`, Ano, IBGE2, IBGE1)) %>%
 mutate(Ano = as.numeric(Ano),
  IBGE2 = as.numeric(IBGE2),
  IBGE1 = as.numeric(IBGE1))
  






#### Exportando os resultados finais

write.csv2(ICMS_IPI_Liq, "./resultados/Resultado_final.csv", row.names = FALSE)

#### Exportando os resultados finais para excel


write.xlsx(ICMS_IPI_Liq, "./resultados/Resultado_final.xlsx", overwrite = TRUE)
print("Cálculo das transferências efetuado com sucesso - Arquivos de Resultado Final gerados")


### Chamando script gerador do CSV do site

source("./scripts/Site_transferencias.r", encoding = "UTF-8")

### Encerramento:

print("Script executado. Arquivos gerados na pasta saidas.")


# FIM ---------------------------------------------------------------------
