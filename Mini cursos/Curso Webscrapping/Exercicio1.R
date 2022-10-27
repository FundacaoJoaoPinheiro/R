
#Carrega as bibliotecas necessárias
library('rvest')

url <- "http://tabnet.datasus.gov.br/cgi/deftohtm.exe?sinasc/cnv/nvmg.def"
pagina <- read_html(url)

#1ª parte - obter as opções disponíveis

#obtém a informação disponível para as linhas. Execute as duas linhas a seguir e observe a diferença
linhas <- pagina |> html_elements(xpath = "//select[@name = 'Linha']") |> html_text2()
linhas <- pagina |> html_elements(xpath = "//select[@name = 'Linha']/option") |> html_text2()

#Note que as informações obtidas tem o caracter especital \r ao final. Para removê-lo, podemos substituí-lo por 
#um caracter vazio, como a seguir
linhas <- gsub(pattern = '\r', replacement = '', linhas)

#Obtém as demais informações
colunas <- pagina |> html_elements(xpath = "//select[@name = 'Coluna']/option") |> html_text2()
colunas <- gsub(pattern = '\r', replacement = '', colunas)

conteudo <- pagina |> html_elements(xpath = "//select[@name = 'Incremento']/option") |> html_text2()
conteudo <- gsub(pattern = '\r', replacement = '', conteudo)

periodos <- pagina |> html_elements(xpath = "//select[@name = 'Arquivos']/option") |> html_text2()
periodos <- gsub(pattern = '\r', replacement = '', periodos)

#para esse select, observe que seu nome é uma string com acento (SIdade_da_mãe). Usar acentuação no xpath 
#normalmente causa erro. Por isso, faço a busca somente por uma parte da string.
idade_mae <- pagina |> html_elements(xpath = "//select[contains(@name, 'SIdade')]/option") |> html_text2()
idade_mae <- gsub(pattern = '\r', replacement = '', idade_mae)

sexo <- pagina |> html_elements(xpath = "//select[contains(@name, 'SSexo')]/option") |> html_text2()
sexo <- gsub(pattern = '\r', replacement = '', sexo)

#2ª parte - obter os valores para alguma seleção específica

#inicialmente os valores para cada uma das opções são obtidos. Então na segunda linha, encontra-se a posição na lista 
#linhas da opção sobre a qual desejamos obter o valor e obtemos o elemento correspondente na lista de valores_linha
valores_linhas <- pagina |> html_elements(xpath = "//select[@name = 'Linha']/option") |> html_attr('value')
valor_municipio <- valores_linhas[which(linhas == "Município")]

valores_colunas <- pagina |> html_elements(xpath = "//select[@name = 'Coluna']/option") |> html_attr('value')
valor_ano_nascimento <- valores_colunas[which(colunas == "Ano do nascimento")]

valores_conteudo <- pagina |> html_elements(xpath = "//select[@name = 'Incremento']/option") |> html_attr('value')
valor_nasc_ocorrencia <- valores_conteudo[which(conteudo == "Nascim p/ocorrênc")]

valores_periodo <- pagina |> html_elements(xpath = "//select[@name = 'Arquivos']/option") |> html_attr('value')
valor_2019 <- valores_periodo[which(periodos == "2019")]

valores_idade_mae <- pagina |> html_elements(xpath = "//select[contains(@name, 'SIdade')]/option") |> html_attr('value')
valor_20_a_24_anos <- valores_idade_mae[which(idade_mae == "20 a 24 anos")]

valores_sexo <- pagina |> html_elements(xpath = "//select[contains(@name, 'SSexo')]/option") |> html_attr('value')
valor_masculino <- valores_sexo[which(sexo == "Masc")]

