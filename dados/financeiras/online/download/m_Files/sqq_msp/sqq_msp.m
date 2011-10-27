function [varargout] = sqq(varargin)
% SQQ -- calls STOCKQUOTEQUERY to fetch historical stock prices for a given ticker symbol
%     from the YAHOO web serve using the MATLAB Java URL interface.  SQQ allows
%     for greater flexibility of inputs, but the main code is in STOCKQUOTEQUERY 
%
%     v1.2 Michael Boldin 10/4/2003
%
%     STOCKQUOTEQUERY is based on parts of GETSTOCKDATA by Peter Webb of Mathworks, 
%     as explained in the October 2002 MATLAB News and Notes article
%     "Internet Enabled Data Analysis and Visualization with MATLAB"  
%     See STOCKQUOTEQUERY notes for corrections of problems and additional
%     features
%
%
% VARARGOUT: [date, close, open, low, high, volume, closeadj]
%
%      If NARGOUT=0, the arrays [date, close, open, low, high, volume, closeadj]
%      are created in 'base' memory.
%
%      If NARGOUT=1, output is single matrix will the full set of data items.
%
%      In the NARGOUT=3 case, output is [date, close, volume]
%
%      Otherwise in the NARGOUT=5 case, the full set of data items are placed into 
%      output arrays in the order [date, close, open, low, high, volume, closeadj]
%       
%      Last output item, closeadj, is usually the same as close in recent periods 
%      but adjusts for stock split in longer historical data.  The closeadj/close ratio 
%      can be used to adjust open, high, low.  Use close/closeadj to adjust volume.
%
%
% VARARGIN: (symbol, date1 or N, date2 or N, frequency)
%
%    If no inputs, keyboard/console inputs are required
%
%    Input Options-- VARARGINs 1 to 4
%
%    (SYMBOL). Single string only.  Assumes last day is today and queries includes the last 7 days. 
%
%    (SYMBOL, N).  Query covers last N days, using today for the last day.  
%
%    (SYMBOL, DATE1, N).  If N < 0, DATE1 is last day, and query covers the prior N days.  
%                         If N > 0, DATE1 is first day, and query covers the next N days.  N <= 5*365 required. 
%
%    (SYMBOL, DATE1, DATE2).  
%         DATE1:  START_DATE  date string or numeric
%         DATE2:  END_DATE date string or numeric.  (The date numeric must be > 5*365. 
%         DATE Inputs will be reordered if DATE1 > DATE2  
%
%    (SYMBOL, DATE1, N or DATE2, FREQUENCY).
%         Fourth input determine FREQUENCY: Daily ('d'), Weekly ('w'), or Monthly ('m')
%         The default FREQUENCY is 'd'.
%
%   These options make the following four cases equivalent
%       sqq('ibm')
%       sqq('ibm',7)
%       sqq('ibm',today,-7)
%       sqq('ibm',today-7,today)
%       sqq('ibm',today,today-7)
%       sqq('ibm',today,today-7,'d')
%
%     Note that N is always interpretted as days, and N is not limitted to trading days 
%     (when the stock market is open).  Thus, frequency does not affect how N is applied, 
%     i.e.  frequency = 'm' does not turn N into months 
%      
% Outputs:  Parallel vectors (column arrays) or single output matrix if NVARGOUT=1. 
%   DATE:       Date for the quote
%   CLOSE:      Closing market price
%   OPEN:       Opening price
%   HIGH:       High price (during trading day or frequency period)
%   LOW:        Low price (during trading day or frequency period)
%   VOLUME:     Volume (during trading day or frequency period)
%   CLOSEADJ:   Close Adjusted for Splits 
%

% disp 'Stock Quote Query';

%extra step to ensure usable 'today' date; 
date_today=floor(731857);
try;
    date_today=today;
catch
    date_today=floor(now);
end;
if date_today < 731857;
  date_today=floor(731857);
end;

%Frequency default is daily 
freq= 'd';

%nargin

%Look at input arguments to determine query parameters
%No arguments-- need to ask for inputs
if ( nargin == 0 )
    symbol=input('Input ticker symbol: ','s');
    symbol=upper(symbol);
    
    sdate=input(['End date (use blank for today, ' datestr(date_today) ' ): '],'s');
    try;
        if isempty(sdate); 
            date2=date_today;
        else
            date2=datenum(char(sdate));
            date2ck=datestr(date2);
        end;
    catch;
        error(['Can not interpret date, please start over' sdate]); 
        return
    end;
    
    snum=input('Start Date or days back as number (use blank for 7 days): ','s');
    
    try, date1=datenum(char(snum)); catch, date1=[]; end;
    
    try;
        if isempty(snum); 
            date1=datenum(date2)-7;
        elseif ~isempty(date1);
            date1=date1; %date1 should be OK;  
        else  
            date1=date2-str2num(snum);  
        end;
    catch;
        error(['Problem with input number, please start over']); 
        return
    end;
    
end;    

if nargin >= 1
try
    
    symbol= varargin{1};
    symbol=upper(symbol);
    
    %One argument case, just stock symbol, get last seven days
    if ( nargin == 1 )
        date2= date_today;
        date1= date2 - 7;
        
        %Two argument case,  stock symbol and N days
    elseif ( nargin == 2 );
        v2= varargin{2};
        if isnumeric(v2)
            date2= date_today;
            v2= abs(v2);
            date1= date2 - v2;
        else
            disp(['*** Problem with Inputs, Please start over']);
            disp(varargin);
            return
        end
        
        %Three or four argument cases,  stock symbol and both start and end dates, or start is a N number
        %Fourth argument is frequency 
    elseif ( nargin == 3 | nargin == 4 )
        v2= varargin{2};
        v3= varargin{3};
        if ( nargin == 4 )
            freq= varargin{4};
        end;  
        
        if isnumeric(v3) & v3 <= 5*365;
            if ( v3 <= 0 );
                date2= datenum(v2);
                date1= date2 + v3;
            else;
                date1= datenum(v2);
                date2= date1 + v3;
            end;
        else;
            date1= datenum(v2);
            date2= datenum(v3);
            if date1 > date2; %switch dates;
                date1= datenum(v3);
                date2= datenum(v2);
            end;    
        end;
        
    elseif ( nargin > 4 );
        disp(['*** Too many inputs, four at most (symbol, date1, date2 or N, freq), Please start over']);
        disp(varargin);
        return
        
    end;    
    
catch
    disp(['*** Problem with Inputs, Please start over']);
    disp(varargin);
    return
    
end
end

%Always convert to date string for  stockquotequery function 
start_date=datestr(date1);  
end_date=datestr(date2);    

%check ticker symbol
try;
    symbol_numeric_ck= ~isempty(str2num(symbol));
    symbol_length=size(symbol,2);
end;

% disp(' ');     
%Confirm symbol and dates are OK
if isempty(symbol) | symbol_numeric_ck | (symbol_length > 6);
    disp(['*** Problem with Ticker Symbol-- ' symbol '-- empty, number, or too long']); 
    disp('*** Please start over');
elseif ( datenum(end_date) >=  datenum(start_date) )
%     disp('Starting query');
%     disp(['Ticker Symbol: ' symbol ' , Start Date: ' datestr(start_date) ' , End Date: ' datestr(end_date)]);
%     disp(['Covering ' num2str(datenum(end_date) - datenum(start_date)+1) ' total days (potentially)']);
else
    disp(['*** Problem with dates, please start over']);
    disp(['*** Check Start Date: ' start_date '  End Date: ' end_date]);
end;

[date, close, open, low, high, volume, closeadj] ...
     = StockQuoteQuery(symbol, start_date, end_date, freq);

if isempty(close);
   disp(['PROBLEM FOUND ... full extract NOT MADE for ' symbol  ]);
else;
   nr_date=size(date,1); 
   n_close=sum(close > 0);
%    disp(['Done ... extracted ' num2str(n_close) ' valid stock price observations'  ...
%       ' over ' num2str(nr_date) ' dates' ]);
end;

 %Now output part
 if nargout == 1;  
     varargout{1} = [date close open low high volume closeadj];
     
 elseif nargout == 2; 
     varargout{1} = date;
     varargout{2} = close; 
     
 elseif nargout == 5; 
     varargout{1} = date;
     varargout{2} = close;
     varargout{3} = open;
     varargout{4} = low;
     varargout{5} = high; 
     
 elseif nargout == 7; 
     varargout{1} = date;
     varargout{2} = close;
     varargout{3} = open;
     varargout{4} = low;
     varargout{5} = high; 
     varargout{6} = volume;
     varargout{7} = closeadj;
     
 elseif nargout == 0;
     assignin('base','date',date);
     assignin('base','close',close);
     assignin('base','open',open);    
     assignin('base','low',low);
     assignin('base','high',high);
     assignin('base','volume',volume);    
     assignin('base','closeadj',closeadj);
     
 end;
 
%end of --SQQ-- function


