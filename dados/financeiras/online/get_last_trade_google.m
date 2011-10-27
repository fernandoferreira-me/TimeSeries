% Get Google Finance Stock Quote 
% LuminousLogic.com

% The following script retrieves the "last trade" price for a given
% stock ticker symbol

% ex: last_trade = get_last_trade_google('AAPL');

function last_trade = get_last_trade_google(stock_symbol)

stock_symbol = upper(stock_symbol);

function get_last_trade_google();
% Open connection to Google Finance statistics page
fprintf(1,'Retrieving Google Finance quote (last trade) for %s...', stock_symbol);
url_name = strcat('http://www.google.com/finance?q=',  stock_symbol);
url     = java.net.URL(url_name);       % Construct a URL object
is      = openStream(url);              % Open a connection to the URL
isr     = java.io.InputStreamReader(is);
br      = java.io.BufferedReader(isr);

% Cycle through the source code until we're close to the last trade...
while 1
    line_buff = char(readLine(br));
    ptr       = strfind(line_buff, '<script>google.finance.renderRelativePerformance();</script>');
    
    % ...And break when we find it
    if length(ptr) > 0,break; end
end

% Now increment a few lines to get to the last trade
for i=1:10
    line_buff = char(readLine(br));
end

% Extract the last trade value
ptr_gt      = strfind(line_buff,'>');
ptr_lt      = strfind(line_buff,'<');
last_trade  = str2num(line_buff(ptr_gt(1)+1:ptr_lt(2)-1));
if length(last_trade) == 0
    fprintf(1,'N/A\n');
else
    fprintf(1,' = %3.2f\n', last_trade);
end
end