% 时间序列法预测收益

% 读取加载股票数据
stock_code = "SH000066"; % 股票代码
stock_file = "./stock_data/" + stock_code.lower + ".csv";
stock_table = readtable(stock_file);

data = stock_table.close(end - 400:end, :); % 取表格的部分行作为数据

%% 平稳性检验

% 一阶差分
ddata = diff(data);
% 二阶差分
dddata = diff(ddata);
% 使用ADF、KPSS检验平稳性
d1_adf = adftest(ddata);
d1_kpss = kpsstest(ddata);
d2_adf = adftest(dddata);
d2_kpss = kpsstest(dddata);

if (d1_adf == 1 && d1_kpss == 0)
    disp('一阶差分通过平稳性检验');
    D = 1;
elseif (d2_adf == 1 && d2_kpss == 0)
    disp('二阶差分通过平稳性检验');
    D = 2;
else
    disp("二阶差分仍未通过平稳性检验，可以修改代码继续更高阶差分");
    exit;
end

% 绘图
figure('Name', '平稳性检验', 'NumberTitle', 'off')
subplot(1, D + 1, 1)
plot(data)
xlabel("time")
ylabel("原始数据")
xlim([1 - 2, length(data) + 2])

subplot(1, D + 1, 2)
plot(ddata)
xlabel("time")
ylabel("一阶差分")
xlim([1 - 2, length(data) + 2])

if D == 2
    subplot(1, D + 1, 3)
    plot(dddata)
    xlabel("time")
    xlim([1 - 2, length(data) + 2])
    ylabel("二阶差分")
end

%% 确定模型阶数
% 绘图
figure('Name', 'ACF&PACF', 'NumberTitle', 'off')

% ACF自相关图
if D == 1 % 一阶差分
    subplot(1, 2, 1)
    autocorr(ddata)
elseif D == 2 % 二阶差分
    subplot(1, 2, 1)
    autocorr(dddata)
end

% PACF偏自相关图
if D == 1 % 一阶差分
    subplot(1, 2, 2)
    parcorr(ddata)
elseif D == 2 % 二阶差分
    subplot(1, 2, 2)
    parcorr(dddata)
end

% 计算pq取值
pmax = 4;
qmax = 4;
% [p, q] = findPQ(ddata, pmax, qmax);  % 暴力计算p q值

% 如果自动计算出的 p q 值不理想，则手动设置
p = 8;
q = 8;

%% 构建模型
Mdl = arima(p, D, q); % 使用ARIMA模型
EstMdl = estimate(Mdl, data);

%% 残差检验
[res, ~, logL] = infer(EstMdl, data); %res即残差
stdr = res / sqrt(EstMdl.Variance);
% 绘图
figure('Name', '残差检验', 'NumberTitle', 'off')
subplot(2, 3, 1)
plot(stdr)
title('标准残差')
subplot(2, 3, 2)
histogram(stdr, 10) % 越接近正态分布越好
title('标准残差')
subplot(2, 3, 3)
autocorr(stdr)
subplot(2, 3, 4)
parcorr(stdr)
subplot(2, 3, 5)
qqplot(stdr) % QQ图，蓝点越靠近红线越好

%% 模型预测
step = 50; % 预测步数
[forData, YMSE] = forecast(EstMdl, step, 'Y0', data);
lower = forData - 1.96 * sqrt(YMSE); %95置信区间下限
upper = forData + 1.96 * sqrt(YMSE); %95置信区间上限

% 绘图
figure('Name', '预测', 'NumberTitle', 'off')
plot(data)
hold on
h1 = plot(length(data):length(data) + step, [data(end); lower], 'r:', 'LineWidth', 2);
plot(length(data):length(data) + step, [data(end); upper], 'r:', 'LineWidth', 2)
h2 = plot(length(data):length(data) + step, [data(end); forData], 'k', 'LineWidth', 2);
legend([h1, h2], '95%置信区间', '预测值')
title('Forecast')
hold off
