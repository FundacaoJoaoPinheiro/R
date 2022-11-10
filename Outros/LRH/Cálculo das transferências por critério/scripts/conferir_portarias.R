library(tidyverse)


## Construindo uma tabela que contém 
## os meses do ano, que será utilizada
## para conferir a ortografia dos nomes
## das coluans que contém os valores brutos
## transferidos.

meses_ano <- tribble(
  ~nome_completo, ~abrev,
  "Janeiro","Jan",
  "Fevereiro", "Fev",
  "Março", "Mar",
  "Abril","Abr",
  "Maio","Mai",
  "Junho","Jun",
  "Julho","Jul",
  "Agosto","Ago",
  "Setembro","Set",
  "Outubro","Out",
  "Novembro","Nov",
  "Dezembro","Dez"
)


meses_ano$meses_factor <- factor(meses_ano$nome_completo, levels = meses_ano$nome_completo)


#### Conferindo os nomes das colunas da portaria de ICMS ------------------------------
##
## Definindo os nomes das colunas que a portaria
## de ICMS deveria possuir

colunas_corretas_ICMS <- c("Ano", "Mês", "SEF", "Município", "Índice", "FUNDEB",
                      "Compensações", "Saúde", "Líquido")


## Concatenando os nomes completos dos meses com o
## operador lógico |

meses <- paste(meses_ano$nome_completo, collapse = "|", sep = "")



## Abaixo, estou selecionando os nomes das planilhas de Idx
## que estão presentes na pasta. Com isso, eu estou interessado
## na quantidade de planilhas de Idx, e não nos nomes dessas
## planilhas em si. Pois, vou comparar logo abaixo, o número
## de colunas de valores brutos encontrados na portaria de ICMS
## pela função localizando_brutos(), com o número de arquivos de
## Idx presentes na pasta. Caso esse valor seja diferente, ou alguma
## das colunas de valores brutos não foi encontrada na portaria de
## ICMS; ou então, você esqueceu de incluir algum arquivo de Idx na pasta.

quantidade_idx <- list.files("./bases_limpas")[str_detect(list.files("./bases_limpas"), "Idx")]


## Definindo a função que irá conferir se 
## os nomes das colunas que contém os valores brutos
## transferidos, estão escritos corretamente.
## Ou seja, a função confere a ortografia desses nomes,
## pois esses nomes serão utilizados para identificar esses
## dados, especialmente a qual mês e ano eles pertencem.

localizando_brutos <- function(x){
  
  teste_brutos <- str_detect(
    x,
    paste("Bruto ", "(", meses, ")", "\\s\\d{4}", collapse = "", sep = "")
  )
  
  brutos <- x[teste_brutos]
  
  if(length(brutos) < 1){
    stop("Não foram encontradas as colunas de transferências brutas na portaria de ICMS. Confira se o nome dessas colunas no arquivo estão no formato indicado abaixo:\n\nBruto Mês (Nome completo) Ano (4 dígitos)\n\nExemplos:\n*Bruto Janeiro 2019\n*Bruto Março 2018\n*Bruto Julho 2020")
  } else
  if(length(brutos) != length(quantidade_idx)){
    stop("O número de colunas encontradas na portaria de ICMS, que contém valores brutos, está diferente do número de arquivos de Idx presentes atualmente na pasta. Por favor, confira se os nomes das colunas de sua portaria de ICMS, que contém valores brutos estão no formato abaixo:\n\nBruto Mês (Nome completo) Ano (4 dígitos)\n\nExemplos:\n*Bruto Janeiro 2019\n*Bruto Março 2018\n*Bruto Julho 2020\n\nConfira todos os espaços, por exemplo, se não há algum espaço sobrando após o nome dessas colunas. Caso esses nomes estejam corretos, confirme se você não se esqueceu de incluir na pasta, o arquivo de Idx de algum dos meses definidos na portaria de ICMS.")
  }
  
}





## Definindo a função que irá conferir os nomes
## de todas as colunas na portaria de ICMS.

conferir_portaria_ICMS <- function(x){
  
  nomes_da_portaria <- colnames(x)
  
  localizando_brutos(nomes_da_portaria)
  
  teste <- all(colunas_corretas_ICMS %in% nomes_da_portaria)
  
  if(!teste){
    print(as.character(colunas_corretas_ICMS[!colunas_corretas_ICMS %in% nomes_da_portaria], "\n"))
    stop("A portaria de ICMS, não possui as colunas definidas acima. Confirme se a ortografia dos nomes de cada coluna estão corretas. Caso queira ver a lista completa com os nomes corretos das colunas, que a portaria deveria possuir, execute o seguinte comando:\n\nprint(colunas_corretas_ICMS)")
  }
  
  return(teste)
}



## Executando a função que irá conferir
## os nomes das colunas da portaria de ICMS

conferir_portaria_ICMS(portaria_ICMS)








## Definindo os nomes das colunas que a portaria de IPI
## deveria possuir.

colunas_corretas_IPI <- c("Ano", "Mês", "SEF", "Município", "Índice", "Bruto", "FUNDEB",
                          "PASEP", "Saúde", "Líquido")


## Definindo a função que irá conferir
## os nomes das colunas na portaria de IPI.

conferir_portaria_IPI <- function(x){
  
  nomes_da_portaria <- colnames(x)
  
  teste <- all(colunas_corretas_IPI %in% nomes_da_portaria)
  
  if(!teste){
    print(as.character(colunas_corretas_IPI[!colunas_corretas_IPI %in% nomes_da_portaria], "\n"))
    stop("A portaria de IPI, não possui as colunas definidas acima. Confirme se a ortografia dos nomes de cada coluna estão corretas. Caso queira ver a lista completa com os nomes corretos das colunas, que a portaria deveria possuir, execute o seguinte comando:\n\nprint(colunas_corretas_IPI)")
  }
  
  return(teste)
}



## Executando a função que irá conferir
## os nomes das colunas da portaria de IPI

conferir_portaria_IPI(portaria_IPI)





  


##### Conferindo a igualdade entre os índices de participação de cada município entre as portarias ------------------------------------
##
## É possível que o índice de participação de um município na portaria de IPI,
## esteja diferente do índice de participação deste mesmo município definido na
## portaria de ICMS. O código abaixo, confere a igualdade entre esses índices
## e solta um aviso caso algum desses índices não seja igual em ambas as portarias.

indices_IPI <- portaria_IPI$`Índice`
indices_ICMS <- portaria_ICMS$`Índice`


if(!all(near(indices_ICMS, indices_IPI))){
  
  print(portaria_ICMS$SEF[!near(indices_ICMS, indices_IPI)])
  warning("Os municípios com os códigos SEF definidos acima, possuem índices de participação diferentes entre as duas portarias (ICMS e IPI). Se o índice de participação de um, ou de vários municípios estão diferentes entre as portarias de ICMS e IPI, é bem provável que o valor final calculado para esses municípios no Resultado_final, estarão com uma diferença significativa em relação aos valores descritos nas portarias.")
  
}



#### FIM ---------------------------------------------------------


