import pandas as pd
import akshare as ak

# 列名与数据对其显示
pd.set_option("display.unicode.ambiguous_as_wide", True)
pd.set_option("display.unicode.east_asian_width", True)
# 显示所有列
pd.set_option("display.max_columns", None)
# 显示所有行
pd.set_option("display.max_rows", None)

symbol = "sh000922"  # 股票代码

stock_zh_index_daily_df = ak.stock_zh_index_daily(symbol=symbol)
# print(stock_zh_index_daily_df)

# 保存至CSV文件中
stock_zh_index_daily_df.to_csv(f"./{symbol}.csv", sep=",", index=False)
