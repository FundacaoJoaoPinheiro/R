Título do script
================
Autor do script
Data de criação do script

Para exibir texto, use \#’. Observe que toda a sintaxe do markdown
funciona aqui.

Se quiser executar código inline, use o acento grave: dois mais dois
igual a 4

# Opções de visualização

Para configurar as opções de visualização do código, faça como a seguir:
\#+ r setup, warning = FALSE

Outras opções:

-   eval = TRUE - executa o código e inclui o resultado
-   echo = TRUE - exibe o código e seu resultado
-   warning = FALSE - exibe as mensagens de aviso
-   error = FALSE - exibe as mensagens de erro
-   tidy = FALSE - exibe o código em um formato mais compacto

As configurações acima devem ser colocadas antes de cada bloco de
código. caso deseje fazer configurações globais, use

``` r
options(warn=-1)
```

# Estrutura do script

## Limpa a memória e console

``` r
cat("\014")  
```



``` r
rm(list = ls())
```

## Carrega as bibliotecas

``` r
library("tidyr")
```

## Importa os dados

## Manipulação da base de dados
