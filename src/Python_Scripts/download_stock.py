from os import system

import sys

try:
    import akshare as ak
except ModuleNotFoundError:
    print("检测到Python环境中未安装 AKShare，尝试安装……")
    pip_install_cmd = "pip install akshare -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host=mirrors.aliyun.com  --upgrade"
    system(pip_install_cmd)
    import akshare as ak

if len(sys.argv) > 1:
    symbol = sys.argv[1].lower()  # 支持通过命令行传参
else:
    symbol = input("请输入需要下载的股票代码：")

stock_zh_index_daily_df = ak.stock_zh_index_daily(symbol=symbol)
# print(stock_zh_index_daily_df)

# 保存文件路径
out_path = f"../stock_data/{symbol}.csv"

# 保存至CSV文件中
stock_zh_index_daily_df.to_csv(out_path, sep=",", index=False)
