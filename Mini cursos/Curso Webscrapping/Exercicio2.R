#Carrega as bilbiotecas necessárias
library(rvest)

url <- "http://fjp.mg.gov.br/"
s <- session(url)

#obtém o html da sessão
p <- read_html(s)
#encontra o elemento que contém o link para a página da biblioteca no site da FJP
p |> html_elements(xpath = "//span[contains(text(), 'Biblioteca')]/..")
s <- s |> session_follow_link(xpath = "//span[contains(text(), 'Biblioteca')]/..")

#obtém o html da página da biblioteca
p <- read_html(s)
#encontra o elemento que deve ser clicado para acessar o Repositório Institucional
p |> html_elements(xpath = "//figcaption[contains(text(), 'Institucional')]/../a")
s <- s |> session_follow_link(xpath = "//figcaption[contains(text(), 'Institucional')]/../a")

#obtém os formulários
f <- s |> html_form()
#escolhe o segundo formulário
f <- f[[2]]

#preenche o formulário
f <- f |> html_form_set(query = "produto interno bruto")
#envia o formulário
resp <- f |> html_form_submit()

#obtem o html da resposta
p <- read_html(resp)
#encontra a tabela
p |> html_elements(xpath = "//h3[contains(text(), 'Conjunto')]/../table")
#lê a tabela com os 10 primeiros resultados
tabela <- p |> html_elements(xpath = "//h3[contains(text(), 'Conjunto')]/../table") |> html_table()
tabela <- tabela[[1]]
#encontra o link para a segunda página de resultados
s <- s |> session_jump_to(resp$url)
s <- s |> session_follow_link(xpath = "//p/a[contains(text(), '2')]")
#obtém o html da segunda página de resultados
p <- read_html(s)
#obtém os próximos 10 elementos do resultado da busca
tabela2 <- p |> html_elements(xpath = "//h3[contains(text(), 'Conjunto')]/../table") |> html_table()
tabela2 <- tabela2[[1]]

#obtém a tabela final com os 20 primeiros resultados da busca
tabela <- rbind(tabela, tabela2)
