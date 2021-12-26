#' ---
#' title: "Título do script"
#' author: "Autor do script - email"
#' date: "Data de criação do script"
#' output: github_document 
#' ---
#' 
#' Para exibir texto, use #'. Observe que toda a sintaxe do markdown funciona aqui.
#' 
#' Se quiser executar código inline, use o acento grave: dois mais dois igual a `r 2 + 2`
#' 
#' # Opções de visualização
#' 
#' Para configurar as opções de visualização do código, faça como a seguir: #+ warning = FALSE
  
#+ warning = FALSE

#' Outras opções:
#' 
#' * eval = TRUE     - executa o código e inclui o resultado
#' * echo = TRUE     - exibe o código e seu resultado
#' * warning = FALSE - exibe as mensagens de aviso
#' * error =  FALSE  - exibe as mensagens de erro
#' * tidy = FALSE    - exibe o código em um formato mais compacto
#' * results = 'hide'- excuta o códifo e oculta o resultado
#' 
#' As configurações acima devem ser colocadas antes de cada bloco de código. caso
#' deseje fazer configurações globais, use
options(warn=-1)

#' # Estrutura do script
#' 
#' ## Limpa a memória e console
cat("\014")  
rm(list = ls())

#' ## Configura o diretório de trabalho
#' Altera a pasta de trabalho para a mesma onde o script está salvo
dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(dir)


#' ## Carrega as bibliotecas
pacotes <- c("readxl", "tidyverse", "RSelenium", "fuzzyjoin")

#' Verifica se alguma das bibliotecas necessárias ainda não foi instalada
pacotes_instalados <- pacotes %in% rownames(installed.packages())
if (any(pacotes_instalados == FALSE)) {
  install.packages(pacotes[!pacotes_instalados])
}

#' carrega as bibliotecas
#+ results = "hide"
lapply(pacotes, library, character.only=TRUE)


# Ano
ano = 2021

#' ## Importa os dados
dados_icms <- readxl::read_excel("patrimôniocultural_2020_Max.xlsx", sheet =1)
dados_imrs <- readxl::read_excel("IMRS Cultura 2000 - 2020.xlsx", sheet =1)
dados_munic <- readxl::read_excel("Base_MUNIC_2018_MG.xlsx", sheet =2)
dados_icms <- as_tibble(dados_icms)
dados_imrs <- as_tibble(dados_imrs)
dados_munic <- as_tibble(dados_munic)

#substitui o - por NA
#dados_munic <- replace(dados_munic, dados_munic=='-', NA)

#cria uma coluna de chave utilizando o último ano disponível na tabela do imrs
#posteriormente, essa chave será atualizada para o ano atual
dados_icms <- dados_icms %>% select(c(1,16)) %>% mutate(ano = ano) #seleciona as colunas relevantes
colnames(dados_icms) <- c("ibge", "total", "ano")
dados_icms <- dados_icms %>% mutate(CHAVE = paste0(ano-1, ibge)) 

#faz a união dos dados de icms com os dados da tabela do imrs
indicadores <- merge(dados_imrs, dados_icms[-c(1,3)], by = c("CHAVE"))
#atualiza a chave e o ano
indicadores <- indicadores %>% mutate(CHAVE = paste0(ano, substring(CHAVE, 5))) %>% mutate(ANO = ano)
#remove os valores relativos ao ano anterior
indicadores[, 4:34] <- NA
#atualiza o valor do indicador C_ICMSPATCULT com o valor da coluna total e em seguida a remove
indicadores <- indicadores %>% mutate(C_ICMSPATCULT = total) %>% select(-total)

#altera o código de município de 7 dígitos para 6
dados_munic <- dados_munic %>% mutate(`Cod Municipio` = substring(`Cod Municipio`, 1, 6))
#cria a coluna de ano e chave
dados_munic <- dados_munic %>% mutate(ANO = ano, .after = `Cod Municipio`) %>% mutate(CHAVE = paste0(ano, `Cod Municipio`), .after=`Cod Municipio`)
#faz a união da tabela de indicadores com os dados da munic
indicadores <- merge(indicadores, dados_munic[c("CHAVE",
                                              "MCUL3901",
                                              "MCUL3902",
                                              "MCUL3903",
                                              "MCUL3904", 
                                              "MCUL3905",
                                              "MCUL3909",
                                              "MCUL371",
                                              "MCUL372",
                                              "MCUL373",
                                              "MCUL374",
                                              "MCUL375",
                                              "MCUL376",
                                              "MCUL377",
                                              "MCUL378")], by = c("CHAVE"))
indicadores <- indicadores %>% mutate(C_BIBLIOTECA = MCUL3901) %>% select(-MCUL3901) %>%
               mutate(C_MUSEU = MCUL3902) %>% select(-MCUL3902) %>%
               mutate(C_TEATRO = MCUL3903) %>% select(-MCUL3903) %>%
               mutate(C_CENTROC = MCUL3904) %>% select(-MCUL3904) %>%
               mutate(C_ARQPUB = MCUL3905) %>% select(-MCUL3905) %>%
               mutate(C_CINEMA = MCUL3909) %>% select(-MCUL3909)
#obtém a quantidade de tipos de equipamentos culturais
tipos_equip <-  rowSums(cbind(indicadores$C_MUSEU=="Sim", 
                              indicadores$C_TEATRO=="Sim",
                              indicadores$C_CENTROC=="Sim",
                              indicadores$C_ARQPUB=="Sim",
                              indicadores$C_CINEMA=="Sim"))
#preenche a coluna C_EQUIP baseado na quantidade de tipos de equipamentos: maior que 2, Sim, caso contrário, Não
indicadores <- indicadores %>% mutate(C_EQUIP =  if_else(tipos_equip >= 2, "Sim", "Não"))

#obtém a quantidade de tipos de meio de comunicação
tipos_meioc <- rowSums(cbind(indicadores$MCUL371=="Sim", #jornal impresso
                             indicadores$MCUL372=="Sim", #revista impressa
                             indicadores$MCUL373=="Sim", #radio AM
                             indicadores$MCUL374=="Sim", #radio FM
                             indicadores$MCUL375=="Sim", #radio comunitária
                             indicadores$MCUL376=="Sim", #TV comunitária
                             indicadores$MCUL377=="Sim", #geradora de TV
                             indicadores$MCUL378=="Sim"))#provedor de internet
#preeche a coluna C_MEIOC baseado na disponibilidade dos meios de comunicação: 4 ou mais: alta; 2 ou 3: média; 1: baixa; 
indicadores <- indicadores %>% mutate(C_MEIOC = if_else(tipos_meioc >=4, "Alta Disponibilidade", if_else(tipos_meioc >=2, "Média Disponibilidade", if_else(tipos_meioc >= 1, "Baixa Disponibilidade", ""))))

#elimina as colunas que não são mais necessárias
indicadores <- indicadores %>% select(-c(MCUL371, MCUL372, MCUL373, MCUL374, MCUL375, MCUL376, MCUL377, MCUL378))

#cria coluna de números, que será utilizada para realizar a junção com os dados do iepha
indicadores <- indicadores %>% mutate(numero = c(1:853), .after=ANO)
#realiza a junção
indicadores <- left_join(indicadores, dados, 
               by = "numero")

indicadores <- indicadores %>% mutate(C_TOMBEF = indicadores$'SOMATÓRIO PARA CÁLCULO DE PONTUAÇÃO PELOS TOMBAMENTOS')
indicadores <- indicadores %>% mutate(C_TOMBMUN = indicadores$'PROTEÇÃO MUNICIPAL calculada com base no')
indicadores <- indicadores %>% mutate(C_PCL = apply(indicadores[, c('PONTUAÇÃO POLÍTICA CULTURAL',
                                                                     'PONTUAÇÃO INVESTIMENTOS E DESPESAS',
                                                                     'PONTUAÇÃO INVENTÁRIO',
                                                                     'PONTUAÇÃO EDUCAÇÃO e DIFUSÃO')], 1, 
                                                    function(x) ifelse(all(is.na(x)), as.numeric(NA), sum(x, na.rm=T))))


indicadores <- indicadores %>% mutate(C_APRESPC = apply(indicadores[, c('PONTUAÇÃO FINAL TOMBAMENTOS', 
                                                                        'PONTUAÇÃO FINAL REGISTROS')], 1,
                                                        function(x) ifelse(all(is.na(x)), as.numeric(NA), sum(x, na.rm=T))))                                      
                                        
indicadores <- indicadores %>% mutate(C_GPRESPC = apply(indicadores[, c('C_PCL', 
                                                                        'C_APRESPC')], 1,
                                                        function(x) ifelse(all(is.na(x)), as.numeric(NA), sum(x, na.rm=T))))                                      

indicadores <- indicadores %>% mutate(C_REGISTRO = indicadores$'PONTUAÇÃO FINAL REGISTROS')

indicadores <- indicadores %>% mutate(C_FUNDO = indicadores$'PONTUAÇÃO INVESTIMENTOS E DESPESAS')

indicadores <- indicadores %>% select(-c("numero", 
                                         "SOMATÓRIO PARA CÁLCULO DE PONTUAÇÃO PELOS TOMBAMENTOS",
                                         "PROTEÇÃO MUNICIPAL calculada com base no",
                                         "PONTUAÇÃO POLÍTICA CULTURAL",
                                         "PONTUAÇÃO INVESTIMENTOS E DESPESAS",
                                         "PONTUAÇÃO INVENTÁRIO",
                                         "PONTUAÇÃO EDUCAÇÃO e DIFUSÃO",
                                         "PONTUAÇÃO FINAL TOMBAMENTOS",
                                         "PONTUAÇÃO FINAL REGISTROS",
                                         "NOME MUNICÍPIO"))



