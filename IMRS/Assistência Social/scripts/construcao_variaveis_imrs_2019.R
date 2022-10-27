# Informação Geral --------------------------------------------------------

# Script de atualização automática das informações do IMRS da área de Assistência Social
# Alexandre Freitas
# Email: alexandre.freitas@fjp.mg.gov.br
# Data de construção: Julho e agosto de 2021.

# Ler bibliotecas ---------------------------------------------------------

library(tidyverse)
library(openxlsx)
library(readxl)
library(abjutils)
library(data.table)
library(deflateBR)

# CRAS, CREAS, CONSELHO E GESTÃO

# Ler base de dados -------------------------------------------------------
rm(list=ls())

## Populacao 2019
pop_2019 <- read_xlsx('data/IMRS/IMRS-População 2000 a 2019.xlsx') %>%
  filter(ANO == 2019)

## CRAS
cras_rh <- read.xlsx("data/2019/CRAS/Censo_SUAS_2019_CRAS_RH_divulgacao.xlsx") %>%
  filter(str_sub(IBGE7, 1, 2) == "31")

cras_geral <- read_xls("data/2019/CRAS/Censo_SUAS_2019_dados_gerais_RH_CRAS_divulgacao.xls") %>%
  left_join(unique(cras_rh[, c("IBGE","IBGE7")]), by = "IBGE") %>%
  filter(!is.na(IBGE7))

## CREAS
creas_geral <-  read_csv2("data/2019/CREAS/Censo_SUAS_2019_CREAS_Dados_Gerais_divulgacao.csv") %>%
  filter(str_sub(IBGE7, 1, 2) == "31")

creas_rh <- read.xlsx("data/2019/CREAS/Censo_SUAS_2019_RH_CREAS_divulgacao.xlsx") %>%
  filter(str_sub(IBGE7, 1, 2) == "31")

## Gestao Municipal
gestao_mun_geral <- read_csv2("data/2019/gestao_municipal/Censo_SUAS_2019_Gestao_Municipal_dados_gerais_divulgacao.csv") %>%
  filter(str_sub(IBGE7, 1, 2) == "31")

gestao_mun_rh <- read.xlsx("data/2019/gestao_municipal/Censo_SUAS_2019_Gestao_Municipal_RH_divulgacao.xlsx") %>%
  filter(str_sub(IBGE7, 1, 2) == "31")

## Conselho Municipal
conselho_mun_geral <- read.csv("data/2019/conselho_municipal/Censo_SUAS_2019_Dados_gerais_RH_Conselho_Municipal_divulgacao.csv", 
                               sep = ";", header = TRUE,
                               encoding = "latin1") %>%
  filter(str_sub(IBGE7, 1, 2) == "31")

conselho_mun_rh <- read.csv("data/2019/conselho_municipal/Censo_Suas_2019_RH_Conselho_Municipal_divulgacao.csv", 
                            sep = ";", header = TRUE,
                            encoding = "latin1") %>%
  filter(str_sub(IBGE7, 1, 2) == "31")


# Construcao das variaveis do IMRS ----------------------------------------


# Base --------------------------------------------------------------------

imrs_cras <- cras_geral %>%
  group_by(IBGE) %>%
  summarise(B_NCRAS = n())

imrs_creas <- creas_geral %>%
  group_by(IBGE) %>%
  summarise(B_NCREAS = n())

# * Selecao variaveis -------------------------------------------------------

# CRAS
cras_var_rh <- cras_rh %>%
  select(IBGE7, q56_11, q56_12, q56_10, d_56_9, q56_9) %>%
  rename("vinculo" = q56_11,
         "funcao" = q56_12,
         "profissao" = q56_10,
         "niveis_escolaridade" = d_56_9,
         "escolaridade" = q56_9) %>%
  mutate(base = "CRAS")

# CREAS
creas_var_rh <- creas_rh %>% 
  select(IBGE7, q58_10, q58_11, q58_9, d_58_8, q58_8) %>%
  rename('vinculo' = q58_10,
         "funcao" = q58_11,
         "profissao" = q58_9,
         "niveis_escolaridade" = d_58_8,
         "escolaridade" = q58_8) %>%
  mutate(base = "CREAS")

# Gestao Municipal
gestao_mun_var_rh <- gestao_mun_rh %>%
  select(IBGE7, q65_11, q65_12, q65_10, d_65_9, q65_9) %>%
  rename('vinculo' = q65_11,
         "funcao" = q65_12,
         "profissao" = q65_10,
         "niveis_escolaridade" = d_65_9,
         "escolaridade" = q65_9) %>%
  mutate(base = "Gestão Municipal")

# Juntar bases
trabalhadores <- bind_rows(cras_var_rh, creas_var_rh, gestao_mun_var_rh)

trabalhadores <- trabalhadores %>%
  mutate_if(is.character, str_trim) %>%
  mutate_if(is.character, str_to_upper) %>%
  mutate_if(is.character, rm_accent)

# Testar consistência das variaveis
vinculo <- trabalhadores %>%
  count(vinculo)

funcao <- trabalhadores %>%
  count(funcao)

profissao <- trabalhadores %>%
  count(profissao)

nivel_escolaridade <- trabalhadores %>%
  count(niveis_escolaridade)

escolaridade <- trabalhadores %>%
  count(escolaridade)

# Corrigir inconsistencias
trabalhadores <- trabalhadores %>%
  mutate(vinculo = case_when(vinculo %in% c("COMISSIONADA(O)", "COMISSIONADO") ~ "COMISSIONADA(O)",
                             vinculo %in% c("EMPREGADA(O) PUBLICA(O) (CLT)", "EMPREGADO PUBLICO CELETISTA (CLT)") ~ "EMPREGADA(O) PUBLICA(O) (CLT)",
                             vinculo %in% c("SERVIDOR TEMPORARIO", "SERVIDOR(A) TEMPORARIA(O)") ~ "SERVIDOR(A) TEMPORARIA(O)",
                             vinculo %in% c("SERVIDOR ESTATUTARIO", "SERVIDOR(A)/ESTATUTARIA(O)") ~ "SERVIDOR(A)/ESTATUTARIO(A)",
                             vinculo %in% c("TERCEIRIZADA(O)", "TERCEIRIZADO") ~ "TERCEIRIZADA(O)",
                             vinculo %in% c("TRABALHADOR DE EMPRESA/COOPERATIVA/ENTIDADE PRESTADORA DE SERVICOS", "TRABALHADOR(A) DE EMPRESA, COOPERATIVA OU ENTIDADE PRESTADORA DE SERVICOS",
                                            "TRABALHADOR(A) DE EMPRESA/ COOPERATIVA/ ENTIDADE PRESTADORA DE SERVICOS") ~ "TRABALHADOR(A) DE EMPRESA, COOPERATIVA OU ENTIDADE PRESTADORA DE SERVICOS",
                             vinculo %in% c("VOLUNTARIA(O)", "VOLUNTARIO") ~ "VOLUNTARIA(O)",
                             TRUE ~ vinculo
                             ),
         funcao = case_when(funcao %in% c("ESTAGIARIA(O)", "ESTAGIARIO(A)") ~ "ESTAGIARIA(O)",
                            funcao %in% c("COORDENADOR(A)" , "COORDENADOR(A)/DIRIGENTE") ~ "COORDENADOR(A)/DIRIGENTE",
                            funcao %in% c("EDUCADOR(A) SOCIAL", "EDUCADOR(A)/ORIENTADOR(A) SOCIAL") ~ "EDUCADOR(A)/ORIENTADOR(A) SOCIAL",
                            str_detect(funcao, "SERVICOS GERAIS") ~ "SERVIÇOS GERAIS",
                            str_detect(funcao, "NIVEL MEDIO") ~ "TECNICA(O) DE NIVEL MEDIO",
                            str_detect(funcao, "NIVEL SUPERIOR") ~ "TECNICA(O) DE NIVEL SUPERIOR",
                            TRUE ~ funcao
                            ),
         escolaridade = str_remove_all(escolaridade, "ENSINO ")
         )

rm(vinculo, funcao, profissao, nivel_escolaridade, escolaridade)

# * Resumo RH -------------------------------------------------------------

imrs_rh <- trabalhadores %>%
  group_by(IBGE7) %>%
  summarise(B_RHTOTALA = n(), # Número de funcionários da Assistência Social (com estagiário)
            B_RHTOTALB = sum(funcao != "ESTAGIARIA(O)"), # Número de funcionários da Assistência Social (sem estagiário)
            B_RHAS = sum(profissao == "ASSISTENTE SOCIAL"), # Número de assistentes sociais atuando na Assistência Social 
            B_RHASPS = sum(profissao == "ASSISTENTE SOCIAL") / sum(niveis_escolaridade == "NIVEL SUPERIOR") * 100, # Percentual de assistentes sociais atuando na Assistência Social em relação ao total de pessoal de nível superior 
            B_RHPSI = sum(profissao == "PSICOLOGA(O)"), # Número de psicólogos atuando na Assistência Social 
            B_RHPSIPS = sum(profissao == "PSICOLOGA(O)") / sum(niveis_escolaridade == "NIVEL SUPERIOR") * 100, # Percentual de psicólogos atuando na Assistência Social em relação ao total de pessoal de nível superior 
            B_RHENME = sum(niveis_escolaridade == "NIVEL MEDIO"), # Número de funcionários com ensino médio ocupados na Assistência Social 
            B_RHCURSU = sum(niveis_escolaridade == "NIVEL SUPERIOR"), # Número de funcionários com curso superior ocupados na Assistência Social
            B_RHPOSGRA = sum(escolaridade %in% c("ESPECIALIZACAO", "MESTRADO", "DOUTORADO")), # Número de funcionários com pós-graduação ocupados na Assistência Social
            B_RHTOEST = sum(vinculo == "SERVIDOR(A)/ESTATUTARIO(A)"), # Número de funcionários  estatutários ocupados na Assistência Social 
            B_RHTOCEL = sum(vinculo == "EMPREGADA(O) PUBLICA(O) (CLT)"), # Número de funcionários celetistas ocupados na assistência Social 
            B_RHVPOAAS = sum(vinculo %in% c("SERVIDOR(A)/ESTATUTARIO(A)", "EMPREGADA(O) PUBLICA(O) (CLT)")) / n() * 100, # Percentual do pessoal estatutário e celestita ocupado na área de Assistência Social
            B_RHVINEST = sum(vinculo == "SERVIDOR(A)/ESTATUTARIO(A)") / n() * 100, # Percentual do pessoal estatutário ocupado na área de Assistência Socia
            ) %>%
  left_join(pop_2019[, c(2,4)], by = "IBGE7") %>%
  mutate(B_RHTPOASPH = B_RHTOTALA / `População total` * 10000) # Proporção de pessoal ocupado na área de Assistência Social por 10 mil habitantes)


# * Variaveis CadUnico ----------------------------------------------------


# * * Ler base de dados ---------------------------------------------------

cadpes <- fread("/home/xedar/Documents/Trabalho/cad/cad_2019/pessoa.csv", 
                select = c("p.cod_familiar_fam","cd_ibge", "cod_deficiencia_memb",
                           "cod_trabalhou_memb", "cod_afastado_trab_memb",
                           "cod_sabe_ler_escrever_memb", "dta_nasc_pessoa"))

caddom <- fread("/home/xedar/Documents/Trabalho/cad/cad_2019/familia.csv", 
                select = c("d.cod_familiar_fam", "d.marc_pbf", "d.fx_rfpc",
                           "cod_abaste_agua_domic_fam", "dat_atual_fam", "cod_escoa_sanitario_domic_fam",
                           "cod_destino_lixo_domic_fam", "vlr_renda_media_fam"))

caddompes <- left_join(cadpes, caddom, by = c("p.cod_familiar_fam" = "d.cod_familiar_fam"))

# * * Corrigir variaveis e criar tabela -----------------------------------

caddompes_2 <- caddompes %>%
  mutate(data_do_cadastro = as.Date("2019-12-31"),
         data_nascimento = as.Date(dta_nasc_pessoa),
         diff_data = difftime(data_do_cadastro, data_nascimento, units = "days"),
         idade = diff_data/365,
         idade = as.integer(idade),
         ano_do_cadastro = str_sub(data_do_cadastro, 1, 4),
         data_inflacao_ano = as.Date(paste(ano_do_cadastro, "-12-31", sep = "")),
         renda = deflate(vlr_renda_media_fam, data_inflacao_ano, "12/2019", index = c("ipca")),
         fx_rfpc = case_when(renda <= 89 ~ 1,
                             renda > 89 & renda <= 178 ~ 2,
                             renda > 178 ~ 3)
  )

imrs_cad <- caddompes_2 %>%
  group_by(cd_ibge) %>%
  summarise(pop_pobres_pobre_e_ext_pobres = sum(fx_rfpc <= 2),
            pop_total_cad = n(),
            pop_pbf = sum(d.marc_pbf == 1),
            pop_idade_ativa_desocupada = sum(cod_trabalhou_memb == 2 & cod_afastado_trab_memb == 2 & idade %in% c(18:64), na.rm = TRUE),
            B_POPPOBEXTRCAD = pop_pobres_pobre_e_ext_pobres / pop_total_cad * 100,
            B_DEFPOBEXTRCAD = sum(cod_deficiencia_memb == 1 & idade %in% c(18:64) & fx_rfpc <= 2) / sum(cod_deficiencia_memb == 1 & idade %in% c(18:64)) * 100,
            B_POPIDPOBEXTRCAD = sum(idade %in% c(18:64) & fx_rfpc <= 2) / sum(idade %in% c(18:64)) * 100,
            B_POPIDPOBEXTRCADS = sum(cod_trabalhou_memb == 2 & cod_afastado_trab_memb == 2 & idade %in% c(18:64) & fx_rfpc <= 2, na.rm = TRUE) / sum(cod_trabalhou_memb == 2 & cod_afastado_trab_memb == 2 & idade %in% c(18:64), na.rm = TRUE) * 100,
            B_POPIDCADS = sum(cod_trabalhou_memb == 2 & cod_afastado_trab_memb == 2 & idade %in% c(18:64), na.rm = TRUE) / sum(idade %in% c(18:64), na.rm = TRUE) * 100,
            B_IDOSOPOBEXTRPOBCADS = sum(idade >= 65 & fx_rfpc <= 2) / sum(idade >= 65) * 100,
            B_PENLECAD = sum(cod_sabe_ler_escrever_memb == 2 & idade >= 15, na.rm = TRUE) / sum(idade >= 15, na.rm = TRUE) * 100,
            B_PVULSANEACAD = sum(cod_abaste_agua_domic_fam %in% c(2:4) & cod_escoa_sanitario_domic_fam %in% c(3:6) & cod_destino_lixo_domic_fam %in% c(3:6), na.rm = TRUE) / pop_total_cad * 100
            # Tem que ter os 3 ou cada um dos 3?
            ) %>%
  left_join(pop_2019[,c(2,4, 20, 30:33)], by = c("cd_ibge" = "IBGE7")) %>%
  mutate(B_POPPOBEXTRPOB = pop_pobres_pobre_e_ext_pobres / `População total` * 100,
         B_POPCADUNICO = pop_total_cad / `População total` * 100,
         B_COBBF = pop_pbf / `População total` * 100,
         ) %>%
  group_by(cd_ibge) %>%
  mutate(pop_idosa = round(sum(c_across(15:18)), digits = 0),
         pop_18_64 = `População com 18 anos ou mais de idade` - pop_idosa,
         B_POPIDCADSPOP = pop_idade_ativa_desocupada / pop_18_64 * 100
         )

# B_CRIANADOLEPOBEXTRPOP
# B_POPRURALCADS
# B_POPRURALPOP 
# B_POPPRETPARDCADS
# B_POPINDIGENACADS

# Vis Data ----------------------------------------------------------------

#> Cobertura BPF - Cad Outubro de 2019
fam_cad_10_2019 <- read_csv("data/2019/cad e bpc/fam_cad_10_2019.csv") %>%
  filter(UF == "MG")

fam_cad_pbf_10_2019 <- read_csv("data/2019/cad e bpc/fam_pbf_10_2019.csv") %>%
  filter(UF == "MG")

fam_cad_mais_meio_sm_10_2019 <- read_csv("data/2019/cad e bpc/fam_cad_mais_meio_sm_10_2019.csv") %>%
  filter(UF == "MG")

imrs_fam_cad_10_2019 <- left_join(fam_cad_10_2019, fam_cad_pbf_10_2019[,c(1,5)], by = "Código") %>%
  left_join(fam_cad_mais_meio_sm_10_2019[,c(1,5)], by = "Código")

imrs_fam_cad_10_2019 <- imrs_fam_cad_10_2019 %>%
  mutate(B_FCADMEIOSAL = `Famílias inscritas no Cadastro Único` - `Famílias inscritas no Cadastro Único com renda maior que meio salário mínimo`,
         B_PCOBBFMEIOSAL = `Famílias beneficiárias do Programa Bolsa Família` / B_FCADMEIOSAL * 100) %>%
  select(1, 8, 9)


#> BPC
bpc_deficiencia <- read_csv("data/2019/cad e bpc/bpc_deficiencia_12_2019.csv") %>%
  filter(UF == "MG")

bpc_idoso <- read_csv("data/2019/cad e bpc/bpc_idoso_12_2019.csv") %>%
  filter(UF == "MG")

bpc <- left_join(bpc_idoso, bpc_deficiencia[,c(1,5)], by = "Código") %>%
  left_join(pop_2019[,c(1,4, 30:33)], by = c("Código" = "IBGE6")) %>%
  group_by(`Código`) %>%
  mutate(pop_idosa = round(sum(c_across(7:10)), digits = 0)) %>%
  select(-c(8:11))

bpc <- bpc %>%
  mutate(bpc_total = `Idosos que recebem o Benefício de Prestação Continuada (BPC) por Município pagador` + `Pessoas com deficiência (PCD) que recebem o Benefício de Prestação Continuada (BPC) por Município pagador`,
         B_BPC = bpc_total / `População total` * 1000,
         B_BPCDEF = `Pessoas com deficiência (PCD) que recebem o Benefício de Prestação Continuada (BPC) por Município pagador` / `População total` * 1000,
         B_BPCID = `Idosos que recebem o Benefício de Prestação Continuada (BPC) por Município pagador` / `População total` * 1000,
         B_BPCIDPOPI = `Idosos que recebem o Benefício de Prestação Continuada (BPC) por Município pagador` / pop_idosa * 100,
         B_BPCPID = `Idosos que recebem o Benefício de Prestação Continuada (BPC) por Município pagador` / bpc_total * 100,
         B_BPCPDEF = `Pessoas com deficiência (PCD) que recebem o Benefício de Prestação Continuada (BPC) por Município pagador` / bpc_total * 100)


# ID CRAS -----------------------------------------------------------------

imrs_id_cras <- read_xlsx("data/2019/CRAS/IDCRAS_2019_DIVULGAÇÃO_210920.xlsx", skip = 6) %>%
  rename("id_cras" = ...11) %>%
  filter(UF == 31)

# Define Min-Max normalization function
min_max_norm <- function(x) {
  (x - min(x)) / (max(x) - min(x))
}

imrs_id_cras <- imrs_id_cras %>%
  group_by(IBGE7) %>%
  summarise(Município = first(Município),
            B_INDCRAS = mean(id_cras))

imrs_id_cras <- imrs_id_cras %>%
  mutate(B_IDCRASME = min_max_norm(B_INDCRAS))

# IGD-M -------------------------------------------------------------------


# IMRS Sintese ------------------------------------------------------------

imrs <- pop_2019 %>%
  select(IBGE6, IBGE7) %>%
  left_join(imrs_cras, by = c("IBGE6" = "IBGE")) %>%
  left_join(imrs_creas, by = c("IBGE6" = "IBGE")) %>%
  mutate(B_NCREAS = ifelse(is.na(B_NCREAS), 0, B_NCREAS)) %>%
  left_join(imrs_id_cras[,c(1,3,4)], by = "IBGE7") %>%
  left_join(imrs_fam_cad_10_2019, by = c("IBGE6" = "Código")) %>%
  left_join(bpc[,c(1, 10:15)], by = c("IBGE6" = "Código")) %>%
  left_join(imrs_rh, by = "IBGE7") %>%
  left_join(imrs_cad[,c(1, 6:13, 20:23, 25)], by = c("IBGE7" = "cd_ibge"))

imrs <- imrs %>%
  select(IBGE6, IBGE7,
         B_NCRAS
         ,B_FCADMEIOSAL
         ,B_INDCRAS
         ,B_IDCRASME
         ,B_NCREAS
         ,B_PCOBBFMEIOSAL
         ,B_BPC
         ,B_BPCDEF
         ,B_BPCID
         ,B_BPCIDPOPI
         ,B_BPCPID
         ,B_BPCPDEF
         ,B_RHTOTALA
         ,B_RHAS
         ,B_RHASPS
         ,B_RHPSI
         ,B_RHPSIPS
         ,B_RHENME
         ,B_RHCURSU
         ,B_RHPOSGRA
         ,B_RHTOEST
         ,B_RHTOCEL
         ,B_RHVPOAAS
         ,B_RHVINEST
         ,B_RHTPOASPH
         ,B_POPPOBEXTRPOB
         ,B_POPCADUNICO
         ,B_COBBF
         ,B_POPPOBEXTRCAD
         ,B_DEFPOBEXTRCAD
         ,B_POPIDPOBEXTRCAD
         ,B_POPIDPOBEXTRCADS
         ,B_POPIDCADS
         ,B_IDOSOPOBEXTRPOBCADS
         ,B_POPIDCADSPOP
         ,B_PENLECAD
         ,B_PVULSANEACAD)

# Incluir depois

#,B_IGDM
#,B_IGDMCONDE
#,B_IGDMCONDS
#,B_IGDMCOBCAD
#,B_IGDMATU
#,B_IDCREASNOR
#,B_IDCONSELHO


# Automatização -----------------------------------------------------------

#intervalo1 <- as.character(readline("Escolha a linha inicial: ")) #Lembre-se que é pra digitar o número da linha inicial no console
#novo_nome <- as.character(readline(cat(paste("O nome na planilha está escrito dessa forma, escreva o novo nome ou aperte enter\n",bolsa_merenda1$Nome.do.aluno.matriculado[n]))))