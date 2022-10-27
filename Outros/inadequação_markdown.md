Cálculo da Inadequação de Domicílios Urbanos no R
================
Coordenação de Habitação e Saneamento - Fundação João Pinheiro
02/09/2022

Este documento está sendo disponibilizado com a finalidade de publicizar
o *script* *R* de geração dos resultados da Inadequação de Domicílios
Urbanos para o ano de 2019, realizada pela Fundação João Pinheiro. Dessa
forma, por meio deste documento, visa-se auxiliar aqueles que desejam
reproduzir este trabalho ou utilizar os dados gerados neste para outras
análises.

Os resultados aqui produzidos são gerados a partir da PNAD Contínua e
referentes aos seguintes componentes da Inadequação Habitacional:

-   Carências de Infraestrutura Urbana

-   Carências Edílicas

-   Inadequação Fundiária

-   Total de domicílios urbanos inadequados

Ressalta-se que a análise final presente neste *script* indicará os
resultados apenas da ***PNAD Contínua de 2019***. Isso se deve, pois,
dentro do componente **“Carências de Infraestrutura Urbana”**,
encontra-se o subcomponente **“Inadequação do Esgotamento Sanitário”**
referente às variáveis S01012 (PNAD Contínua 2016 a 2018) e S01012A
(PNAD Contínua 2019). Para os anos de 2016 a 2018 uma das resposta de
interesse, ***“Fossa rudimentar”,*** que indica situação de inadequação
do esgotamento sanitário, esteve contida na mesma categoria de resposta
da “**Fossa não ligada à rede”** e, consequentemente, não é
contabilizada diretamente para o período de 2016 até 2018. No mesmo
sentido, ao se considerar a ***”Fossa não ligada à rede”*** como
inadequado, *há superestimação do indicador*, pois se considera formas
adequadas - como a *”fossa séptica não ligada à rede*” - como
inadequada.

Para contornar este problema, foram calculadas as proporções da
distribuição dos diferentes componentes que compunham a “*fossa não
ligada à rede*”, isto é, a proporção do que seria *“fossa séptica não
ligada à rede*” e o que seria “*fossa rudimentar*” para o novo cálculo
da inadequação do esgotamento sanitário entre 2016 e 2018, a partir dos
dados de 2019 para todas as unidades geográficas de análise.

Posteriormente, foi aplicada a média da variação dos resultados obtidos
para de 2019 e os superestimados, entre 2016 e 2018, para gerar os as
tabelas com os dados referentes ao total de domicílios com carências de
infraestrutura e o total de domicílios inadequados, também para os anos
de 2016 até 2018 e para todas as unidades geográficas de análise.

Para uma explicação mais detida, recomenda-se a leitura de [Metodologia
do Deficit Habitacional e da Inadequação de Domicílios no Brasil
2016-2019](http://fjp.mg.gov.br/wp-content/uploads/2020/12/04.03_Relatorio-Metodologia-do-Deficit-Habitacional-e-da-Inadequacao-de-Domicilios-no-Brasil-2016-2019-v-1.0_compressed.pdf)
(Fundação João Pinheiro, 2020, p. 52-58) para sanar dúvidas
metodológicas a respeito deste *script.*

Deste modo, o processamento deste *script* foi todo realizado utilizando
as PNADs Contínua entre 2016 e 2019, mas, ao final, foi extraído apenas
o último ano para geração das tabelas referentes aos componentes da
Inadequação de Domicílios.

Não obstante, caso se queria gerar os resultados para todos os
componentes da inadequação de domicílios - com exceção do ***total de
domicílios urbanos inadequados, total de domicílios urbanos com carência
de infraestrutura e total de domicílios urbanos com inadequação
esgotamento sanitário*** - basta gerar as tabelas usando a lista com as
PNADs Contínua, ao invés de apenas a lista com o plano amostral complexo
de 2019.

# 1. Preparativos iniciais

## 1.1 Obtendo os dados da PNAD Contínua

Estabeleça o diretório onde estão localizados os dados da PNAD Contínua
2016 a 2019:

``` r
setwd("directory/")
```

Caso necessário, utilize o código abaixo para baixar os dados da PNAD
Contínua, os quais devem ser salvos em uma pasta denominada ***input***
no diretório estabelecido. Os dados referentes às características dos
domicílios se encontram na primeira visita da PNAD Contínua de 2016 a
2019.

``` r
install.packages("PNADcIBGE")
library("PNADcIBGE")
get_pnadc(2016,interview = 1, savedir = "input/")
get_pnadc(2017,interview = 1, savedir = "input/")
get_pnadc(2018,interview = 1, savedir = "input/")
get_pnadc(2019,interview = 1, savedir = "input/")
```

## 1.2 Preparando o Ambiente R

Estabeleça os pacotes a serem utilizados:

``` r
pacotes <- c("tidyverse", "data.table", "PNADcIBGE", "survey", "srvyr", "rio", "ggtext", 
             "ggthemes", "ipeadatar", "rlist")
```

Caso precise instale os pacotes que forem necessários:

``` r
install.packages(pacotes)
```

Carregue os pacotes em seu ambiente R:

``` r
carregar <- lapply(pacotes, library, character.only = TRUE)
```

Se necessário, utilize o código abaixo para aumentar a memória
disponível para seu ambiente R:

``` r
memory.limit(size = 20000)
```

# 2. Preparando a Base de dados

## 2.1 Importando dados da PNAD Contínua

Utilize os comandos abaixo para selecionar as variáveis, identifcar os
arquivos da PNAD Contínua e, em seguida, importá-los. Note-se que para a
construção das variáveis da inadequação de domicílios se faz necessário
a importação das bases de forma separada, em função das alterações nos
nomes e códigos de algumas variáveis entre os anos. Assim, os nomes são
normatizados e as bases unidas.

``` r
variaveis_2016 <- c(
  "Ano", # Ano
  "UF", # Unidade da Federação
  "Capital", # Município da Capital
  "RM_RIDE", # Regiãoo Metropolitana e Regiãoo Administrativa Integrada
  'UPA', # Unidade Primaria de amostragem (unidade de amostragem mais granular)
  'Estrato', # Estratos da amostra
  "V1030", # Projeção da população
  "V1031", # Peso com correção de não entrevista sem pós estratificação
  "V1032", # Peso com correção de nãoo entrevista com pós estratificação
  "V2001", # Número de pessoas no domicílio
  "V2005", # Condição no domicílio
  "S01002", # Material paredes externas domicílio
  "S01001", # Tipo de domicílio (casa, apt, cômodo/cortiço...)
  "S01017", # Este domicílio é (próprio, alugado...)
  "V1022", # Situação do domicílio (urbano/rural)
  "S01019", # Valor mensal do aluguel
  "VD5004", # Rendimento (efetivo) domiciliar
  "S01005", # Total de comodos do domicilio
  "S01006", # Cômodos servindo de dormitórios
  "VD2003", # Núm. componentes do domicílio (exclusive pensionista, emp. domest. ou parente emp. 
  #domest.)
  "S01004", # Piso que predomina no domicílio
  "VD2004", # Espécie da unidade doméstica
  'S01007', # Forma de abastecimento de agua
  'S01012', # Escoadouro do banheiro/sanitario
  'S01014', # Origem da energia eletrica
  'S01013', # Principal destino do lixo
  'S01011', # Numero de banheiros ou sanitarios ATENCAO DIFERENCIAR 2016 e 2017-2018
  'S01020', # Onde o terreno esta localizado
  'S01003',  # Cobertura do telhado
  "S01009", #Possui reservatório
  "S01008", 
  "S01010",
  'V2010',  # cor ou raça
  "S01015",
  'V2007'  # sexo moradores
)

variaveis_2017_2018 <- c(
  "Ano", # Ano
  "UF", # Unidade da Federação
  "Capital", # Município da Capital
  "RM_RIDE", # Regiãoo Metropolitana e Regiãoo Administrativa Integrada
  'UPA', # Unidade Primaria de amostragem (unidade de amostragem mais granular)
  'Estrato', # Estratos da amostra
  "V1030", # Projeção da população
  "V1031", # Peso com correção de não entrevista sem pós estratificação
  "V1032", # Peso com correção de nãoo entrevista com pós estratificação
  "V2001", # Número de pessoas no domicílio
  "V2005", # Condição no domicílio
  "S01002", # Material paredes externas domicílio
  "S01001", # Tipo de domicílio (casa, apt, cômodo/cortiço...)
  "S01017", # Este domicílio é (próprio, alugado...)
  "V1022", # Situação do domicílio (urbano/rural)
  "S01019", # Valor mensal do aluguel
  "VD5004", # Rendimento (efetivo) domiciliar
  "S01005", # Total de comodos do domicilio
  "S01006", # Cômodos servindo de dormitórios
  "VD2003", # Núm. componentes do domicílio (exclusive pensionista, emp. domest. ou parente emp. 
  #domest.)
  "S01004", # Piso que predomina no domicílio
  "VD2004", # Espécie da unidade doméstica
  'S01007', # Forma de abastecimento de agua
  'S01012', # Escoadouro do banheiro/sanitario
  'S01014', # Origem da energia eletrica
  'S01013', # Principal destino do lixo
  'S01011A', # Numero de banheiros ou sanitarios ATENCAO DIFERENCIAR 2016 e 2017-2018
  'S01020', # Onde o terreno esta localizado
  'S01003',  # Cobertura do telhado
  "S01009", #Possui reservatÃ³rio
  "S01008",
  "S01010",
  "S01015",
  'V2010',  # cor ou raça
  'V2007'  # sexo moradores
)
variaveis_2019 <- c(
  "Ano", # Ano
  "UF", # Unidade da Federação
  "Capital", # Município da Capital
  "RM_RIDE", # Regiãoo Metropolitana e Regiãoo Administrativa Integrada
  'UPA', # Unidade Primaria de amostragem (unidade de amostragem mais granular)
  'Estrato', # Estratos da amostra
  "V1030", # Projeção da população
  "V1031", # Peso com correção de não entrevista sem pós estratificação
  "V1032", # Peso com correção de nãoo entrevista com pós estratificação
  "V2001", # Número de pessoas no domicílio
  "V2005", # Condição no domicílio
  "S01002", # Material paredes externas domicílio
  "S01001", # Tipo de domicílio (casa, apt, cômodo/cortiço...)
  "S01017", # Este domicílio é (próprio, alugado...)
  "V1022", # Situação do domicílio (urbano/rural)
  "S01019", # Valor mensal do aluguel
  "VD5004", # Rendimento (efetivo) domiciliar
  "S01005", # Total de comodos do domicilio
  "S01006", # Cômodos servindo de dormitórios
  "VD2003", # Núm. componentes do domicílio (exclusive pensionista, emp. domest. ou parente emp. 
  #domest.)
  "S01004", # Piso que predomina no domicílio
  "VD2004", # Espécie da unidade doméstica
  'S01007', # Forma de abastecimento de agua
  'S01012A', # Escoadouro do banheiro/sanitario
  'S01014', # Origem da energia eletrica
  'S01013', # Principal destino do lixo
  'S01011A', # Numero de banheiros ou sanitarios ATENCAO DIFERENCIAR 2016 e 2017-2018
  'S01020', # Onde o terreno esta localizado
  'S01003',  # Cobertura do telhado
  "S01009", #Possui reservatório
  "S01008",
  "S01010",
  "S01015",
  'V2010',  # cor ou raça
  'V2007'  # sexo moradores
)

## Importar dados offline
# Identificar os arquivos de microdados
microdados <- list.files(path = "input/", pattern = "^PNADC_201(7|8)(.*?)txt$")
microdados <- map_chr(microdados, function(x) paste0("input/", x))
# Identificar os inputs
input_PNADc <- list.files(path = "input/", pattern = "^input_PNADC_201(7|8)(.*?)txt$")
input_PNADc <- map_chr(input_PNADc, function(x) paste0("input/", x))
# Identificar os dicionários
dicionarios <- list.files(path = "input/",
                          pattern = "^dicionario_PNADC_microdados_201(6|7|8|9)(.*?)xls$")
dicionarios <- map_chr(dicionarios, function(x) paste0("input/", x))
## 2017 E 2018
# Importar os dados 2017 e 2018 em uma lista
PNADc_lista <- map2(microdados, input_PNADc, function(x, y) 
  read_pnadc(microdata = x,
             input_txt = y,
             vars = variaveis_2017_2018))
# Renomear as pesquisas de acordo com os anos
names(PNADc_lista) <- paste0("PNADc_", c(2017:2018))

# Importar dados 2016
PNADc_2016 <- read_pnadc(
  microdata = "input/PNADC_2016_visita1.txt",
  input_txt = "input/input_PNADC_2016_visita1.txt",
  vars = variaveis_2016
)

# Importar dados 2019
PNADc_2019 <- read_pnadc(
  microdata = "input/PNADC_2019_visita1.txt",
  input_txt = "input/input_PNADC_2019_visita1.txt",
  vars = variaveis_2019
)

#install.packages('rlist')
library(rlist)
# Adicionar PNADc_2016 e PNADc_2019 a lista
PNADc_lista <- list.append(PNADc_lista, 'PNADc_2016' = PNADc_2016, 'PNADc_2019' = PNADc_2019)

rm(PNADc_2016)
rm(PNADc_2019)

# Reordenar lista
PNADc_lista <- PNADc_lista[c("PNADc_2016","PNADc_2017","PNADc_2018","PNADc_2019")]

# Adicionar os rótulos das variáveis categóricas
PNADc_lista$PNADc_2016 <- pnadc_labeller(PNADc_lista$PNADc_2016,
                                         dictionary.file = dicionarios[1])
PNADc_lista$PNADc_2017 <- pnadc_labeller(PNADc_lista$PNADc_2017,
                                         dictionary.file = dicionarios[2])
PNADc_lista$PNADc_2018 <- pnadc_labeller(PNADc_lista$PNADc_2018,
                                         dictionary.file = dicionarios[3])

PNADc_lista$PNADc_2019 <- pnadc_labeller(PNADc_lista$PNADc_2019,
                                         dictionary.file = dicionarios[4])

# Renomear S01011A em 2017-18 para S01011
colnames(PNADc_lista$PNADc_2017)[colnames(PNADc_lista$PNADc_2017) == 'S01011A'] <- 'S01011'
colnames(PNADc_lista$PNADc_2018)[colnames(PNADc_lista$PNADc_2018) == 'S01011A'] <- 'S01011'
colnames(PNADc_lista$PNADc_2019)[colnames(PNADc_lista$PNADc_2019) == 'S01011A'] <- 'S01011'

## Renomear S01012A EM 2019 PARA S01012
colnames(PNADc_lista$PNADc_2019)[colnames(PNADc_lista$PNADc_2019) == 'S01012A'] <- 'S01012'
```

Verificando as Colunas da Base de dados importada[^1]:

``` r
colnames(PNADc_lista$PNADc_2019)
```

    ##   [1] "Ano"          "Trimestre"    "UF"           "Capital"      "RM_RIDE"     
    ##   [6] "UPA"          "Estrato"      "V1008"        "V1014"        "V1022"       
    ##  [11] "V1030"        "V1031"        "V1032"        "V1034"        "posest"      
    ##  [16] "posest_sxi"   "V2001"        "V2003"        "V2005"        "V2007"       
    ##  [21] "V2010"        "S01001"       "S01002"       "S01003"       "S01004"      
    ##  [26] "S01005"       "S01006"       "S01007"       "S01008"       "S01009"      
    ##  [31] "S01010"       "S01011"       "S01012"       "S01013"       "S01014"      
    ##  [36] "S01015"       "S01017"       "S01019"       "S01020"       "VD2003"      
    ##  [41] "VD2004"       "VD5004"       "V1032001"     "V1032002"     "V1032003"    
    ##  [46] "V1032004"     "V1032005"     "V1032006"     "V1032007"     "V1032008"    
    ##  [51] "V1032009"     "V1032010"     "V1032011"     "V1032012"     "V1032013"    
    ##  [56] "V1032014"     "V1032015"     "V1032016"     "V1032017"     "V1032018"    
    ##  [61] "V1032019"     "V1032020"     "V1032021"     "V1032022"     "V1032023"    
    ##  [66] "V1032024"     "V1032025"     "V1032026"     "V1032027"     "V1032028"    
    ##  [71] "V1032029"     "V1032030"     "V1032031"     "V1032032"     "V1032033"    
    ##  [76] "V1032034"     "V1032035"     "V1032036"     "V1032037"     "V1032038"    
    ##  [81] "V1032039"     "V1032040"     "V1032041"     "V1032042"     "V1032043"    
    ##  [86] "V1032044"     "V1032045"     "V1032046"     "V1032047"     "V1032048"    
    ##  [91] "V1032049"     "V1032050"     "V1032051"     "V1032052"     "V1032053"    
    ##  [96] "V1032054"     "V1032055"     "V1032056"     "V1032057"     "V1032058"    
    ## [101] "V1032059"     "V1032060"     "V1032061"     "V1032062"     "V1032063"    
    ## [106] "V1032064"     "V1032065"     "V1032066"     "V1032067"     "V1032068"    
    ## [111] "V1032069"     "V1032070"     "V1032071"     "V1032072"     "V1032073"    
    ## [116] "V1032074"     "V1032075"     "V1032076"     "V1032077"     "V1032078"    
    ## [121] "V1032079"     "V1032080"     "V1032081"     "V1032082"     "V1032083"    
    ## [126] "V1032084"     "V1032085"     "V1032086"     "V1032087"     "V1032088"    
    ## [131] "V1032089"     "V1032090"     "V1032091"     "V1032092"     "V1032093"    
    ## [136] "V1032094"     "V1032095"     "V1032096"     "V1032097"     "V1032098"    
    ## [141] "V1032099"     "V1032100"     "V1032101"     "V1032102"     "V1032103"    
    ## [146] "V1032104"     "V1032105"     "V1032106"     "V1032107"     "V1032108"    
    ## [151] "V1032109"     "V1032110"     "V1032111"     "V1032112"     "V1032113"    
    ## [156] "V1032114"     "V1032115"     "V1032116"     "V1032117"     "V1032118"    
    ## [161] "V1032119"     "V1032120"     "V1032121"     "V1032122"     "V1032123"    
    ## [166] "V1032124"     "V1032125"     "V1032126"     "V1032127"     "V1032128"    
    ## [171] "V1032129"     "V1032130"     "V1032131"     "V1032132"     "V1032133"    
    ## [176] "V1032134"     "V1032135"     "V1032136"     "V1032137"     "V1032138"    
    ## [181] "V1032139"     "V1032140"     "V1032141"     "V1032142"     "V1032143"    
    ## [186] "V1032144"     "V1032145"     "V1032146"     "V1032147"     "V1032148"    
    ## [191] "V1032149"     "V1032150"     "V1032151"     "V1032152"     "V1032153"    
    ## [196] "V1032154"     "V1032155"     "V1032156"     "V1032157"     "V1032158"    
    ## [201] "V1032159"     "V1032160"     "V1032161"     "V1032162"     "V1032163"    
    ## [206] "V1032164"     "V1032165"     "V1032166"     "V1032167"     "V1032168"    
    ## [211] "V1032169"     "V1032170"     "V1032171"     "V1032172"     "V1032173"    
    ## [216] "V1032174"     "V1032175"     "V1032176"     "V1032177"     "V1032178"    
    ## [221] "V1032179"     "V1032180"     "V1032181"     "V1032182"     "V1032183"    
    ## [226] "V1032184"     "V1032185"     "V1032186"     "V1032187"     "V1032188"    
    ## [231] "V1032189"     "V1032190"     "V1032191"     "V1032192"     "V1032193"    
    ## [236] "V1032194"     "V1032195"     "V1032196"     "V1032197"     "V1032198"    
    ## [241] "V1032199"     "V1032200"     "ID_DOMICILIO"

Transformando os dados importados em um objeto de plano amostral
complexo e, depois, permitindo seu tratamento dentro da lógica do
*dplyr*:

``` r
PNADc_lista <- PNADc_lista %>% map(pnadc_design)
PNADc_svy <- lapply(PNADc_lista, as_survey)
rm(PNADc_lista)
```

## 2.2 Gerando Variáveis que comporão a base de dados

A função abaixo será utilizada para gerar novas variáveis categóricas e
aplicá-las em todos os objetos da lista criada:

``` r
fct_case_when <- function(...) {
  args <- as.list(match.call())
  levels <- sapply(args[-1], function(f) f[[3]])  # extract RHS of formula
  levels <- levels[!is.na(levels)]
  factor(dplyr::case_when(...), levels=levels)
}
```

### 2.2.1 Variáveis de Renda domiciliar em termos do salário mínimo

Baixe a série histórica do salário mínimo e crie vetores para o salário
mínimo usando o primeiro mês de cada ano:

``` r
library(ipeadatar)
serie_sm <- ipeadata(code = "MTE12_SALMIN12", language = "br")

sm_2016 <- serie_sm %>% 
  filter(date == "2016-01-01") %>% 
  summarise(Valor = sum(value)) %>% 
  as.double()
sm_2017 <- serie_sm %>% 
  filter(date == "2017-01-01") %>% 
  summarise(Valor = sum(value)) %>% 
  as.double()
sm_2018 <- serie_sm %>% 
  filter(date == "2018-01-01") %>% 
  summarise(Valor = sum(value)) %>% 
  as.double()
sm_2019 <- serie_sm %>% 
  filter(date == "2019-01-01") %>% 
  summarise(Valor = sum(value)) %>% 
  as.double()

# Criar uma lista com os salários mínimos de cada ano
SMs <- list(SM_2016 = sm_2016,
            SM_2017 = sm_2017,
            SM_2018 = sm_2018,
            SM_2019 = sm_2019)
```

Crie, utilzando a função *fct_case_when*, os códigos abaixo das
variáveis de renda em termos do salário mínimo de cada ano:

``` r
# Criar função que cria variável com faixa salarial: Faixa_Rend_Dom
fun_faixa <- function(x, y){
  x %>% mutate(Faixa_Rend_Dom = fct_case_when(
    VD5004 <= 0.25 * y ~ "Até ¼ salário mínimo",
    VD5004 > 0.25 * y & VD5004 <= 0.5 * y ~ "Mais de ¼ até ½ salário mínimo",
    VD5004 > 0.5 * y & VD5004 <= 1 * y ~ "Mais de ½ até 1 salário mínimo",
    VD5004 > 1 * y & VD5004 <= 2 * y ~ "Mais de 1 até 2 salários mínimos",
    VD5004 > 2 * y & VD5004 <= 3 * y ~ "Mais de 2 até 3 salários mínimos",
    VD5004 > 3 * y & VD5004 <= 5 * y ~ "Mais de 3 até 5 salários mínimos",
    VD5004 > 5 * y ~ "Mais de 5 salários mínimos",
    is.na(VD5004) ~ NA_character_
  ))
}
# Aplicar função para todas os anos, de acordo com a lista de SMs
PNADc_svy <- map2(PNADc_svy, SMs, fun_faixa)

## Criar função de faixa salarial para politicas habitacionais
fun_faixa_2 <- function(x, y){
  x %>% mutate(Faixa_Rend_Dom_2 = fct_case_when(
    VD5004 <= 1 * y ~ "Até 1 salário mínimo",
    VD5004 > 1 * y & VD5004 <= 2 * y ~ "Mais de 1 até 2 salário mínimo",
    VD5004 > 2 * y & VD5004 <= 3 * y ~ "Mais de 2 até 3 salário mínimo",
    VD5004 > 3 * y ~ "Mais de 3 salários mínimos",
    is.na(VD5004) ~ NA_character_
  ))
}
PNADc_svy <- map2(PNADc_svy, SMs, fun_faixa_2)

# Criar um vetor com as faixas com menos de 3SMs
SMs_3 <- c("Até ¼ salário mínimo",
           "Mais de ¼ até ½ salário mínimo",
           "Mais de ½ até 1 salário mínimo",
           "Mais de 1 até 2 salários mínimos",
           "Mais de 2 até 3 salários mínimos")
```

### 2.2.2 Variável de Região

Crie com os códigos abaixo a variável da região para a base de dados:

``` r
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(Regiao = fct_case_when(
    UF %in% c("Rondônia", "Acre", "Amazonas", "Roraima", "Pará", "Amapá", "Tocantins") ~ 
      "Norte",
    UF %in% c("Maranhão", "Piauí", "Ceará", "Rio Grande do Norte", "Paraíba", "Pernambuco", 
              "Alagoas", "Bahia", "Sergipe") ~ 
      "Nordeste",
    UF %in% c("Minas Gerais", "Espírito Santo", "Rio de Janeiro", "São Paulo") ~ 
      "Sudeste",
    UF %in% c("Paraná", "Santa Catarina", "Rio Grande do Sul") ~ 
      "Sul",
    UF %in% c("Mato Grosso do Sul", "Mato Grosso", "Goiás", "Distrito Federal") ~ 
      "Centro-Oeste",
    is.na(UF) ~ 
      NA_character_
  )))
```

### 2.2.3 Variável de Região Metropolitana

Crie com os códigos abaixo a variável identificadora de região
metropolitana para a base de dados:

``` r
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(RMs = fct_case_when(
    !is.na(RM_RIDE) ~ 
      "RM",
    is.na(RM_RIDE) ~ 
      NA_character_
  )))
```

### 2.2.4 Variável de Cômodos servindo como dormitório

Crie com os códigos abaixo a variável que identifica se o número de
cômodos utilizados como dormitório é igual ao total de cômodos do
domicílio exceto banheiros:

``` r
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(comodos_menos_banheiros = fct_case_when(
    S01006 >= S01005 - S01011 ~
      "Número de cômodos servindo de dormitório igual ou maior que número total de cômodos (exceto banheiro)",
    S01006 < S01005 - S01011 ~  
      "Número de cômodos servindo de dormitório menor que o número total de cômodos (exceto banheiro)"
    # is.na(S01005) | is.na(S01006) | is.na(S01011) ~ 
    #   NA_character_
  )))   
```

### 2.2.5 Variável identificadora de Déficit Habitacional

Como explicado em [Metodologia do Deficit Habitacional e da Inadequação
de Domicílios no Brasil
2016-2019](https://drive.google.com/file/d/1bHOyrem6wB5KupeBGYPgfNCNi0Z9IDV4/view)
(Fundação João Pinheiro, 2020), a análise de Inadequação Domiciliar
restringe-se aos ***domicílios urbanos e são excluídos os domicílios em
situação de déficit habitacional do tipo domicílio rústico e do tipo
domicílio cômodo***. Dessa forma, é preciso identificar na base de dados
as observações que se encontram nessa situação para que não sejam
incluídas errôneamente na análise final.

A seguir, crie os identificadores dos componentes *“Domicílios
Rústicos”* e *“Cômodos”* do déficit habitacional, e use-os para
categorizar os domicílios em situação de Déficit.

``` r
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(CH = fct_case_when(
    S01002 %in% c("Taipa sem revestimento", 
                  "Madeira aproveitada",
                  "Outro material") ~ "Domicílios Rústicos",
    S01001 %in% "Habitação em casa de cômodos, cortiço ou cabeça de porco" & 
      ! S01017 %in% c("Cedido por empregador") ~ "Cômodos",
    TRUE ~ "Sem Déficit"
  )))

# CRIACAO VARIAVEL DEFICIT ----
# Variável numérica: Deficit
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(Deficit = case_when(
    CH %in% c("Domicílios Rústicos", 
              "Cômodos") ~ 1, # Deficit
    TRUE ~ 0 # Sem Deficit
  )))

# Variável categórica: DH
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(DH = fct_case_when(
    CH %in% c("Domicílios Rústicos", 
              "Cômodos") ~ "Deficit",
    TRUE ~ "Sem Deficit"
  )))   
```

# 3. Gerando Indicadores de Inadequação de Domicílios Urbanos

A seguir, serão criados por meio da função *fct_case_when* os
indicadores de Inadequação dos Domicílios Urbanos. Inicialmente serão
criados os indicadores para cada componente e subcomponentes da
inadequação, bem como a variável que identifica o total de domicílios
urbanos com pelo menos uma inadequação.

Note que, como explicado anteriormente, os domicílios são primeiro
identificados como rurais ou em situação de déficit para depois
categorizá-los de acordo com a inadequação domiciliar.

Do mesmo modo, os componentes de Carência de Infraestrutura e Carência
Edilícia, indicam a existência de ***pelo menos uma inadequação de seu
grupo***, não podendo os resultados de cada subcomponente ser somado aos
demais. Por fim, o indicador de inadequação de domicílios indica a
existência de ***ao menos uma inadequação*** em qualquer um dos
componentes - Infraestrutura, Edilícia ou Fundiária.

## 3.1 Carência de Infraestrutura Urbana

Crie a variável indicadora dos domicílios que apresentam ***ao menos um
tipo de Carência de Infraestrutura Urbana***.

``` r
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(inf_urb = fct_case_when(
    V1022 %in% "Rural" ~ "Rural",
    DH %in% "Deficit" ~ "Deficit",
    S01007 %in% c('Poço profundo ou artesiano','Poço raso, freático ou cacimba',
                  'Fonte ou nascente','Água da chuva armazenada', 'Outra', 'Outra (especifique)') |
      S01012 %in% c('Fossa rudimentar', 'Vala','Rio, lago ou mar', 'Outra', 'Outra forma (especifique)') |
      S01008 %in% c('De 4 a 6 dias na semana','De 1 a 3 dias na semana','Outra frequência') |
      S01010 %in% c('Canalizada só na propriedade ou terreno','Não canalizada') |  
      S01014 %in% c('Não utiliza/tem energia eletrica') |
      S01015 %in% c('Diária, por algumas horas','Outra frequência') |
      S01013 %in% c('Queimado (na propriedade)','Enterrado (na propriedade)',
                    'Jogado em terreno baldio ou logradouro', 'Outro destino', 
                    'Outro destino  (especifique)') ~ "Infraestrutura Urbana",
    TRUE ~ "Sem inadequação"
  )))
```

Em seguida, crie as variáveis identificadoras de cada subcomponente de
Carência de Infraestrutua Urbana.

``` r
# energia_eletrica
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(energia_eletrica = fct_case_when(
    V1022 %in% "Rural" ~ "Rural",
    DH %in% "Deficit" ~ "Deficit",
    S01014 %in% c('Não utiliza/tem energia eletrica') |
      S01015 %in% c('Diária, por algumas horas','Outra frequência') ~ 
      "Energia elétrica",
    TRUE ~ "Sem inadequação"
  )))

# agua
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(agua = fct_case_when(
    V1022 %in% "Rural" ~ "Rural",
    DH %in% "Deficit" ~ "Deficit",
    S01007 %in% c('Poço profundo ou artesiano','Poço raso, freático ou cacimba',
                  'Fonte ou nascente','Água da chuva armazenada', 'Outra', 'Outra (especifique)') | 
      S01008 %in% c('De 4 a 6 dias na semana','De 1 a 3 dias na semana','Outra frequência') |
      S01010 %in% c('Canalizada só na propriedade ou terreno','Não canalizada') ~
      "Abastecimento de água",
    TRUE ~ "Sem inadequação"
  )))

# esgotamento sanitario
PNADc_svy <- PNADc_svy %>%
  map(~ .x %>% mutate(esgotamento_sanitario = fct_case_when(
    V1022 %in% "Rural" ~ "Rural",
    DH %in% "Deficit" ~ "Deficit",
    S01012 %in% c('Fossa não ligada à rede', 'Fossa rudimentar', 'Vala', 'Rio, lago ou mar',
                  'Outra forma', 'Outra forma (especifique)') ~
      "Esgotamento sanitário",
    TRUE ~ "Sem inadequação"
  )))

# coleta_lixo
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(coleta_lixo = fct_case_when(
    V1022 %in% "Rural" ~ "Rural",
    DH %in% "Deficit" ~ "Deficit",
    S01013 %in% c('Queimado (na propriedade)','Enterrado (na propriedade)',
                  'Jogado em terreno baldio ou logradouro','Outro destino',
                  'Outro destino  (especifique)') ~
      "Coleta de lixo",
    TRUE ~ "Sem inadequação"
  )))
```

## 3.2 Carência Edílica

Crie a variável indicadora dos domicílios que apresentam ***ao menos um
tipo de Carência Edílica***.

``` r
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(car_edil = fct_case_when(
    V1022 %in% "Rural" ~ "Rural",
    DH %in% "Deficit" ~ "Deficit",
    S01009 %in% 'Não' |
      S01011 == 0 |
      comodos_menos_banheiros %in% "Número de cômodos servindo de dormitório igual ou maior que número total de cômodos (exceto banheiro)" |
      S01003 %in% c('Zinco,alumínio ou chapa metálica', 'Outro material') |
      S01004 %in% c('Terra')  ~
      "Carências Edilícias",
    TRUE ~ "Sem inadequação"
  )))
```

Em seguida, crie as variáveis identificadoras de cada subcomponente de
Carência Edílica.

``` r
### ARMAZENAMENTO
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(armazen_agua = fct_case_when(
    V1022 %in% "Rural" ~ "Rural",
    DH %in% "Deficit" ~ "Deficit",
    S01009 %in% 'Não' ~ "Sem Armazenamento",
    # is.na(S01009) ~ NA_character_,
    TRUE ~ "Sem inadequação"
  )))

# AUSENCIA DE BANHEIRO
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(ausencia_banheiro = fct_case_when(
    V1022 %in% "Rural" ~ "Rural",
    DH %in% "Deficit" ~ "Deficit",
    S01011 == 0 ~ "Ausência de banheiro",
    # is.na(S01011) ~ NA_character_,
    TRUE ~ "Sem inadequação"
  )))

# Número de cômodos servindo de dormitório = número total de cômodos exceto banheiro
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(comodos_dormitorios = fct_case_when(
    V1022 %in% "Rural" ~ "Rural",
    DH %in% "Deficit" ~ "Deficit",
    comodos_menos_banheiros %in% 
      "Número de cômodos servindo de dormitório igual ou maior que número total de cômodos (exceto banheiro)"  ~ 
      "Todos os cômodos (exceto banheiro) servindo de dormitório",
    TRUE ~ "Sem inadequação"
  )))   

# COBERTURA INADEQUADA
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(cobertura = fct_case_when(
    V1022 %in% "Rural" ~ "Rural",
    DH %in% "Deficit" ~ "Deficit",
    S01003 %in% c('Zinco,alumínio ou chapa metálica', 'Outro material') ~ 
      "Cobertura inadequada",
    # is.na(S01003) ~ NA_character_,
    TRUE ~ "Sem inadequação"
  )))


#Piso
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(piso = fct_case_when(
    V1022 %in% "Rural" ~ "Rural",
    DH %in% "Deficit" ~ "Deficit",
    S01004 %in% c('Terra') ~ 
      "piso inadequado",
    # is.na(S01004) ~ NA_character_,
    TRUE ~ "Sem inadequação"
  )))
```

## 3.3 Inadequação Fundiária

Crie a variável indicadora dos domicílios que apresentam Inadequação
Fundiária.

``` r
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(inadeq_fund = fct_case_when(
    V1022 %in% "Rural" ~ "Rural",
    DH %in% "Deficit" ~ "Deficit",
    S01017 %in% c('Próprio de algum morador - já pago',
                  'Próprio de algum morador - ainda pagando') &
      S01020 %in% 'Não' ~ 
      "Inadequação fundiária",
    # is.na(S01017) | is.na(S01020) ~ NA_character_,
    TRUE ~ "Sem inadequação"
  )))
```

## 3.4 Total de domicílios urbanos inadequados

Crie a variável indicadora dos domicílios que apresentam ***ao menos um
componente de inadequação domiciliar***.

``` r
PNADc_svy <- PNADc_svy %>% 
  map(~ .x %>% mutate(inadequacao = fct_case_when(
    V1022 %in% "Rural" ~ "Rural",
    DH %in% "Deficit" ~ "Deficit",
    inf_urb %in% "Infraestrutura Urbana" |
      car_edil %in% "Carências Edilícias"|
      inadeq_fund %in% "Inadequação fundiária" ~
      "Domicílios inadequados",
    TRUE ~ "Domicílios urbanos duráveis"
  )))
```

# 4. Gerando dados finais

Como discutido inicialmente, devido a questões referentes ao
subcomponente de *“Esgotamento Sanitário”* específicas dos anos de 2016
a 2018, serão geradas tabelas ***apenas para o ano de 2019***.

Essas tabelas podem ser geradas seguindo o exemplo abaixo, para as
Unidades Federativas:

``` r
###Inadequação Total por UF
UF_abast <-  PNADc_svy$PNADc_2019 %>% 
  filter(V2005 %in% "Pessoa responsável pelo domicílio") %>% 
  group_by(Ano, agua, UF) %>% 
  summarise(count = survey_total(vartype = "se", na.rm = T)) %>% 
  filter(!agua %in% "Rural") %>% 
  group_by(UF) %>% 
  mutate(percent = (count / sum(count, na.rm = T)) * 100) %>% 
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se) %>% 
  select(1,4,2,3,5,6) %>% 
  rename("regiao" = 2)

UF_energia <-  PNADc_svy$PNADc_2019 %>% 
  filter(V2005 %in% "Pessoa responsável pelo domicílio") %>% 
  group_by(Ano, energia_eletrica, UF) %>% 
  summarise(count = survey_total(vartype = "se", na.rm = T)) %>% 
  filter(!energia_eletrica %in% "Rural") %>% 
  group_by(UF) %>% 
  mutate(percent = (count / sum(count, na.rm = T)) * 100) %>% 
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se) %>% 
  select(1,4,2,3,5,6) %>% 
  rename("regiao" = 2)

UF_esgoto <-  PNADc_svy$PNADc_2019 %>% 
  filter(V2005 %in% "Pessoa responsável pelo domicílio") %>% 
  group_by(Ano, esgotamento_sanitario, UF) %>% 
  summarise(count = survey_total(vartype = "se", na.rm = T)) %>% 
  filter(!esgotamento_sanitario %in% "Rural") %>% 
  group_by(UF) %>% 
  mutate(percent = (count / sum(count, na.rm = T)) * 100) %>% 
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se) %>% 
  select(1,4,2,3,5,6) %>% 
  rename("regiao" = 2)

UF_lixo <-  PNADc_svy$PNADc_2019 %>% 
  filter(V2005 %in% "Pessoa responsável pelo domicílio") %>% 
  group_by(Ano, coleta_lixo, UF) %>% 
  summarise(count = survey_total(vartype = "se", na.rm = T)) %>% 
  filter(!coleta_lixo %in% "Rural") %>% 
  group_by(UF) %>% 
  mutate(percent = (count / sum(count, na.rm = T)) * 100) %>% 
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se) %>% 
  select(1,4,2,3,5,6) %>% 
  rename("regiao" = 2)

UF_armazenamento <-  PNADc_svy$PNADc_2019 %>% 
  filter(V2005 %in% "Pessoa responsável pelo domicílio") %>% 
  group_by(Ano, armazen_agua, UF) %>% 
  summarise(count = survey_total(vartype = "se", na.rm = T)) %>% 
  filter(!armazen_agua %in% "Rural") %>% 
  group_by(UF) %>% 
  mutate(percent = (count / sum(count, na.rm = T)) * 100) %>% 
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se) %>% 
  select(1,4,2,3,5,6) %>% 
  rename("regiao" = 2)

UF_banheiro <-  PNADc_svy$PNADc_2019 %>% 
  filter(V2005 %in% "Pessoa responsável pelo domicílio") %>% 
  group_by(Ano, ausencia_banheiro, UF) %>% 
  summarise(count = survey_total(vartype = "se", na.rm = T)) %>% 
  filter(!ausencia_banheiro %in% "Rural") %>% 
  group_by(UF) %>% 
  mutate(percent = (count / sum(count, na.rm = T)) * 100) %>% 
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se) %>% 
  select(1,4,2,3,5,6) %>% 
  rename("regiao" = 2)

UF_comodos <-  PNADc_svy$PNADc_2019 %>% 
  filter(V2005 %in% "Pessoa responsável pelo domicílio") %>% 
  group_by(Ano, comodos_dormitorios, UF) %>% 
  summarise(count = survey_total(vartype = "se", na.rm = T)) %>% 
  filter(!comodos_dormitorios %in% "Rural") %>% 
  group_by(UF) %>% 
  mutate(percent = (count / sum(count, na.rm = T)) * 100) %>% 
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se) %>% 
  select(1,4,2,3,5,6) %>% 
  rename("regiao" = 2)

UF_cobertura <-  PNADc_svy$PNADc_2019 %>% 
  filter(V2005 %in% "Pessoa responsável pelo domicílio") %>% 
  group_by(Ano, cobertura, UF) %>% 
  summarise(count = survey_total(vartype = "se", na.rm = T)) %>% 
  filter(!cobertura %in% "Rural") %>% 
  group_by(UF) %>% 
  mutate(percent = (count / sum(count, na.rm = T)) * 100) %>% 
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se) %>% 
  select(1,4,2,3,5,6) %>% 
  rename("regiao" = 2)

UF_piso <-  PNADc_svy$PNADc_2019 %>% 
  filter(V2005 %in% "Pessoa responsável pelo domicílio") %>% 
  group_by(Ano, piso, UF) %>% 
  summarise(count = survey_total(vartype = "se", na.rm = T)) %>% 
  filter(!piso %in% "Rural") %>% 
  group_by(UF) %>% 
  mutate(percent = (count / sum(count, na.rm = T)) * 100) %>% 
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se) %>% 
  select(1,4,2,3,5,6) %>% 
  rename("regiao" = 2)

UF_fundiaria <- PNADc_svy$PNADc_2019 %>% 
  filter(V2005 %in% "Pessoa responsável pelo domicílio") %>% 
  group_by(Ano, inadeq_fund, UF) %>% 
  summarise(count = survey_total(vartype = "se", na.rm = T)) %>% 
  filter(!inadeq_fund %in% "Rural") %>% 
  group_by(UF) %>% 
  mutate(percent = (count / sum(count, na.rm = T)) * 100) %>% 
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se) %>% 
  select(1,4,2,3,5,6) %>% 
  rename("regiao" = 2)

UF_inadequacao <- PNADc_svy$PNADc_2019 %>% 
  filter(V2005 %in% "Pessoa responsável pelo domicílio") %>% 
  group_by(Ano, inadequacao, UF) %>% 
  summarise(count = survey_total(vartype = "se", na.rm = T)) %>% 
  filter(!inadequacao %in% "Rural") %>% 
  group_by(UF) %>% 
  mutate(percent = (count / sum(count, na.rm = T)) * 100) %>% 
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se) %>% 
  select(1,4,2,3,5,6) %>% 
  rename("regiao" = 2)

UF_infra <- PNADc_svy$PNADc_2019 %>% 
  filter(V2005 %in% "Pessoa responsável pelo domicílio") %>% 
  group_by(Ano, inf_urb, UF) %>% 
  summarise(count = survey_total(vartype = "se", na.rm = T)) %>% 
  filter(!inf_urb %in% "Rural") %>% 
  group_by(UF) %>% 
  mutate(percent = (count / sum(count, na.rm = T)) * 100) %>% 
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se) %>% 
  select(1,4,2,3,5,6) %>% 
  rename("regiao" = 2)

UF_edil <- PNADc_svy$PNADc_2019 %>% 
  filter(V2005 %in% "Pessoa responsável pelo domicílio") %>% 
  group_by(Ano, car_edil, UF) %>% 
  summarise(count = survey_total(vartype = "se", na.rm = T)) %>% 
  filter(!car_edil %in% "Rural") %>% 
  group_by(UF) %>% 
  mutate(percent = (count / sum(count, na.rm = T)) * 100) %>% 
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se) %>% 
  select(1,4,2,3,5,6) %>% 
  rename("regiao" = 2)

UF_lista_total <- list(UF_inadequacao, UF_infra, UF_abast, UF_energia, UF_esgoto, 
                       UF_lixo, UF_edil, UF_armazenamento, UF_banheiro, UF_comodos, 
                       UF_cobertura, UF_piso, UF_fundiaria)

writexl::write_xlsx(UF_lista_total, "UF_inadequacao_total.xlsx")
```

[^1]: Nota-se a importação de outras *variáveis* além das solicitadas.
    Estas são variáveis necessárias para expansão da amostra segundo a
    nova ponderação e metodologia do IBGE para a PNAD Contínua. Para
    mais informações: [Reponderação
    Bootstrap](https://github.com/Gabriel-Assuncao/PNADcIBGE/issues/8) e
    [IBGE
    (2021)](https://biblioteca.ibge.gov.br/visualizacao/livros/liv101866.pdf).
