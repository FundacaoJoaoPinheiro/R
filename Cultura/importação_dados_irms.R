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
pacotes <- c("readxl", "tidyverse")

#' Verifica se alguma das bibliotecas necessárias ainda não foi instalada
pacotes_instalados <- pacotes %in% rownames(installed.packages())
if (any(pacotes_instalados == FALSE)) {
  install.packages(pacotes[!pacotes_instalados])
}

#' carrega as bibliotecas
#+ results = "hide"
lapply(pacotes, library, character.only=TRUE)


#' Ano
ano = 2021

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

#' ## Tratamento dos dados

#' ### Dados do ICMS Patrimônio Cultural
#' 
#' O primeiro passo é criar uma coluna de chave utilizando o último ano disponível na tabela do IMRS.
#' Isso é feito para que seja possível realizar a junção dos dados do ICMS com os nomes dos municípios 
#' presentes na tabela do IMRS. Posteriormente, essa chave será atualizada para o ano atual
#' 
dados_icms <- dados_icms %>% select(c(1,16)) %>%                  #seleciona as colunas relevantes
                             mutate(ano = ano)                    #cria uma coluna de ano
colnames(dados_icms) <- c("ibge", "total", "ano")                 #atualiza os nomes das colunas
dados_icms <- dados_icms %>% mutate(CHAVE = paste0(ano-1, ibge))  #cria uma coluna de chave utilizando o ano anterior ao atual

#' Agora é feita a união dos dados do ICMS com os dados da tabela do IMRS. Observe que dos dados do ICMS foram excluídas
#' as colunas 1 e 3, ou seja, foram utilizadas apenas as colunas de chave e total. O resultado é armazenado na
#' tabela chamada indicadores, que tem os números dos indicadores do último ano. Esses dados serão removidos e 
#' a tabela será preenchida com os números do ano atual. No final, essa tabela será anexa à tabela do IMRS e
#' os dados serão salvos em um arquivo excel.

indicadores <- merge(dados_imrs, dados_icms[-c(1,3)], by = c("CHAVE")) 
    
#' Atualiza a chave e o ano na tabela indicadores
indicadores <- indicadores %>% mutate(CHAVE = paste0(ano, substring(CHAVE, 5))) %>%  
                               mutate(ANO = ano)

#' Remove os valores relativos ao ano anterior
indicadores[, 4:34] <- NA # seleciona todas as linhas e colunas de 4 a 34 e atribui o valor NA a elas

#' Atualiza o valor do indicador C_ICMSPATCULT com o valor da coluna total e em seguida a remove
indicadores <- indicadores %>% mutate(C_ICMSPATCULT = total) %>% 
                               select(-total)

#' ### Dados da MUNIC
#' 
#' Altera o código de município de 7 dígitos para 6
dados_munic <- dados_munic %>% mutate(`Cod Municipio` = substring(`Cod Municipio`, 1, 6))
#' Cria as colunas de ano e chave
dados_munic <- dados_munic %>% mutate(ANO = ano, .after = `Cod Municipio`) %>% 
                               mutate(CHAVE = paste0(ano, `Cod Municipio`), .after=`Cod Municipio`)
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

#' Preenche a coluna C_EQUIP baseado na quantidade de tipos de equipamentos: maior que 2, Sim, caso contrário, Não
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
indicadores <- indicadores %>% mutate(C_MEIOC = if_else(tipos_meioc >=4, "Alta Disponibilidade", 
                                                        if_else(tipos_meioc >=2, "Média Disponibilidade", 
                                                                if_else(tipos_meioc >= 1, "Baixa Disponibilidade", ""))))

#' Elimina as colunas que não são mais necessárias
indicadores <- indicadores %>% select(-c(MCUL371, MCUL372, MCUL373, MCUL374, MCUL375, MCUL376, MCUL377, MCUL378))

#' ### Dados do IEPHA

#' Inicialmente seleciona-se as colunas com dados relevantes. Essas colunas deverão sofrer alteração caso 
#' a tabela seja alterada
dados_iepha <- dados_iepha %>% select(c(1, 2, 3, 4, 20, 21, 24, 32, 33))   

#' Atribui um nome às colunas
colnames(dados_iepha) <- c("Município", 
                           "SOMATÓRIO PARA CÁLCULO DE PONTUAÇÃO PELOS TOMBAMENTOS",
                           "PROTEÇÃO MUNICIPAL calculada com base no",
                           "PONTUAÇÃO POLÍTICA CULTURAL", 
                           "PONTUAÇÃO INVESTIMENTOS E DESPESAS",
                           "PONTUAÇÃO INVENTÁRIO", 
                           "PONTUAÇÃO EDUCAÇÃO e DIFUSÃO", 
                           "PONTUAÇÃO FINAL TOMBAMENTOS", 
                           "PONTUAÇÃO FINAL REGISTROS")

#' Remove as primeiras 5 linhas, que são desnecessárias. Além disso, remove as linhas que contém
#' as letras correspondentes às colunas. Essas linhas foram introduzidas durante a conversão do arquivo
#' pdf para excel 
dados_iepha <- dados_iepha[-c(1:5), ]   
dados_iepha <- subset(dados_iepha, Município != 'A')

#' Extrai o número do município a partir da primeira coluna. 
numeros_municipios <-  as.integer(sapply(dados_iepha$Município, substr, 1, 3))

#' Atualiza a coluna de nomes dos municípios para conter somente os nomes e cria uma nova coluna
#' que conterá os números
dados_iepha <- dados_iepha %>% mutate(Município = sapply(dados_iepha$Município, substr, 5, 50)) %>%
                               mutate(numero = numeros_municipios, .before = Município)
        
#' Faz a conversão dos dados de caracter para númerico                       
dados_iepha[, c(3:10)] <- sapply(dados_iepha[, c(3:10)], as.numeric)
                               

#' Na tabela de indicadores, cria-se a coluna de números, que será utilizada para realizar a 
#' junção com os dados do iepha
indicadores <- indicadores %>% mutate(numero = c(1:853), .after=ANO)

#' Realiza a junção
indicadores <- left_join(indicadores, dados_iepha, by = "numero")

#' Preenche as colunas dos indicadores que são obtidos diretamente dos dados do iepha
indicadores <- indicadores %>% mutate(C_TOMBEF = indicadores$'SOMATÓRIO PARA CÁLCULO DE PONTUAÇÃO PELOS TOMBAMENTOS')
indicadores <- indicadores %>% mutate(C_TOMBMUN = indicadores$'PROTEÇÃO MUNICIPAL calculada com base no')
indicadores <- indicadores %>% mutate(C_REGISTRO = indicadores$'PONTUAÇÃO FINAL REGISTROS')
indicadores <- indicadores %>% mutate(C_FUNDO = indicadores$'PONTUAÇÃO INVESTIMENTOS E DESPESAS')

#' Os indicadores a seguir são obtidos pela soma de outras variáveis. A função ifelse é necessária pois 
#' alguns dos valores podem estar em branco (NA). Se todos os valores forem NA, então o resultado é NA. Se pelo menos
#' algum dos valores for diferente de NA, então o resultado é a soma desses valores.
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


#' Por fim, elimina as colunas que não são mais necessárias
indicadores <- indicadores %>% select(-c("numero", 
                                         "SOMATÓRIO PARA CÁLCULO DE PONTUAÇÃO PELOS TOMBAMENTOS",
                                         "PROTEÇÃO MUNICIPAL calculada com base no",
                                         "PONTUAÇÃO POLÍTICA CULTURAL",
                                         "PONTUAÇÃO INVESTIMENTOS E DESPESAS",
                                         "PONTUAÇÃO INVENTÁRIO",
                                         "PONTUAÇÃO EDUCAÇÃO e DIFUSÃO",
                                         "PONTUAÇÃO FINAL TOMBAMENTOS",
                                         "PONTUAÇÃO FINAL REGISTROS",
                                         "Município"))

auxiliar <- drop_na(dados_biblios %>% group_by(Município) %>% summarise(num_bib = n()))
colnames(auxiliar) <- c("MUNICÍPIO", "num bib")





auxiliar <- left_join(auxiliar, setNames(aggregate(dados_biblios$`Área de ocupação [m²]`, by= list(dados_biblios$Município), sum), c("MUNICÍPIO", "Área")), by="MUNICÍPIO")

auxiliar <- auxiliar %>% mutate(faixa_area = sapply(auxiliar[, c("Área")], function(x) ifelse(x > 200, ">200", 
                                       ifelse(x >= 161, "161-200", 
                                               ifelse(x >= 131, "131-160", 
                                                       ifelse(x >= 101, "101-130",
                                                               ifelse(x >= 71, "71-100",
                                                                      ifelse(x >= 51, "51-70",
                                                                             ifelse(x >= 31, "31-50", "<30")))))))))

auxiliar <- left_join(auxiliar, setNames(aggregate(dados_biblios$`Quantos livros...34`, by= list(dados_biblios$Município), sum), c("MUNICÍPIO", "Acervo")), by="MUNICÍPIO")

#acervo <- aggregate(dados_biblios$`Quantos livros...34`, by= list(dados_biblios$MUNICÍPIO), sum)
#colnames(acervo) <- c("Município", "Acervo")
#auxiliar <- left_join(auxiliar, acervo, by="MUNICÍPIO")

auxiliar <- auxiliar %>% mutate(faixa_acervo = sapply(auxiliar[, c("Acervo")], function(x) ifelse(x > 50000, "acima de 50.000", 
                                                                         ifelse(x >= 20001, "20.001 - 50.000", 
                                                                                ifelse(x >= 10001, "10.001 - 20.000", 
                                                                                       ifelse(x >= 5001, "5.001 - 10.000",
                                                                                              ifelse(x >= 3001, "3.001 - 5.000",
                                                                                                     ifelse(x >= 51, "1.001 - 3.000", "até 1.000"))))))))


auxiliar <- left_join(auxiliar, setNames(aggregate(dados_biblios$`Leitores por mês`, by= list(dados_biblios$Município), sum), c("MUNICÍPIO", "Leitores")) , by="MUNICÍPIO")

auxiliar <- left_join(auxiliar, setNames(aggregate(dados_biblios$`Média mensal empréstimo`, by= list(dados_biblios$Município), sum), c("MUNICÍPIO", "Média emprestimo")), by="MUNICÍPIO")

auxiliar <- left_join(auxiliar, setNames(aggregate(dados_biblios$`PC, internet`, by= list(dados_biblios$Município), function(x)  ifelse(any(x=="Sim"), "Sim", 
                                                                                                                          ifelse(x=="Branco", as.numeric(NA), "Não"))), c("MUNICÍPIO", "Internet") ), by="MUNICÍPIO")

auxiliar <- left_join(auxiliar, setNames(aggregate(dados_biblios$`Prefeitura comprou últimos 2 anos`, by= list(dados_biblios$Município), function(x)  ifelse(any(x=="Sim"), "Sim", "Não")), c("MUNICÍPIO", "Compras")), by="MUNICÍPIO")


indicadores <- left_join(indicadores, auxiliar, by="MUNICÍPIO")

indicadores <- indicadores %>% mutate(C_AREABIB = indicadores$faixa_area) %>% select(-faixa_area)

indicadores <- indicadores %>% mutate(C_ACERVOBIB = indicadores$faixa_acervo) %>% select(-faixa_acervo)

indicadores <- indicadores %>% mutate(C_WEBBIB = indicadores$Internet) %>% select(-Internet)

indicadores <- indicadores %>% mutate(C_COMPBIB = indicadores$Compras) %>% select(-Compras)

indicadores <- indicadores %>% mutate(C_LEITMESBIB = indicadores$Leitores) %>% select(-Leitores)

indicadores <- indicadores %>% mutate(C_EMPMESBIB = indicadores$`Média emprestimo`) %>% select(-`Média emprestimo`)

indicadores <- indicadores %>% mutate(C_NUMBIB = indicadores$`num bib`) %>% select(-`num bib`)

indicadores <- indicadores %>% select(-c("Área", "Acervo"))
