%   SP500 function
%   Tom Driedger
%   Dec 17, 2007
%   Rev Apr 5, 2008 Change in download path
%   m file obtains current S&P 500 stock listing
%   and feeds into the yahoo query
%   Requires current date to be a weekday


function SP500_to_txt(Index_Code,fileName)

%   Inputs:
%       SP_DATE: Serial date number
%       Index_Code = number
%   Outputs:
%       SP_Listing Array

if nargin<2
    error('The function SP500_to_txt.m need at least 3 arguments');
end

refDate=datestr(datenum(date())-1);

if ~isbusday(refDate)    % if is not a business day, then get the last bus day
        
    Busday = busdate(refDate,-1);
    newDate=datestr(Busday);
    
    str=['Today is not a business day, so the SP500 composition will be ' ...
        'downloaded for the closest business day available.'];
    
    disp(str);
else
    newDate=refDate;
end

SP_Date=newDate;

% the next function will get the curret sp500 composition. The whole
% function was kindly provided by Tom Driedger. Thanks Tom!
% SP_Date='23-APR-2008';

disp(['Downloading SP500 Composition for ' SP_Date '.']);

SP_Listing = get_SP500_tickers(SP_Date,Index_Code); 

n=size(SP_Listing,1)-1;

fid=fopen(fileName,'w');

% the next loop will fix some string issues with the data dowloaded from
% sp500 page

for i=1:n
    token = strtok(SP_Listing{i+1,1},' ');
     
    fprintf(fid,[token{1},'\n']);
end

fclose(fid);

disp(['Most up to date SP500 composition sucessifully saved at ' fileName '.']);



