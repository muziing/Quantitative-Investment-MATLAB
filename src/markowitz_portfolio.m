% 马科维茨组合投资优化

data_file = "./stock_data/four_stocks.csv";
data_table = readtable(data_file);
data = data_table{end:-1:1, :}; % 股价数据矩阵

%% 数据分析
% 股价数据
figure('Name', '股价数据', 'NumberTitle', 'off')
subplot(2, 2, 1)
plot(data(:, 1))
subplot(2, 2, 2)
plot(data(:, 2))
subplot(2, 2, 3)
plot(data(:, 3))
subplot(2, 2, 4)
plot(data(:, 4))

% 计算收益率、平均收益率、协方差
return_rate = (data(2:end, :) - data(1:end - 1, :)) ./ data(1:end - 1, :); % 每日收益率矩阵
%ExpReturn = mean(return_rate); % 平均日收益率
ExpVariance = var(return_rate); % 方差
%ExpCovariance = cov(return_rate); % 协方差

% DecayFactor = 0.98;  % 衰减因子
DecayFactor = 1; % 使用默认的等权线性移动平均模型（BIS）
[ExpReturn, ExpCovariance] = ewstats(return_rate, DecayFactor); % 使用ewstats 函数替代逐个计算

fprintf("平均日收益率：\n")
disp(ExpReturn)
fprintf("收益率方差：\n")
disp(ExpVariance)
fprintf("协方差矩阵：\n")
disp(ExpCovariance)

% 绘图
figure('Name', '收益率数据', 'NumberTitle', 'off')
subplot(2, 2, 1)
plot(return_rate(:, 1))
subplot(2, 2, 2)
plot(return_rate(:, 2))
subplot(2, 2, 3)
plot(return_rate(:, 3))
subplot(2, 2, 4)
plot(return_rate(:, 4))

%% 组合优化
% https://ww2.mathworks.cn/help/finance/portfolio.html

% 创建并配置Portfolio对象
p = Portfolio;
p = Portfolio(p, 'AssetList', data_table.Properties.VariableNames); % 池内资产名称
p = Portfolio(p, 'assetmean', ExpReturn, 'assetcovar', ExpCovariance);
p = Portfolio(p, 'lowerbudget', 1, 'upperbudget', 1); % 上、下界预算约束
p = Portfolio(p, 'lowerbound', 0); % 下界约束

% 绘图：有效前沿
figure('Name', '有效前沿', 'NumberTitle', 'off')
plotFrontier(p);

% 求解最优投资组合
NumPorts = 4;
PortWts = estimateFrontier(p, NumPorts);
[PortRisk, PortReturn] = estimatePortMoments(p, PortWts);
pnames = cell(1, NumPorts);

for i = 1:NumPorts
    pnames{i} = sprintf('Port%d', i);
end

Blotter = dataset([{PortWts}, pnames], 'obsnames', p.AssetList);
fprintf("投资组合：\n")
disp(Blotter)

pwgt = estimateFrontierLimits(p); % 获得端点投资组合
prsk = estimatePortRisk(p, pwgt); % 显示pwgt中每个投资组合收益的标准差
fprintf("投资组合的风险向量：\n"); % 估计投资组合的风险向量
disp(prsk)

%% 有效前沿投资组合的最佳资本分配（旧代码风格）
% 注：本小节中代码均为旧版本MATLAB代码，新版应使用Portfolio对象工作流！

RisklessRate = 0.08; % 无风险贷款利率

[RiskyRisk, RiskyReturn, RiskyWts] = portalloc(PortRisk, PortReturn, PortWts, RisklessRate);

fprintf("最佳风险组合的标准偏差：\n")
disp(RiskyRisk)
fprintf("每个风险资产有效前沿组合的预期收益：\n")
disp(RiskyReturn)
fprintf("分配给最佳风险投资组合的权重：\n")
disp(RiskyWts)

%% 带有约束条件的资产组合

% 旧版MATLAB风格代码：
NumAssets = 4;
PVal = 1; % 将投资组合值的比例改为1
AssetMin = 0; % 单支可以购入的最小比例
AssetMax = [0.5, 0.9, 0.5, 0.8]; % 最大比例
GroupA = [1, 1, 0, 0];
GroupB = [0, 0, 1, 1];
AtoBmax = 1.5; % A组的资产价值最多是B组价值的1.5倍
ConSet = portcons('PortValue', PVal, NumAssets, 'AssetLims', ...
    AssetMin, AssetMax, NumAssets, 'GroupComparison', GroupA, NaN, ...
    AtoBmax, GroupB); % 构建约束条件矩阵

% 使用ConSet构建约束条件矩阵，并作为参数传递给portopt已过时被弃用，
% 应改为配置 Portfolio 对象中的相关属性！

% 将股票1、2分为A组；股票3、4分为B组；
% 限制A组对B组最低比例配置为0.4；最高比例配置为1.5
p = Portfolio(p, 'groupa', [1, 1, 0, 0], 'groupb', [0, 0, 1, 1], ...
'lowerratio', 0.4, 'upperratio', 1.5);

% 绘图：有效前沿
figure('Name', '有效前沿【分组约束版】', 'NumberTitle', 'off')
plotFrontier(p);

% 求解最优投资组合
NumPorts = 4;
PortWts = estimateFrontier(p, NumPorts);
[PortRisk, PortReturn] = estimatePortMoments(p, PortWts);
pnames = cell(1, NumPorts);

for i = 1:NumPorts
    pnames{i} = sprintf('Port%d', i);
end

Blotter = dataset([{PortWts}, pnames], 'obsnames', p.AssetList);
fprintf("投资组合（分组约束版）：\n")
disp(Blotter)

pwgt = estimateFrontierLimits(p); % 获得端点投资组合
prsk = estimatePortRisk(p, pwgt); % 显示pwgt中每个投资组合收益的标准差
fprintf("投资组合的风险向量（分组约束版）：\n"); % 估计投资组合的风险向量
disp(prsk)
