import yfinance as yf
import pymysql

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'your_database_name',
    'charset': 'utf8mb4',
}

def get_conn():
    return pymysql.connect(**DB_CONFIG)

def fetch_and_store(symbols):
    conn = get_conn()
    try:
        with conn.cursor() as cur:
            for s in symbols:
                t = yf.Ticker(s)
                info = t.info
                name = info.get('shortName') or info.get('longName') or s
                # upsert into stock_catalog
                cur.execute("INSERT INTO stock_catalog (stock_symbol, company_name, exchange) VALUES (%s,%s,%s) ON DUPLICATE KEY UPDATE company_name=VALUES(company_name)", (s, name, info.get('exchange', 'NSE')))
                price = info.get('regularMarketPrice')
                volume = info.get('volume')
                if price is not None:
                    cur.execute("INSERT INTO market_prices (stock_symbol, current_price, volume) VALUES (%s,%s,%s) ON DUPLICATE KEY UPDATE current_price=VALUES(current_price), volume=VALUES(volume), last_updated=CURRENT_TIMESTAMP", (s, price, volume))
        conn.commit()
    finally:
        conn.close()

if __name__ == '__main__':
    # example symbols for Indian market (NSE tickers usually end with .NS)
    symbols = ['RELIANCE.NS', 'TCS.NS', 'INFY.NS']
    fetch_and_store(symbols)
