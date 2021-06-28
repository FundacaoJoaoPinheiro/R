                       #=================== VISUALIZAÇÃO - PAM ========================#

# APRESENTAÇÃO: Script para visualização de gáficos gerados a partir dos dados 
#... importados pelo script "PAM_importação"
# ATENÇÃO!! Essa não é uma rotina.
# ORIENTAÇÕES: importar os dados desejados para objetos nomeados de acordo com...
#... o script de importação "PAM_importação".

# Pacotes utilizados----------------------------------------------------
pacotes <- c("tidyverse", "sidrar", "data.table", "openxlsx", "curl")
#install.packages(pacotes) #opcionalmente instalar o plotly
lapply(pacotes, library, character.only = TRUE)

# 6 "N" MAIORES DE MINAS =====================================================#

# Filtrar dados 
## primeiro vamos manipular os dados, selecionando "n" maiores
t_maiores <- MG_agr %>%
  group_by(Variável,Ano) %>%                    # poderíamos fazer outros filtros, por exemplo da Variável
  slice_max(Valor, n = 10) %>%                  # seleciona as dez maiores linhas por Ano e Variável (que foram agrupadas)
  filter(Ano >= 2010, Produto != "Total")       # de 2010 para frente para facilitar a visualização

# Montar gráfico 
## agora vamos montar o gráfico
g_maiores <-  t_maiores %>%
  ggplot(aes(x = Ano, y = factor(Produto), text = Rank)) +
  geom_point(
    mapping = aes(size = Valor, alpha = -Rank, color = Variável),
    show.legend = F
  ) +
  facet_wrap(~Variável, nrow = 2, scales = "free_y") +
  scale_size(range = c(4.5,10)) +
  scale_alpha(range = c(0.3,1)) +
  labs(y = "Produtos da Lavoura") 

# Visualizar o gráfico
g_maiores

## visualizar o gráfico com o plotly (opcional)
plotly::ggplotly(g_maiores, tooltip = c("text", "y", "size")) %>% plotly::hide_guides()

# 7 MINAS x OUTRAS UF's =====================================================
# Filtrar dados
t_MGxUF <-filter(UF_agr, Ano >= 2010, str_detect(Produto, "Milho"))

# Montar gráfico
g_MGxUF <- t_MGxUF %>%
  ggplot(mapping = aes(x = Ano, y = Valor)) +
  geom_point(
    mapping = aes(shape = str_detect(Unidade.da.Federação, "Minas"),
                  fill = str_detect(Unidade.da.Federação, "Minas"),
                  alpha = str_detect(Unidade.da.Federação, "Minas"),
                  text = Unidade.da.Federação),
    size = 5,
    show.legend = FALSE
  ) +
  scale_shape_manual(values = c(21,24)) +
  scale_fill_manual(values = c("gray50", "red")) +
  scale_alpha_manual(values = c(0.5,1)) + 
  stat_summary(fun = mean, geom = "line", group = 'Produto', color = "blue")+
  facet_wrap(~Variável, nrow = 2, scales = "free_y")

# Visualizar gráfico
g_MGxUF

## opcionalmente visualizar com plotly
plotly::ggplotly(g_MGxUF, tooltip = c("text","y")) %>% plotly::hide_guides()

# 8 MG AGREGADO - Produto e Variável x Ano ======================================#
# Filtrar dados
t_MG_agr <- filter(MG_agr,
                   # str_detect(Variável, "Área"),           # descomentar para visualizar apenas uma Variável
                   Ano > 2007,
                   str_detect(Produto, "Soja|Milho|Café.*T|Cana.*aç"))

# Montar gráfico
g_MG_agr <- t_MG_agr %>%                  
  ggplot(aes(x = Ano, y = Valor, group = Produto, color = Produto)) +
  geom_line()+
  facet_wrap(~Variável, nrow = 2, scales = "free_y")

# Visualizar gráfico
g_MG_agr

## opcionalmente visualizar com o plotly
plotly::ggplotly(g_MG_agr, tooltip = c("y", "color")) %>% plotly::hide_guides()

# 9 RegInt's - DISTRIBUIÇÃO DE CAIXA ===========================================#
# Filtrar dados
t_regints <- regint_agr %>%
  filter(
    Ano >= 2010,
    str_detect(Variável, "Área"),
    str_detect(Produto, "Milho|Café.*T|Cana.*aç|Soja"),
  )
# Montar gráfico
g_regints <- t_regints %>%
  ggplot(aes(x = Ano, y = Valor)) +
  geom_boxplot(aes(group = Ano))+
  geom_violin(
    mapping = aes(group = Ano),
    fill = "orange", color = "red", alpha = 0.2
  ) +
  geom_jitter(aes(text = RegInt, group = Ano))+
  stat_summary(fun = mean, geom = "line", group = 'Ano', color = "blue")+
  facet_wrap(~Produto, nrow = 2) 

# Visualizar gráfico
g_regints

## visualizar opcionalmente com o plotly
plotly::ggplotly(g_regints, tooltip = c("y","text")) %>% plotly::hide_guides()

# 10 MG DESAGREGADO - DISTRIBUIÇÃO DE CAIXA
# Filtrar dados
t_MG_mun <- MG_mun %>%
  filter(
    Ano >= 2015,
    RegInt == "Varginha",
    str_detect(Variável, "Área"),
    str_detect(Produto, "Milho|Soja|Café.*T|Cana.*aç"),
  )
# Montar gráfico
g_MG_mun <- t_MG_mun %>%
  ggplot(aes(x = Produto, y = Valor)) +
  geom_jitter(aes(text = Município, group = Produto))+
  geom_boxplot(aes(group = Produto), outlier.shape = NULL)+
  geom_violin(
    mapping = aes(group = Produto),
    fill = "orange", color = "red", alpha = 0.2
  ) +
  stat_summary(fun = mean, geom = "line", group = 'Produto', color = "blue")+
  stat_summary(fun = median, geom = "line", group = 'Produto', color = "red") +
  facet_wrap(~Ano, nrow = 2)

# Visualizar o gráfico
g_MG_mun

## visualizar opcionalmente como o plotly
plotly::ggplotly(g_MG_mun, tooltip = c("text","x","y"))%>%plotly::hide_guides()

                       ##===================== FIM ===========================##