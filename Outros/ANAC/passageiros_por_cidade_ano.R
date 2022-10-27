
#Script que extrai as informações do número de passageiros (pagos e grátis) para 
#cada aeroporto em Minas Gerais, para cada ano a partir de 2010. O resultado é 
#salvo em um arquivo xlsx, em que cada aba corresponde à quantidade de passageiros
#por ano. As linhas que contém dados NA nas variáveis de interesse não foram 
#consideradas no cálculo.

#bibliotecas
library(readr) #necessária para importação do base de dados
library(dplyr) #necessária para as funções de manipulação da base de dados
library(xlsx) #necessária para gerar o arquivo em formato xlsx

Sys.setlocale("LC_ALL","pt_BR.UTF-8")

#obtenção da base de dados
#https://www.gov.br/anac/pt-br/assuntos/dados-e-estatisticas/dados-estatisticos/arquivos/DadosEstatsticos.csv


#carrega a base de dados
#DE <- read_delim("DadosEstatisticos.csv", 
#                  ";", escape_double = FALSE, locale = locale(encoding = "ISO-8859-1"), 
#                  trim_ws = TRUE)

#seleciona as variáveis de interesse
DE_selected <- select(DE, ANO, 
                   MÊS,
                   'AEROPORTO DE ORIGEM (NOME)',
                   'AEROPORTO DE ORIGEM (UF)',
                   'PASSAGEIROS GRÁTIS',
                   'PASSAGEIROS PAGOS')


#para cada ano a partir de 2010
for (ano in c(2010:2021)) {
  
  #retira as linhas em que aparecem dados incompletos (NA) e seleciona de acordo 
  #com ano e estado de origem
  DE_filtred <- na.omit(filter(DE_selected, DE$ANO == ano & 
                       DE$`AEROPORTO DE ORIGEM (UF)` == "MG"))
  
  #renomeia as colunas
  DE_filtred <- DE_filtred %>% dplyr::rename(nome_origem = 'AEROPORTO DE ORIGEM (NOME)',
                                 uf_origem = 'AEROPORTO DE ORIGEM (UF)',
                                 pass_gratis = 'PASSAGEIROS GRÁTIS',
                                 pass_pagos = 'PASSAGEIROS PAGOS')
  
  #agrupa por cidade de origem e faz a soma do total de passageiros
  result <- group_by(DE_filtred, nome_origem) %>% summarise(soma_passageiros = sum(pass_gratis, pass_pagos))
  
  # escreve no arquivo do excel
  write.xlsx(x = result,
             file = "anac_passageiros_por_cidade_ano.xlsx",
             sheetName = toString(ano),
             append = TRUE)
}
  
