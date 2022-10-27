#' ---
#' title: "Importação dos dados IMRS dimensão Cultura"
#' author: "Michel Alves - michel.alves@fjp.mg.gov.br"
#' date: "janeiro de 2022"
#' output: github_document 
#' ---
#' 
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
pacotes <- c("readxl", "tidyverse", "fuzzyjoin", "janitor", "writexl", "stringdist", "hablar")

#' Verifica se alguma das bibliotecas necessárias ainda não foi instalada
pacotes_instalados <- pacotes %in% rownames(installed.packages())
if (any(pacotes_instalados == FALSE)) {
  install.packages(pacotes[!pacotes_instalados])
}

#' carrega as bibliotecas
#+ results = "hide"
lapply(pacotes, library, character.only=TRUE)


#' Ano corrente
ano = 2022

#' A diferença entre nomes define o número máximo aceitável de caracteres diferentes entre nomes de municípios com grafias diferentes
#' Observe que aumentar esse valor fará com que mais nomes sejam parecidos entre si.
diferenca_entre_nomes <- 2

#' ## Importação dos dados
#' 
#' Aqui é realizada a leitura dos arquivos em formato .xlsx. Para os dados que são disponibilizados
#' originalmente em pdf, como os provenientes do IEPHA, é necessário antes realizar a conversão para o 
#' formato xlsx, que pode ser realizado [aqui](https://www.ilovepdf.com/pt/pdf_para_excel).
dados_icms <- as_tibble(readxl::read_excel("patrimôniocultural_2020_Max.xlsx", sheet =1))
dados_imrs <- as_tibble(readxl::read_excel("IMRS Cultura 2000 - 2020.xlsx", sheet =1))
dados_munic <- as_tibble(readxl::read_excel("Base_MUNIC_2018_MG.xlsx", sheet =2))
dados_iepha <- as_tibble(readxl::read_excel("iepha_2021.xlsx", sheet =1))
dados_biblios <- as_tibble(readxl::read_excel("Questionário 2015_bibliotecas.xlsx", sheet =1))
municipio_codigo <- as_tibble(readxl::read_excel("lista municipios FJP.xlsx")) 

#' ## Tratamento dos dados

#' Extrai a informação de códigos e nomes dos municípios, que será útil para
#' realizar a junção de diferentes dados
colnames(municipio_codigo) <- c("municipio", "IBGE6")
municipio_codigo <- municipio_codigo %>% mutate(municipio = tolower(municipio_codigo$municipio)) 
#' ### Dados do ICMS Patrimônio Cultural
#'

#' O primeiro passo é criar uma coluna de chave utilizando o último ano disponível na tabela do IMRS.
#' Isso é feito para que seja possível realizar a junção dos dados do ICMS com os nomes dos municípios 
#' presentes na tabela do IMRS. Posteriormente, essa chave será atualizada para o ano atual
#' 
dados_icms <- dados_icms %>% select(c(1,16)) %>%                  #seleciona as colunas relevantes
                             mutate(ano = ano-1)                  #cria uma coluna de ano
colnames(dados_icms) <- c("ibge", "total", "ano")                 #atualiza os nomes das colunas
dados_icms <- dados_icms %>% mutate(CHAVE = paste0(ano-1, ibge))  #cria uma coluna de chave utilizando o ano anterior ao atual



#' Agora é feita a união dos dados do ICMS com os dados da tabela do IMRS. Observe que dos dados do ICMS foram excluídas
#' as colunas 1 e 3, ou seja, foram utilizadas apenas as colunas de chave e total. O resultado é armazenado na
#' tabela chamada indicadores, que tem os números dos indicadores do último ano. Esses dados serão removidos e 
#' a tabela será preenchida com os números do ano atual. No final, essa tabela será anexa à tabela do IMRS e
#' os dados serão salvos em um arquivo excel.

indicadores <- merge(dados_imrs, dados_icms[-c(1,3)], by = c("CHAVE")) 
    
#' Atualiza a chave e o ano na tabela indicadores
indicadores <- indicadores %>% mutate(CHAVE = paste0(ano-1, substring(CHAVE, 5))) %>%  
                               mutate(ANO = ano-1)

#' Remove os valores relativos ao ano anterior
indicadores[, 5:35] <- NA # seleciona todas as linhas e colunas de 4 a 34 e atribui o valor NA a elas

#' Atualiza o valor do indicador C_ICMSPATCULT com o valor da coluna total e em seguida a remove
indicadores <- indicadores %>% mutate(C_ICMSPATCULT = round(as.numeric(total), digits=2)) %>% 
                               select(-total)

#' ### Dados da MUNIC
#' 
#' Altera o código de município de 7 dígitos para 6
dados_munic <- dados_munic %>% mutate(`Cod Municipio` = substring(`Cod Municipio`, 1, 6))
#' Cria as colunas de ano e chave
dados_munic <- dados_munic %>% mutate(ANO = ano-1, .after = `Cod Municipio`) %>% 
                               mutate(CHAVE = paste0(ano-1, `Cod Municipio`), .after=`Cod Municipio`)

#' Substitui o - por NA
dados_munic <- replace(dados_munic, dados_munic=='-', NA)

#' Faz a união da tabela de indicadores com os dados da munic utilizando a chave
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
                                              "MCUL378",
                                              "MCUL15",
                                              "MCUL01")], by = c("CHAVE"))
#' Atualiza os indicadores que são obtidos diretamente por variáveis da munic. O indicador
#' é atualizado e a coluna de onde o dado veio originalmente é retirada da tabela de indicadores
indicadores <- indicadores %>% mutate(C_BIBLIOTECA = MCUL3901) %>% select(-MCUL3901) %>%
                               mutate(C_MUSEU = MCUL3902) %>% select(-MCUL3902) %>%
                               mutate(C_TEATRO = MCUL3903) %>% select(-MCUL3903) %>%
                               mutate(C_CENTROC = MCUL3904) %>% select(-MCUL3904) %>%
                               mutate(C_ARQPUB = MCUL3905) %>% select(-MCUL3905) %>%
                               mutate(C_CINEMA = MCUL3909) %>% select(-MCUL3909) %>%
                               mutate(C_LEGPAT = MCUL15) %>% select(-MCUL15) %>%
                               mutate(C_ORGAOC = MCUL01) %>% select(-MCUL01)
  
#' Obtém a quantidade de tipos de equipamentos culturais. Inicialmente cria-se uma nova tabela
#' que contém TRUE caso o valor do indicador para um dado município seja Sim e FALSE no caso contrário.
#' A função rowSums considera 1 se o valor é TRUE e 0 caso seja FALSE. Assim, o valor da soma de cada
#' linha dessa tabela criada indicará a quantidade de tipos de equipamentos culturais presentes no município.
tipos_equip <-  rowSums(cbind(indicadores$C_MUSEU=="Sim", 
                              indicadores$C_TEATRO=="Sim",
                              indicadores$C_CENTROC=="Sim",
                              indicadores$C_ARQPUB=="Sim",
                              indicadores$C_CINEMA=="Sim"))

#' Preenche a coluna C_EQUIP baseado na quantidade de tipos de equipamentos: maior ou igual a 2, Sim, caso contrário, Não
indicadores <- indicadores %>% mutate(C_EQUIP =  if_else(tipos_equip >= 2, "Sim", "Não"))

#' De maneira semelhante ao que foi feito para se obter o indicador de equipamentos culturais, obtém-se a
#' quantidade de tipos de meio de comunicação
tipos_meioc <- rowSums(cbind(indicadores$MCUL371=="Sim", #jornal impresso
                             indicadores$MCUL372=="Sim", #revista impressa
                             indicadores$MCUL373=="Sim", #radio AM
                             indicadores$MCUL374=="Sim", #radio FM
                             indicadores$MCUL375=="Sim", #radio comunitária
                             indicadores$MCUL376=="Sim", #TV comunitária
                             indicadores$MCUL377=="Sim", #geradora de TV
                             indicadores$MCUL378=="Sim"))#provedor de internet
#' Preeche a coluna C_MEIOC baseado na disponibilidade dos meios de comunicação: 4 ou mais: alta; 2 ou 3: média; 1: baixa; 
indicadores <- indicadores %>% mutate(C_MEIOC = if_else(tipos_meioc >=4, "Alta disponibilidade", 
                                                        if_else(tipos_meioc >=2, "Média disponibilidade", 
                                                                if_else(tipos_meioc >= 1, "Baixa disponibilidade", ""))))

#' Elimina as colunas que não são mais necessárias
indicadores <- indicadores %>% select(-c(MCUL371, MCUL372, MCUL373, MCUL374, MCUL375, MCUL376, MCUL377, MCUL378))

#' ### Dados do IEPHA

#' Inicialmente seleciona-se as colunas com dados relevantes. Essas colunas deverão sofrer alteração caso 
#' a tabela seja alterada
dados_iepha <- dados_iepha %>% select(c(1, 21, 20, 2, 3, 4, 33, 24, 32))   

#' Atribui um nome às colunas
colnames(dados_iepha) <- c("MUNICÍPIO", 
                           "SOMATÓRIO PARA CÁLCULO DE PONTUAÇÃO PELOS TOMBAMENTOS",
                           "PROTEÇÃO MUNICIPAL calculada com base no",
                           "PONTUAÇÃO POLÍTICA CULTURAL", 
                           "PONTUAÇÃO INVESTIMENTOS E DESPESAS",
                           "PONTUAÇÃO INVENTÁRIO", 
                           "PONTUAÇÃO EDUCAÇÃO e DIFUSÃO", 
                           "PONTUAÇÃO FINAL TOMBAMENTOS", 
                           "PONTUAÇÃO FINAL REGISTROS")
dados_iepha <- dados_iepha %>% janitor::clean_names()


#' Remove as primeiras 5 linhas, que são desnecessárias. Além disso, remove as linhas que contém
#' as letras correspondentes às colunas. Essas linhas foram introduzidas durante a conversão do arquivo
#' pdf para excel 
dados_iepha <- dados_iepha[-c(1:5), ]   
dados_iepha <- subset(dados_iepha, municipio != 'A')


#' Atualiza a coluna de nomes dos municípios para conter somente os nomes 
dados_iepha <- dados_iepha %>% mutate(municipio = tolower(sapply(dados_iepha$municipio, substr, 5, 50)))
                               

#' Faz a junção da tabela com os dados do iepha com a de código de municípios
#' A primeira tentativa é por nomes exatos dos municípios. No caso de nomes de municípios com grafia diferente
#' daquela do IBGE, é realizada uma junção por aproximação. A variável diferença_entre_nomes determina o quão diferente
#' os nomes podem ser e ainda serem considerados iguais.
dados_iepha <- left_join(dados_iepha, municipio_codigo, by="municipio")
dados_iepha <- dados_iepha %>% mutate(IBGE6 = as.numeric(unlist(apply(dados_iepha, 1, function(x) ifelse(is.na(x[10]), municipio_codigo[which(stringdist(x[1], municipio_codigo$municipio, method="lv") <= diferenca_entre_nomes), 2], x[10]))))) %>%
                               mutate(CHAVE = paste0(ano-1, IBGE6))


#' Verifica se algum município ainda está sem o código do IBGE
if(any(is.na(dados_iepha$IBGE6))){
  stop("Não foi possível encontrar o código para o(s) município(s): ")
  dados_iepha$municipio[which(is.na(dados_iepha$IBGE6))]
}
        
#' Faz a conversão dos dados de caracter para númerico                       
dados_iepha[, c(2:10)] <- sapply(dados_iepha[, c(2:10)], as.numeric)

indicadores <- left_join(indicadores, select(dados_iepha, -c("IBGE6")), by="CHAVE")

#' Preenche as colunas dos indicadores que são obtidos diretamente dos dados do iepha
indicadores <- indicadores %>% mutate(C_TOMBEF = indicadores$somatorio_para_calculo_de_pontuacao_pelos_tombamentos)
indicadores <- indicadores %>% mutate(C_TOMBMUN = indicadores$protecao_municipal_calculada_com_base_no)
indicadores <- indicadores %>% mutate(C_REGISTRO = indicadores$pontuacao_final_registros)
indicadores <- indicadores %>% mutate(C_FUNDO = indicadores$pontuacao_investimentos_e_despesas)

#' Os indicadores a seguir são obtidos pela soma de outras variáveis. 
indicadores <- indicadores %>% mutate(C_PCL = apply(indicadores[, c('pontuacao_politica_cultural',
                                                                     'pontuacao_investimentos_e_despesas',
                                                                     'pontuacao_inventario',
                                                                     'pontuacao_educacao_e_difusao')], 1, sum_))


indicadores <- indicadores %>% mutate(C_APRESPC = apply(indicadores[, c('pontuacao_final_tombamentos', 
                                                                        'pontuacao_final_registros')], 1, sum_))                                      
                                        
indicadores <- indicadores %>% mutate(C_GPRESPC = apply(indicadores[, c('C_PCL', 
                                                                        'C_APRESPC')], 1, sum_))                                      


#' Por fim, elimina as colunas que não são mais necessárias
indicadores <- indicadores %>% select(-c(somatorio_para_calculo_de_pontuacao_pelos_tombamentos,
                                         protecao_municipal_calculada_com_base_no,
                                         pontuacao_politica_cultural,
                                         pontuacao_investimentos_e_despesas,
                                         pontuacao_inventario,
                                         pontuacao_educacao_e_difusao,
                                         pontuacao_final_tombamentos,
                                         pontuacao_final_registros,
                                         municipio))

#' ### Dados da Secretaria de Cultura
#' 
#' Limpa os nomes das colunas
dados_biblios <- dados_biblios %>% janitor::clean_names()
dados_biblios$municipio = tolower(dados_biblios$municipio)

#' Extrai a informação sobre os limites da faixa de área de ocupação, criando duas novas colunas
dados_biblios <- dados_biblios %>% mutate(faixa_area_de_ocupacao_min = sapply(dados_biblios$faixa_area_de_ocupacao,
                                                                              function(x) ifelse(length(grep("-", x))>0, strsplit(x, "[-]")[[1]][1], 
                                                                                                 ifelse(length(grep(">", x))>0, "201", 
                                                                                                        ifelse(length(grep("<", x))>0, "30", NA)))), .after="faixa_area_de_ocupacao") %>%
                                  mutate(faixa_area_de_ocupacao_max = sapply(dados_biblios$faixa_area_de_ocupacao,
                                                                             function(x) ifelse(length(grep("-", x))>0, strsplit(x, "[-]")[[1]][2], 
                                                                                                ifelse(length(grep("<", x))>0, "30",
                                                                                                       ifelse(length(grep(">", x))>0, "201", NA)))), .after="faixa_area_de_ocupacao")
#' Faz a conversão dos dados de caracter para númerico                       
dados_biblios[, c("faixa_area_de_ocupacao_max", "faixa_area_de_ocupacao_min")] <- sapply(dados_biblios[, c("faixa_area_de_ocupacao_max", "faixa_area_de_ocupacao_min")], as.numeric)

#' Obtém a área de ocupação por biblioteca da seguinte forma: Caso a área de ocupação tenha sido informada, ela é considerada. Caso a área não tenha sido informada, mas a faixa sim, então
#' calcula-se a média da área de acordo com a faixa 
dados_biblios <- dados_biblios %>% mutate(area_pela_faixa= apply(dados_biblios[c("area_de_ocupacao_m2", "faixa_area_de_ocupacao_max", "faixa_area_de_ocupacao_min")], 1, function(x) ifelse(is.na(x[1]), (((x[2]+x[3])/2)), x[1])), .after="faixa_area_de_ocupacao")

#' Obtém os limites das faixas de acervo
dados_biblios <- dados_biblios %>% mutate(faixa_acervo_min = sapply(dados_biblios$faixa_livros_milhares,
                                                                    function(x) ifelse(length(grep("-", x))>0, strsplit(x, "[-]")[[1]][1], 
                                                                                       ifelse(length(grep(">", x))>0, "51", 
                                                                                              ifelse(length(grep("<", x))>0, "1", NA)))), .after="faixa_livros_milhares") %>%
                                   mutate(faixa_acervo_max = sapply(dados_biblios$faixa_livros_milhares,
                                                                    function(x) ifelse(length(grep("-", x))>0, strsplit(x, "[-]")[[1]][2], 
                                                                            ifelse(length(grep("<", x))>0, "1",
                                                                                   ifelse(length(grep(">", x))>0, "51", NA)))), .after="faixa_livros_milhares")
#' Converte os dados para números
dados_biblios[, c("faixa_acervo_max", "faixa_acervo_min")] <- sapply(dados_biblios[, c("faixa_acervo_max", "faixa_acervo_min")], as.numeric)

#' Obtém a quantidade de livros por biblioteca. Se o valor do acervo foi informado, então usa-se esse valor. Caso contrário, usa-se o valor médio
#' da faixa de acervo
dados_biblios <- dados_biblios %>% mutate(acervo = apply(dados_biblios[c("quantos_livros_34", "faixa_acervo_min", "faixa_acervo_max")], 1, function(x) ifelse(is.na(x[1]), (((x[3]+x[2])/2))*1000, x[1])), .after="faixa_livros_milhares")

#' Aqui será criada uma tabela auxiliar onde a unidade de análise é o municipío. Isso é necessário
#' pois nos dados da secretaria, a unidade de análise é a biblioteca

#' O primeiro passo é obter o número de bibliotecas por município
auxiliar <- drop_na(dados_biblios %>% group_by(municipio) %>% summarise(num_bib = n()))
colnames(auxiliar) <- c("municipio", "num_bib")

#' Em seguida, é feita a união da tabela auxiliar com a tabela de códigos dos municípios. Essa união é feita
#' de forma semelhante à anterior.
auxiliar <- auxiliar %>% mutate(municipio = tolower(municipio)) # faz os nomes dos municípios ficarem em letras minúsculas
auxiliar <- left_join(auxiliar, municipio_codigo, by="municipio")
auxiliar <- auxiliar %>% mutate(IBGE6= as.numeric(unlist(apply(auxiliar[, c(1, 3)], 1,  function(x) ifelse(is.na(x[2]), municipio_codigo[which(stringdist(x[1], municipio_codigo$municipio, method="lv") <= diferenca_entre_nomes), 2], x[2]))))) %>%
                         mutate(CHAVE = paste0(ano-1, IBGE6))

#' Verifica se algum município está sem código
if(any(is.na(auxiliar$IBGE6))){
  stop("Não foi possível encontrar o código para o(s) município(s): ")
  auxiliar$municipio[which(is.na(auxiliar$IBGE6))]
}

#' Obtem a área de ocupação das bibliotecas, por município. Isso é feito da seguinte forma:
#' - aggregate: soma as áreas de ocupação agrupadas por município (Observe que está sendo utilizada a função sum_. Ela é ligeiramente diferente pois retorna
#'              NA caso todos os valores sejam NA ou o valor da soma caso um ou mais elementos sejam diferente de NA.)
#' - setNames: atribui nomes às colunas retornadas pela função aggregate, nesse caso, municipio e area 
#' - left_join: faz a união da tabela retornada pela função aggregate à tabela auxiliar, de acordo com o município
auxiliar <-  left_join(auxiliar, setNames(aggregate(dados_biblios$area_pela_faixa, by= list(dados_biblios$municipio), sum_), c("municipio", "area")), by="municipio")



#' Obtém a classificação da área por faixa de ocupação
auxiliar <- auxiliar %>% mutate(faixa_area = sapply(auxiliar[, c("area")], function(x) ifelse(is.na(x), NA,
                                                                                              ifelse(x> 200, ">200", 
                                                                                                     ifelse(x >= 161, "161-200", 
                                                                                                            ifelse(x >= 131, "131-160", 
                                                                                                                   ifelse(x >= 101, "101-130",
                                                                                                                          ifelse(x >= 71, "71-100",  
                                                                                                                                 ifelse(x >= 51, "51-70",
                                                                                                                                        ifelse(x >= 31, "31-50", "<30"))))))))))

#' Obtém a soma dos acervos das bibliotecas por município
auxiliar <- left_join(auxiliar, setNames(aggregate(dados_biblios$acervo, by= list(dados_biblios$municipio), sum_), c("municipio", "acervo")), by="municipio")

#' Obtém a classificação do acervo por faixa
auxiliar <- auxiliar %>% mutate(faixa_acervo = sapply(auxiliar[, c("acervo")], function(x) ifelse(x > 50000, "acima de 50.000", 
                                                                                                  ifelse(x >= 20001, "20.001 - 50.000", 
                                                                                                         ifelse(x >= 10001, "10.001 - 20.000", 
                                                                                                                ifelse(x >= 5001, "5.001 - 10.000",
                                                                                                                       ifelse(x >= 3001, "3.001 - 5.000",
                                                                                                                              ifelse(x >= 1001, "1.001 - 3.000", "até 1.000"))))))))

#' Obtém a quantidade de leitores por mês, por município
auxiliar <- left_join(auxiliar, setNames(aggregate(dados_biblios$leitores_por_mes, by= list(dados_biblios$municipio), sum_), c("municipio", "leitores")) , by="municipio")

#' Obtém a média mensal de empréstimos, por município
auxiliar <- left_join(auxiliar, setNames(aggregate(dados_biblios$media_mensal_emprestimo, by= list(dados_biblios$municipio), sum_), c("municipio", "media_emprestimo")), by="municipio")

#' Obtém a informação se o município tem alguma biblioteca com computador com acesso à internet. Para isso, a função aggregate agrupa as bibliotecas por município. Em seguida,
#' é verificado se algum das bibliotecas tem acesso. Se tiver, então o resultado é Sim. Caso não tenha nenhum um sim, então é verificado se há o valor Branco, que na verdade indica 
#' que a informação não é conhecida. Nesse caso, o resultado é NA. 
auxiliar <- left_join(auxiliar, setNames(aggregate(dados_biblios$pc_internet, by= list(dados_biblios$municipio), function(x)  ifelse(any(x=="Sim"), "Sim", 
                                                                                                                                     ifelse(x=="Branco", as.numeric(NA), "Não"))), c("municipio", "internet") ), by="municipio")
#' Obtém a informação sobre a compra de livros, por município
auxiliar <- left_join(auxiliar, setNames(aggregate(dados_biblios$prefeitura_comprou_ultimos_2_anos, by= list(dados_biblios$municipio), function(x)  ifelse(any(x=="Sim"), "Sim", "Não")), c("municipio", "compras")), by="municipio")

#' Agora será feita a união da tabela auxiliar com a tabela de indicadores, pelo código do IBGE
indicadores <- left_join(indicadores, select(auxiliar, -c("IBGE6")), by="CHAVE")

#' Atualiza os indicadores com base nas variáveis calculadas anteriormente. Em seguida, remove a coluna que não é mais necessária
indicadores <- indicadores %>% mutate(C_AREABIB = indicadores$faixa_area) %>% select(-faixa_area)
indicadores <- indicadores %>% mutate(C_ACERVOBIB = indicadores$faixa_acervo) %>% select(-faixa_acervo)
indicadores <- indicadores %>% mutate(C_WEBBIB = indicadores$internet) %>% select(-internet)
indicadores <- indicadores %>% mutate(C_COMPBIB = indicadores$compra) %>% select(-compras)
indicadores <- indicadores %>% mutate(C_LEITMESBIB = indicadores$leitores) %>% select(-leitores)
indicadores <- indicadores %>% mutate(C_EMPMESBIB = indicadores$media_emprestimo) %>% select(-media_emprestimo)
indicadores <- indicadores %>% mutate(C_NUMBIB = indicadores$num_bib) %>% select(-num_bib)
indicadores <- indicadores %>% select(-c("area", "acervo", "municipio"))

#' Verifica se as variáveis binárias estão corretas


variaveis_binarias <- c("C_MUSEU", "C_TEATRO", "C_CINEMA", "C_BIBLIOTECA", "C_CENTROC", "C_EQUIP", "C_BANDA", "C_WEBBIB", "C_COMPBIB", "C_LEGPAT", "C_ARQPUB")

for(var in c(1:length(variaveis_binarias))){
  if(any(apply(indicadores[variaveis_binarias[var]], 1, function(x) x %in% c("Sim", "Não", NA) ==  FALSE))){
    stop(paste("Erro na variável binária ", variaveis_binarias[var]))
  }
}

indicadores %>% glimpse()

#' Faz a união dos dados originais do IMRS com os dados calculados para o ano atual
dados_imrs <- rbind(dados_imrs, indicadores)

#' Salva o resultado num novo arquivo excel
write_xlsx(dados_imrs, paste0("IMRS_BASE_CULTURA_2000-", as.character(ano-1), ".xlsx"))

