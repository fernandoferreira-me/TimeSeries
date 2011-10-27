%   SP500 function
%   Tom Driedger
%   Dec 17, 2007
%   Rev Apr 5, 2008 Change in download path
%   m file obtains current S&P 500 stock listing
%   and feeds into the yahoo query
%   Requires current date to be a weekday


function SP_Listing = get_SP500_tickers(SP_Date,Index_Code)

%   Inputs:
%       SP_DATE: Serial date number
%       Index_Code = number
%   Outputs:
%       SP_Listing Array

SP_Listing = cell(501,6);

SP_server = 'http://www2.standardandpoors.com/servlet/Satellite';
DL_Location = 'spcom/page/download';
SectorID = '%20%3E%20''00''';
Itemname = '%3E=%20''1''';
if SP_Date; else SP_Date = Date; end;
if Index_Code; else Index_Code = 500; end;
SP_Url = [SP_server ...
          '?pagename=' num2str(DL_Location) ...
          '&sectorid=' num2str(SectorID) ...
          '&itemname=' num2str(Itemname) ...
          '&dt=' num2str(num2str(SP_Date)) ...
          '&indexcode=' num2str(Index_Code)];
url = java.net.URL(SP_Url);

try
    os = openStream(url);
    isr = java.io.InputStreamReader(os);
    br = java.io.BufferedReader(isr);
    %   Reading buffered text      
        reading=1;
        i=1;
        rl = readLine(br);
        SP_Listing(i,:) = textscan(char(rl), '%s%s%s%s%s%s', 'delimiter', ',', 'CollectOutput', 0);

        while reading
          i=i+1; 
          rl = readLine(br);
          if isempty(char(rl));
            reading=0;
            break;
          end;       
          SP_Listing(i,:) = textscan(char(rl), '%s%s%s%f%s%f', 'delimiter', ',', 'CollectOutput', 0);
        end
       
catch
        rethrow(lasterror);
end