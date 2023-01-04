Importação e cálculo dos indicadores do IMRS - Dimensão Emprego e Renda
================
Marcos Damasceno - <marcos.damasceno@fjp.mg.gov.br>
Dezembro de 2022

Neste script, será feita a importação dos dados e o cálculo dos
indicadores da dimensão “Emprego e Renda” do Índice Mineiro de
Responsabilidade Social (IMRS), elaborado e publicado pela Fundação João
Pinheiro (FJP). Ao todo, 58 indicadores compõem essa dimensão, cujos
dados são extraídos de quatro instituições: Ministério do Trabalho e
Emprego (MTE), Ministério da Cidadania (MDS), Secretaria de Estado da
Fazenda de Minas Gerais (SEF/MG) e a própria FJP.

Há de se destacar desde logo que o script foi construído para extrair
dados e calcular os indicadores do IMRS divulgado em 2022, que toma como
base dados dos anos de 2019, 2020 e 2021. Isso implicou alguns ajustes
particulares, como a agregação dos dados dos programas de transferência
de renda “Auxílio Emergencial” e “Auxílio Brasil” aos dados do programa
“Bolsa Família”. Assim, para o cálculo dos indicadores de outros anos,
pode ser necessário fazer pequenos ajustes no código, para além da
simples alteração dos anos nas funções que filtram os dados pelo
período.

Outra ressalva muito importante deve ser feita em relação aos arquivos
utilizados como fonte dos dados para cálculo dos indicadores. Ao se
adaptar este script para calcular indicadores de outros anos, as
planilhas devem ter o exato formato e padrão das aqui utilizadas para os
anos de 2019 a 2021. Portanto, ao extrair os dados do *site* do MTE ou
do MDS, por exemplo, as seleções devem ser feitas de maneira que a
planilha gerada mantenha o formato das utilizadas e indicadas como fonte
neste script.

## **1) Comandos preliminares:**

Antes de iniciar a importação dos dados, serão acionados alguns comandos
úteis para facilitar o uso da interface do RStudio. O primeiro deles
indica ao programa que desative notificações que não sejam referentes a
erros do script, evitando que o usuário seja confundido com mensagens de
alerta. Em seguida, são excluídos objetos abertos no ambiente do RStudio
e limpo o console de comandos. Depois, é indicado o diretório (pasta) de
trabalho que será utilizado, impondo que ele seja o mesmo no qual está
salvo o arquivo deste script (o ideal é rodar o script dentro de um
projeto – “project” – do RStudio pois, assim, o próprio programa já
identifica o diretório onde estão localizados o script e demais arquivos
a serem utilizados). Por fim, são instaladas (caso já não estejam) e
carregadas as bibliotecas (pacotes) que serão utilizadas neste script.

``` r
# Desativa notificações para todos os blocos de código ("chunks"):

options(warn=-1)


# Limpa a memória e console:

cat("\014")  
rm(list = ls())


# Indica o diretório de trabalho:

dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(dir)
rm(dir)


# Indica as bibliotecas utilizadas num único vetor:

pacotes <- c("rstudioapi", "readr", "readxl", "writexl", "tidyverse", "dplyr")


# Verifica se alguma das bibliotecas ainda não foi instalada e, caso não, faz com que o sejam:

pacotes_instalados <- pacotes %in% rownames(installed.packages())
if (any(pacotes_instalados == FALSE)) {
  install.packages(pacotes[!pacotes_instalados])
}

# Carrega as as bibliotecas:

lapply(pacotes, library, character.only = TRUE)


# Remove os objetos que não serão mais utilizados:

rm(pacotes, pacotes_instalados)
```

## **2) Importação dos dados de projeções populacionais:**

Antes de importar os dados das bases de dados de emprego e renda, serão
importados os das projeções populacionais por município mineiro,
elaboradas pela FJP com base nas projeções do Instituto Brasileiro de
Geografia e Estatística (IBGE), que são estratificadas por idade e sexo.
Tais dados são necessários para o cálculo dos indicadores de emprego e
renda que têm como denominador a população do município, a população em
idade ativa e indicadores per capita.

Essas informações são extraídas do arquivo intitulado *IMRS2022 - BASE
POPULACAO REFERENCIA.xlsx*, planilha em que constam, para cada município
mineiro e desde o ano 2000 até o de 2021, a população total informada
pelo IBGE e também as estimativas por sexo e grupos de idade calculadas
pela FJP. Vale observar que a população total corresponde ao indicador
“População total (estimativas ajustadas)” - *D_POPTA*, que contém a
população ajustada após a revisão das projeções populacionais pelo IBGE
em 2018.

Para tanto, primeiramente é criado um objeto *Populacao*, que armazena a
base citada acima. Dessa base são filtrados os dados das populações
municipais dos anos de 2019, 2020 e 2021, usados para calcular os
indicadores do IMRS de 2022. Para calcular indicadores de outros
períodos, basta modificar o filtro *ANO ==* na função *filter*,
indicando o ano desejado e alterando o nome do objeto/variável
correspondente, para evitar confusão.

``` r
# Carrega os dados populacionais por município:

Populacao <- as_tibble(read_excel("IMRS2022 - BASE POPULACAO REFERENCIA.xlsx"), col_names = TRUE) %>% select(c("IBGE7", "ANO", "D_POPTA", "D_POPP16a64"))


# Mantém apenas as observações dos anos de interesse:

Populacao <- filter(Populacao, (ANO == 2019 | ANO == 2020 | ANO == 2021))


# Ordena a base de população segundo o código dos municípios:
  
Populacao <- Populacao[order(Populacao$IBGE7),]


# Arredonda os dados da população em idade ativa:

Populacao$D_POPP16a64 <- round(Populacao$D_POPP16a64, 0)
```

## **3) Importação dos dados de emprego e renda e cálculo dos indicadores do trabalho formal:**

Iniciando pelos dados da Relação Anual de Informações Sociais (RAIS) do
MTE, as informações almejadas são duas, extraídas do sistema Dardo do
MTE (<https://bi.mte.gov.br/bgcaged/>): o número de vínculos
empregatícios ativos em 31/12 (variável *vínculo ativo 31/12*) e a
remuneração média nominal também apurada em dezembro (variável *VI Remun
Dezembro Nom*). Ambas as informações devem ser obtidas para cada
município do estado de Minas Gerais e, no caso dos vínculos de emprego,
também é necessário desagregar os dados para cada um dos oito setores de
atividades econômicas definidos segundo a classificação do IBGE.

Nos comandos abaixo, tais dados serão importados de planilhas em formato
*.csv*, baixadas diretamente da página do MTE (sistema Dardo), sendo uma
tabela para cada ano. Tem-se, assim, três tabelas anuais com os dados
sobre o total de vínculos de emprego e outras três com a remuneração
média nominal no mês de dezembro, todas elas com os códigos e nomes dos
municípios de Minas Gerais nas linhas e, nas colunas, os oito grupos
(setores) econômicos definidos pela classificação pelo IBGE (além de uma
última coluna com o valor total, isto é, a soma de todos os vínculos de
emprego ou da remuneração média em cada setor).

Depois de limpar os dados desnecessários das bases importadas, adicionar
colunas separadas para ano, nomes e códigos dos municípios, o resultado
são duas bases (“dataframes”), um contendo os dados de vínculos de
emprego para os três anos analisados e outro contendo os dados da
remuneração média para o mesmo período.

``` r
# Faz a leitura das planilhas em formato .csv e monta tabelas em formato "tibble":

RAIS_vinculos_2019 <- as_tibble(read_csv2("RAIS - Vínculos ativos 31.12 - 2019.csv", col_names = TRUE, skip = 1, locale = locale(encoding = "latin1"), show_col_types = FALSE))

RAIS_renda_2019 <- as_tibble(read_csv2("RAIS - Vl Remun Dezembro Nom - 2019.csv", col_names = TRUE, skip = 1, locale = locale(encoding = "latin1"), show_col_types = FALSE))

RAIS_vinculos_2020 <- as_tibble(read_csv2("RAIS - Vínculos ativos 31.12 - 2020.csv", col_names = TRUE, skip = 1, locale = locale(encoding = "latin1"), show_col_types = FALSE))

RAIS_renda_2020 <- as_tibble(read_csv2("RAIS - Vl Remun Dezembro Nom - 2020.csv", col_names = TRUE, skip = 1, locale = locale(encoding = "latin1"), show_col_types = FALSE))

RAIS_vinculos_2021 <- as_tibble(read_csv2("RAIS - Vínculos ativos 31.12 - 2021.csv", col_names = TRUE, skip = 1, locale = locale(encoding = "latin1"), show_col_types = FALSE))

RAIS_renda_2021 <- as_tibble(read_csv2("RAIS - Vl Remun Dezembro Nom - 2021.csv", col_names = TRUE, skip = 1, locale = locale(encoding = "latin1"), show_col_types = FALSE))


# Exclui linhas com informações desnecessárias:

RAIS_renda_2019 <- RAIS_renda_2019[-c(854:length(RAIS_renda_2019$`Município-Minas Gerais`)),]

RAIS_vinculos_2019 <- RAIS_vinculos_2019[-c(854:length(RAIS_vinculos_2019$`Município-Minas Gerais`)),]

RAIS_renda_2020 <- RAIS_renda_2020[-c(854:length(RAIS_renda_2020$`Município-Minas Gerais`)),]

RAIS_vinculos_2020 <- RAIS_vinculos_2020[-c(854:length(RAIS_vinculos_2020$`Município-Minas Gerais`)),]

RAIS_renda_2021 <- RAIS_renda_2021[-c(854:length(RAIS_renda_2021$`Município-Minas Gerais`)),]

RAIS_vinculos_2021 <- RAIS_vinculos_2021[-c(854:length(RAIS_vinculos_2021$`Município-Minas Gerais`)),]


# Adiciona coluna com informação sobre o ano:

RAIS_renda_2019 <- RAIS_renda_2019 %>% mutate(Ano = 2019, .after = "Município-Minas Gerais")

RAIS_vinculos_2019 <- RAIS_vinculos_2019 %>% mutate(Ano = 2019, .after = "Município-Minas Gerais")

RAIS_renda_2020 <- RAIS_renda_2020 %>% mutate(Ano = 2020, .after = "Município-Minas Gerais")

RAIS_vinculos_2020 <- RAIS_vinculos_2020 %>% mutate(Ano = 2020, .after = "Município-Minas Gerais")

RAIS_renda_2021 <- RAIS_renda_2021 %>% mutate(Ano = 2021, .after = "Município-Minas Gerais")

RAIS_vinculos_2021 <- RAIS_vinculos_2021 %>% mutate(Ano = 2021, .after = "Município-Minas Gerais")


# Exclui dados de renda por setor (que não serão usados):


RAIS_renda_2019 <- select(RAIS_renda_2019, "Município-Minas Gerais", "Ano", "Total")

RAIS_renda_2020 <- select(RAIS_renda_2020, "Município-Minas Gerais", "Ano", "Total")

RAIS_renda_2021 <- select(RAIS_renda_2021, "Município-Minas Gerais", "Ano", "Total")


# Unifica bases de vínculos de emprego e de renda:

RAIS_renda <- merge(RAIS_renda_2019, RAIS_renda_2020, all = TRUE)

RAIS_renda <- merge(RAIS_renda, RAIS_renda_2021, all = TRUE)

RAIS_vinculos <- merge(RAIS_vinculos_2019, RAIS_vinculos_2020, all = TRUE)

RAIS_vinculos <- merge(RAIS_vinculos, RAIS_vinculos_2021, all = TRUE)


# Arredonda dado sobre rendimento:

RAIS_renda$Total <- round(RAIS_renda$Total, 2)


# Separa códigos e nomes de municípios em colunas distintas:

x <- strsplit(RAIS_renda$`Município-Minas Gerais`, ":MG-")

x <- matrix(unlist(x), ncol=2, byrow = TRUE)

RAIS_renda$Município <- x[,2]

RAIS_renda$IBGE6 <- x[,1]

RAIS_vinculos$Município <- x[,2]

RAIS_vinculos$IBGE6 <- x[,1]

RAIS_renda <- RAIS_renda[,-1]

RAIS_vinculos <- RAIS_vinculos[,-1]


# Reordena as colunas das bases:

RAIS_renda <- RAIS_renda %>% relocate(IBGE6, .before = Ano)

RAIS_renda <- RAIS_renda %>% relocate(Município, .before = Ano)
  
RAIS_vinculos <- RAIS_vinculos %>% relocate(IBGE6, .before = Ano)

RAIS_vinculos <- RAIS_vinculos %>% relocate(Município, .before = Ano)


# Remove objetos desnecessários ao restante do script:

rm(x, RAIS_renda_2019, RAIS_renda_2020, RAIS_renda_2021, RAIS_vinculos_2019, RAIS_vinculos_2020, RAIS_vinculos_2021)
```

A partir dos dados obtidos da RAIS, onze indicadores devem ser
calculados, conforme descrito nos metadados do IMRS. São eles:

1)  *ER_EMPRSF*: número de empregados do setor formal – corresponde ao
    total de vínculos indicado na variável “vínculo ativo 31/12” do
    sistema Dardo.
2)  *ER_EMPRSFTX*: taxa de emprego no setor formal – corresponde à
    divisão do total de empregos formais (o indicador *ER_EMPRSF*) pela
    população do município com idade entre 16 e 64 anos (informada pelo
    IBGE para o mesmo período/ano analisado).
3)  *ER_RENSF*: rendimento médio no setor formal (R\$) – corresponde à
    divisão da variável “Vl Remun Dezembro Nom” do sistema Dardo pelo
    total de empregos formais (*R_EMPRSF*).
4)  *ER_RENPCSF*: rendimento per capita no setor formal (R\$) –
    corresponde à divisão da variável “Vl Remun Dezembro Nom” do sistema
    Dardo pela população do município (informada pelo IBGE para o mesmo
    período/ano analisado).
5)  *ER_EMPRSFAG*: número de empregados do setor formal - atividades
    primárias – corresponde à variável “vínculo ativo 31/12” do sistema
    Dardo na subcoluna “8 - Agropecuária, extração vegetal, caça e
    pesca”.
6)  *ER_EMPRSFMI*: número de empregados do setor formal - extrativa
    mineral – corresponde à variável “vínculo ativo 31/12” do sistema
    Dardo na subcoluna “1 - Extrativa mineral”.
7)  *ER_EMPRSFIT*: número de empregados do setor formal - indústria de
    transformação – corresponde à variável “vínculo ativo 31/12” do
    sistema Dardo na subcoluna “2 - Indústria de transformação”.
8)  *ER_EMPRSFUP*: número de empregados do setor formal - serviços
    industriais de utilidade pública - corresponde à variável “vínculo
    ativo 31/12” do sistema Dardo na subcoluna “3 - Serviços industriais
    de utilidade pública”.
9)  *ER_EMPRSFIC*: número de empregados do setor formal - indústria da
    construção – corresponde à variável “vínculo ativo 31/12” do sistema
    Dardo na subcoluna “4 - Construção Civil”.
10) *ER_EMPRSFCO*: número de empregados do setor formal - comércio –
    corresponde à variável “vínculo ativo 31/12” do sistema Dardo na
    subcoluna “5 - Comércio”.
11) *ER_EMPRSFSE*: número de empregados do setor formal - serviços –
    corresponde à variável “vínculo ativo 31/12” do sistema Dardo nas
    subcolunas “6 - Serviços” e “7 - Administração Pública”.

Os comandos abaixo calculam cada um desses indicadores para os 853
municípios mineiros, que serão salvos em uma tabela de formato “tibble”
chamada *IMRS_emprego_renda*:

``` r
# Cria tabela em formato tibble/data frame para inserir os indicadores calculados:

IMRS_emprego_renda <- data.frame(RAIS_renda$IBGE6, Populacao$IBGE7, RAIS_renda$Município, RAIS_renda$Ano)

IMRS_emprego_renda <- IMRS_emprego_renda %>% rename("IBGE6" = "RAIS_renda.IBGE6", "IBGE7" = "Populacao.IBGE7", "Município" = "RAIS_renda.Município", "ANO" = "RAIS_renda.Ano")


# Calcula os indicadores:

IMRS_emprego_renda <- IMRS_emprego_renda %>% mutate(ER_EMPRSF = as.numeric(RAIS_vinculos$Total))

IMRS_emprego_renda <- IMRS_emprego_renda %>% mutate(ER_EMPRSFTX = round((IMRS_emprego_renda$ER_EMPRSF/Populacao$D_POPP16a64)*100, 2))

IMRS_emprego_renda <- IMRS_emprego_renda %>% mutate(ER_RENSF = round(RAIS_renda$Total/ER_EMPRSF, 2))

IMRS_emprego_renda <- IMRS_emprego_renda %>% mutate(ER_RENPCSF = round(RAIS_renda$Total/Populacao$D_POPTA, 2))

IMRS_emprego_renda <- IMRS_emprego_renda %>% mutate(ER_EMPRSFAG = as.numeric(RAIS_vinculos$`8 - Agropecuária, extração vegetal, caça e pesca`))

IMRS_emprego_renda <- IMRS_emprego_renda %>% mutate(ER_EMPRSFMI = as.numeric(RAIS_vinculos$`1 - Extrativa mineral`))

IMRS_emprego_renda <- IMRS_emprego_renda %>% mutate(ER_EMPRSFIT = as.numeric(RAIS_vinculos$`2 - Indústria de transformação`))

IMRS_emprego_renda <- IMRS_emprego_renda %>% mutate(ER_EMPRSFUP = as.numeric(RAIS_vinculos$`3 - Servicos industriais de utilidade pública`))

IMRS_emprego_renda <- IMRS_emprego_renda %>% mutate(ER_EMPRSFIC = as.numeric(RAIS_vinculos$`4 - Construção Civil`))

IMRS_emprego_renda <- IMRS_emprego_renda %>% mutate(ER_EMPRSFCO = as.numeric(RAIS_vinculos$`5 - Comércio`))

IMRS_emprego_renda <- IMRS_emprego_renda %>% mutate(ER_EMPRSFSE = as.numeric(RAIS_vinculos$`6 - Serviços`) + as.numeric(RAIS_vinculos$`7 - Administração Pública`))


# Exclui objetos que não serão mais necessários: 

rm(RAIS_renda, RAIS_vinculos)
```

## **4) Importação dos dados e cálculo dos indicadores relacionados a programas de transferência de renda:**

O próximo conjunto de indicadores diz respeito ao número de
beneficiários e valores transferidos no âmbito dos programas de
transferência de renda do Governo Federal, dados que são extraídos do
sistema VisData do MDS
(<https://aplicacoes.mds.gov.br/sagi/vis/data3/data-explorer.php>).
Dessa página são baixadas sete planilhas com os dados mensais, por
município, para cada período anual, a saber:

- total de famílias beneficiadas e valores transferidos pelo programa
  Bolsa Família;
- total de famílias cadastradas no programa Bolsa Família e beneficiadas
  pelo Auxílio Emergencial concedido em função da pandemia da Covid-19,
  bem como o valor total transferido para tais famílias;
- total de famílias cadastradas no programa Bolsa Família e beneficiadas
  pelo programa Auxílio Brasil, acrescido do benefício extraordinário
  instituído pela Lei nº 14.342/2022, bem como o valor total transferido
  para tais famílias;
- total de idosos que recebem o Benefício de Prestação Continuada (BPC)
  e valor total repassado a esses idosos;
- total de pessoas com deficiência (PCD) que recebem o BPC e valor total
  repassado a essas pessoas.

Primeiramente, os dados são importados e organizados segundo o ano e o
mês das transferências:

``` r
# Faz a leitura das planilhas em formato .csv e monta tabelas em formato "tibble":

BolsaFamilia <- as_tibble(read_csv("VisData - Bolsa Família - 2018-2021.csv", col_names = TRUE, locale = locale(encoding = "latin1"), show_col_types = FALSE))

BPC_PCD <- as_tibble(read_csv("VisData - BPC - PCD - Quantidade - 2018-2021.csv",  col_names = TRUE, locale = locale(encoding = "latin1"), show_col_types = FALSE))

BPC_Idosos <- as_tibble(read_csv("VisData - BPC - Idosos - Quantidade - 2018-2021.csv", col_names = TRUE, locale = locale(encoding = "latin1"), show_col_types = FALSE))

BPC_PCD_valores <- as_tibble(read_csv("VisData - BPC - PCD - Valores - 2018-2021.csv", col_names = TRUE, locale = locale(encoding = "latin1"), show_col_types = FALSE))

BPC_Idosos_valores <- as_tibble(read_csv("VisData - BPC - Idosos - Valores - 2018-2021.csv", col_names = TRUE, locale = locale(encoding = "latin1"), show_col_types = FALSE))

AuxilioEmergencial <- as_tibble(read_csv("VisData - Auxílio Emergencial - 2020-2021.csv", col_names = TRUE, locale = locale(encoding = "latin1"), show_col_types = FALSE))

AuxilioBrasil <- as_tibble(read_csv("VisData - Auxílio Brasil - 2021-2022.csv", col_names = TRUE, locale = locale(encoding = "latin1"), show_col_types = FALSE))


# Desagrega a coluna "Referência" das bases acima em duas colunas com ano e mês:

x <- strsplit(BolsaFamilia$Referência, split = "/")

for (i in 1:length(BolsaFamilia$Referência)){
  BolsaFamilia$Ano[i] <- x[[i]][2]
  BolsaFamilia$Mês[i] <- x[[i]][1]
}

BolsaFamilia <- BolsaFamilia %>% relocate(Ano, .after = UF)
BolsaFamilia <- BolsaFamilia %>% relocate(Mês, .after = UF)
BolsaFamilia$Referência <- NULL

x <- strsplit(BPC_Idosos$Referência, split = "/") 

i <- 1

for (i in 1:length(BPC_Idosos$Referência)){
  BPC_Idosos$Ano[i] <- x[[i]][2]
  BPC_Idosos$Mês[i] <- x[[i]][1]
}

BPC_Idosos <- BPC_Idosos %>% relocate(Ano, .after = UF)
BPC_Idosos <- BPC_Idosos %>% relocate(Mês, .after = UF)
BPC_Idosos$Referência <- NULL

x <- strsplit(BPC_Idosos_valores$Referência, split = "/") 

i <- 1

for (i in 1:length(BPC_Idosos_valores$Referência)){
  BPC_Idosos_valores$Ano[i] <- x[[i]][2]
  BPC_Idosos_valores$Mês[i] <- x[[i]][1]
}

BPC_Idosos_valores <- BPC_Idosos_valores %>% relocate(Ano, .after = UF)
BPC_Idosos_valores <- BPC_Idosos_valores %>% relocate(Mês, .after = UF)
BPC_Idosos_valores$Referência <- NULL

x <- strsplit(BPC_PCD$Referência, split = "/") 

i <- 1

for (i in 1:length(BPC_PCD$Referência)){
  BPC_PCD$Ano[i] <- x[[i]][2]
  BPC_PCD$Mês[i] <- x[[i]][1]
}

BPC_PCD <- BPC_PCD %>% relocate(Ano, .after = UF)
BPC_PCD <- BPC_PCD %>% relocate(Mês, .after = UF)
BPC_PCD$Referência <- NULL

x <- strsplit(BPC_PCD_valores$Referência, split = "/") 

i <- 1

for (i in 1:length(BPC_PCD_valores$Referência)){
  BPC_PCD_valores$Ano[i] <- x[[i]][2]
  BPC_PCD_valores$Mês[i] <- x[[i]][1]
}

BPC_PCD_valores <- BPC_PCD_valores %>% relocate(Ano, .after = UF)
BPC_PCD_valores <- BPC_PCD_valores %>% relocate(Mês, .after = UF)
BPC_PCD_valores$Referência <- NULL

x <- strsplit(AuxilioEmergencial$Referência, split = "/") 

i <- 1

for (i in 1:length(AuxilioEmergencial$Referência)){
  AuxilioEmergencial$Ano[i] <- x[[i]][2]
  AuxilioEmergencial$Mês[i] <- x[[i]][1]
}

AuxilioEmergencial <- AuxilioEmergencial %>% relocate(Ano, .after = UF)
AuxilioEmergencial <- AuxilioEmergencial %>% relocate(Mês, .after = UF)
AuxilioEmergencial$Referência <- NULL

x <- strsplit(AuxilioBrasil$Referência, split = "/") 

i <- 1

for (i in 1:length(AuxilioBrasil$Referência)){
  AuxilioBrasil$Ano[i] <- x[[i]][2]
  AuxilioBrasil$Mês[i] <- x[[i]][1]
}

AuxilioBrasil <- AuxilioBrasil %>% relocate(Ano, .after = UF)
AuxilioBrasil <- AuxilioBrasil %>% relocate(Mês, .after = UF)
AuxilioBrasil$Referência <- NULL

rm(x, i)
```

Em seguida, os dados dos programas Bolsa Família, Auxílio Emergencial e
Auxílio Brasil (esse último acrescido do benefício extraordinário
instituído pela Lei nº 14.342/2022) são organizados numa única base e
exportados para uma planilha conjunta, com o único intuito de facilitar
a identificação do número de beneficiários e valores transferidos no
âmbito de cada programa, haja vista a coincidência temporal e o fato de
esses benefícios serem mutuamente excludentes:

``` r
# Calcula valor total repassado em cada programa de transferência, número de famílias beneficiadas e valor médio mensal das transferências, anualmente e por município:


# 2019

x <- BolsaFamilia %>% filter(Ano == "2019") %>% group_by(`Código`) %>% summarise(n = sum(`Valor Total Repassado`))

y <- BolsaFamilia %>% filter(Ano == "2019") %>% group_by(`Código`) %>% summarise(n = sum(`Famílias Beneficiárias`))

BF_2019 <- data.frame("IBGE6" = x$Código , "Ano" = 2019, "Valor transferido - Bolsa Família" = x$n,
                      "Famílias beneficiárias" = y$n, check.names = F)

# 2020

x <- AuxilioEmergencial %>% filter(Ano == "2020") %>% group_by(`Código`) %>% 
  summarise(n = sum(`Valor total a ser repassado para público Bolsa Família`))

y <- BolsaFamilia %>% filter(Ano == "2020") %>% group_by(`Código`) %>% summarise(n = sum(`Valor Total Repassado`))

z <- BolsaFamilia %>% filter(Ano == "2020") %>% group_by(`Código`) %>% summarise(n = sum(`Famílias Beneficiárias`))

BF_AuxEm_2020 <- data.frame("IBGE6" = x$Código, "Ano" = 2020, "Valor transferido - Bolsa Família" = y$n,
                            "Valor transferido - Auxílio Emergencial" = x$n, "Famílias beneficiárias" = z$n, check.names = F)

# 2021 (até setembro)

x <- BolsaFamilia %>% filter(Ano == "2021") %>% group_by(`Código`) %>% summarise(n = sum(`Valor Total Repassado`))

y <- AuxilioBrasil %>% filter(Ano == "2021") %>% group_by(`Código`) %>%
  summarise(n = sum(`Valores Repassados do Auxílio Brasil + Benefício Extraordinário`))

z <- BolsaFamilia %>% filter(Ano == "2021") %>% group_by(`Código`) %>% summarise(n = sum(`Famílias Beneficiárias`))

w <- AuxilioBrasil %>% filter(Ano == "2021") %>% group_by(`Código`) %>% summarise(n = sum(`Famílias Beneficiárias do Auxílio Brasil`))

BF_AuxBr_2021 <- data.frame("IBGE6" = x$Código, "Ano" = 2021, "Valor transferido - Bolsa Família" = x$n,
                            "Valor transferido - Auxílio Brasil" = y$n, "Famílias beneficiárias" = z$n + w$n, check.names = F)

rm(x,y,z,w)


# Une as bases de 2019 a 2021 para os programas Bolsa Família, Auxílio Emergencial e Auxílio Brasil e exporta em arquivo de formato Excel:

Transferencias_2019a2021 <- bind_rows(BF_2019, BF_AuxEm_2020, BF_AuxBr_2021)

Transferencias_2019a2021 <- Transferencias_2019a2021 %>% relocate(`Famílias beneficiárias`, .after = Ano)

Transferencias_2019a2021 <- Transferencias_2019a2021 %>% replace(is.na(.), 0)

Transferencias_2019a2021 <- Transferencias_2019a2021 %>% mutate("Valor transferido - Total" = `Valor transferido - Bolsa Família` +
                                                                  `Valor transferido - Auxílio Emergencial` + `Valor transferido - Auxílio Brasil`)

Transferencias_2019a2021 <- Transferencias_2019a2021 %>% mutate("Valor médio mensal da transferência" = `Valor transferido - Total` /
                                                                `Famílias beneficiárias`)

write_xlsx(Transferencias_2019a2021, path = "output_Transferências_2019a2021.xlsx", col_names = TRUE, format_headers = TRUE)

rm(Transferencias_2019a2021)
```

Enfim, são calculados os quatorze indicadores do IMRS, da seguinte
forma:

1)  *ER_BFFAM*: famílias beneficiadas pelo Bolsa Família – média simples
    anual da coluna “Famílias Beneficiárias” do indicador “Programa
    Bolsa Família - quantidade de famílias e valores”.

2)  *ER_TRFAM*: transferências do Bolsa Família (R\$ mil correntes) –
    soma dos valores da coluna “Valor Total Repassado” do indicador
    “Programa Bolsa Família - quantidade de famílias e valores”,
    dividida por 1.000.

3)  *ER_TRPF*: transferências por família beneficiada (R\$ correntes) –
    divisão das duas variáveis anteriores, resultado que é dividido por
    12 e multiplicado por 1.000.

4)  *ER_BPCDEF*: deficientes beneficiados pelo BPC – média simples anual
    da coluna “Pessoas com deficiência (PCD) que recebem o Benefício de
    Prestação Continuada (BPC) por Município pagador” do indicador de
    mesmo nome.

5)  *ER_BPCIDO*: idosos beneficiados pelo BPC – média simples anual da
    coluna “Idosos que recebem o Benefício de Prestação Continuada (BPC)
    por Município pagador” do indicador de mesmo nome.

6)  *ER_BFBPC*: total de beneficiários do BPC – soma das duas variáveis
    anteriores.

7)  *ER_TRBPCDEF*: transferências do BPC - deficientes (R\$ mil
    correntes) – total anual (em milhares de reais) dos valores da
    coluna “Valor repassado às pessoas com deficiência (PCD) via
    Benefício de Prestação Continuada (BPC) por município pagador” do
    indicador de mesmo nome.

8)  *ER_TRBPCIDO*: transferências do BPC - idosos (R\$ mil correntes) –
    total anual (em milhares de reais) dos valores da coluna “Valor
    repassado aos idosos via Benefício de Prestação Continuada (BPC) por
    município pagador” do indicador de mesmo nome.

9)  *ER_TRBPC*: total das transferências do BPC (R\$ mil correntes) –
    soma das duas variáveis anteriores.

10) *ER_TRBPCPB*: transferências por beneficiário do BPC (R\$ correntes)
    – divisão da variável *ER_TRBPC* (total anual de repasses do PBC
    para idosos e PCDs) multiplicada por 1.000 pela variável R_BFBPC
    (média anual de idosos e PCDs beneficiários do BPC), cujo resultado
    é dividido por 12.

11) *ER_TRBFBPC*: transferências do BF e BPC (R\$ mil correntes) – soma
    das variáveis R_TRFAM e R_TRBPC.

12) *ER_TRPC*: transferências per capita - BF e BPC (R\$ correntes) –
    divisão da variável anterior multiplicada por 1.000 pelo total de
    habitantes do município, sendo o resultado dividido por 12.

13) *ER_TRPCBF*: transferências per capita - BF (R\$ correntes) –
    divisão da variável R_TRFAM multiplicada por 1.000 pelo total de
    habitantes do município, sendo o resultado dividido por 12.

14) *ER_TRPCBPC*: Transferências per capita - BPC (R\$ correntes) –
    divisão da variável R_TRBPC multiplicada por 1.000 pelo total de
    habitantes do município, sendo o resultado dividido por 12.

``` r
# Calcula indicadores do Bolsa Família, Auxílio Emergencial e Auxílio Brasil:

ER_BFFAM <- BF_2019 %>% group_by(`IBGE6`) %>% summarise("2019" = sum(`Famílias beneficiárias`)/12)

ER_BFFAM <- ER_BFFAM %>% mutate(BF_AuxEm_2020 %>% group_by(IBGE6) %>% summarise("2020" = sum(`Famílias beneficiárias`)/12))

ER_BFFAM <- ER_BFFAM %>% mutate(BF_AuxBr_2021 %>% group_by(IBGE6) %>% summarise("2021" = sum(`Famílias beneficiárias`)/12))


ER_TRFAM <- BF_2019 %>% group_by(`IBGE6`) %>% summarise("2019" = sum(`Valor transferido - Bolsa Família`)/1000)

ER_TRFAM <- ER_TRFAM %>% mutate(BF_AuxEm_2020 %>% group_by(`IBGE6`) %>% summarise("2020" = sum(`Valor transferido - Bolsa Família` + `Valor transferido - Auxílio Emergencial`)/1000))

ER_TRFAM <- ER_TRFAM %>% mutate(BF_AuxBr_2021 %>% group_by(`IBGE6`) %>% summarise("2021" = sum(`Valor transferido - Bolsa Família` + `Valor transferido - Auxílio Brasil`)/1000))


ER_TRPCBF <- data.frame("IBGE6" = ER_TRFAM$IBGE6)

ER_TRPCBF <- ER_TRPCBF %>% mutate(((ER_TRFAM$`2019` *1000) / (filter(Populacao, ANO == 2019) %>% select("2019" = D_POPTA))) /12)

ER_TRPCBF <- ER_TRPCBF %>% mutate(((ER_TRFAM$`2020` *1000) / (filter(Populacao, ANO == 2020) %>% select("2020" = D_POPTA))) /12)

ER_TRPCBF <- ER_TRPCBF %>% mutate(((ER_TRFAM$`2021` *1000) / (filter(Populacao, ANO == 2021) %>% select("2021" = D_POPTA))) /12)


ER_BFFAM <- ER_BFFAM %>% pivot_longer(c("2019", "2020", "2021"), "Ano", values_to = "ER_BFFAM")

ER_TRFAM <- ER_TRFAM %>% pivot_longer(c("2019", "2020", "2021"), "Ano", values_to = "ER_TRFAM")

ER_TRPCBF <- ER_TRPCBF %>% pivot_longer(c("2019", "2020", "2021"), "Ano", values_to = "ER_TRPCBF")


ER_TRPF <- (ER_TRFAM$ER_TRFAM/ER_BFFAM$ER_BFFAM)/12*1000
                                                                  

# Calcula indicadores do BPC:

ER_BPCDEF <- BPC_PCD %>% filter(Ano == "2019") %>% group_by(Código) %>% summarise("2019" = sum(`Pessoas com deficiência (PCD) que recebem o Benefício de Prestação Continuada (BPC) por Município pagador`)/12)

ER_BPCDEF <- ER_BPCDEF %>% mutate(BPC_PCD %>% filter(Ano == "2020") %>% group_by(Código) %>% summarise("2020" = sum(`Pessoas com deficiência (PCD) que recebem o Benefício de Prestação Continuada (BPC) por Município pagador`)/12))

ER_BPCDEF <- ER_BPCDEF %>% mutate(BPC_PCD %>% filter(Ano == "2021") %>% group_by(Código) %>% summarise("2021" = sum(`Pessoas com deficiência (PCD) que recebem o Benefício de Prestação Continuada (BPC) por Município pagador`)/12))


ER_BPCIDO <- BPC_Idosos %>% filter(Ano == "2019") %>% group_by(Código) %>% summarise("2019" = round(sum(`Idosos que recebem o Benefício de Prestação Continuada (BPC) por Município pagador`)/12))

ER_BPCIDO <- ER_BPCIDO %>% mutate(BPC_Idosos %>% filter(Ano == "2020") %>% group_by(Código) %>% summarise("2020" = round(sum(`Idosos que recebem o Benefício de Prestação Continuada (BPC) por Município pagador`)/12)))

ER_BPCIDO <- ER_BPCIDO %>% mutate(BPC_Idosos %>% filter(Ano == "2021") %>% group_by(Código) %>% summarise("2021" = round(sum(`Idosos que recebem o Benefício de Prestação Continuada (BPC) por Município pagador`)/12)))


ER_TRBPCDEF <- BPC_PCD_valores %>% filter(Ano == "2019") %>% group_by(Código) %>% summarise("2019" = sum(`Valor repassado às pessoas com deficiência (PCD) via Benefício de Prestação Continuada (BPC) por município pagador`)/1000)

ER_TRBPCDEF <- ER_TRBPCDEF %>% mutate(BPC_PCD_valores %>% filter(Ano == "2020") %>% group_by(Código) %>% summarise("2020" = sum(`Valor repassado às pessoas com deficiência (PCD) via Benefício de Prestação Continuada (BPC) por município pagador`)/1000))

ER_TRBPCDEF <- ER_TRBPCDEF %>% mutate(BPC_PCD_valores %>% filter(Ano == "2021") %>% group_by(Código) %>% summarise("2021" = sum(`Valor repassado às pessoas com deficiência (PCD) via Benefício de Prestação Continuada (BPC) por município pagador`)/1000))


ER_TRBPCIDO <- BPC_Idosos_valores %>% filter(Ano == "2019") %>% group_by(Código) %>% summarise("2019" = sum(`Valor repassado aos idosos via Benefício de Prestação Continuada (BPC) por município pagador`)/1000)

ER_TRBPCIDO <- ER_TRBPCIDO %>% mutate(BPC_Idosos_valores %>% filter(Ano == "2020") %>% group_by(Código) %>% summarise("2020" = sum(`Valor repassado aos idosos via Benefício de Prestação Continuada (BPC) por município pagador`)/1000))

ER_TRBPCIDO <- ER_TRBPCIDO %>% mutate(BPC_Idosos_valores %>% filter(Ano == "2021") %>% group_by(Código) %>% summarise("2021" = sum(`Valor repassado aos idosos via Benefício de Prestação Continuada (BPC) por município pagador`)/1000))


ER_TRPCBPC <- data.frame("IBGE6" = ER_TRBPCDEF$Código)

ER_TRPCBPC <- ER_TRPCBPC %>% mutate((((ER_TRBPCDEF$`2019` + ER_TRBPCIDO$`2019`) * 1000) / (filter(Populacao, ANO == 2019) %>%  select("2019" = D_POPTA))) / 12)

ER_TRPCBPC <- ER_TRPCBPC %>% mutate((((ER_TRBPCDEF$`2020` + ER_TRBPCIDO$`2020`) * 1000) / (filter(Populacao, ANO == 2020) %>%  select("2020" = D_POPTA))) / 12)

ER_TRPCBPC <- ER_TRPCBPC %>% mutate((((ER_TRBPCDEF$`2021` + ER_TRBPCIDO$`2021`) * 1000) / (filter(Populacao, ANO == 2021) %>%  select("2021" = D_POPTA))) / 12)


ER_BPCDEF <- ER_BPCDEF %>% pivot_longer(c("2019", "2020", "2021"), "Ano", values_to = "ER_BPCDEF")

ER_BPCIDO <- ER_BPCIDO %>% pivot_longer(c("2019", "2020", "2021"), "Ano", values_to = "ER_BPCIDO")

ER_TRBPCDEF <- ER_TRBPCDEF %>% pivot_longer(c("2019", "2020", "2021"), "Ano", values_to = "ER_TRBPCDEF")

ER_TRBPCIDO <- ER_TRBPCIDO %>% pivot_longer(c("2019", "2020", "2021"), "Ano", values_to = "ER_TRBPCIDO")

ER_TRPCBPC <- ER_TRPCBPC %>% pivot_longer(c("2019", "2020", "2021"), "Ano", values_to = "ER_TRPCBPC")


ER_BFBPC <- ER_BPCDEF$ER_BPCDEF + ER_BPCIDO$ER_BPCIDO

ER_TRBPC <- ER_TRBPCDEF$ER_TRBPCDEF + ER_TRBPCIDO$ER_TRBPCIDO

ER_TRBPCPB <- ((ER_TRBPC*1000)/ER_BFBPC)/12


# Calcula indicadores conjuntos dos programas de transferência de renda:

ER_TRBFBPC <- ER_TRFAM$ER_TRFAM + ER_TRBPC

ER_TRPC <- ((ER_TRBFBPC * 1000) / Populacao$D_POPTA) / 12


# Monta planilha com os indicadores do IMRS de 2019:

IMRS_emprego_renda <- IMRS_emprego_renda %>% mutate(ER_BFFAM = round(ER_BFFAM$ER_BFFAM, 0),
                                                    ER_TRFAM = round(ER_TRFAM$ER_TRFAM, 2),
                                                    ER_TRPF = round(ER_TRPF, 2),
                                                    ER_BPCDEF = round(ER_BPCDEF$ER_BPCDEF, 0),
                                                    ER_BPCIDO = round(ER_BPCIDO$ER_BPCIDO, 0),
                                                    ER_BFBPC = round(ER_BFBPC, 0),
                                                    ER_TRBPCDEF = round(ER_TRBPCDEF$ER_TRBPCDEF, 2),
                                                    ER_TRBPCIDO = round(ER_TRBPCIDO$ER_TRBPCIDO, 2),
                                                    ER_TRBPC = round(ER_TRBPC, 2),
                                                    ER_TRBPCPB = round(ER_TRBPCPB, 2),
                                                    ER_TRBFBPC = round(ER_TRBFBPC, 2),
                                                    ER_TRPC = round(ER_TRPC, 2),
                                                    ER_TRPCBF = round(ER_TRPCBF$ER_TRPCBF, 2),
                                                    ER_TRPCBPC = round(ER_TRPCBPC$ER_TRPCBPC, 2),
                                                    .after = ANO)


# Exclui objetos que não serão mais necessários: 

rm(AuxilioBrasil, AuxilioEmergencial, BF_2019, BF_AuxEm_2020, BF_AuxBr_2021, BolsaFamilia, BPC_Idosos, BPC_Idosos_valores, BPC_PCD, BPC_PCD_valores, ER_BFFAM, ER_BPCDEF, ER_BPCIDO, ER_TRBPCDEF, ER_TRBPCIDO, ER_TRFAM, ER_TRPCBF, ER_TRPCBPC, ER_BFBPC, ER_TRBFBPC, ER_TRBPC, ER_TRBPCPB, ER_TRPC, ER_TRPF)
```

## **5) Importação dos dados e cálculo dos indicadores relacionados à produção municipal:**

Por fim, são importados os dados referentes ao valor adicionado e ao
Produto Interno Bruto (PIB) dos municípios mineiros. Essas informações
são extraídas de duas fontes: a primeira, o arquivo intitulado *PIB dos
Municípios - base de dados 2010-2019.xls*, baixado da página do IBGE
(<https://www.ibge.gov.br/estatisticas/economicas/contas-nacionais/9088-produto-interno-bruto-dos-municipios.html?=&t=resultados>)
e que contém o PIB e o valor adicionado por setor produtivo de todos os
municípios brasileiros desde 2010; a segunda é composta por duas
planilhas internas da FJP intituladas *VERSÃO OFICIAL 08-09-2020 VAF
ANO-BASE 2019 CONSOL POR MUNICIPIO E CNAE PARA FUNDAÇÃO JOÃO
PINHEIRO.xlsx* e *VERSÃO 28-09-2022 OFICIAL RETIFICADA - VAF ANO-BASE
2020 CONSOL POR MUNICIPIO E CNAE PARA FUNDAÇÃO JOÃO PINHEIRO (após a
correção).xlsx*, que contêm o Valor Adicionado Fiscal (VAF) total
(coluna *VAF TOTAL*) dos anos de 2019 e 2020, respectivamente (os dados
para 2021 ainda não estão disponíveis no momento da elaboração deste
script).

Adicionalmente, será utilizado um terceiro arquivo, chamado *VAF
2019.xlsx*, de cuja planilha *cod munic* serão importados os nomes e
respectivos códigos dos municípios mineiros, uma vez que a planilha do
VAF não indica tais códigos e a planilha do PIB, apesar de indicá-los,
apresenta grafias diferentes para determinadas cidades (e o mesmo ocorre
com as planilhas extraídas da RAIS), a exemplo dos municípios de Dona
Euzébia (ora escrito com “s” ou sem acento), São Tomé das Letras (ora
escrito com “h” em Tomé) e Passa Vinte (ora escrito com hífen).

Com base nesses dados são calculados trinta e três indicadores, da
seguinte forma:

1)  **ER_VAAGR**: valor Adicionado - agropecuária (em mil reais
    correntes) – corresponde ao valor indicado na coluna “Valor
    adicionado bruto da Agropecuária, a preços correntes (R\$ 1.000)” da
    planilha *PIB dos municípios* publicada pelo IBGE.

2)  **ER_VAIND**: valor Adicionado - indústria (em mil reais correntes)
    – corresponde ao valor indicado na coluna “Valor adicionado bruto da
    Indústria, a preços correntes (R\$ 1.000)” da planilha *PIB dos
    municípios* publicada pelo IBGE.

3)  **ER_VAADM**: valor Adicionado - administração pública (em mil reais
    correntes) – corresponde ao valor indicado na coluna “Valor
    adicionado bruto da Administração, defesa, educação e saúde públicas
    e seguridade social, a preços correntes (R\$ 1.000)” da planilha
    *PIB dos municípios* publicada pelo IBGE.

4)  **ER_VASERV**: valor Adicionado - serviços (em mil reais correntes)
    – corresponde ao valor indicado na coluna “Valor adicionado bruto
    dos Serviços, a preços correntes - exceto Administração, defesa,
    educação e saúde públicas e seguridade social (R\$ 1.000)” da
    planilha *PIB dos municípios* publicada pelo IBGE.

5)  **ER_PVAAGR**: participação da agropecuária no Valor Adicionado (em
    percentual) – corresponde à divisão da variável *ER_VAAGR* pela
    variável *ERVATOT*, multiplicada por 100.

6)  **ER_PVAIND**: participação da indústria no Valor Adicionado (em
    percentual) – corresponde à divisão da variável *ER_VAIND* pela
    variável *ERVATOT*, multiplicada por 100.

7)  **ER_PVAADM**: participação da administração pública no Valor
    Adicionado (em percentual) – corresponde à divisão da variável
    *ER_VAADM* pela variável *ERVATOT*, multiplicada por 100.

8)  **ER_PVASERV**: participação dos serviços no Valor Adicionado (em
    percentual) – corresponde à divisão da variável *ER_VASERV* pela
    variável *ERVATOT*, multiplicada por cem.

9)  **ER_VATOT**: valor Adicionado - total (mil reais correntes) –
    corresponde à soma das variáveis *ERVAAGR*, *ER_VAIND* e
    *ER_VASERV*.

10) **ER_IMPLIQ**: impostos líquidos (mil reais correntes) – corresponde
    à diferença entre as variáveis *ER_PIB* e *ER_VATOT*.

11) **ER_PIB**: Produto Interno Bruto (mil reais correntes) –
    corresponde ao valor indicado na coluna “Produto Interno Bruto, a
    preços correntes (R\$ 1.000)” da planilha *PIB dos municípios*
    publicada pelo IBGE.

12) **ER_PIBPC**: Produto Interno Bruto per capita (em reais correntes
    por habitante)– corresponde à divisão da variável *ER_PIB* pela
    população do município, multiplicado por mil.

13) **ER_VAF**: Valor Adicionado Fiscal (VAF) total do município (mil
    reais correntes) – corresponde à soma de todos os valores indicados
    para cada município na coluna “VAF TOTAL” da planilha *VERSÃO
    OFICIAL 08-09-2020 VAF ANO-BASE 2019 CONSOL POR MUNICIPIO E CNAE
    PARA FUNDAÇÃO JOÃO PINHEIRO.xlsx*.

14) **ER_VAFAG**: Valor Adicionado Fiscal (VAF) das atividades primárias
    (mil reais correntes) – soma de todo o valor adicionado nas
    atividades agropecuárias (as que iniciam com os códigos 01 a 03 da
    Classificação Nacional de Atividades Econômicas - CNAE) do
    município, dividida por mil.

15) **ER_VAFMI**: Valor Adicionado Fiscal (VAF) da extrativa mineral
    (mil reais correntes) – soma de todo o valor adicionado nas
    atividades de extração mineral (as que iniciam com os códigos 05 a
    09 da Classificação Nacional de Atividades Econômicas - CNAE) do
    município, dividida por mil.

16) **ER_VAFIT**: Valor Adicionado Fiscal (VAF) da indústria de
    transformação (mil reais correntes) – soma de todo o valor
    adicionado nas atividades da indústria de transformação (as que
    iniciam com os códigos 10 a 33 da Classificação Nacional de
    Atividades Econômicas - CNAE) do município, dividida por mil.

17) **ER_VAFIC**: Valor Adicionado Fiscal (VAF) da indústria da
    construção (mil reais correntes) – soma de todo o valor adicionado
    nas atividades da indústria da construção (as que iniciam com os
    códigos 41 a 43 da Classificação Nacional de Atividades Econômicas -
    CNAE) do município, dividida por mil.

18) **ER_VAFUP**: Valor Adicionado Fiscal (VAF) dos serviços industriais
    de utilidade pública (mil reais correntes) – soma de todo o valor
    adicionado nas atividades dos serviços industriais de utilidade
    pública (as que iniciam com os códigos 35 a 39 da Classificação
    Nacional de Atividades Econômicas - CNAE) do município, dividida por
    mil.

19) **ER_VAFCV**: Valor Adicionado Fiscal (VAF) do comércio varejista
    (mil reais correntes) – soma de todo o valor adicionado nas
    atividades do comércio varejista (as que iniciam com o código 47 ou
    correspondem aos códigos 4511101, 4511102, 4530703 a 4530705 ou
    4541203 a 4541207 da Classificação Nacional de Atividades
    Econômicas - CNAE) do município, dividida por mil.

20) **ER_VAFCA**: Valor Adicionado Fiscal (VAF) do comércio atacadista
    (mil reais correntes) – soma de todo o valor adicionado nas
    atividades do comércio atacadista (as que iniciam com o código 46 ou
    correspondem aos códigos 4511103 a 4511106, 4512901, 4512902,
    4530701, 4530702, 4530706, 4541201, 4541202, 4542101 ou 4542102 da
    Classificação Nacional de Atividades Econômicas - CNAE) do
    município, dividida por mil.

21) **ER_VAFSE**: Valor Adicionado Fiscal (VAF) dos serviços (mil reais
    correntes) – soma de todo o valor adicionado nas atividades do setor
    de serviços (as que iniciam com os códigos 49 a 69, 71 a 97 ou
    correspondem aos códigos 7020400, 4543900 ou 4520001 a 4520008 da
    Classificação Nacional de Atividades Econômicas - CNAE) do
    município, dividida por mil.

22) **ER_VAFO**: Valor Adicionado Fiscal (VAF) de outros setores (mil
    reais correntes) – soma de todo o valor adicionado nas atividades de
    outros setores (as que correspondem aos códigos 99 ou 0 da
    Classificação Nacional de Atividades Econômicas - CNAE) do
    município, dividida por mil.

23) **ER_PVAFAG**: participação das atividades primárias no VAF (em
    percentual) – divisão do indicador **ER_VAFAG** pelo indicador
    **ER_VAF**, multiplicada por cem.

24) **ER_PVAFMI**: participação da extrativa mineral no VAF (em
    percentual) – divisão do indicador **ER_VAFMI** pelo indicador
    **ER_VAF**, multiplicada por cem.

25) **ER_PVAFIT**: participação da indústria de transformação no VAF (em
    percentual) – divisão do indicador **ER_VAFIT** pelo indicador
    **ER_VAF**, multiplicada por cem.

26) **ER_PVAFIC**: participação da indústria da construção no VAF (em
    percentual) – divisão do indicador **ER_VAFIC** pelo indicador
    **ER_VAF**, multiplicada por cem.

27) **ER_PVAFUP**: participação dos serviços industriais de utilidade
    pública no VAF (em percentual) – divisão do indicador **ER_VAFUP**
    pelo indicador **ER_VAF**, multiplicada por cem.

28) **ER_PVAFCV**: participação do comércio varejista no VAF (em
    percentual) – divisão do indicador **ER_VAFCV** pelo indicador
    **ER_VAF**, multiplicada por cem.

29) **ER_PVAFCA**: participação do comércio atacadista no VAF (em
    percentual) – divisão do indicador **ER_VAFCA** pelo indicador
    **ER_VAF**, multiplicada por cem.

30) **ER_PVAFSE**: participação dos serviços no VAF (em percentual) –
    divisão do indicador **ER_VAFSE** pelo indicador **ER_VAF**,
    multiplicada por cem.

31) **ER_PVAFO**: participação dos outros setores no VAF (em percentual)
    – divisão do indicador **ER_VAFO** pelo indicador **ER_VAF**,
    multiplicada por cem.

32) **ER_VAFPC**: VAF per capita (em reais correntes / habitante) –
    divisão da variável **ER_VAF** pelo número de habitantes do
    município, multiplicada por mil.

33) **ER_VAFCVPC**: VAF per capita do comércio varejista (em reais
    correntes / habitante) – divisão da variável **ER_VAFCV** pelo
    número de habitantes do município, multiplicada por mil.

Uma observação importante sobre os indicadores calculados com os dados
do VAF é que tais dados são organizados e publicados segundo o código de
cada atividade ou grupo de atividades econômicas na CNAE. No entanto,
tais códigos sofrem revisões com certa frequência por parte da Comissão
Nacional de Classificação (CONCLA), responsável pela elaboração e
divulgação da CNAE. Portanto, é importante estar atento a alterações na
classificação e nos códigos das atividades para que dados da produção
não sejam ignorados quando do cálculo dos indicadores, bem como para que
os indicadores passados sejam recalculados com as novas classificações
antes de serem comparados com indicadores atuais.

``` r
# Importa os dados do Valor Adicionado Fiscal (VAF) de 2019:

VAF <- as_tibble(read_xlsx("VERSÃO OFICIAL 08-09-2020  VAF ANO-BASE 2019 CONSOL POR MUNICIPIO E CNAE PARA FUNDAÇÃO JOÃO PINHEIRO.xlsx", skip = 1, col_names = TRUE))

Cod_Municipio <- as_tibble(read_xlsx("VAF 2019.xlsx", sheet = "cod munic", col_names = TRUE))

VAF <- VAF[-c(length(VAF$MUNICIPIO)),] # Exclui última linha (total)

VAF <- cbind("Código do município" = array(data = NA, dim = length(VAF$MUNICIPIO)), VAF) # Cria coluna para armazenar cod. dos municípios

i2 <- 1 # Índice para loop

for (i in 1:length(VAF$MUNICIPIO)){ # Loop para atribuir código dos municípios na planilha do VAF
  
  if (VAF$MUNICIPIO[i] == Cod_Municipio$MUNICÍPIOS[i2]) {
    VAF$`Código do município`[i] <- Cod_Municipio$COD[i2]
  } else {
    i2 <- i2 + 1
    VAF$`Código do município`[i] <- Cod_Municipio$COD[i2]
  }
}

VAF <- VAF %>% arrange(`Código do município`) # Reordena as observações da base segundo o código do município

rm(i, i2)


# Importa dados do produto interno bruto (PIB) e valor adicionado (VA) de 2019:

PIB <- as_tibble(read_xls("PIB dos Municípios - base de dados 2010-2020.xls", col_names = TRUE))

PIB <- filter(PIB, `Sigla da Unidade da Federação` == "MG", Ano == "2019") %>%  select(`Código do Município`, `Valor adicionado bruto da Agropecuária, 
a preços correntes
(R$ 1.000)`, `Valor adicionado bruto da Indústria,
a preços correntes
(R$ 1.000)`, `Valor adicionado bruto da Administração, defesa, educação e saúde públicas e seguridade social, 
a preços correntes
(R$ 1.000)`, `Valor adicionado bruto dos Serviços,
a preços correntes 
- exceto Administração, defesa, educação e saúde públicas e seguridade social
(R$ 1.000)`, `Produto Interno Bruto, 
a preços correntes
(R$ 1.000)`)


# Calcula os indicadores do VAF e do PIB em 2019:

ER_VAAGR <- round(PIB$`Valor adicionado bruto da Agropecuária, 
a preços correntes
(R$ 1.000)`, 2)
  
ER_VAIND <- round(PIB$`Valor adicionado bruto da Indústria,
a preços correntes
(R$ 1.000)`, 2)
  
ER_VAADM <- round(PIB$`Valor adicionado bruto da Administração, defesa, educação e saúde públicas e seguridade social, 
a preços correntes
(R$ 1.000)`, 2)
  
ER_VASERV <- round(PIB$`Valor adicionado bruto dos Serviços,
a preços correntes 
- exceto Administração, defesa, educação e saúde públicas e seguridade social
(R$ 1.000)`, 2)
  
ER_PVAAGR <- round(ER_VAAGR/(ER_VAAGR + ER_VAIND + ER_VASERV) * 100, 2)

ER_PVAIND <- round(ER_VAIND/(ER_VAAGR + ER_VAIND + ER_VASERV) * 100, 2)
  
ER_PVAADM <- round(ER_VAADM/(ER_VAAGR + ER_VAIND + ER_VASERV) * 100, 2)
  
ER_PVASERV <- round(ER_VASERV/(ER_VAAGR + ER_VAIND + ER_VASERV) * 100, 2)
  
ER_VATOT <- round(ER_VAAGR + ER_VAIND + ER_VAADM + ER_VASERV, 2)
  
ER_IMPLIQ <- round(PIB$`Produto Interno Bruto, 
a preços correntes
(R$ 1.000)` - ER_VATOT, 2)
  
ER_PIB <- round(PIB$`Produto Interno Bruto, 
a preços correntes
(R$ 1.000)`, 2)

ER_PIBPC <- round( (ER_PIB / (Populacao %>% filter(ANO == 2019) %>% select(D_POPTA))) * 1000, 2)
  
ER_VAF <- VAF %>% group_by(`Código do município`) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFAG <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter(CNAE > 0 & CNAE < 0400000) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFMI <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter(CNAE >= 0500000 & CNAE < 1000000) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFIT <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter(CNAE >= 1000000 & CNAE < 3400000) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFIC <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter(CNAE >= 4100000 & CNAE < 4400000) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFUP <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter(CNAE >= 3500000 & CNAE < 4000000) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFCV <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter( (CNAE >= 4700000 & CNAE < 4800000) | CNAE == 4511101 | CNAE == 4511102 | (CNAE >= 4530703 & CNAE <= 4530705) | (CNAE >= 4541203 & CNAE <= 4541207)) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFCA <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter( (CNAE >= 4600000 & CNAE < 4700000) | (CNAE >= 4511103 & CNAE <= 4511106) | CNAE == 4512901 | CNAE == 4512902 | CNAE == 4530701 | CNAE == 4530702 | CNAE == 4530706 | CNAE == 4541201 | CNAE == 4541202 | CNAE == 4542101 | CNAE == 4542102) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFSE <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter( (CNAE >= 4900000 & CNAE < 5000000) | (CNAE >= 5011401 & CNAE <= 5022002) | (CNAE >= 5030101 & CNAE <= 5030103) | (CNAE >= 5091201 & CNAE <= 5130700) | (CNAE >= 5211701 & CNAE <= 5212500) | CNAE == 5221400  | CNAE == 5222200 | (CNAE >= 5223100 & CNAE <= 5232000) | (CNAE >= 5239701 & CNAE <= 5240199) | (CNAE >= 5250801 & CNAE <= 5250805) | (CNAE >= 5300000 & CNAE < 9800000) | (CNAE >= 4520001 & CNAE <= 4520008) | CNAE == 4543900) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFO <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter( (CNAE >= 9900000 & CNAE < 10000000) | CNAE == 0) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_PVAFAG <- round( (ER_VAFAG$Soma/ER_VAF$Soma) * 100, 2)

ER_PVAFMI <- round( (ER_VAFMI$Soma/ER_VAF$Soma) * 100, 2)

ER_PVAFIT <- round( (ER_VAFIT$Soma/ER_VAF$Soma) * 100, 2)

ER_PVAFIC <- round( (ER_VAFIC$Soma/ER_VAF$Soma) * 100, 2)

ER_PVAFUP <- round( (ER_VAFUP$Soma/ER_VAF$Soma) * 100, 2)

ER_PVAFCV <- round( (ER_VAFCV$Soma/ER_VAF$Soma) * 100, 2)

ER_PVAFCA <- round( (ER_VAFCA$Soma/ER_VAF$Soma) * 100, 2)

ER_PVAFSE <- round( (ER_VAFSE$Soma/ER_VAF$Soma) * 100, 2)

ER_PVAFO <- round( (ER_VAFO$Soma/ER_VAF$Soma) * 100, 2)

ER_VAFPC <- round( (ER_VAF$Soma / Populacao %>% filter(ANO == 2019) %>% select(D_POPTA)) * 1000, 2)
  
ER_VAFCVPC <- round( (ER_VAFCV$Soma / Populacao %>% filter(ANO == 2019) %>% select(D_POPTA)) * 1000, 2)


# Salva indicadores do VAF de 2019:

VAF_2019 <- data.frame(IBGE6 = sort(Cod_Municipio$COD),
                       ANO = "2019",
                       ER_VAAGR,
                       ER_VAIND,
                       ER_VAADM,
                       ER_VASERV,
                       ER_PVAAGR,
                       ER_PVAIND,
                       ER_PVAADM,
                       ER_PVASERV,
                       ER_VATOT,
                       ER_IMPLIQ,
                       ER_PIB,
                       ER_PIBPC = ER_PIBPC$D_POPTA,
                       ER_VAF = ER_VAF$Soma,
                       ER_VAFAG = ER_VAFAG$Soma,
                       ER_VAFMI = ER_VAFMI$Soma,
                       ER_VAFIT = ER_VAFIT$Soma,
                       ER_VAFIC = ER_VAFIC$Soma,
                       ER_VAFUP = ER_VAFUP$Soma,
                       ER_VAFCV = ER_VAFCV$Soma,
                       ER_VAFCA = ER_VAFCA$Soma,
                       ER_VAFSE = ER_VAFSE$Soma,
                       ER_VAFO = ER_VAFO$Soma,
                       ER_PVAFAG,
                       ER_PVAFMI,
                       ER_PVAFIT,
                       ER_PVAFIC,
                       ER_PVAFUP, 
                       ER_PVAFCV, 
                       ER_PVAFCA,
                       ER_PVAFSE, 
                       ER_PVAFO, 
                       ER_VAFPC = ER_VAFPC$D_POPTA, 
                       ER_VAFCVPC = ER_VAFCVPC$D_POPTA)


# Importa os dados do VAF para 2020:

VAF <- as_tibble(read_xlsx("VERSÃO 28-09-2022 OFICIAL RETIFICADA - VAF ANO-BASE 2020 CONSOL POR MUNICIPIO E CNAE PARA FUNDAÇÃO JOÃO PINHEIRO (após a correção).xlsx", skip = 1, col_names = TRUE))

VAF <- VAF[-c(length(VAF$MUNICIPIO)),] # Exclui última linha (total)

VAF <- cbind("Código do município" = array(data = NA, dim = length(VAF$MUNICIPIO)), VAF) # Cria coluna para armazenar cod. dos municípios

i2 <- 1 # Índice para loop

for (i in 1:length(VAF$MUNICIPIO)){ # Loop para atribuir código dos municípios na planilha do VAF
  
  if (VAF$MUNICIPIO[i] == Cod_Municipio$MUNICÍPIOS[i2]) {
    VAF$`Código do município`[i] <- Cod_Municipio$COD[i2]
  } else {
    i2 <- i2 + 1
    VAF$`Código do município`[i] <- Cod_Municipio$COD[i2]
  }
}

rm(i, i2)

VAF <- VAF %>% arrange(`Código do município`) # Ordena as observações segundo o código do município


# Importa dados do produto interno bruto (PIB) e valor adicionado (VA) de 2020:

PIB <- as_tibble(read_xls("PIB dos Municípios - base de dados 2010-2020.xls", col_names = TRUE))

PIB <- filter(PIB, `Sigla da Unidade da Federação` == "MG", Ano == "2020") %>%  select(`Código do Município`, `Valor adicionado bruto da Agropecuária, 
a preços correntes
(R$ 1.000)`, `Valor adicionado bruto da Indústria,
a preços correntes
(R$ 1.000)`, `Valor adicionado bruto da Administração, defesa, educação e saúde públicas e seguridade social, 
a preços correntes
(R$ 1.000)`, `Valor adicionado bruto dos Serviços,
a preços correntes 
- exceto Administração, defesa, educação e saúde públicas e seguridade social
(R$ 1.000)`, `Produto Interno Bruto, 
a preços correntes
(R$ 1.000)`)


# Calcula os indicadores do VAF para 2020:

ER_VAAGR <- round(PIB$`Valor adicionado bruto da Agropecuária, 
a preços correntes
(R$ 1.000)`, 2)
  
ER_VAIND <- round(PIB$`Valor adicionado bruto da Indústria,
a preços correntes
(R$ 1.000)`, 2)
  
ER_VAADM <- round(PIB$`Valor adicionado bruto da Administração, defesa, educação e saúde públicas e seguridade social, 
a preços correntes
(R$ 1.000)`, 2)
  
ER_VASERV <- round(PIB$`Valor adicionado bruto dos Serviços,
a preços correntes 
- exceto Administração, defesa, educação e saúde públicas e seguridade social
(R$ 1.000)` , 2)

ER_PVAAGR <- round(ER_VAAGR/(ER_VAAGR + ER_VAIND + ER_VASERV) * 100, 2)

ER_PVAIND <- round(ER_VAIND/(ER_VAAGR + ER_VAIND + ER_VASERV) * 100, 2)
  
ER_PVAADM <- round(ER_VAADM/(ER_VAAGR + ER_VAIND + ER_VASERV) * 100, 2)
  
ER_PVASERV <- round(ER_VASERV/(ER_VAAGR + ER_VAIND + ER_VASERV) * 100, 2)
  
ER_VATOT <- round(ER_VAAGR + ER_VAIND + ER_VAADM + ER_VASERV, 2)
  
ER_IMPLIQ <- round(PIB$`Produto Interno Bruto, 
a preços correntes
(R$ 1.000)` - ER_VATOT, 2)
  
ER_PIB <- round(PIB$`Produto Interno Bruto, 
a preços correntes
(R$ 1.000)`, 2)

ER_PIBPC <- round( (ER_PIB / (Populacao %>% filter(ANO == 2020) %>% select(D_POPTA))) * 1000, 2)

ER_VAF <- VAF %>% group_by(`Código do município`) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFAG <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter(CNAE > 0 & CNAE < 0400000) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFMI <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter(CNAE >= 0500000 & CNAE < 1000000) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFIT <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter(CNAE >= 1000000 & CNAE < 3400000) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFIC <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter(CNAE >= 4100000 & CNAE < 4400000) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFUP <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter(CNAE >= 3500000 & CNAE < 4000000) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFCV <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter( (CNAE >= 4700000 & CNAE < 4800000) | CNAE == 4511101 | CNAE == 4511102 | (CNAE >= 4530703 & CNAE <= 4530705) | (CNAE >= 4541203 & CNAE <= 4541207)) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFCA <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter( (CNAE >= 4600000 & CNAE < 4700000) | (CNAE >= 4511103 & CNAE <= 4511106) | CNAE == 4512901 | CNAE == 4512902 | CNAE == 4530701 | CNAE == 4530702 | CNAE == 4530706 | CNAE == 4541201 | CNAE == 4541202 | CNAE == 4542101 | CNAE == 4542102) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFSE <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter( (CNAE >= 4900000 & CNAE < 5000000) | (CNAE >= 5011401 & CNAE <= 5022002) | (CNAE >= 5030101 & CNAE <= 5030103) | (CNAE >= 5091201 & CNAE <= 5130700) | (CNAE >= 5211701 & CNAE <= 5212500) | CNAE == 5221400  | CNAE == 5222200 | (CNAE >= 5223100 & CNAE <= 5232000) | (CNAE >= 5239701 & CNAE <= 5240199) | (CNAE >= 5250801 & CNAE <= 5250805) | (CNAE >= 5300000 & CNAE < 9800000) | (CNAE >= 4520001 & CNAE <= 4520008) | CNAE == 4543900) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_VAFO <- VAF %>% group_by(`Código do município`, .drop = FALSE) %>% filter( (CNAE >= 9900000 & CNAE < 10000000) | CNAE == 0) %>% summarise(Soma = sum(`VAF TOTAL`)/1000) %>% round(2)

ER_PVAFAG <- round( (ER_VAFAG$Soma/ER_VAF$Soma) * 100, 2)

ER_PVAFMI <- round( (ER_VAFMI$Soma/ER_VAF$Soma) * 100, 2)

ER_PVAFIT <- round( (ER_VAFIT$Soma/ER_VAF$Soma) * 100, 2)

ER_PVAFIC <- round( (ER_VAFIC$Soma/ER_VAF$Soma) * 100, 2)

ER_PVAFUP <- round( (ER_VAFUP$Soma/ER_VAF$Soma) * 100, 2)

ER_PVAFCV <- round( (ER_VAFCV$Soma/ER_VAF$Soma) * 100, 2)

ER_PVAFCA <- round( (ER_VAFCA$Soma/ER_VAF$Soma) * 100, 2)

ER_PVAFSE <- round( (ER_VAFSE$Soma/ER_VAF$Soma) * 100, 2)

ER_PVAFO <- round( (ER_VAFO$Soma/ER_VAF$Soma) * 100, 2)

ER_VAFPC <- round( (ER_VAF$Soma / Populacao %>% filter(ANO == 2020) %>% select(D_POPTA)) * 1000, 2)
  
ER_VAFCVPC <- round( (ER_VAFCV$Soma / Populacao %>% filter(ANO == 2020) %>% select(D_POPTA)) * 1000, 2)


# Salva indicadores do VAF de 2020:

VAF_2020 <- data.frame(IBGE6 = sort(Cod_Municipio$COD),
                       ANO = "2020",
                       ER_VAAGR,
                       ER_VAIND,
                       ER_VAADM,
                       ER_VASERV,
                       ER_PVAAGR,
                       ER_PVAIND,
                       ER_PVAADM,
                       ER_PVASERV,
                       ER_VATOT,
                       ER_IMPLIQ,
                       ER_PIB,
                       ER_PIBPC = ER_PIBPC$D_POPTA,
                       ER_VAF = ER_VAF$Soma,
                       ER_VAFAG = ER_VAFAG$Soma,
                       ER_VAFMI = ER_VAFMI$Soma,
                       ER_VAFIT = ER_VAFIT$Soma,
                       ER_VAFIC = ER_VAFIC$Soma,
                       ER_VAFUP = ER_VAFUP$Soma,
                       ER_VAFCV = ER_VAFCV$Soma,
                       ER_VAFCA = ER_VAFCA$Soma,
                       ER_VAFSE = ER_VAFSE$Soma,
                       ER_VAFO = ER_VAFO$Soma,
                       ER_PVAFAG,
                       ER_PVAFMI,
                       ER_PVAFIT,
                       ER_PVAFIC,
                       ER_PVAFUP, 
                       ER_PVAFCV, 
                       ER_PVAFCA,
                       ER_PVAFSE, 
                       ER_PVAFO, 
                       ER_VAFPC = ER_VAFPC$D_POPTA, 
                       ER_VAFCVPC = ER_VAFCVPC$D_POPTA)


# Monta base com indicadores do VAF e PIB de 2019 e do VAF de 2020:

VAF_2019a2020 <- bind_rows(VAF_2019, VAF_2020)

VAF_2019a2020 <- VAF_2019a2020[order(VAF_2019a2020$IBGE6),]


# Une a base do VAF com a do IMRS:

IMRS_emprego_renda$IBGE6 <- as.numeric(IMRS_emprego_renda$IBGE6)

VAF_2019a2020$ANO <- as.numeric(VAF_2019a2020$ANO)

IMRS_emprego_renda <- left_join(IMRS_emprego_renda, VAF_2019a2020, by = c("IBGE6", "ANO"))


# Exclui objetos que não serão mais necessários:

rm(ER_IMPLIQ, ER_PIB, ER_PIBPC, ER_PVAADM, ER_PVAAGR, ER_PVAIND, ER_PVASERV, ER_VAADM, ER_VAAGR, ER_VAIND, ER_VASERV, ER_VATOT, ER_VAF, ER_VAFAG, ER_VAFMI, ER_VAFIT, ER_VAFIC, ER_VAFUP, ER_VAFCV, ER_VAFCA, ER_VAFSE, ER_VAFO, ER_VAFPC, ER_VAFCVPC, ER_PVAFAG, ER_PVAFMI, ER_PVAFIT, ER_PVAFIC, ER_PVAFUP, ER_PVAFCV, ER_PVAFCA, ER_PVAFSE, ER_PVAFO, PIB, VAF, VAF_2019, VAF_2020, VAF_2019a2020, Cod_Municipio, Populacao)
```

## **6) Ajustes finais na base e exportação dos indicadores para planilha de formato Excel:**

Calculados os indicadores, os últimos passos deste script são o
reposicionamento, remoção e inserção de algumas colunas (indicadores),
de modo a manter o mesmo padrão das planilhas do IMRS anteriores e, em
seguida, a exportação dos dados para uma planilha de formato Excel
(extensão .xlsx).

``` r
# Reposiciona as colunas, para que os indicadores sejam apresentados na mesma ordem das planilhas anteriores do IMRS:

IMRS_emprego_renda <- IMRS_emprego_renda %>% relocate(c(ER_EMPRSF, ER_EMPRSFTX, ER_RENSF, ER_RENPCSF, ER_EMPRSFAG, ER_EMPRSFMI, ER_EMPRSFIT, ER_EMPRSFUP, ER_EMPRSFIC, ER_EMPRSFCO, ER_EMPRSFSE), .after = ER_VAFCVPC)


# Cria coluna "Chave", composta pelo ano mais o código do município (seis dígitos), e exclui a coluna com o nome dos municípios:

IMRS_emprego_renda <- IMRS_emprego_renda %>% mutate("CHAVE" = paste(ANO, IBGE6, sep = ""), .before = IBGE6)

IMRS_emprego_renda <- IMRS_emprego_renda %>% select(-Município)
```

Por fim, o código abaixo exporta a base para uma planilha de Excel:

``` r
# Exporta planilha com os indicadores de 2019 a 2021 para arquivo em Excel:

write_xlsx(IMRS_emprego_renda, path = "IMRS_ER_2022_output.xlsx", col_names = TRUE, format_headers = TRUE)
```
