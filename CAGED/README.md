# CAGED - Cadastro Geral de Empregados e Desempregados

A importação dos microdados do CAGED de é realizada de forma offline, 
isto é, os arquivos precisam ser baixados e salvos no computador antes de ser executada.

Os microdados do CAGED estão disponíveis no formato “7z” e ainda não existem pacotes no R para esse formato (os pacotes unzip e unz, disponíveis para extrair arquivos em zip no R, funcionam somente com extensão “.zip”). Então será necessário fazer o download dos microdados da CAGED disponíveis em: ftp://ftp.mtps.gov.br/pdet/microdados e em seguida utilizar algum programa extrator de arquivos no formato 7z. 

*Observação*: o site só funciona pelo navegador internet explorer.

Recomenda-se o [7zip](https://www.7-zip.org/download.html) ou [WinRAR](https://www.win-rar.com/postdownload.html?&L=0) por serem softwares gratuitos. 

Feito o download dos microdados CAGED e do programa para extração no computador, basta extrair os arquivos dos microdados em sua pasta de trabalho.

A estrutura do script pode ser visulizada [aqui](https://github.com/FundacaoJoaoPinheiro/R/blob/main/CAGED/CAGED.md), enquanto o scrip completo pode ser acessado [aqui](https://github.com/FundacaoJoaoPinheiro/R/blob/main/CAGED/CAGED.R).

Um vídeo explicativo sobre o script pode ser visualizado [aqui](https://drive.google.com/file/d/1i9CYRVJBO0J7RikeMjBzRzqfc0ArsKeZ/view?usp=sharing)
