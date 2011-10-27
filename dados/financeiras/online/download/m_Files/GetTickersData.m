%{
Function for Downloading Trading Data from Yahoo

This is a simple algorithm that downloads trading data from yahoo based on a set of tickers
and user options.

The main advantage of this function is that it controls for bad data or for
the cases where yahoo server doesn't have the data you want. You can also set a
critera for bad data (eg. missing 5% of valid prices, when comparing to a full date ticker).
When bad data is found, the function skips that particular asset.

It is basicly a large scale application of sqq.m which is originally submited by
Michael Boldin, link at FEX description.

The steps of the algorithm are:

1) Get tickers from tickers.txt (you can change this file for you own purpose)
1) Download data using sqq() (controlling for bad data and missing prices)
2) Substitute values of 0 (price=0) for the most closest previous price
(this way you set return on that date = 0. This substitution shouldn't happen
much. You can control the filter for this event by using a reasonable value for variable Critera)

Please notes that SP500 changes composition over time. The composition
for the function is from 01-july-07.

INPUT:

    firstDay    - Date in string notation. First date in sample (format: dd/mm/yyyy)

    lastDay    - Date in string notation. Last date in sample (format: dd/mm/yyyy)

    n_stocks    - Number of stocks which to get data from sp500 (in the same order as ticker.txt)

    ticker_fileName - Name of the txt file with the ticker (check the file itself for the structure)

    Freq        - (optional,default='d'). Frequency of data. Options: 'd' dailly, 'w' weekly, 'm', monthlly

    P_Criteria    - (optional, default=.05). The percentage of a full valid price vector (from a valid ticker eg. IBM)
                  that will set how many missing prices is enough to set bad data event (and cut such stock
                  from the downloaded database.

    benchTicker - The benchmark ticker that is going to be used to compare all dates in the data.

OUTPUT:

    SPData - A structure with the folowning fields:

    Date
    Close
    Open
    High
    Low
    Volume
    Closeadj
    Valid_Tickers - The downloaded valid tickers (those with enough valid prices and no yahoo problems)

    In such matrices, each collum represents each asset

Author: Marcelo Scherer Perlin
Contact:  marceloperlin@gmail.com
Phd Student, Reading University - ICMA/UK

Fell free to use it and/or modify it for your own interest.

%}

function [SPData]=GetTickersData(firstDay,lastDay,n_stocks,ticker_fileName,Freq,P_Criteria,benchTicker)

if nargin()<4
    error('The function needs at least 4 inputs');
end

switch nargin()
    case 4
        Freq='d';
        P_Criteria=.05;
        benchTicker='^GSPC';    % SP500 ticker
    case 5
        P_Criteria=.05;
        benchTicker='^GSPC';    % SP500 ticker
    case 6
        benchTicker='^GSPC';    % SP500 ticker
end



if ~any([strcmp(Freq,'d') strcmp(Freq,'w') strcmp(Freq,'m')])
    error('The input Freq should be ''d'' for dailly data, ''w'' for weekly data or ''m'' for montly.')
end

if (exist(ticker_fileName,'file'))==0
    error(['The required file ' ticker_fileName ' was not found at working directory. Please check it.']);
end

if P_Criteria>1
    error('The input Criteria is a percentage and therefore lower than 1');
end

% Conversion of dates (from dd/mm/yyyy to mm/dd/yyyy)

firstDay=datestr(datenum(firstDay,'dd/mm/yyyy'),'mm/dd/yyyy');
lastDay=datestr(datenum(lastDay,'dd/mm/yyyy'),'mm/dd/yyyy');

% Getting ticker from ticker.txt

fid = fopen(ticker_fileName, 'r');
a=textscan(fid, '%s','delimiter',' ');
fclose(fid);

tickers=a{1,1};

fprintf(1,'\nDownloading BenchMark Ticker for Date comparisons <-');

% Downloading IBM for date comparinson (from my tests IBM is a reliable
% stock regarding dates)

try
    first_out=sqq_msp(benchTicker,lastDay,firstDay,Freq);
catch
    error('Problem with downloading data for the benchMark ticker. Please check internet conection  or ticker value and try again..');
end

% creting Criteria for bad data. When number of missing prices is higher than Criteria,
% then the stock is removed from database

Criteria=floor(P_Criteria*length(first_out));

fprintf(1,['Download complete:\n First Date in data -> ',datestr(first_out(1,1)),'\n Last  Date in data -> ',datestr(first_out(end,1))])
fprintf(1,['\nCriteria for bad data is: ',num2str(Criteria),' missing prices.\n']);

Date(:,1)=first_out(:,1);

fprintf(1,'\n-> Starting Yahoo Downloads <-');

Invalid_Tickers{1,1}='None';

idxInvalid=0;
idx=0;
missingPriceTable=zeros(1,n_stocks);
StatusCell=cell(1,n_stocks);
missingDates=cell(1,n_stocks);

for i=1:n_stocks
    missingDates{1,i}=cell(1,1);
    missingDates{1,i}{1,1}='None';
end

for i=1:n_stocks
    try
        fprintf(1,['\nAsset #',num2str(i),' - Ticker: ',tickers{i},' --> ']);
        
        out=sqq_msp(tickers{i},lastDay,firstDay,Freq);
        
        if size(out,1)==size(first_out(:,1),1) % cases where the dates match
            
            idx=idx+1;
            
            Date(:,idx)=out(:,1);
            Close(:,idx)=out(:,2);
            Open(:,idx)=out(:,3);
            Low(:,idx)=out(:,4);
            High(:,idx)=out(:,5);
            Volume(:,idx)=out(:,6);
            Closeadj(:,idx)=out(:,7);
            
            fprintf(1,'DL OK. Dates fully matching.');
            Valid_Tickers{1,idx}=tickers{i};
            
            StatusCell{1,i}='OK';
            
        elseif (length(first_out(:,1))-length(out(:,1)))<Criteria % cases where the dates DONT match
            
            idx=idx+1;
            
            for j=1:size(out,1) % this loop will set all prices according to matching dates of valid ticker (in this case IBM)
                
                [a]=find(out(j,1)==Date(:,1));
                
                Date(a,idx)=out(j,1);
                Close(a,idx)=out(j,2);
                Open(a,idx)=out(j,3);
                Low(a,idx)=out(j,4);
                High(a,idx)=out(j,5);
                Volume(a,idx)=out(j,6);
                Closeadj(a,idx)=out(j,7);
                
            end
            
            %             =length(first_out(:,1))-length(out(:,1));
            
            fprintf(1,['DL OK, but is missing ',num2str(length(first_out(:,1))-length(out(:,7))),' price(s)']);
            Valid_Tickers{1,idx}=tickers{i};
            
            StatusCell{1,i}='OK';
            [datesOut]=findMissingDates(out(:,1),first_out(:,1));
            missingPriceTable(1,i)=length(datesOut);
            missingDates{1,i}=datesOut;
            
        else
            fprintf(1,'DL OK, but number of missing prices is higher than criteria. Skipping this one.');
            
            StatusCell{1,i}='Not OK. Number of missing prices higher than criteria.';
            %             missingPriceTable(1,i)=length(first_out(:,1))-length(out(:,1)
            %             );
            [datesOut]=findMissingDates(out(:,1),first_out(:,1));
            missingDates{1,i}=datesOut;
            missingPriceTable(1,i)=length(datesOut);
            idxInvalid=idxInvalid+1;
            Invalid_Tickers{1,idxInvalid}=tickers{i};
        end
        
    catch
        fprintf(1,'No Data found in Yahoo, skipping this one');
        
        StatusCell{1,i}='No Data Found in Yahoo.';
        
        idxInvalid=idxInvalid+1;
        Invalid_Tickers{1,idxInvalid}=tickers{i};
        continue
    end
end

% fixing cases where the first price = 0 (this would be a problem in the
% substituion part

[a]=find(Close(1,:)==0);

for j=1:size(a,2)
    for i=1:size(Close,1)
        if Close(i,a(j))~=0
            
            Close(1,a(j))=Close(i,a(j));
            Closeadj(1,a(j))=Closeadj(i,a(j));
            High(1,a(j))=High(i,a(j));
            Low(1,a(j))=Low(i,a(j));
            Open(i,a(j))=Open(i,a(j));
            
            break;
        end
    end
    
end

% Replacing prices = 0 with the oldest availabe price

for i=2:size(Close,1)
    for j=1:size(Close,2)
        if Close(i,j)==0
            
            Close(i,j)=Close(i-1,j);
            Closeadj(i,j)=Closeadj(i-1,j);
            High(i,j)=High(i-1,j);
            Low(i,j)=Low(i-1,j);
            Open(i,j)=Open(i-1,j);
            
        end
    end
end

% Conversion of dates (from mm/dd/yyyy to dd/mm/yyyy)

firstDay=datestr(datenum(firstDay,'mm/dd/yyyy'),'dd/mm/yyyy');
lastDay=datestr(datenum(lastDay,'mm/dd/yyyy'),'dd/mm/yyyy');

% Saving it all in the structure

SPData.Close=Close;
SPData.Closeadj=Closeadj;
SPData.Date=Date;
SPData.missingPriceTable=missingPriceTable;
SPData.StatusCell=StatusCell;
SPData.missingDates=missingDates;

for i=1:size(Date,1)
    SPData.DateStr{i,1}=datestr(Date(i,1));
end

SPData.Open=Open;
SPData.Volume=Volume;
SPData.Low=Low;
SPData.High=High;
SPData.Valid_Tickers=Valid_Tickers;

SPData.Invalid_Tickers=Invalid_Tickers;

SPData.Query.firstDay=firstDay;
SPData.Query.lastDay=lastDay;
SPData.Query.n_stocks=n_stocks;
SPData.Query.Freq=Freq;
SPData.Query.P_Criteria=P_Criteria;
SPData.Query.tickers=tickers;
SPData.Query.timeofQuery=datestr(now);

fprintf(1,'\n');

function [datesOut]=findMissingDates(datesAsset,datesBench)

datesOut=cell(1,1);

idx=1;
for i=1:size(datesAsset,1)
    myDate=datesBench(i);
    if sum(myDate==datesAsset)==0
        datesOut{idx,1}=datestr(myDate,'dd/mm/yyyy');
        idx=idx+1;
    end
end

