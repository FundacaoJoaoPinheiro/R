# Produção Agrícola Municipal (PAM) - IBGE

Exemplos de extração online e offline de dados relativos à Produção Agrícola Municipal podem ser encontrado  [aqui](https://github.com/FundacaoJoaoPinheiro/R/blob/main/PAM/PAM_importacao.md). 

Observe que a consulta aos dados do IBGE, seja por meio da função `get_sidra` ou através de uma url, só é possível se a consulta retorna até 50.000 observações. Caso deseje realizar uma consulta que retorne mais dados, ela terá que ser feita de forma parcial, como por exemplo, por ano ou UF. Para cada consulta deve-se salvar um arquivo. No script, faz-se a leitura dos arquivos e os dados são unificados.

Exemplos de gráficos que podem ser obtidos a partir dos dados extraídos no script anterior podem ser encontrados [aqui](https://github.com/FundacaoJoaoPinheiro/R/blob/main/PAM/PAM_visualizacao.md).

Os scripts completos podem ser obtidos a seguir:

  * [Importação](https://github.com/FundacaoJoaoPinheiro/R/blob/main/PAM/PAM_importacao.R);
  * [Visualização](https://github.com/FundacaoJoaoPinheiro/R/blob/main/PAM/PAM_visualizacao.R).

*Observação*: o script de importação utiliza arquivos que foram obtidos no sidra. Eles podem ser obtidos [aqui](https://drive.google.com/file/d/1oP2fNwh_XjzKqgqeei-voXhfEv_3U-az/view?usp=sharing).
