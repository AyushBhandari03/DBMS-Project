import threading
from trading import buy

def worker(user_id, portfolio_id, symbol, qty, price, results, idx):
    ok = buy(user_id, portfolio_id, symbol, qty, price)
    results[idx] = ok

def run_test():
    threads = []
    results = [None] * 5
    for i in range(5):
        t = threading.Thread(target=worker, args=(f'user1', 'portfolio1', 'RELIANCE.NS', 1, 2500.0, results, i))
        threads.append(t)
        t.start()
    for t in threads:
        t.join()
    print('Results:', results)

if __name__ == '__main__':
    run_test()
