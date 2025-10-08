import yfinance as yf
import pymysql
from datetime import datetime

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'your_database_name',
    'charset': 'utf8mb4',
}

def get_conn():
    return pymysql.connect(**DB_CONFIG)

def fetch_history_and_load(symbols, period='5d'):
    conn = get_conn()
    try:
        with conn.cursor() as cur:
            for s in symbols:
                data = yf.download(s, period=period, progress=False)
                for idx, row in data.iterrows():
                    price = float(row['Close'])
                    vol = int(row['Volume']) if not row['Volume'] is None else None
                    dt = idx.to_pydatetime()
                    sql = ("INSERT INTO market_prices (stock_symbol, current_price, volume, last_updated) VALUES (%s,%s,%s,%s) "
                           "ON DUPLICATE KEY UPDATE current_price=VALUES(current_price), volume=VALUES(volume), last_updated=VALUES(last_updated)")
                    cur.execute(sql, (s, price, vol, dt))
        conn.commit()
    finally:
        conn.close()

if __name__ == '__main__':
    symbols = ['RELIANCE.NS','TCS.NS','INFY.NS']
    fetch_history_and_load(symbols)
