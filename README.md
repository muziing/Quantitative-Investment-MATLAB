# Quantitative Investment

量化投资（非专业课程）作业代码，MATLAB语言。仅为练习与学习基础理论只用，不应用于实践。

![MATLAB version](https://img.shields.io/badge/MATLAB-R2022a-blue)

## 项目结构

所有源码位于 [src](src/) 目录下。

- [股票行情数据绘图](src/stock_plots.m) - 绘制K线图、布林线图、竹线图、卡吉图、砖线图等
- [时间序列法预测](src/time_series.m) - 由某支股票过去一段时间的情况使用时间序列分析方法预测未来
- [马科维茨组合投资理论](src/markowitz_portfolio.m) - 组合投资优化、有效前沿、具有约束的组合投资等
- [股票数据下载脚本](src/Python_Scripts/download_stock.py) - 一个简易的调用 [AKShare](https://github.com/akfamily/akshare) 接口下载股票数据的 Python 脚本
