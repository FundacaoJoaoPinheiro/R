# RAIS - Relação Anual de Informações Sociais 

## Importação online de dados

No site do [Ministério do Trabalho](http://pdet.mte.gov.br/microdados-rais-e-caged), onde é disponibilizado as bases com os microdados da RAIS e CAGED é indicado um [site](http://cemin.wikidot.com/raisr), o qual tem instruções para baixar e importar os microdados da RAIS, usando o R.

A seguir serão mostrados os passos que devem ser seguidos para realizar tal importação de dados. O [script](https://github.com/FundacaoJoaoPinheiro/R/blob/main/RAIS/RAIS.R) que deverá ser executado é mostrado a seguir. Nesse script, inicialmente limpa-se a memória e o console. Em seguida, as bibliotecas necessárias são carregadas. Por fim, é executado o comando `source('http://cemin.wikidot.com/local--files/raisr/rais.r')`, que realiza a conexão com o base de dados e permite sua obtenção.

```{r}
cat("\014")
rm(list = ls())

library(rio)
library(openxlsx)
library(csv)

source('http://cemin.wikidot.com/local--files/raisr/rais.r')

```

Uma vez executado o script, uma série de caixas de diálogo serão exibidas, as quais guiarão o processo de importação dos microdados. A primeira é mostra a seguir.

![rais1](https://user-images.githubusercontent.com/12836843/125288090-1eb4e000-e2f4-11eb-86d3-22812a7260c1.JPG)

Clicar em OK.

![rais2](https://user-images.githubusercontent.com/12836843/125288092-1f4d7680-e2f4-11eb-9d4c-c4eaad15d089.JPG)

Clicar em OK.

![rais3](https://user-images.githubusercontent.com/12836843/125288094-1f4d7680-e2f4-11eb-91e2-66b158cf1ef6.JPG)

Clicar em OK.

![rais4](https://user-images.githubusercontent.com/12836843/125288098-1fe60d00-e2f4-11eb-83b8-bfbbd54423fc.JPG)

Nessa última janela, ao clicar em OK, será aberto uma janela para a escolha da diretório em que serão salvos os arquivos. Após escolher o diretório, clique em Selecionar.

![rais5](https://user-images.githubusercontent.com/12836843/125288101-1fe60d00-e2f4-11eb-895c-409e56cb572f.JPG)

Na última janela, ao clicar em OK, será aberto uma janela para a escolha de arquivos previamente baixados. Caso não haja, basta clicar em Cancelar.

![rais6](https://user-images.githubusercontent.com/12836843/125288102-1fe60d00-e2f4-11eb-8c59-bf314d76867b.JPG)

Clicar em OK.

![rais7](https://user-images.githubusercontent.com/12836843/125288065-1bb9ef80-e2f4-11eb-8969-fb974fe26492.JPG)

Escolher os anos. Segurar a tecla CTRL para selecionar mais de um ano.

![rais8](https://user-images.githubusercontent.com/12836843/125288066-1ceb1c80-e2f4-11eb-9fa8-0946e00a39da.JPG)

Clicar em OK.

![rais9](https://user-images.githubusercontent.com/12836843/125288068-1ceb1c80-e2f4-11eb-9bd2-6321956ceb12.JPG)

Selecionar os estados. Segurar a tecla CTRL para selecionar mais de um estado.

![rais10](https://user-images.githubusercontent.com/12836843/125288069-1ceb1c80-e2f4-11eb-8c81-2369017b675b.JPG)

Clicar em OK.

![rais11](https://user-images.githubusercontent.com/12836843/125288072-1d83b300-e2f4-11eb-936a-99405a976824.JPG)

Selecionar as variáveis de interesse. Segurar a tecla CTRL para selecionar mais de uma variável. 

*Observação*: a seleção de muitas variáveis (mais de 10) fará com que o processo fique muito lento. Caso seja necessário selecionar um grande número de variáveis, é recomendável fazer a importação dos dados por partes.

![rais12](https://user-images.githubusercontent.com/12836843/125288075-1d83b300-e2f4-11eb-8509-a60bf9215c0e.JPG)

Clicar em OK.

![rais13](https://user-images.githubusercontent.com/12836843/125288079-1e1c4980-e2f4-11eb-8c50-016617e1612e.JPG)

Caso deseje baixar os dados de municípios específicos, basta indicar seus códigos, como mostrado na caixa de diálogo. Se desejar baixar os dados de todos os municípios, basta clicar em cancelar.

![rais14](https://user-images.githubusercontent.com/12836843/125288081-1e1c4980-e2f4-11eb-80c4-2021dfea037c.JPG)

Clicar em OK.

![rais15](https://user-images.githubusercontent.com/12836843/125288085-1e1c4980-e2f4-11eb-98b4-3b6d9d4e9473.JPG)

Selecionar os dados que serão baixados e em seguida clicar em OK.

![rais16](https://user-images.githubusercontent.com/12836843/125288088-1eb4e000-e2f4-11eb-8d69-eeaada598f04.JPG)

Os dados serão baixados. Aguarde o fim do processo.

![rais17](https://user-images.githubusercontent.com/12836843/125289414-959ea880-e2f5-11eb-8aff-5cab651cc616.JPG)

Clicar em OK.

![rais18](https://user-images.githubusercontent.com/12836843/125289417-96373f00-e2f5-11eb-97f1-9e8dae01798a.JPG)

Se for realizar mais algum download, clique em Cancelar. Caso contrário, clicar em OK.

![rais19](https://user-images.githubusercontent.com/12836843/125289418-96cfd580-e2f5-11eb-9bf8-067b9ba97ff7.JPG)

Clicar em OK.

Após esse processo, os dados estarão disponíveis em seu ambiente de trabalho no R.
