# Pesquisas do IBGE

Aqui você encontra exemplos de como realizar a importação, manipulação e visualização
de dados para várias pesquisas do IBGE:

 * [PAC - Pesquisa Anual de Comércio](https://github.com/FundacaoJoaoPinheiro/R/tree/main/Pesquisas%20do%20IBGE/PAC);
 * [PAM - Produção Agrícola Municipal](https://github.com/FundacaoJoaoPinheiro/R/tree/main/Pesquisas%20do%20IBGE/PAM);
 * [PIA - Pesquisa Industrial Anual](https://github.com/FundacaoJoaoPinheiro/R/tree/main/Pesquisas%20do%20IBGE/PIA);
 * [PIB - Produto Interno Bruto](https://github.com/FundacaoJoaoPinheiro/R/tree/main/Pesquisas%20do%20IBGE/PIB).

Observe que a consulta aos dados do IBGE, seja por meio da função `get_sidra` ou através de uma url, só é possível se a consulta retorna até 50.000 dados. Caso deseje realizar uma consulta que retorne mais dados, ela terá que ser feita de forma parcial, como por exemplo, por ano ou UF. Para cada consulta deve-se salvar um arquivo. No script, faz-se a leitura dos arquivos e os dados são unificados.
