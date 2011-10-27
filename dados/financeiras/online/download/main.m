%Faz o downlad de uma lista de ativos


firstDay='01/01/2010';  % First day in sample to be downloaded (format: dd/mm/yyyy)
lastDay ='25/02/2011';  % Last day in sample to be downloaded (format: dd/mm/yyyy)
Criteria=.05;           % Percent of missing prices for bad data event
Freq='d';               % Frequency ('d'-dailly ; 'w' - Weekly, 'm' - monthly)

%benchTicker='^GSPC';%Índice SP500
benchTicker='^BVSP';%Ibovespa

%ticker_fileName='acoes_ibov27-02-2011.txt';
ticker_fileName='bluechips.txt';  % the name of the ticker txt file
n_stocks=1;            % Number of stocks to download data (according to tickers.txt)


[x]=download(firstDay,lastDay,ticker_fileName,n_stocks, Criteria, Freq,benchTicker);
