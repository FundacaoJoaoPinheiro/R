library(tidyverse)
library(openxlsx)
#install_github("timriffe/AdultCoverage/AdultCoverage/R/DDM")
library(DDM)
library(DemoTools)

### Fundação João Pinheiro - Belo Horizonte - 06/12/2024
### Algoritmo de cálculo das tábuas para o artigo da REBEP (Versão p/ GitHub)
### Autor: Igor Souza

# Declarar função ---------------------------------------------------------

## Método de Chiang revisado para cálculo de esperança de vida
## Chiang CL. The Life Table and its Construction. 
## In: Introduction to Stochastic Processes in Biostatistics. 1968:189-214.		

## Baseado na tábua disponibilizada pelo Office for National Statistics

# i:     faixa etária
# death: mortes registradas na população em estudo
# pop:   população em estudo
chiang_ii <- function(i, death, pop){
  
  # Calculate 95% confidence interval
  conf_interval <- function(n, a, death, M, q, l, e){
    # Sample variance of proportion surviving
    Sp_2 <- ifelse(death == 0, 0, q ^ 2 * (1 - q) / death)
    # Sample variance of proportion surviving (adjust last interval)
    Sp_2[length(Sp_2)] <- 4 / death[length(death)] / M[length(M)] ^ 2
    # Weighted variance of proportion surviving in interval
    Sp_2_w <- l ^ 2 * ((1 - a) * n + lead(e)) ^ 2 * Sp_2
    # Weighted variance of proportion surviving in interval (adjust last interval)
    Sp_2_w[length(Sp_2_w)] <- (l[length(l)] / 2) ^ 2 * Sp_2[length(Sp_2)]
    # Sample variance of person-years lived beyond start of interval
    ST_2 <- rev(cumsum(rev(Sp_2_w)))
    # Sample variance of observed life expectancy at start of interval
    Se_2 <- ST_2 / l ^ 2
    # Standard error
    Se <- sqrt(Se_2)
    # 95% confidence interval - lower
    ci_lower <- round(e - 1.96 * Se, 2)
    # 95% confidence interval - upper
    ci_upper <- round(e + 1.96 * Se, 2)
    
    df <- data.frame(Sp_2, Sp_2_w, ST_2, Se_2, Se, ci_lower, ci_upper)
    
    return(df)
  }
  
  # Fraction of last age interval survived
  a <- c(.1, rep(.5, times = length(i) - 1))
  # Death rate in interval
  M <- ifelse(death / pop < 1, death / pop, 1)
  # Interval width
  n <- c(1, 4, rep(5, times = length(i) - 3), 1 / a[length(a)] / M[length(M)])
  # Probability of dying in interval
  q <- ifelse(death > (pop / n / a), 1, n * M / (1 + n * (1 - a) * M))
  # Number alive at start of interval
  l <- cumprod(1 - lag(q, default = 0)) * 100000
  # Number dying in interval
  d <- l - lead(l, default = 0)
  # Person-years lived in interval
  L <- n * (lead(l, default = 0) + a * d)
  # Person-years lived beyond start of interval
  T_ <- rev(cumsum(rev(L)))
  # Observed life expectancy at start of interval
  e <- round(ifelse(l == 0, 0, T_ / l), 2)
  # 95% confidence interval
  ci_values <- conf_interval(n, a, death, M, q, l, e)
  
  df_result <- data.frame(
    i, 
    n, 
    a, 
    pop, 
    death, 
    M, 
    q, 
    l, 
    d, 
    L, 
    T_, 
    e, 
    ci_lower = ci_values$ci_lower, 
    ci_upper = ci_values$ci_upper,
    se       = ci_values$Se,
    cv       = ci_values$Se / e
  )
  
  return(df_result)
}

## Função para alterar o último grupo etário de uma tábua de mortalidade
alterar_tabua_mortalidade <- function(x, n, nax, nqx, lx, ndx, nlx, ultimo_intervalo = 80L){
  x_novo <- x[x <= ultimo_intervalo]
  n_novo <- n[x <= ultimo_intervalo]
  nax_novo <- nax[x <= ultimo_intervalo]
  nqx_novo <- nqx[x <= ultimo_intervalo]
  lx_novo <- lx[x <= ultimo_intervalo]
  ndx_novo <- ndx[x <= ultimo_intervalo]
  nlx_novo <- nlx[x <= ultimo_intervalo]
  n_novo[length(n_novo)] <- NA
  mx_novo <- -nqx_novo/(nqx_novo * (n_novo - nax_novo) - n_novo)
  mx_novo[length(mx_novo)] <- sum(ndx[x >= ultimo_intervalo]) / sum(nlx[x >= ultimo_intervalo])
  nax_novo[length(nax_novo)] <- 1 / mx_novo[length(mx_novo)]
  nqx_novo[length(nqx_novo)] <- 1
  npx_novo <- 1 - nqx_novo
  ndx_novo[length(ndx_novo)] <- sum(ndx[x >= ultimo_intervalo])
  lx_novo[length(lx_novo)] <- lx_novo[length(lx_novo) - 1] - ndx_novo[length(ndx_novo) - 1]
  nlx_novo[length(nlx_novo)] <- ndx_novo[length(ndx_novo)] / mx_novo[length(mx_novo)]
  nsx_novo <- nlx_novo / lag(nlx_novo, default = 1)
  tx_novo <- rev(cumsum(rev(nlx_novo)))
  ex_novo <- tx_novo / lx_novo
  
  return(
    data.frame(
      "x"   = x_novo, 
      "n"   = n_novo, 
      "nax" = nax_novo, 
      "nqx" = nqx_novo,
      "npx" = npx_novo,
      "lx"  = lx_novo,
      "ndx" = ndx_novo,
      "nlx" = nlx_novo,
      "mx"  = mx_novo,
      "nsx" = nsx_novo,
      "tx"  = tx_novo,
      "ex"  = ex_novo
    )
  )
}

# Importar ----------------------------------------------------------------

## Censo 2010, Censo 2022, SIM 2010 a 2022 (acumulado), SIM 2022 e  
## SIM 2022 redistribuído (baseado em estimativas municipais do IBGE)
dados_mun <- read.xlsx("dados_ddm_rgint.xlsx")

# Unir e transformar ------------------------------------------------------

## Último grupo etário deve ser 80+ (DDM)
dados_rgint <- dados_mun |> 
  select(!rgint_cod) |> 
  mutate(
    faixa_etaria = if_else(faixa_etaria > 80, 80, faixa_etaria)
  ) |> 
  group_by(rgint_nome, faixa_etaria) |> 
  summarise(
    across(!ibge7, ~sum(.x, na.rm = T))
  ) |> 
  ungroup() |> 
  rename(rgint = rgint_nome)

# Transformar -------------------------------------------------------------

## Dados por sexo, no formato apropriado para a função DDM::ddm()

### Homem
dados_ddm_homem <- dados_rgint |> 
  mutate(
    sex   = "m",
    date1 = as_date("2010-08-01"),
    date2 = as_date("2022-08-01")
  ) |> 
  select( 
    cod    = rgint,   
    pop1   = pop_homem_2010, 
    pop2   = pop_homem_2022,
    deaths = obito_homem_2010_2022,
    age    = faixa_etaria,
    sex,
    date1,
    date2
  )

### Mulher
dados_ddm_mulher <- dados_rgint |> 
  mutate(
    sex   = "f",
    date1 = as_date("2010-08-01"),
    date2 = as_date("2022-08-01")
  ) |> 
  select( 
    cod    = rgint,   
    pop1   = pop_mulher_2010, 
    pop2   = pop_mulher_2022,
    deaths = obito_mulher_2010_2022,
    age    = faixa_etaria,
    sex,
    date1,
    date2
  )

# Calcular ----------------------------------------------------------------

## Calcular
## https://github.com/timriffe/AdultCoverage
resultado_ddm_homem <- ddm(dados_ddm_homem, deaths.summed = T)
resultado_ddm_mulher <- ddm(dados_ddm_mulher, deaths.summed = T)

## Empilhar resultados e pivotar
resultado_ddm <- bind_rows(
  list(
    "homem"  = resultado_ddm_homem,
    "mulher" = resultado_ddm_mulher
  ), 
  .id = "sexo"
) |> 
  select(rgint = cod, sexo, ggbseg) |> 
  pivot_wider(id_cols = rgint, names_from = sexo, names_glue = "{.value}_{sexo}", values_from = ggbseg)

# Corrigir ----------------------------------------------------------------

## Corrigir óbitos baseado no fator de cobertura (ggbseg)
## corrigido = observado + (observado * (1 - ggbseg))
## Exceto para as faixas 0-4 e rgints cujas ggbseg > 1
dados_rgint_edit <- dados_rgint |> 
  left_join(resultado_ddm, by = join_by(rgint)) |> 
  mutate(
    corrigir_homem  = if_else((!faixa_etaria %in% c(0, 1)) & (ggbseg_homem <= 1), T, F),
    corrigir_mulher = if_else((!faixa_etaria %in% c(0, 1)) & (ggbseg_mulher <= 1), T, F)
  ) |> 
  mutate(
    obito_homem_2022_corrig = if_else(
      corrigir_homem, 
      obito_homem_2022 + (obito_homem_2022 * (1-ggbseg_homem)), 
      obito_homem_2022
    ),
    obito_mulher_2022_corrig = if_else(
      corrigir_mulher, 
      obito_mulher_2022 + (obito_mulher_2022 * (1-ggbseg_mulher)), 
      obito_mulher_2022
    ),
    across(obito_homem_2022_corrig:obito_mulher_2022_corrig, ~round(.x, 2))
  )

# Chiang ------------------------------------------------------------------

## Calcular tábua de mortalidade (Chiang)

### Chiang - Cálculo direto - Homem
tabua_chiang_homem_direto <- dados_rgint_edit |>
  group_by(rgint) |> 
  reframe(
    chiang_ii(faixa_etaria, obito_homem_2022, pop_homem_2022)
  ) |> 
  ungroup()

### Chiang - Cálculo direto - Mulher
tabua_chiang_mulher_direto <- dados_rgint_edit |>
  group_by(rgint) |> 
  reframe(
    chiang_ii(faixa_etaria, obito_mulher_2022, pop_mulher_2022)
  ) |> 
  ungroup()

### Chiang - Redistribuído (subreg IBGE) - Homem
tabua_chiang_homem_redist <- dados_rgint_edit |>
  group_by(rgint) |> 
  reframe(
    chiang_ii(faixa_etaria, obito_homem_2022_redist, pop_homem_2022)
  ) |> 
  ungroup()

### Chiang - Redistribuído (subreg IBGE) - Mulher
tabua_chiang_mulher_redist <- dados_rgint_edit |>
  group_by(rgint) |> 
  reframe(
    chiang_ii(faixa_etaria, obito_mulher_2022_redist, pop_mulher_2022)
  ) |> 
  ungroup()

### Chiang - Corrigido (DDM) - Homem
tabua_chiang_homem_corrig <- dados_rgint_edit |>
  group_by(rgint) |> 
  reframe(
    chiang_ii(faixa_etaria, obito_homem_2022_corrig, pop_homem_2022)
  ) |> 
  ungroup()

### Chiang - Corrigido (DDM) - Mulher
tabua_chiang_mulher_corrig <- dados_rgint_edit |>
  group_by(rgint) |> 
  reframe(
    chiang_ii(faixa_etaria, obito_mulher_2022_corrig, pop_mulher_2022)
  ) |> 
  ungroup()

# nqx ---------------------------------------------------------------------

## Calcular nqx a partir da tábua de mortalidade (p/ logquad)

### nqx - Cálculo direto - Homem
nqx_homem_direto <- tabua_chiang_homem_direto |>
  group_by(rgint) |> 
  reframe(
    nqx_0_5   = (l[i == 0]-l[i == 5]) / l[i == 0],
    nqx_15_45 = (l[i == 15]-l[i == 60]) / l[i == 15]
  ) |> 
  ungroup()

### nqx - Cálculo direto - Mulher
nqx_mulher_direto <- tabua_chiang_mulher_direto |>
  group_by(rgint) |> 
  reframe(
    nqx_0_5   = (l[i == 0]-l[i == 5]) / l[i == 0],
    nqx_15_45 = (l[i == 15]-l[i == 60]) / l[i == 15]
  ) |> 
  ungroup()

### nqx - Redistribuído (subreg IBGE) - Homem
nqx_homem_redist <- tabua_chiang_homem_redist |>
  group_by(rgint) |> 
  reframe(
    nqx_0_5   = (l[i == 0]-l[i == 5]) / l[i == 0],
    nqx_15_45 = (l[i == 15]-l[i == 60]) / l[i == 15]
  ) |> 
  ungroup()

### nqx - Redistribuído (subreg IBGE) - Mulher
nqx_mulher_redist <- tabua_chiang_mulher_redist |>
  group_by(rgint) |> 
  reframe(
    nqx_0_5   = (l[i == 0]-l[i == 5]) / l[i == 0],
    nqx_15_45 = (l[i == 15]-l[i == 60]) / l[i == 15]
  ) |> 
  ungroup()

### nqx - Corrigido (DDM) - Homem
nqx_homem_corrig <- tabua_chiang_homem_corrig |>
  group_by(rgint) |> 
  reframe(
    nqx_0_5   = (l[i == 0]-l[i == 5]) / l[i == 0],
    nqx_15_45 = (l[i == 15]-l[i == 60]) / l[i == 15]
  ) |> 
  ungroup()

### nqx - Corrigido (DDM) - Mulher
nqx_mulher_corrig <- tabua_chiang_mulher_corrig |>
  group_by(rgint) |> 
  reframe(
    nqx_0_5   = (l[i == 0]-l[i == 5]) / l[i == 0],
    nqx_15_45 = (l[i == 15]-l[i == 60]) / l[i == 15]
  ) |> 
  ungroup()

# Log-quadrático ----------------------------------------------------------

## Logquad - Cálculo direto - Homem
tabua_logquad_homem_direto <- nqx_homem_direto |> 
  group_by(rgint) |> 
  reframe(
    lt_model_lq(Sex = "m", q0_5 = nqx_0_5, q15_45 = nqx_15_45)$lt
  ) |> 
  rename(
    x = Age,
    n = AgeInt
  ) |> 
  rename_with(tolower)

## Logquad - Cálculo direto - Mulher
tabua_logquad_mulher_direto <- nqx_mulher_direto |> 
  group_by(rgint) |> 
  reframe(
    lt_model_lq(Sex = "f", q0_5 = nqx_0_5, q15_45 = nqx_15_45)$lt
  ) |> 
  rename(
    x = Age,
    n = AgeInt
  ) |> 
  rename_with(tolower)

## Logquad - Redistribuído (subreg IBGE) - Homem
tabua_logquad_homem_redist <- nqx_homem_redist |> 
  group_by(rgint) |> 
  reframe(
    lt_model_lq(Sex = "m", q0_5 = nqx_0_5, q15_45 = nqx_15_45)$lt
  ) |> 
  rename(
    x = Age,
    n = AgeInt
  ) |> 
  rename_with(tolower)

## Logquad - Redistribuído (subreg IBGE) - Mulher
tabua_logquad_mulher_redist <- nqx_mulher_redist |> 
  group_by(rgint) |> 
  reframe(
    lt_model_lq(Sex = "f", q0_5 = nqx_0_5, q15_45 = nqx_15_45)$lt
  ) |> 
  rename(
    x = Age,
    n = AgeInt
  ) |> 
  rename_with(tolower)

## Logquad - Corrigido (DDM) - Homem
tabua_logquad_homem_corrig <- nqx_homem_corrig |> 
  group_by(rgint) |> 
  reframe(
    lt_model_lq(Sex = "m", q0_5 = nqx_0_5, q15_45 = nqx_15_45)$lt
  ) |> 
  rename(
    x = Age,
    n = AgeInt
  ) |> 
  rename_with(tolower)

## Logquad - Corrigido (DDM) - Mulher
tabua_logquad_mulher_corrig <- nqx_mulher_corrig |> 
  group_by(rgint) |> 
  reframe(
    lt_model_lq(Sex = "f", q0_5 = nqx_0_5, q15_45 = nqx_15_45)$lt
  ) |> 
  rename(
    x = Age,
    n = AgeInt
  ) |> 
  rename_with(tolower)

# Alterar último grupo ----------------------------------------------------

## Alterar o último intervalo etário da tábua de mortalidade (de 110+ para 80+), 
## dado que DemoTools::lt_model_lq() retorna uma tábua 110+.

### Alterado - Cálculo direto - Homem
tabua_logquad_homem_direto_alterado <- tabua_logquad_homem_direto |> 
  group_by(rgint) |> 
  reframe(
    alterar_tabua_mortalidade(x, n, nax, nqx, lx, ndx, nlx)
  )

### Alterado - Cálculo direto - Mulher
tabua_logquad_mulher_direto_alterado <- tabua_logquad_mulher_direto |> 
  group_by(rgint) |> 
  reframe(
    alterar_tabua_mortalidade(x, n, nax, nqx, lx, ndx, nlx)
  )

### Alterado - Redistribuído (subreg IBGE) - Homem
tabua_logquad_homem_redist_alterado <- tabua_logquad_homem_redist |> 
  group_by(rgint) |> 
  reframe(
    alterar_tabua_mortalidade(x, n, nax, nqx, lx, ndx, nlx)
  )

### Alterado - Redistribuído (subreg IBGE) - Mulher
tabua_logquad_mulher_redist_alterado <- tabua_logquad_mulher_redist |> 
  group_by(rgint) |> 
  reframe(
    alterar_tabua_mortalidade(x, n, nax, nqx, lx, ndx, nlx)
  )

### Alterado - Corrigido (DDM) - Homem
tabua_logquad_homem_corrig_alterado <- tabua_logquad_homem_corrig |> 
  group_by(rgint) |> 
  reframe(
    alterar_tabua_mortalidade(x, n, nax, nqx, lx, ndx, nlx)
  )

### Alterado - Corrigido (DDM) - Mulher
tabua_logquad_mulher_corrig_alterado <- tabua_logquad_mulher_corrig |> 
  group_by(rgint) |> 
  reframe(
    alterar_tabua_mortalidade(x, n, nax, nqx, lx, ndx, nlx)
  )

# Chiang (reestimado) ----------------------------------------------------

## Calcular tábua de mortalidade (Chiang) após novos óbitos 
## obtidos pelo log-quadrático através da fórmula nmx*populacao

### Chiang - Cálculo direto - Homem
tabua_chiang_homem_direto_reestim <- tabua_logquad_homem_direto_alterado |>
  inner_join(dados_rgint, by = join_by(rgint, x == faixa_etaria)) |> 
  select(rgint, faixa_etaria = x, pop_homem_2022, mx) |> 
  mutate(
    obito_homem_2022_reestim = mx*pop_homem_2022
  ) |> 
  group_by(rgint) |> 
  reframe(
    chiang_ii(faixa_etaria, obito_homem_2022_reestim, pop_homem_2022)
  ) |> 
  ungroup()

### Chiang - Cálculo direto - Mulher
tabua_chiang_mulher_direto_reestim <- tabua_logquad_mulher_direto_alterado |>
  inner_join(dados_rgint, by = join_by(rgint, x == faixa_etaria)) |> 
  select(rgint, faixa_etaria = x, pop_mulher_2022, mx) |> 
  mutate(
    obito_mulher_2022_reestim = mx*pop_mulher_2022
  ) |> 
  group_by(rgint) |> 
  reframe(
    chiang_ii(faixa_etaria, obito_mulher_2022_reestim, pop_mulher_2022)
  ) |> 
  ungroup()

### Chiang - Redistribuído (subreg IBGE) - Homem
tabua_chiang_homem_redist_reestim <- tabua_logquad_homem_redist_alterado |>
  inner_join(dados_rgint, by = join_by(rgint, x == faixa_etaria)) |> 
  select(rgint, faixa_etaria = x, pop_homem_2022, mx) |> 
  mutate(
    obito_homem_2022_reestim = mx*pop_homem_2022
  ) |> 
  group_by(rgint) |> 
  reframe(
    chiang_ii(faixa_etaria, obito_homem_2022_reestim, pop_homem_2022)
  ) |> 
  ungroup()

### Chiang - Redistribuído (subreg IBGE) - Mulher
tabua_chiang_mulher_redist_reestim <- tabua_logquad_mulher_redist_alterado |>
  inner_join(dados_rgint, by = join_by(rgint, x == faixa_etaria)) |> 
  select(rgint, faixa_etaria = x, pop_mulher_2022, mx) |> 
  mutate(
    obito_mulher_2022_reestim = mx*pop_mulher_2022
  ) |> 
  group_by(rgint) |> 
  reframe(
    chiang_ii(faixa_etaria, obito_mulher_2022_reestim, pop_mulher_2022)
  ) |> 
  ungroup()

### Chiang - Corrigido (DDM) - Homem
tabua_chiang_homem_corrig_reestim <- tabua_logquad_homem_corrig_alterado |>
  inner_join(dados_rgint, by = join_by(rgint, x == faixa_etaria)) |> 
  select(rgint, faixa_etaria = x, pop_homem_2022, mx) |> 
  mutate(
    obito_homem_2022_reestim = mx*pop_homem_2022
  ) |> 
  group_by(rgint) |> 
  reframe(
    chiang_ii(faixa_etaria, obito_homem_2022_reestim, pop_homem_2022)
  ) |> 
  ungroup()

### Chiang - Corrigido (DDM) - Mulher
tabua_chiang_mulher_corrig_reestim <- tabua_logquad_mulher_corrig_alterado |>
  inner_join(dados_rgint, by = join_by(rgint, x == faixa_etaria)) |> 
  select(rgint, faixa_etaria = x, pop_mulher_2022, mx) |> 
  mutate(
    obito_mulher_2022_reestim = mx*pop_mulher_2022
  ) |> 
  group_by(rgint) |> 
  reframe(
    chiang_ii(faixa_etaria, obito_mulher_2022_reestim, pop_mulher_2022)
  ) |> 
  ungroup()

# Empilhar ----------------------------------------------------------------

## Empilhar homem e mulher

### Chiang - Cálculo direto
tabua_chiang_direto <- bind_rows(
  list(
    "Homem"  = tabua_chiang_homem_direto,
    "Mulher" = tabua_chiang_mulher_direto
  ),
  .id = "sexo"
)

### Chiang - Redistribuído (subreg IBGE)
tabua_chiang_redist <- bind_rows(
  list(
    "Homem"  = tabua_chiang_homem_redist,
    "Mulher" = tabua_chiang_mulher_redist
  ),
  .id = "sexo"
)

### Chiang - Corrigido (DDM)
tabua_chiang_corrig <- bind_rows(
  list(
    "Homem"  = tabua_chiang_homem_corrig,
    "Mulher" = tabua_chiang_mulher_corrig
  ),
  .id = "sexo"
)

### Logquad - Cálculo direto
tabua_logquad_direto <- bind_rows(
  list(
    "Homem"  = tabua_logquad_homem_direto_alterado,
    "Mulher" = tabua_logquad_mulher_direto_alterado
  ),
  .id = "sexo"
)

### Logquad - Redistribuído (subreg IBGE)
tabua_logquad_redist <- bind_rows(
  list(
    "Homem"  = tabua_logquad_homem_redist_alterado,
    "Mulher" = tabua_logquad_mulher_redist_alterado
  ),
  .id = "sexo"
)

### Logquad - Corrigido (DDM)
tabua_logquad_corrig <- bind_rows(
  list(
    "Homem"  = tabua_logquad_homem_corrig_alterado,
    "Mulher" = tabua_logquad_mulher_corrig_alterado
  ),
  .id = "sexo"
)

### Chiang reestimado - Cálculo direto
tabua_chiang_direto_reestim <- bind_rows(
  list(
    "Homem"  = tabua_chiang_homem_direto_reestim,
    "Mulher" = tabua_chiang_mulher_direto_reestim
  ),
  .id = "sexo"
)

### Chiang reestimado - Redistribuído (subreg IBGE)
tabua_chiang_redist_reestim <- bind_rows(
  list(
    "Homem"  = tabua_chiang_homem_redist_reestim,
    "Mulher" = tabua_chiang_mulher_redist_reestim
  ),
  .id = "sexo"
)

### Chiang reestimado - Corrigido (DDM)
tabua_chiang_corrig_reestim <- bind_rows(
  list(
    "Homem"  = tabua_chiang_homem_corrig_reestim,
    "Mulher" = tabua_chiang_mulher_corrig_reestim
  ),
  .id = "sexo"
)
 
# Exportar ----------------------------------------------------------------

pt <- createWorkbook()

addWorksheet(pt, "Dados")
addWorksheet(pt, "Chiang - Direto")
addWorksheet(pt, "Chiang - Redist")
addWorksheet(pt, "Chiang - Corrig")
addWorksheet(pt, "Logquad - Direto")
addWorksheet(pt, "Logquad - Redist")
addWorksheet(pt, "Logquad - Corrig")
addWorksheet(pt, "Chiang (reestimado) - Direto")
addWorksheet(pt, "Chiang (reestimado) - Redist")
addWorksheet(pt, "Chiang (reestimado) - Corrig")

writeData(pt, "Dados", dados_rgint_edit)
writeData(pt, "Chiang - Direto", tabua_chiang_direto)
writeData(pt, "Chiang - Redist", tabua_chiang_redist)
writeData(pt, "Chiang - Corrig", tabua_chiang_corrig)
writeData(pt, "Logquad - Direto", tabua_logquad_direto)
writeData(pt, "Logquad - Redist", tabua_logquad_redist)
writeData(pt, "Logquad - Corrig", tabua_logquad_corrig)
writeData(pt, "Chiang (reestimado) - Direto", tabua_chiang_direto_reestim)
writeData(pt, "Chiang (reestimado) - Redist", tabua_chiang_redist_reestim)
writeData(pt, "Chiang (reestimado) - Corrig", tabua_chiang_corrig_reestim)

saveWorkbook(pt, "tabuamortalidade_logquad_rgint_2022_redist-corrig.xlsx", overwrite = T)