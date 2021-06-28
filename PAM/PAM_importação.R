          #================== Produção Agrícola Municipal ===================#

# APRESENTAÇÂO: Script para análise dos dados da PAM, recolhidos através do SIDRA
# ATENÇÃO!! este script não é exatamente uma rotina, embora possa ser executado como uma

# ORIENTAÇÕES:
#...baixar os arquivos csv no site do SIDRA
#...no início da página do SIDRA, ajustar o layout com uma coluna por variável 
#...ordenar as colunas: "Produto (...)" e "Valor" como as colunas 5ª e 6ª, respectivamente
#...armazene os arquivos dos dados a serem importados no diretório de trabalho

#=================================== INTRODUÇÃO =========================================#
# Pacotes utilizados----------------------------------------------------
pacotes <- c("tidyverse", "sidrar", "data.table", "openxlsx", "curl")
#install.packages(pacotes) #opcionalmente instalar o plotly
lapply(pacotes, library, character.only = TRUE)

# IMPORTAR TABELAS
## 1 AGREGADO - MG
## 2 AGREGADO - UF's
## 3 DESAGREGADO - MG
## 4 AGREGADO - Regiões Intermediárias
## 5 DESAGREGADO - BR (opcional; necessário "descomentar")

# ================================== IMPORTAR TABELAS =================================#
# 1 AGREGADO - MG-----------------------------------------------
## requisitos: pacotes utilizados

## importar tabela do sidra
MG_agr<- get_sidra(
  5457,
  variable = c(112,214,215,216),
  period = c("last" = 17),
  geo = "State",
  geo.filter = list("State" = 31),
  classific = "c782",
  #category = "allxt",
  header = TRUE,
  format = 2
)
## renomear a coluna de categorias, facilitando filtros
names(MG_agr)[[5]] <- "Produto"

## adicionar uma coluna "Rank" que será útil mais a frente
MG_agr <-  MG_agr %>%
  group_by(Variável, Ano) %>%
  mutate(
    "Valorxt" = ifelse(Produto != 'Total', Valor, as.numeric(NA)),
    "Rank" = frank(desc(Valorxt), na.last = "keep")
)
# 2 AGREGADO - UF's---------------------------------------------------------------
## requisitos: pacotes utilizados

## primeiro é preciso baixar as tabelas no SIDRA diretamente do R
### ATENÇÃO: esse arquivo só precisa ser baixado uma vez!!
curl_download(
  url = "https://sidra.ibge.gov.br/geratabela?format=br.csv&name=tabela5457.csv&terr=NC&rank=-&query=t/5457/n3/all/v/112,214,215,216/p/last%2017/c782/all/l/,,t%2Bp%2Bv%2Bc782",
  destfile = "t5457_UF.csv"   
)
## então gerar a tabela a partir do arquivo csv baixado
UF_agr <- read.csv2("t5457_UF.csv", skip = 1, na.strings = c("-","..","..."))

## renomear coluna de Valor
colnames(UF_agr)[[6]] <- "Valor"

## renomear a coluna dos Produtos
colnames(UF_agr)[[5]] <- "Produto"

## criar coluna de ranks
#UF_agr <- UF_agr %>%
#  group_by(Ano, Variável, `Unidade da Federação`)%>%
#  mutate(
#    "Valorxt" = ifelse(Produto != 'Total', Valor, as.numeric(NA)),
#    "Rank" = rank(desc(Valorxt), na.last = "keep")
#)
### Obs: não é possível importar tabelas para as Regioões Intermediárias diretamente...
### ... antes vamos ter que importar os dados desagrados

# 3 DESAGREGADO - MG --------------------------------------------------------------
## requisitos: 3 DESAGREGADO - BR OU arquivo csv + pacotes utilizados
## podemos importar diretamente os dados ou filtrar os dados para o Brasil

# 3.1 Importando arquivo csv ........................................................
MG_mun <- bind_rows(
  read.csv2("MG_mun1.csv", 
            skip = 1, 
            nrows = 2088144, 
            na.strings = c("..","...","-")),
  read.csv2("MG_mun2.csv", 
            skip = 1, 
            nrows = 2088144, 
            na.strings = c("..","...","-"))
) 
## renomear a coluna de valores
colnames(MG_mun)[[6]] <- "Valor"

## renomear a coluna de produtos
colnames(MG_mun)[[5]] <- "Produto"

## criar coluna com Ranks
#MG_mun <-  MG_mun %>%
#  group_by(Variável, Ano, Município) %>%
#  mutate(
#    "Valorxt" = ifelse(Produto != 'Total', Valor, as.numeric(NA)),
#    "Rank" = frank(desc(Valorxt), na.last = "keep")
#)

# Criar coluna com as RegInts
## importar os dados para uma tabela
geo_cod <- read.xlsx("regints")

## criar as coluna 
MG_mun <- MG_mun %>%
  mutate(
    "RegInt" = geo_cod$nome_rgint[match(MG_mun$Cód.,
                                        geo_cod$CD_GEOCODI)],
    "Cód.RegInt" = geo_cod$cod_rgint[match(MG_mun$Cód.,
                                        geo_cod$CD_GEOCODI)]
  )
## realocar as colunas criadas para o começo da tabela
MG_mun <- MG_mun %>%
  relocate(
    "Cód.RegInt", "RegInt", 
    .after = Município
)
# 4 AGREGADO (!) - Regiões Intermediárias (MG e BR) -------------------------------
## requisitos: 3 DESAGREGADO - BR OU 3 DESAGREGADO - MG + pacotes utilizados 

## vamos gerar uma tabela para as RegInt's de MG; para realizar o mesmo processo...
##...para o Brasil, basta substituir MG_mun por BR_mun EM TODAS AS PRÓXIMAS LINHAS
### OBS: as outras tabelas já fornecem dados desagregados filtráveis por RegInt

regint_agr <- MG_mun %>%
  group_by(Ano, Cód.RegInt, RegInt, Variável, Produto) %>%
  summarise("Valor" = sum(Valor, na.rm = TRUE))

### criar coluna de ranks
#regint_agr <- regint_agr %>%
#  mutate("Rank" = frank(desc(Valor), na.last = "keep")) 
#
# 5 DESAGREGADO - BR ----------------------------------------------------------------
## requisitos: pacotes utilizados

## os dados desagregados para todos os municípios do Brasil são muitos, não ...
##...sendo possível importar todos de uma vez. É necessário baixar manualmente...
##...e então acessar os arquivos na memória do computador. A melhor forma que...
##...encontramos foi baixar um arquvo csv por ano, entre 2002 e 2008.

# 5.1 Importando as tabelas em uma lista ....................................
## primeiro criar um vetor com os nomes das tabelas
#nomes <- paste0("tab", "_", "5457", "_", 2002:2018) # ex: "tab_5457_2012"

## criar uma lista que vamos preencher com as 17 tabelas importadas utilizando...
##...as função read.csv2 em combinação com a função for
#tabelas <- vector("list", 17)
##for (i in 1:17) {
#  tabelas[[i]] <- read.csv2(file = paste0(nomes[[i]], ".csv"),
#                            skip = 1,                          # pular linhas com as descrições das tabelas
#                            nrows = 1602144,                    # não ler as notas
#                            na.strings = c("-","..","..."))    # NA's; ver notas no final da página: https://sidra.ibge.gov.br/tabela/5457
#  
#}
## vamos nomear os itens da lista com os nomes das tabelas
#names(tabelas) <- nomes

# 5.2 Formatando a tabela .................................................
## criar uma tabela única com todos os dados de município (BR)
#BR_mun <- bind_rows(
#  tabelas
#)
### renomear a coluna de valores
#colnames(BR_mun)[[6]] <- "Valor"
#
### renomear a coluna de produtos
#colnames(BR_mun)[[5]] <- "Produto"
#
## Criar colunas algumas colunas que serão úteis
### primeiro baixar arquivo csv com os municípios por regint 
#curl_download(
#  url = "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/divisao_regional/divisao_regional_do_brasil/divisao_regional_do_brasil_em_geo_cod_2017/tabelas/geo_cod_composicao_por_municipios_2017_20180911.xlsx",
#  destfile = "regints"
#)
### importar os dados para uma tabela
#geo_cod <- read.xlsx("regints")
#
### criar as coluna com a função mutate
#BR_mun <- BR_mun %>%
#  mutate(
#    "UF" = str_sub(BR_mun$Município,-5.-2),            # extrair a penúltima (-2) e a antepenúltima (-5. letras; ex: Cabixi (RO) --> RO
#    "RegInt" = geo_cod$nome_rgint[match(BR_mun$Cód.,
#                                        geo_cod$CD_GEOCODI)],
#    "Cód.RegInt" = geo_cod$cod_rgint[match(BR_mun$Cód.,
#                                           geo_cod$CD_GEOCODI)]
#  )
### realocar as colunas criadas para o começo da tabela
#BR_mun <- BR_mun %>%
#  relocate(
#    "Cód.RegInt", "RegInt", "UF",
#    .after = Município
#)
### criar coluna de ranks
#BR_mun <- BR_mun %>%
#  group_by(Variável, Ano, Município)
#  mutate("Rank" = frank(desc(Valor), na.last = "keep")) 

                       ##===================== FIM ===========================##
### OBSERVAÇÃO: utilize o script "PAM_visualização" para gerar gráficos