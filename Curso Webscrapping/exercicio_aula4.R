library(rvest)

url <- "http://fjp.mg.gov.br/"
s <- session(url)

p <- read_html(s)
p |> html_elements(xpath = "//span[contains(text(), 'Biblioteca')]/..")
s <- s |> session_follow_link(xpath = "//span[contains(text(), 'Biblioteca')]/..")

p <- read_html(s)
p |> html_elements(xpath = "//figcaption[contains(text(), 'Institucional')]/../a")
s <- s |> session_follow_link(xpath = "//figcaption[contains(text(), 'Institucional')]/../a")

f <- s |> html_form()
f <- f[[2]]

f <- f |> html_form_set(query = "produto interno bruto")
resp <- f |> html_form_submit()

p <- read_html(resp)
p |> html_elements(xpath = "//h3[contains(text(), 'Conjunto')]/../table")
tabela <- p |> html_elements(xpath = "//h3[contains(text(), 'Conjunto')]/../table") |> html_table()
tabela <- tabela[[5]]
