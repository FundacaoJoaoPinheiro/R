# CAGED

A importação dos microdados do CAGED de é realizada de forma offline, 
isto é, os arquivos precisam ser baixados e salvos no computador antes de ser executada.

Os microdados do CAGED estão disponíveis no formato “7z” e ainda não existem pacotes no R para esse formato (os pacotes unzip e unz, disponíveis para extrair arquivos em zip no R, funcionam somente com extensão “.zip”). Então será necessário fazer o download dos microdados da CAGED disponíveis no site: ftp://ftp.mtps.gov.br/pdet/microdados/ e em seguida utilizar algum programa extrator de arquivos no formato 7z.

Recomenda-se o [7zip](https://www.7-zip.org/download.html) ou [WinRAR](https://www.win-rar.com/postdownload.html?&L=0) por serem softwares gratuitos. 

Feito o download dos microdados CAGED e do programa para extração no computador, basta extrair os arquivos dos microdados em sua pasta de trabalho.