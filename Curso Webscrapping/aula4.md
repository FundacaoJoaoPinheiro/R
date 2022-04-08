Curso Webscrapping
================
Michel Alves
08/04/2022

# Unidade 4

## Navegação em páginas e preenchimento de formulários

O pacote Rvest permite a simulação de um usuário interagindo com um
website, usando formulários e navegando de página em página.

Para mostrar essas funcionalidades, iremos fazer uma busca pelo Google
Acadêmico. O primeiro é carregar o pacote que iremos utilizar, o Rvest.
Em seguida, definimos a URL a partir da qual começaremos a navegar e
então criamos uma sessão.

    library("rvest")

    url <-"http://www.google.com.br"

    s <- session(url)

Uma sessão representa um usuário que está acessando uma página. Para
encontrarmos a URL do Google Acadêmico, podemos usar o próprio Google
para fazer a pesquisa. Para isso temos que encontrar e preencher o
formulário de busca.

    s |> html_form()
    formulario <- s |> html_form()
    formulario <- formulario[[1]]

    formulario <- html_form(s)[[1]]

    formulario <- formulario |> html_form_set(q="google academico")

Agora temos que enviar o formulário e obter a resposta. A resposta
consiste em uma página as respostas obtidas para a pesquisa que fizemos.
Podemos usar as técnicas vistas nas aulas anteriores para encontrar
algum texto específico.

    resp <- formulario |> html_form_submit()

    p <- read_html(resp)
    p |> html_element(xpath = "//div[contains(text(), 'Google Acad')]/../..")

Depois de encontrarmos o texto desejado, podemos simular o usuário
clicando no link relacionado. Assim, finalmente chegamos à página do
Google Acadêmico.

    nova_url <- p |> html_element(xpath = "//div[contains(text(), 'Google Acad')]/../..") |> html_attr('href')

    s <- s |> session_jump_to(nova_url)

    s |> session_history()

Agora iremos pesquisar pelo termo *produto interno bruto*. Inicialmente
temos que selecionar o formulário adequado, preenchê-lo e submetê-lo.

    s |> html_form()
    formulario <- s |> html_form()
    formulario <- formulario[[2]]

    formulario <- formulario |> html_form_set(q="produto interno bruto")

    resp <- formulario |> html_form_submit()

Agora podemos ler a página obtida como resposta e extrair algumas
informações, como os nomes dos trabalhos encontrados.

    p <- read_html(resp)

    p |> html_elements(xpath = "//h3/a") |> html_text2()

E se quisermos alterar os filtros da busca? Por exemplo, se quisermos
buscar trabalhos no período entre 2015 a 2018, temos que preencher o
formulário correspondente.

    s <- s |> session_jump_to(resp$url)

    s |> html_form()
    formulario <- s |> html_form()
    formulario <- formulario[[4]]

    formulario <- formulario |> html_form_set(as_ylo ="2015", as_yhi = "2018")

    resp <- formulario |> html_form_submit()

    p <- read_html(resp)

    p |> html_elements(xpath = "//h3/a") |> html_text2()

E se quisermos navegar até a segunda página de resultados?

    p |> html_elements(xpath = "//a[contains(text(), '2')]/span[@class= 'gs_ico gs_ico_nav_page']") 

    s <- s |> session_follow_link(xpath = "//a[contains(text(), '2')]/span[@class= 'gs_ico gs_ico_nav_page']/..")

    p <- read_html(s$url)

    p |> html_elements(xpath = "//h3/a") |> html_text2()

Alguns sites proibem o uso de ferramentas automatizadas, ou **robôs**,
tal como o webscrapping. Para descobrir se um site permite ou não o uso
de webscrapping, é só procurar pelo arquivo `robots.txt`. Exemplo:

    http://fjp.mg.gov.br/robots.txt

## Exercício

A partir do página inicial da FJP, ir em Biblioteca e em seguida
Repositório Institucional, realizar uma pesquisa pelo termo *Produto
Interno Bruto* e armazenar os 20 primeiros resultados numa tabela.
