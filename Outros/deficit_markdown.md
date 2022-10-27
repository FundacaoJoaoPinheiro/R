Cálculo do Déficit Habitacional no R
================
Coordenação de Habitação e Saneamento - Fundação João Pinheiro
31/08/2022

Este documento está sendo disponibilizado com a finalidade de publicizar
o *script* *R* de geração dos resultados do Déficit Habitacional,
período 2016 até 2019, realizada pela Fundação João Pinheiro.

Em função do sigilo dos dados do CadÚnico, os resultados aqui produzidos
são *exclusivamente aqueles gerados a partir da PNAD Contínua*[^1],
portanto referente aos seguintes subcomponentes do Déficit Habitacional:

-   Domicílios rústicos

-   Cômodos

-   Unidades Conviventes Déficit

-   Ônus excessivo com o aluguel urbano

Desse modo, por meio deste *script*, visa-se auxiliar aqueles que
desejam reproduzir este trabalho ou utilizar os dados gerados neste
documento para outras análises. Reforça-se que, em caso de dúvidas a
respeito da metodologia aplicada, recomenda-se a leitura de [Metodologia
do Deficit Habitacional e da Inadequação de Domicílios no Brasil
2016-2019](http://fjp.mg.gov.br/wp-content/uploads/2020/12/04.03_Relatorio-Metodologia-do-Deficit-Habitacional-e-da-Inadequacao-de-Domicilios-no-Brasil-2016-2019-v-1.0_compressed.pdf)
(Fundação João Pinheiro, 2020).

# 1. Preparativos iniciais

## 1.1 Obtendo os dados da PNAD Contínua

Estabeleça o diretório onde estão localizados os dados da PNAD Contínua
para 2016-2019:

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
pacotes <- c( "tidyverse", "data.table", "PNADcIBGE", "survey", "srvyr", "rio", "ggtext", 
              "ggthemes", "ipeadatar")
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
arquivos da PNAD Contínua e, em seguida, importá-los:

``` r
#Selecionando as Variáveiis
variaveis <- c(
  "Ano",     # Ano
  "UF",      # Unidade da Federação
  "Capital", # Município da Capital
  "RM_RIDE", # Região Metropolitana e Região Administrativa Integrada
  'UPA',     # Unidade Primaria de amostragem (unidade de amostragem mais granular)
  'Estrato', # Estratos da amostra
  "V1008",   # Número do domicílio
  "V1030",   # Projeção da população
  "V1031",   # Peso com correção de não entrevista sem pós estratificação
  "V1032",   # Peso com correção de não entrevista com pós estratificação
  "V2001",   # Número de pessoas no domicílio
  "V2005",   # Condição no domicílio
  "S01002",  # Material paredes externas domicílio
  "S01001",  # Tipo de domicílio (casa, apt, cômodo/cortiço...)
  "S01017",  # Este domicílio é (próprio, alugado...)
  "V1022",   # Situação do domicílio (urbano/rural)
  "S01019",  # Valor mensal do aluguel
  "VD5004",  # Rendimento (efetivo) domiciliar (inclusive rendimentos.)
  "S01006",  # Cômodos servindo de dormitórios
  "VD2003",  # Núm. componentes do domicílio (exclusive pensionista, emp. domest. ou parente emp. 
  #domest.)
  "S01004",  # Piso que predomina no domicílio
  "VD2004",  # Espécie da unidade doméstica
  'V2009',  # Idade moradores
  'V2007',  # sexo moradores
  'V2010',  # cor ou raça
  'VD5002'  # rendimento domiciliar per capita
)

# Identificar os arquivos de microdados
microdados <- list.files(path = "input/", pattern = "^PNADC_201(6|7|8|9)(.*?)txt$")
microdados <- map_chr(microdados, function(x) paste0("input/", x))
# Identificar os inputs
input_PNADc <- list.files(path = "input/", pattern = "^input_PNADC_201(6|7|8|9)(.*?)txt$")
input_PNADc <- map_chr(input_PNADc, function(x) paste0("input/", x))
# Identificar os dicionários
dicionarios <- list.files(path = "input/",
                          pattern = "^dicionario_PNADC_microdados_201(6|7|8|9)(.*?)xls$")
dicionarios <- map_chr(dicionarios, function(x) paste0("input/", x))
dicionarios
# Importar os dados 2016, 2017, 2018 e 2019 em uma lista
PNADc_lista <- map2(microdados, input_PNADc, function(x, y) 
  read_pnadc(microdata = x,
             input_txt = y,
             vars = variaveis))
# Renomear as pesquisas de acordo com os anos
names(PNADc_lista) <- paste0("PNADc_", c(2016:2019))
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
```

Verificando as Colunas da Base de dados importada[^2]:

``` r
colnames(PNADc_lista$PNADc_2019)
```

    ##   [1] "Ano"          "Trimestre"    "UF"           "Capital"      "RM_RIDE"     
    ##   [6] "UPA"          "Estrato"      "V1008"        "V1014"        "V1022"       
    ##  [11] "V1030"        "V1031"        "V1032"        "V1034"        "posest"      
    ##  [16] "posest_sxi"   "V2001"        "V2003"        "V2005"        "V2007"       
    ##  [21] "V2009"        "V2010"        "S01001"       "S01002"       "S01004"      
    ##  [26] "S01006"       "S01017"       "S01019"       "VD2003"       "VD2004"      
    ##  [31] "VD5002"       "VD5004"       "V1032001"     "V1032002"     "V1032003"    
    ##  [36] "V1032004"     "V1032005"     "V1032006"     "V1032007"     "V1032008"    
    ##  [41] "V1032009"     "V1032010"     "V1032011"     "V1032012"     "V1032013"    
    ##  [46] "V1032014"     "V1032015"     "V1032016"     "V1032017"     "V1032018"    
    ##  [51] "V1032019"     "V1032020"     "V1032021"     "V1032022"     "V1032023"    
    ##  [56] "V1032024"     "V1032025"     "V1032026"     "V1032027"     "V1032028"    
    ##  [61] "V1032029"     "V1032030"     "V1032031"     "V1032032"     "V1032033"    
    ##  [66] "V1032034"     "V1032035"     "V1032036"     "V1032037"     "V1032038"    
    ##  [71] "V1032039"     "V1032040"     "V1032041"     "V1032042"     "V1032043"    
    ##  [76] "V1032044"     "V1032045"     "V1032046"     "V1032047"     "V1032048"    
    ##  [81] "V1032049"     "V1032050"     "V1032051"     "V1032052"     "V1032053"    
    ##  [86] "V1032054"     "V1032055"     "V1032056"     "V1032057"     "V1032058"    
    ##  [91] "V1032059"     "V1032060"     "V1032061"     "V1032062"     "V1032063"    
    ##  [96] "V1032064"     "V1032065"     "V1032066"     "V1032067"     "V1032068"    
    ## [101] "V1032069"     "V1032070"     "V1032071"     "V1032072"     "V1032073"    
    ## [106] "V1032074"     "V1032075"     "V1032076"     "V1032077"     "V1032078"    
    ## [111] "V1032079"     "V1032080"     "V1032081"     "V1032082"     "V1032083"    
    ## [116] "V1032084"     "V1032085"     "V1032086"     "V1032087"     "V1032088"    
    ## [121] "V1032089"     "V1032090"     "V1032091"     "V1032092"     "V1032093"    
    ## [126] "V1032094"     "V1032095"     "V1032096"     "V1032097"     "V1032098"    
    ## [131] "V1032099"     "V1032100"     "V1032101"     "V1032102"     "V1032103"    
    ## [136] "V1032104"     "V1032105"     "V1032106"     "V1032107"     "V1032108"    
    ## [141] "V1032109"     "V1032110"     "V1032111"     "V1032112"     "V1032113"    
    ## [146] "V1032114"     "V1032115"     "V1032116"     "V1032117"     "V1032118"    
    ## [151] "V1032119"     "V1032120"     "V1032121"     "V1032122"     "V1032123"    
    ## [156] "V1032124"     "V1032125"     "V1032126"     "V1032127"     "V1032128"    
    ## [161] "V1032129"     "V1032130"     "V1032131"     "V1032132"     "V1032133"    
    ## [166] "V1032134"     "V1032135"     "V1032136"     "V1032137"     "V1032138"    
    ## [171] "V1032139"     "V1032140"     "V1032141"     "V1032142"     "V1032143"    
    ## [176] "V1032144"     "V1032145"     "V1032146"     "V1032147"     "V1032148"    
    ## [181] "V1032149"     "V1032150"     "V1032151"     "V1032152"     "V1032153"    
    ## [186] "V1032154"     "V1032155"     "V1032156"     "V1032157"     "V1032158"    
    ## [191] "V1032159"     "V1032160"     "V1032161"     "V1032162"     "V1032163"    
    ## [196] "V1032164"     "V1032165"     "V1032166"     "V1032167"     "V1032168"    
    ## [201] "V1032169"     "V1032170"     "V1032171"     "V1032172"     "V1032173"    
    ## [206] "V1032174"     "V1032175"     "V1032176"     "V1032177"     "V1032178"    
    ## [211] "V1032179"     "V1032180"     "V1032181"     "V1032182"     "V1032183"    
    ## [216] "V1032184"     "V1032185"     "V1032186"     "V1032187"     "V1032188"    
    ## [221] "V1032189"     "V1032190"     "V1032191"     "V1032192"     "V1032193"    
    ## [226] "V1032194"     "V1032195"     "V1032196"     "V1032197"     "V1032198"    
    ## [231] "V1032199"     "V1032200"     "ID_DOMICILIO"

Transformando os dados importados em um objeto de plano amostral
complexo e, depois, permitindo seu tratamento dentro da lógica do
*dplyr*:

``` r
PNADc_lista <- PNADc_lista %>% map(pnadc_design)
PNADc_lista
PNADcfam_svy <- lapply(PNADc_lista, as_survey)
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
PNADcfam_svy <- map2(PNADcfam_svy, SMs, fun_faixa)

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
PNADcfam_svy <- map2(PNADcfam_svy, SMs, fun_faixa_2)

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
PNADcfam_svy <- PNADcfam_svy %>% 
  map(~ .x %>% mutate(Regiao = fct_case_when(
    UF %in% c("Rondônia", "Acre", "Amazonas", "Roraima", "Pará", "Amapá", "Tocantins") ~ 
      "Norte",
    UF %in% c("Maranhão", "Piauí", "Ceará", "Rio Grande do Norte", "Paraíba", "Pernambuco", "Alagoas", "Bahia", "Sergipe") ~ 
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

### 2.2.3 Variável de Percentual de renda gasta com aluguel

Crie com os códigos abaixo a variável que determina o percentual da
renda domiciliar gasto em aluguel.

``` r
PNADcfam_svy <- PNADcfam_svy %>% 
  map(~ .x %>% mutate(Pct_Renda_Aluguel = S01019/ VD5004 ))
```

### 2.2.4 Variável de Morador por Cômodo

Crie com os códigos abaixo a variável que determina a proporção de
moradores para cada cômodo utilizado como dormitório no domicílio.

``` r
PNADcfam_svy <- PNADcfam_svy %>% 
  map(~ .x %>% mutate(Moradores_Comodos = V2001 / S01006))
```

# 3. Criando as variáveis utilizadas para identificação de unidade convivente déficit no domicílio.

Nesta seção serão criadas variáveis utilizadas para identificar a
presença de mais de um núcleo familiar no domicílio. Esta parte do
*script* reflete o desafio metodológico deste processo, pois, devido a
exclusão desta pergunta no questionário da PNAD Contínua, exigiu a
reconstituição e a identificação de potenciais núcleos familiares
secundários existêntes nos domicílios. Para mais informações acerca da
metodologia, consultar: [FJP (2020,
p. 31-37)](https://drive.google.com/file/d/1bHOyrem6wB5KupeBGYPgfNCNi0Z9IDV4/view).

Além disso, por questão de eficiência no processamento dos dados e
geração das variáveis, foi extraído do objeto lista da *PNADcfam_svy*, a
tabela do banco de dados das variáveis. Do mesmo modo, por razões de
eficiência e tempo de processamento, utilizou-se o pacote *data.table*
em determinadas etapas. Posteriormente, ao longo do *script*, a tabela é
reinserida na lista do plano amostra complexo *PNADcfam_svy.*

## 3.1 Reclassificação das unidades domésticas

Utilize o código a seguir para criar uma ID do domicílio.

Depois reclassifique os domicílios compostos entre:

1.  aqueles com apenas não parentes em relação ao responsável pelo
    domicílio; Este subconjunto é excluído da análise

2.  aqueles compostos por parentes e não parentes do responsável pelo
    domicílio; Este subconjunto será utilizado para identificação da
    existência de núcleos secundários no domicílio

``` r
variables <- PNADcfam_svy %>%
  map(~.x %>% as.data.frame("variables")) %>%
  map(~ .x %>% mutate(V2005=as.integer(V2005))) %>%  ### Transformando a V2005 em um integer, inteiro
  map(~ .x %>% mutate(VD2004=as.integer(VD2004))) %>% ### Transformando a VD2004 em um integer, inteiro
  map(~ .x %>% mutate(UPA=as.integer(UPA))) %>% ### Transformando a UPA em um integer, inteiro
  map(~ .x %>% mutate(V1008=as.integer(V1008))) %>% ### Transformando a  em um integer, inteiro
  map(~ .x %>% mutate(UPA100=UPA*100)) %>% #Auxilia criacao de variavel de identificacao do domicilio
  map(~ .x %>% mutate(domicilioid=UPA100+V1008)) %>% #Cria variavel de identificacao do domicilio
  map(~ .x %>% mutate(nao_parente=ifelse((V2005>=15), 1, 0))) %>% #cria variavel para nao parente
  map(~ .x %>% mutate(parente=ifelse((V2005>=2 & V2005<=14), 1, 0))) %>%
  map(~ .x %>% group_by(domicilioid)) %>% #agrupa por domicilio 
  map(~ .x %>% mutate(total_naoparente = sum(nao_parente))) %>% #soma total de nao parentes
  map(~ .x %>% mutate(total_parente = sum(parente))) %>%
  map(~ .x %>% mutate(composta_parente = ifelse((VD2004==4 & total_naoparente>=1 & total_parente>=1), 1, #cria variavel de nao parentes em fam. compostas
                                                ifelse((VD2004==4 & total_naoparente>=1 & total_parente==0), 0, NA)))) %>%
  map(~ .x %>% ungroup()) %>%
  map(~ .x %>% mutate(VD2004_2 = ifelse((VD2004==1), "Unipessoal",
                                        ifelse((VD2004==2), "Nuclear",
                                               ifelse((VD2004==3), "Estendida", 
                                                      ifelse((composta_parente==1), "Composta por parentes e não parentes do responsável pelo domicílio",
                                                             ifelse((composta_parente==0), "Composta somente por não parentes do responsável pelo domicílio", 
                                                                    NA))))))) %>%
  map(~ .x %>% mutate(VD2004_2 = as.factor(VD2004_2)))
```

## 3.2 Criação de variáveis que identificam relações de conjugalidade e parentalidade ascendente

O código abaixo cria as variáveis que identifica as relações de
conjugalidade e/ou parentalidade ascendente, em relação ao responsável
pelo domicílio, existentes no domicílio.

``` r
variables <- variables %>%
  map(~ .x %>% mutate(V2007=as.integer(V2007))) %>%
  map(~ .x %>% mutate(conjuge=ifelse((V2005==2|V2005==3), 1, 0))) %>% # cria variavel para cônjuge no domicilio
  map(~ .x %>% mutate(pai_pad=ifelse((V2005==8 & V2007==1), 1, 0))) %>% # cria variavel para Pai/padrasto no domicilio
  map(~ .x %>% mutate(mae_mad=ifelse((V2005==8 & V2007==2), 1, 0))) %>% # cria variavel para mae/madrastra no domicilio
  map(~ .x %>% group_by(domicilioid)) %>% #agrupa por domicilio 
  map(~ .x %>% mutate(total_conjuge = sum(conjuge))) %>% # Cria variável com o total de cônjuges no domicílio
  map(~ .x %>% mutate(total_pai_pad = sum(pai_pad))) %>% # Cria variável com o total de pai/padrastos no domicílio
  map(~ .x %>% mutate(total_mae_mad = sum(mae_mad))) %>% # Cria variável com o total de mãe/madrastas no domicílio 
  map(~ .x %>% ungroup())
```

## 3.3 Criação de variáveis que identificam relações de parentalidade descendente

O código abaixo cria as variáveis que identifica as relações de
parentalidade descendente, em relação ao responsável pelo domicílio,
existentes no domicílio. Bem como, identifica filhos, netos, bisnetos
mais maiores e menores de idade, isto é, acima e abaixo de 18 anos.

``` r
variables <- variables %>%
  map(~ .x %>% mutate(V2005=as.integer(V2005))) %>% #condicao no domicilio como inteira
  map(~ .x %>% mutate(VD2004=as.integer(VD2004))) %>% #especie da unidade domestica como inteira
  map(~ .x %>% mutate(UPA=as.integer(UPA))) %>% #UPA como inteira
  map(~ .x %>% mutate(V1008=as.integer(V1008))) %>% #número de selecao do domicilio como inteiro
  map(~ .x %>% mutate(UPA100=UPA*100)) %>% #Auxilia criacao de variavel de identificacao do domicilio
  map(~ .x %>% mutate(domicilioid=UPA100+V1008)) %>% #Cria variavel de identificacao do domicilio
  map(~ .x %>% mutate(filho_maior=ifelse(((V2005==4 | V2005==5 | V2005==6) & V2009 >=18), 1, 0))) %>% #cria variavel para filho maior de idade no domicilio (do responsavel e do conjuge, so do responsavel e so do conjuge)
  map(~ .x %>% mutate(filho_menor=ifelse(((V2005==4 | V2005==5 | V2005==6) & V2009 <18), 1, 0))) %>% #cria variavel para filho menor de idade no domicilio (do responsavel e do conjuge, so do responsavel e so do conjuge)
  map(~ .x %>% mutate(filhos=ifelse(((V2005==4 | V2005==5 | V2005==6)), 1, 0))) %>% #cria variavel para filho no domicilio (do responsavel e do conjuge, so do responsavel e so do conjuge)
  map(~ .x %>% mutate(neto=ifelse((V2005==10), 1, 0))) %>% # cria variavel para neto no domicilio
  map(~ .x %>% mutate(neto_maior=ifelse((V2005==10) & V2009>=18, 1, 0))) %>% # cria variavel para neto maior de idade no domicilio
  map(~ .x %>% mutate(bisneto=ifelse((V2005==11), 1, 0))) %>% # cria variavel para bisneto no domicilio
  map(~ .x %>% mutate(genro=ifelse((V2005==7), 1, 0))) %>% # cria variavel para genro ou nora no domicilio
  map(~ .x %>% mutate(outros=ifelse((V2005==9| V2005>=12), 1, 0))) %>% # cria variável de outros componentes da V2005 no domicilio
  map(~ .x %>% group_by(domicilioid)) %>% #agrupa por domicilio 
  map(~ .x %>% mutate(total_filho_maior = sum(filho_maior))) %>% #soma o total de filhos maiores de idade no domicílio
  map(~ .x %>% mutate(total_filho_menor = sum(filho_menor))) %>% #soma o total de filhos menores de idade no domicílio
  map(~ .x %>% mutate(total_filhos = sum(filhos))) %>% #soma o total de filhos independente da idade
  map(~ .x %>% mutate(total_neto = sum(neto))) %>% #soma o total de netos
  map(~ .x %>% mutate(total_neto_maior = sum(neto_maior))) %>% #soma o total de netos maiores de idade
  map(~ .x %>% mutate(total_bisneto = sum(bisneto))) %>% #soma o total de bisnetos
  map(~ .x %>% mutate(total_genro = sum(genro))) %>% #soma o total de genros/noras
  map(~ .x %>% mutate(total_outros = sum(outros))) %>% #soma o total de outros integrantes da V2005
  map(~ .x %>% ungroup()) 
```

Verifique se há coerência nas variáveis criadas

``` r
var_sec <- select(variables$PNADc_2019,domicilioid,V2005, V2009,neto, neto_maior,filho_maior,filho_menor)   
var_sec
```

    ## # A tibble: 443,790 × 7
    ##    domicilioid V2005 V2009  neto neto_maior filho_maior filho_menor
    ##          <dbl> <int> <dbl> <dbl>      <dbl>       <dbl>       <dbl>
    ##  1 11000001601     1    44     0          0           0           0
    ##  2 11000001601     2    61     0          0           0           0
    ##  3 11000001601     4    26     0          0           1           0
    ##  4 11000001601     4    17     0          0           0           1
    ##  5 11000001601    10     6     1          0           0           0
    ##  6 11000001602     1    48     0          0           0           0
    ##  7 11000001603     1    54     0          0           0           0
    ##  8 11000001603     2    54     0          0           0           0
    ##  9 11000001603     4    29     0          0           1           0
    ## 10 11000001603    10    15     1          0           0           0
    ## # … with 443,780 more rows

``` r
rm(var_sec)
```

## 3.4 Identificando, dentre os parentes descendentes, os mais velho e mais novos

O código abaixo identifica as idades dos filhos maiores e menores de
idade do responsável pelo domicílio.

``` r
variables <- map(variables, data.table)

### Cria variavel que indica a idade dos filhos e do mais velho e mais novo
variables <- map(variables, ~.x[,idade_filho := ifelse((filhos == 1), V2009, NA)]) #Cria variável que identifica a idade dos filhos(indica a V2009 se é filho e NA caso contrário)
variables <- map(variables, ~.x[,idade_filho_menor := min(idade_filho, na.rm = T), by = domicilioid]) #Cria variável que indica a idade do filho mais novo
variables <- map(variables, ~.x[,idade_filho_menor := na_if(idade_filho_menor, Inf), by = domicilioid]) #trannsforma em NA, valores infinitos
```

``` r
variables <- map(variables, ~.x[,idade_filho_maior := max(idade_filho, na.rm = T), by = domicilioid]) #cria variável que indica a idade do filho mais velho
variables <- map(variables, ~.x[,idade_filho_maior := na_if(idade_filho_maior, -Inf), by = domicilioid]) #transforma em NA, valores infinitos (limite lateral inferior)
```

O código abaixo identifica as idades dos netos maiores e menores de
idade do responsável pelo domicílio.

``` r
## Replica o que foi feito para identificar a idade do neto mais novo e do neto mais velho
variables <- map(variables, ~.x[,idade_neto := ifelse((neto == 1), V2009, NA)])
variables <- map(variables, ~.x[,c("idade_neto_menor", "idade_neto_maior") := 
                                  list(min(idade_neto, na.rm = T),
                                       max(idade_neto, na.rm = T)), by = domicilioid])

variables <- map(variables, ~.x[,c("idade_neto_menor", "idade_neto_maior") := 
                                  list(na_if(idade_neto_menor, Inf),
                                       na_if(idade_neto_maior, -Inf)), by = domicilioid])
```

O código abaixo identifica a idade do genro ou nora mais velho

``` r
## Replica o que foi feito para identificar a idade do genro ou nora mais velho
variables <- map(variables, ~.x[,idade_genro := ifelse((genro==1), V2009, NA)])
variables <- map(variables, ~.x[,idade_genro_maior := max(idade_genro, na.rm = T), by = domicilioid])
variables <- map(variables, ~.x[,idade_genro_maior := na_if(idade_genro_maior, -Inf), by = domicilioid])
```

O código abaixo identifica as idades dos netos maiores e menores de
idade do responsável pelo domicílio.

``` r
### Replica o que foi feito criando variável que identifica a idade do bisneto mais novo de cada domicílio
variables <- map(variables, ~.x[,idade_bisneto := ifelse((bisneto==1), V2009, NA)])
variables <- map(variables, ~.x[,idade_bisneto_menor := min(idade_bisneto, na.rm = T), by = domicilioid])
variables <- map(variables, ~.x[,idade_bisneto_menor := na_if(idade_bisneto_menor, Inf), by = domicilioid])
```

Verifique se há coerência nas variáveis criadas. Primeiramente, crie a
variável de moradores no domicílio que são parentes, em seguida observe
os dados.

``` r
## Criar nova variável de número de moradores(Subtração da V2001 e a variável criada de outros componentes da V2005 que não entrarão na análise)
variables <- variables %>% 
  map(~ .x %>% mutate(V2001_2 = V2001 - total_outros ))

### Ver os dados e conferir as variáveis criadas
var_conv <- select(variables$PNADc_2019,domicilioid,V2005, V2001,total_outros, V2001_2,V2009,VD2004,filho_maior, filho_menor, filhos, neto, bisneto, genro,
                   outros, total_filho_maior,total_filho_menor, total_filhos, total_neto,total_bisneto,total_genro)
var_conv
```

    ##         domicilioid V2005 V2001 total_outros V2001_2 V2009 VD2004 filho_maior
    ##      1: 11000001601     1     5            0       5    44      3           0
    ##      2: 11000001601     2     5            0       5    61      3           0
    ##      3: 11000001601     4     5            0       5    26      3           1
    ##      4: 11000001601     4     5            0       5    17      3           0
    ##      5: 11000001601    10     5            0       5     6      3           0
    ##     ---                                                                      
    ## 443786: 53005106713     5     2            0       2    13      2           0
    ## 443787: 53005106714     1     4            0       4    34      2           0
    ## 443788: 53005106714     2     4            0       4    28      2           0
    ## 443789: 53005106714     4     4            0       4    11      2           0
    ## 443790: 53005106714     4     4            0       4     4      2           0
    ##         filho_menor filhos neto bisneto genro outros total_filho_maior
    ##      1:           0      0    0       0     0      0                 1
    ##      2:           0      0    0       0     0      0                 1
    ##      3:           0      1    0       0     0      0                 1
    ##      4:           1      1    0       0     0      0                 1
    ##      5:           0      0    1       0     0      0                 1
    ##     ---                                                               
    ## 443786:           1      1    0       0     0      0                 0
    ## 443787:           0      0    0       0     0      0                 0
    ## 443788:           0      0    0       0     0      0                 0
    ## 443789:           1      1    0       0     0      0                 0
    ## 443790:           1      1    0       0     0      0                 0
    ##         total_filho_menor total_filhos total_neto total_bisneto total_genro
    ##      1:                 1            2          1             0           0
    ##      2:                 1            2          1             0           0
    ##      3:                 1            2          1             0           0
    ##      4:                 1            2          1             0           0
    ##      5:                 1            2          1             0           0
    ##     ---                                                                    
    ## 443786:                 1            1          0             0           0
    ## 443787:                 2            2          0             0           0
    ## 443788:                 2            2          0             0           0
    ## 443789:                 2            2          0             0           0
    ## 443790:                 2            2          0             0           0

``` r
rm(var_conv)
```

Em seguida serão criadas variáveis que avaliam as relações de idade
entre os filhos, genros, noras, netos e bisnetos do responsável. O
objetivo é identificar se descendentes mais novos e distantes (netos,
bisnetos) da pessoa responsável pelo domiílio são ou não mais novos do
que os descentes mais velhos e próximos (filhos, genros e noras) do
responsável pelo domicílio.

A lógica é evitar a identificação de relações de conjugalidade e
parentalidade erradas. Por exemplo, não é possível a existência de
núcleo familiar secundário em determinado domicílio, se o neto mais novo
(do responsável pelo domicílio) for mais velho que o filho mais velho
(do responsável pelo domcílio) presente no domicílio no momento da
entrevista. Em outras palavras, este neto mais novo com certeza não é
descendente do filho mais velho presente neste domicílio.

Ademais, nota-se a utilização da função *fct_case_when*, criada no seção
2.2, para criação de variáveis categóricas de interesse.

``` r
## Criar variável indicadora: filho mais velho possui idade superior ao neto mais novo do domicílio? 
variables <- variables %>%
  map(~ .x %>% mutate(V2001_2 = V2001 - total_outros )) %>% 
  map(~ .x %>% mutate(Idade_filho_neto = fct_case_when(
    idade_filho_maior>idade_neto_menor ~ 
      "Sim",
    idade_filho_maior<idade_neto_menor  ~ 
      "Não",
    is.na(idade_filho_maior) |
      is.na(idade_neto_menor)  ~ 
      NA_character_
  )))
## Criar variável indicadora: O filho mais velho possui idade superior ao bisneto mais novo do domicílio? 
variables <- variables %>%
  map(~ .x %>% mutate(Idade_filho_bisneto = fct_case_when(
    idade_filho_maior>idade_bisneto_menor ~ 
      "Sim",
    idade_filho_maior<idade_bisneto_menor  ~ 
      "Não",
    is.na(idade_filho_maior) |
      is.na(idade_bisneto_menor)  ~ 
      NA_character_
  )))
## Cria variável indicadora: O genro/nora mais velho possui idade superior ao neto mais novo do domicílio? 
variables <- variables %>%
  map(~ .x %>% mutate(Idade_genro_neto = fct_case_when(
    idade_genro_maior>idade_neto_menor ~ 
      "Sim",
    idade_genro_maior<idade_neto_menor  ~ 
      "Não",
    is.na(idade_genro_maior) |
      is.na(idade_neto_menor)  ~ 
      NA_character_
  )))
## Cria variável indicadora: O genro/nora mais velho possui idade superior ao bisneto mais novo do domicílio? 
variables <- variables %>%
  map(~ .x %>% mutate(Idade_genro_bisneto = fct_case_when(
    idade_genro_maior>idade_bisneto_menor ~ 
      "Sim",
    idade_genro_maior<idade_bisneto_menor  ~ 
      "Não",
    is.na(idade_genro_maior) |
      is.na(idade_bisneto_menor)  ~ 
      NA_character_
  )))
## Cria variável indicadora: O neto mais velho possui idade superior ao bisneto mais novo do domicílio? 
variables <- variables %>%
  map(~ .x %>% mutate(Idade_neto_bisneto = fct_case_when(
    idade_neto_maior>idade_bisneto_menor ~ 
      "Sim",
    idade_neto_maior<idade_bisneto_menor  ~ 
      "Não",
    is.na(idade_neto_maior) |
      is.na(idade_bisneto_menor)  ~ 
      NA_character_
  )))
```

Verifique se há coerência nas variáveis criadas.

``` r
#Conferir se as variáveis criadas estao corretas e fazem o que queríamos que elas fizesem
Idade_conv <- select(variables$PNADc_2019,domicilioid,V2005,V2009,filho_maior, filho_menor, filhos, neto_maior, bisneto, genro,
                     idade_filho_menor, idade_filho_maior, idade_genro_maior, idade_bisneto_menor, Idade_genro_bisneto,idade_genro_maior,
                     idade_neto_menor,Idade_genro_neto, idade_filho_maior,idade_bisneto_menor,Idade_filho_bisneto, Idade_filho_neto )
Idade_conv
```

    ##         domicilioid V2005 V2009 filho_maior filho_menor filhos neto_maior
    ##      1: 11000001601     1    44           0           0      0          0
    ##      2: 11000001601     2    61           0           0      0          0
    ##      3: 11000001601     4    26           1           0      1          0
    ##      4: 11000001601     4    17           0           1      1          0
    ##      5: 11000001601    10     6           0           0      0          0
    ##     ---                                                                  
    ## 443786: 53005106713     5    13           0           1      1          0
    ## 443787: 53005106714     1    34           0           0      0          0
    ## 443788: 53005106714     2    28           0           0      0          0
    ## 443789: 53005106714     4    11           0           1      1          0
    ## 443790: 53005106714     4     4           0           1      1          0
    ##         bisneto genro idade_filho_menor idade_filho_maior idade_genro_maior
    ##      1:       0     0                17                26                NA
    ##      2:       0     0                17                26                NA
    ##      3:       0     0                17                26                NA
    ##      4:       0     0                17                26                NA
    ##      5:       0     0                17                26                NA
    ##     ---                                                                    
    ## 443786:       0     0                13                13                NA
    ## 443787:       0     0                 4                11                NA
    ## 443788:       0     0                 4                11                NA
    ## 443789:       0     0                 4                11                NA
    ## 443790:       0     0                 4                11                NA
    ##         idade_bisneto_menor Idade_genro_bisneto idade_neto_menor
    ##      1:                  NA                <NA>                6
    ##      2:                  NA                <NA>                6
    ##      3:                  NA                <NA>                6
    ##      4:                  NA                <NA>                6
    ##      5:                  NA                <NA>                6
    ##     ---                                                         
    ## 443786:                  NA                <NA>               NA
    ## 443787:                  NA                <NA>               NA
    ## 443788:                  NA                <NA>               NA
    ## 443789:                  NA                <NA>               NA
    ## 443790:                  NA                <NA>               NA
    ##         Idade_genro_neto Idade_filho_bisneto Idade_filho_neto
    ##      1:             <NA>                <NA>              Sim
    ##      2:             <NA>                <NA>              Sim
    ##      3:             <NA>                <NA>              Sim
    ##      4:             <NA>                <NA>              Sim
    ##      5:             <NA>                <NA>              Sim
    ##     ---                                                      
    ## 443786:             <NA>                <NA>             <NA>
    ## 443787:             <NA>                <NA>             <NA>
    ## 443788:             <NA>                <NA>             <NA>
    ## 443789:             <NA>                <NA>             <NA>
    ## 443790:             <NA>                <NA>             <NA>

``` r
rm(Idade_conv)
```

## 3.5 Criação de variáveis descritivas identificadoras

O bloco de variáveis a seguir identifica características categóricas do
domicílio que são utilizadas para identificar os núcleos primários e
secundários. Crie-as utilizando os códigos abaixo.

``` r
#### Cria variáveis indicadores Utilizadas nas descritivas(Indicadoras dos núcleos primários e secundários)
## Filhos maiores de Idade
variables <- variables %>%
  map(~ .x %>% mutate(Filhos_maiores = fct_case_when(
    total_filho_maior ==0 ~
      "Não tem Filho maior de idade",
    total_filho_maior ==1  ~ 
      "1 Filho maior de idade",
    total_filho_maior >=2  ~ 
      "Pelo menos dois 2 Filhos maiores",
    is.na(total_filho_maior) ~ 
      NA_character_
  ))) %>%
## Filho menores de Idade
  map(~ .x %>% mutate(Filhos_menores = fct_case_when(
    total_filho_menor ==0 ~
      "Não tem Filho menor de idade",
    total_filho_menor >=1  ~ 
      "Pelo menos 1 Filho menor de idade",
    is.na(total_filho_menor) ~ 
      NA_character_
  ))) %>%
##Netos
  map(~ .x %>% mutate(Netos = fct_case_when(
    total_neto ==0 ~
      "Não tem Neto",
    total_neto >=1   ~ 
      "Tem pelo menos 1 Neto",
    is.na(total_neto) ~ 
      NA_character_
  ))) %>%
## Netos maiores de idade
  map(~ .x %>% mutate(Neto_maior = fct_case_when(
    total_neto_maior ==0 ~
      "Não tem Neto",
    total_neto_maior >=1   ~ 
      "Tem pelo menos 1 Neto",
    is.na(total_neto_maior) ~ 
      NA_character_
  ))) %>%
##Bisnetos  
  map(~ .x %>% mutate(Bisnetos = fct_case_when(
    total_bisneto ==0 ~
      "Não tem Bisnetos",
    total_bisneto >=1  ~ 
      "Tem pelo menos 1 Bisneto",
    is.na(total_bisneto) ~ 
      NA_character_
  ))) %>%
### Genros ou noras
  map(~ .x %>% mutate(Genros_nora = fct_case_when(
    total_genro ==0 ~
      "Não tem genro ou nora",
    total_genro >=1  ~ 
      "Tem pelo menos um genro ou nora",
    is.na(total_genro) ~ 
      NA_character_
  ))) %>%
## Variáveis do núcleo primário
## Cônjuge
  map(~ .x %>% mutate(Conjuge = fct_case_when(
    total_conjuge ==0 ~
      "Não tem Cônjuge",
    total_conjuge >=1  ~ 
      "Possui Cônjuge",
    is.na(total_conjuge) ~ 
      NA_character_
  ))) %>%
## Mãe ou Madrastra
  map(~ .x %>% mutate(Mae_Madrasta = fct_case_when(
    total_mae_mad ==0 ~
      "Não tem Mãe ou Madrasta",
    total_mae_mad >=1  ~ 
      "Possui Mãe ou Madrasta",
    is.na(mae_mad) ~ 
      NA_character_
  ))) %>%
## Pai ou Padastro
  map(~ .x %>% mutate(Pai_Padrasto = fct_case_when(
    total_pai_pad ==0 ~
      "Não tem Pai ou padrasto",
    total_pai_pad >=1  ~ 
      "Possui Pai ou padrasto",
    is.na(total_pai_pad) ~ 
      NA_character_
  )))
```

# 4. Identificando a existência potencial de famílias conviventes nos domicílios estendidos e compostos por parentes e não parentes

As variáveis criadas na seção anterior auxiliam na identificação de
provável existência de mais de um núcleo familiar no domicílio. Elas
serão usadas nesta etapa para avaliar a presença de ao menos uma unidade
familiar convivente. O processo de criação da variável que identifica se
existem ao menos uma família convivente no domicílio é feito em duas
rodadas com 4 etapas cada uma:

1.  Identificar se o domicílio possui mais de 4 moradores (exclusive,
    sogros(a),Avô ou avó, outro parente, agregado).
2.  Identificar se o domicílio é estendido OU composto por parentes e
    não parentes do responsável pelo domicílio.
3.  Identificar se existe conjuge ou ao menos um filho menor de idade,
    ou ao menos um pai/padrasto/mãe/madrasta.
4.  Identifica se há um par de núcleo secundário que seja um dos tipos
    abaixo:

-   Neto maior de idade (acima de 18 anos) & bisneto, sendo a idade do
    bisneto menor do que a do neto maior de idade.
-   Neto (de qualquer idade) & genro ou nora, sendo a idade do genro ou
    nora mais velha maior que a idade do neto mais novo.
-   Filho maior de idade (acima de 18 anos) & neto (de qualquer idade),
    sendo o filho mais velho do domicílio tendo idade maior que o neto
    mais novo.
-   Genro ou nora e um bisneto, sendo o genro ou nora mais velho que o
    bisneto.
-   Genro ou nora e filho ou filha ou Filho maior de idade com bisneto,
    sendo o filho mais velho que o bisneto.

Então, se o domicílio possui mais de quatro moradores, é extenso, possui
alguma das categorias de núcleo primário e possui em seus componentes
algum par citado na etapa anterior, identifica-se a existência de ao
menos um núcleo secundário e ele é considerado como “Família
convivente”.

Caso ele não seja identificado na etapa anterior, o domicílio é
submetido ***a segunda rodada***, a qual se faz necessária devido ao
fato dos *filhos maiores de idade poderem fazer parte tanto do núcleo
primário como do núcleo secundário*. A segunda rodada é constituída de
quatro etapas, sendo as duas primeiras iguais à etapa anterior:

1.  Identificar se o domicílio possui mais de 4 moradores (exclusive,
    sogros(a),Avô ou avó, outro parente, agregado).
2.  Identificar se o domicílio é estendido OU composto por parentes e
    não parentes do responsável pelo domicílio.
3.  Identificar apenas se temos filhos no núcleo primário (de qualquer
    idade).
4.  Identificar se existem no domicílio alguma seguintes condições:

-   Ao menos 2 filhos maiores de idade & um neto, com o filho mais velho
    tendo idade superior ao neto mais novo
-   Ao menos 2 filhos maiores de idade & um bisneto, sendo o filho mais
    velho com idade maior ao bisneto mais novo
-   Ao menos 2 filhos maiores de idade & um genro ou nora ou um Neto
    maior de idade e um bisneto com idade do neto maior que a do bisneto
    (categoria criada para identificar responsável, filho maior de
    idade, neto e bisneto).
-   Genro ou nora & neto, com o genro ou nora sendo mais velho que o
    neto (categoria criada para identificar responsável, filho maior de
    idade, genro ou nora e neto)
-   Genro ou nora & bisneto com o genro ou senda mais veho que o bisneto
    (categoria criada para identificar responsável, filho maior de
    idade, genro ou nora e bisneto)

Se nesta segunda rodada também não for identificado a existência de ao
menos um núcleo familiar secundário, o domicílio recebe a categoria “Sém
Déficit”, ou seja, sem existência de ao menos um núcleo secundário no
domicílio.

Ressalta-se que a segunda rodada é justamente criada para identificar
combinações dos filhos maiores de idade.

``` r
#### VARIÁVEL COMPOSTAS E ESTENDIDAS
variables <- variables %>%
map(~ .x %>% mutate(conviventes_ec = fct_case_when(                         
  V2001_2>=4 & #Se o número de moradores indicado pela V2001_4 é maior ou igual a 4 passamos para a próxima etapa
    VD2004_2 %in% c("Composta por parentes e não parentes do responsável pelo domicílio",
                    "Estendida") & #Se o domicílio é estendido passamos para a próxima etapa
    ((total_conjuge >=1 | total_filho_menor>=1 | total_pai_pad>=1 | total_mae_mad>=1) & # Etapa de identificação de algum componente do núcleo primário: Se o domicílio tem algum conjugê, ou algum filho menor de idade, ou algum pai ou padrato, ou alguma mãe ou madrasta passamos para a próxima etapa
       ((total_neto_maior>=1 & total_bisneto>=1 & Idade_neto_bisneto %in% c("Sim")) |(total_neto>=1 & total_genro>=1 & Idade_genro_neto %in% c("Sim"))|
          (total_neto>=1 & total_filho_maior>=1 & Idade_filho_neto %in% c("Sim") )|(total_genro>=1 & total_bisneto>=1 & Idade_genro_bisneto %in% c("Sim") )|
          (total_genro>=1 & total_filho_maior>=1) |(total_bisneto>=1 & total_filho_maior>=1) & Idade_filho_bisneto %in% c("Sim")))|               ## Quarta etapa:identifiação do núcleo secundário
    V2001_2>=4 &  ### Então se o domicílio passa pelas quatro etapas acima ele é considerado família convivente, senão ele passa para a rodada abaixo. Primeira etapa da segunda rodada: passa pra próxima se a V2001_2 for maior ou igual a 4 moradores
    VD2004_2 %in% c("Composta por parentes e não parentes do responsável pelo domicílio",
                    "Estendida") & #Se o domicílio é estendido passamos para a próxima etapa
    total_filhos>=1 & ## Identificação do núcleo primário se há algum filho no domicílio passamos para a próxima etapa
    ((total_filho_maior>=2 & total_neto>=1 & Idade_filho_neto %in% c("Sim") )|(total_filho_maior>=2 & total_bisneto>=1 & Idade_filho_bisneto %in% c("Sim"))|    
       (total_filho_maior>=2 & total_genro>=1)|(total_neto_maior>=1 & total_bisneto>=1 & Idade_neto_bisneto %in% c("Sim"))) ### Identificação do núcleo secundário
  ~ "Possui pelo menos uma família convivente",
  TRUE ~ "Sem Déficit" ## Se o domicílio não tiver nenhuma das características acima ele é definido como Sém déficit.
)))
```

# 5. Gerando indicadores de déficit habitacional

Os códigos abaixo são usados para gerar os indicadores de déficit a
partir dos dados da PNAD Contínua em conjunto com as variáveis criadas
nesse documento.

Primeiramente, como dito, reinserimos as tabelas na lista do plano
amostral complexo (*PNADcfam_svy*).

Posteriormente, utilizando a função *fct_case_when*, criamos as
variáveis que identificam os subcomponentes do déficit habitacional
gerados a partir da PNAD Contínua:

``` r
# Substituindo as variáveis de volta à base original
PNADcfam_svy$PNADc_2016$variables <- variables$PNADc_2016
PNADcfam_svy$PNADc_2017$variables <- variables$PNADc_2017
PNADcfam_svy$PNADc_2018$variables <- variables$PNADc_2018
PNADcfam_svy$PNADc_2019$variables <- variables$PNADc_2019

rm(variables)

## Déficit com ônus
PNADcfam_svy <- PNADcfam_svy %>% 
  map(~ .x %>% mutate(CH_onus = fct_case_when(
    S01002 %in% c("Taipa sem revestimento", 
                  "Madeira aproveitada",
                  "Outro material") ~ "Domicílios Rústicos",
    S01001 %in% "Habitação em casa de cômodos, cortiço ou cabeça de porco" & 
      ! S01017 %in% c("Cedido por empregador") ~ "Cômodos",
    V1022 %in% "Urbana" & 
      S01017 %in% "Alugado" &
      Faixa_Rend_Dom %in% SMs_3 &
      Pct_Renda_Aluguel > 0.3 & 
      !is.na(Pct_Renda_Aluguel) &
      is.finite(Pct_Renda_Aluguel) ~ "Ônus",
    TRUE ~ "Sem Déficit"
  )))
```

Alternativamente, caso seja de interesse, utilize o código abaixo para
gerar a variável que identifica as componentes do déficit excluindo o
ônus com aluguel.

``` r
#Déficit sem ônus
PNADcfam_svy <- PNADcfam_svy %>% 
  map(~ .x %>% mutate(CH = fct_case_when(
    S01002 %in% c("Taipa sem revestimento", 
                  "Madeira aproveitada",
                  "Outro material") ~ "Domicílios Rústicos",
    S01001 %in% "Habitação em casa de cômodos, cortiço ou cabeça de porco" & 
      ! S01017 %in% c("Cedido por empregador") ~ "Cômodos",
    TRUE ~ "Sem Déficit"
  )))
```

A seguir, utilize os códigos abaixo para identificar domicílios com
alguma componente de déficit habitacional em variáveis numérica e
categórica, respectivamente.

``` r
# Variável numérica: Deficit
PNADcfam_svy <- PNADcfam_svy %>% 
  map(~ .x %>% mutate(Deficit_onus = case_when(
    CH_onus %in% c("Domicílios Rústicos", 
                   "Cômodos",
                   "Ônus") ~ 1, # Deficit
    TRUE ~ 0 # Sem Deficit
  )))
# Variável categórica: DH
PNADcfam_svy <- PNADcfam_svy %>% 
  map(~ .x %>% mutate(DH_onus = fct_case_when(
    CH_onus %in% c("Domicílios Rústicos", 
                   "Cômodos",
                   "Ônus") ~ "Deficit",
    TRUE ~ "Sem Deficit"
  )))
```

Por fim, utilize o códigos abaixo para incluir o subcomponente de
Unidades Conviventes ***Déficit*** na análise do déficit habitacional.
Ou seja, a existência de uma unidade convivente déficit pressupõe, além
da identificação de ao menos uma famílias convivente, uma densidade
moradores por cômodo acima de 2 pessoas.

Conforme [FJP
(2020)](https://drive.google.com/file/d/1bHOyrem6wB5KupeBGYPgfNCNi0Z9IDV4/view),
as unidades conviventes são uma coluna a parte, porque o mesmo domicílio
pode apresentar ***simultaneamente*** uma situação déficit qualquer -
pelas características do domicílio ou em situação de ônus excessivo com
o aluguel urbano - e possuir também uma unidade convivente déficit. O
que representaria a necessidade de ao menos duas unidades habitacionais
novas para aquele domicílio: uma para o núcleo primário e ao menos outra
para o núcleo secundário identificado.

``` r
## Variável de unidades conviventes déficit
PNADcfam_svy <- PNADcfam_svy %>% 
  map(~ .x %>% mutate(fan_conviven = fct_case_when(
    conviventes_ec  %in% c(("Possui pelo menos uma família convivente")) & 
      Moradores_Comodos>2 
    ~ "Unidade convivente déficit",
    TRUE ~ "Sem Deficit"
  )))
```

As informações geradas sobre o déficit habitacional podem ser
sumarizadas e salvas em um arquivo formato *xlsx* como segue no exemplo
abaixo.

Note que neste caso estão sendo geradas tabelas de acorodo com a
variável indicadora de déficit *CH_onus*, portanto separando as
componentes de déficit considerando o ônus com aluguel.

``` r
### Deficit total ----
#Brasil
r_deficit_brasil <- PNADcfam_svy %>% 
  map(~ .x %>% filter(V2005 == 1)) %>% 
  map(~ .x %>% group_by(Ano, CH_onus)) %>%
  map(~ .x %>% summarise(count = survey_total(vartype = "se", na.rm = T),
                         Percentual = survey_mean(na.rm = T))) %>% 
  map(~ .x %>% filter(!CH_onus %in% "Sem Déficit")) %>%
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se, -Percentual_se) %>% 
  mutate(regiao = "Brasil") %>% 
  select(1,6,2,3:5) %>% 
  rename("regiao" = 2)

#Regiao
r_deficit_regiao <- PNADcfam_svy %>% 
  map(~ .x %>% filter(V2005 == 1)) %>%
  map(~ .x %>% group_by(Ano, CH_onus, Regiao)) %>%
  map(~ .x %>% summarise(count = survey_total(vartype = "se", na.rm = T),
                         Percentual = survey_mean(na.rm = T))) %>% 
  map(~ .x %>% filter(!CH_onus %in% "Sem Déficit")) %>%
  map(~ .x %>% group_by(Regiao)) %>% 
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se, -Percentual_se) %>%  
  select(1,4,2,3,5,6) %>% 
  rename("regiao" = 2)

#UF
r_deficit_UF <- PNADcfam_svy %>% 
  map(~ .x %>% filter(V2005 == 1)) %>%
  map(~ .x %>% group_by(Ano, CH_onus, UF)) %>%
  map(~ .x %>% summarise(count = survey_total(vartype = "se", na.rm = T),
                         Percentual = survey_mean(na.rm = T))) %>% 
  map(~ .x %>% filter(!CH_onus %in% "Sem Déficit")) %>%
  map(~ .x %>% group_by(UF)) %>% 
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se, -Percentual_se) %>%  
  select(1,4,2,3,5,6) %>% 
  rename("regiao" = 2)


#RM
r_deficit_RM <- PNADcfam_svy %>% 
  map(~ .x %>% filter(V2005 == 1)) %>% 
  map(~ .x %>% group_by(Ano, CH_onus, RM_RIDE)) %>% 
  map(~ .x %>% summarise(count = survey_total(vartype = "se", na.rm = T),
                         Percentual = survey_mean(na.rm = T))) %>% 
  map(~ .x %>% filter(!CH_onus %in% "Sem Déficit")) %>%
  map(~ .x %>% group_by(RM_RIDE)) %>% 
  map(~ .x %>% mutate(percent = (count/sum(count,na.rm = T)))) %>% 
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se, -Percentual_se) %>%  
  select(1,4,2,3,5,6) %>% 
  rename("regiao" = 2)

# Capitais
r_deficit_Capital <- PNADcfam_svy %>% 
  map(~ .x %>% filter(V2005 == 1)) %>% 
  map(~ .x %>% group_by(Ano, CH_onus, Capital)) %>% 
  map(~ .x %>% summarise(count = survey_total(vartype = "se", na.rm = T),
                         Percentual = survey_mean(na.rm = T))) %>% 
  map(~ .x %>% filter(!CH_onus %in% "Sem Déficit")) %>%
  map(~ .x %>% group_by(Capital)) %>% 
  map(~ .x %>% mutate(percent = (count/sum(count,na.rm = T)))) %>% 
  bind_rows(.id = "Pesquisa") %>% 
  mutate(Pesquisa = "PNAD_Continua") %>% 
  select(-count_se, -Percentual_se) %>%  
  select(1,4,2,3,5,6) %>% 
  rename("regiao" = 2)

deficit <- list(brasil = r_deficit_brasil, 
                regiao = r_deficit_regiao,
                uf = r_deficit_UF, 
                rm = r_deficit_RM, 
                capital = r_deficit_Capital)

writexl::write_xlsx(deficit, "deficit.xlsx")
```

[^1]: Dessa maneira, o subcomponente *domicílios improvisados*,
    calculado a partir da base do universo do CadÚnico, não consta neste
    documento.

[^2]: Nota-se a importação de outras *variáveis* além das solicitadas.
    Estas são variáveis necessárias para expansão da amostra segundo a
    nova ponderação e metodologia do IBGE para a PNAD Contínua. Para
    mais informações: [Reponderação
    Bootstrap](https://github.com/Gabriel-Assuncao/PNADcIBGE/issues/8) e
    [IBGE
    (2021)](https://biblioteca.ibge.gov.br/visualizacao/livros/liv101866.pdf).
