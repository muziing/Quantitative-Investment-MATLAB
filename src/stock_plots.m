% 股票行情数据绘图

% 读取加载股票数据
stock_code = "SH000066"; % 股票代码
stock_file = "./stock_data/" + stock_code.lower + ".csv";
stock_table = readtable(stock_file);
stock_table1 = stock_table(end - 200:end, :); % 只读取最后的若干列来实验

date = stock_table1.date;
open_price = stock_table1.open;
high_price = stock_table1.high;
low_price = stock_table1.low;
close_price = stock_table1.close;

%% K线图
figure('Name', 'K线', 'NumberTitle', 'off')
candle([open_price, high_price, low_price, close_price])
title(stock_code)
xlim([1 - 2, height(stock_table1) + 2]) % x轴坐标范围
date_labels = datestr(stock_table1.date, 'yyyy-mm-dd'); %中间临时变量，将日期格式化为string
xticks(1:5:height(stock_table1)) %x轴刻度
xticklabels(date_labels(1:5:end, :)) %x轴刻度标签

%% 布林线
window_size = 20;
nstd = 2;
[mid, uppr, lowr] = bollinger(close_price, 'WindowSize', window_size, 'NumStd', nstd);

figure('Name', '布林线', 'NumberTitle', 'off')
plot(date, close_price, 'k');
hold on
plot(date(window_size:end), mid(window_size:end));
plot(date(window_size:end), uppr(window_size:end));
plot(date(window_size:end), lowr(window_size:end));
hold off
legend('close price', 'mid', 'uppr', 'lowr')
xlabel('date')
ylabel('price')
title('bollinger')

%% 竹线图
figure('Name', '高低价竹线图', 'NumberTitle', 'off')
highlow([open_price, high_price, low_price, close_price])
title(stock_code)
xlim([1 - 2, height(stock_table1) + 2])
xticks(1:5:height(stock_table1))
xticklabels(date_labels(1:5:end, :))

%% 卡吉图
figure('Name', 'kagi图', 'NumberTitle', 'off')
kagi(table(date, close_price, 'VariableNames', {'Date', 'price'}))
title(stock_code)
xlim([1 - 2, height(stock_table1) + 2])
xticks(1:5:height(stock_table1))
xticklabels(date_labels(1:5:end, :))

%% 砖形图
figure('Name', '砖形图', 'NumberTitle', 'off')
renko(table(date, close_price, 'VariableNames', {'Date', 'price'}))
