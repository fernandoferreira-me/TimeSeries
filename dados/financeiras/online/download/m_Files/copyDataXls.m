% Function for copying Trading Data from Matlab to Excel
%  
%   INPUT:  myData - a structure from the use of GetTickersData()
%           fileName - the name of the excel file to be created
%
%   OUTPUT: None. An excel file is created in working directory

function copyDataXls(myData,fileName)

if ~strcmp(fileName(end-3:end),'.xls')
    error('The fileName argument should end with .xls (e.g. fileName=''myFile.xls''. ');
end

if size(myData.Close,2)>250
    warning('If youre using excel 2003, the maximum number of columns is 256. Excel may not let you copy the data (or some will be lost).')
end

fprintf(1,['\nCopying Data to ' fileName '.\n'])
fprintf(1,'(this may take a while...)\n')
copyfile([pwd '\sourceXls\sourceXls.xls'],fileName);

Query=myData.Query;

fprintf(1,'\n-> Copying Tickers.')
xlswrite(fileName,myData.Valid_Tickers,'OpeningPrice','b1')
xlswrite(fileName,myData.Valid_Tickers,'ClosingPrice','b1')
xlswrite(fileName,myData.Valid_Tickers,'AdjustedClosingPrice','b1')
xlswrite(fileName,myData.Valid_Tickers,'Volume','b1')
xlswrite(fileName,myData.Valid_Tickers,'Low','b1')
xlswrite(fileName,myData.Valid_Tickers,'High','b1')

fprintf(1,'\n-> Copying Date Vector.')
xlswrite(fileName,myData.DateStr,'OpeningPrice','a2')
xlswrite(fileName,myData.DateStr,'ClosingPrice','a2')
xlswrite(fileName,myData.DateStr,'AdjustedClosingPrice','a2')
xlswrite(fileName,myData.DateStr,'Volume','a2')
xlswrite(fileName,myData.DateStr,'Low','a2')
xlswrite(fileName,myData.DateStr,'High','a2')

fprintf(1,'\n-> Copying Numeric Data.')
xlswrite(fileName,myData.Open,'OpeningPrice','b2')
xlswrite(fileName,myData.Close,'ClosingPrice','b2')
xlswrite(fileName,myData.Closeadj,'AdjustedClosingPrice','b2')
xlswrite(fileName,myData.Volume,'Volume','b2')
xlswrite(fileName,myData.Low,'Low','b2')
xlswrite(fileName,myData.High,'High','b2')

fprintf(1,'\n-> Copying Data Handling Report.')

dataHandlingTable=cell(3,Query.n_stocks);
for i=1:Query.n_stocks
    dataHandlingTable{1,i}=Query.tickers{i};
    dataHandlingTable{2,i}=myData.StatusCell{i};
    dataHandlingTable{3,i}=myData.missingPriceTable(i);
    
    for j=1:size(myData.missingDates{1,i},1)
        dataHandlingTable{3+j,i}=myData.missingDates{1,i}{j,1};
    end
end


xlswrite(fileName,dataHandlingTable,'DataHandling Report','b1')

summary=cell(17,1);

summary{1}=Query.timeofQuery;

summary{3}=Query.firstDay;
summary{4}=datestr(datenum(myData.DateStr{1}),'dd/mm/yyyy');

summary{6}=Query.lastDay;
summary{7}=datestr(datenum(myData.DateStr{end}),'dd/mm/yyyy');

switch Query.Freq
    case 'd'
        summary{9}='Dailly';
    case 'w'
        summary{9}='Weekly';
    case 'm'
        summary{9}='Monthly';
end

summary{10}=size(myData.Closeadj,1);

summary{12}=Query.n_stocks;
summary{13}=size(myData.Closeadj,2);

summary{15}=[num2str(Query.P_Criteria*100) '%'];
summary{16}=summary{12}-summary{13};

for i=1:size(myData.Invalid_Tickers,2)
    summary{17,i}=myData.Invalid_Tickers{1,i};
end

fprintf(1,'\n-> Copying Summary Data.\n')

xlswrite(fileName,summary,'Summary','b1')