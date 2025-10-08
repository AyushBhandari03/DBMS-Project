CREATE VIEW holdings_summary AS
SELECT h.portfolio_id, h.stock_symbol, h.quantity, h.average_cost,
       mp.current_price,
       (h.quantity * mp.current_price) AS market_value,
       (h.quantity * mp.current_price) - (h.quantity * h.average_cost) AS unrealized_pnl
FROM user_holdings h
LEFT JOIN market_prices mp ON mp.stock_symbol = h.stock_symbol;

CREATE VIEW portfolio_value AS
SELECT p.user_id, p.portfolio_id, p.portfolio_name, SUM(h.quantity * mp.current_price) AS total_market_value
FROM user_portfolio p
LEFT JOIN user_holdings h ON h.portfolio_id = p.portfolio_id
LEFT JOIN market_prices mp ON mp.stock_symbol = h.stock_symbol
GROUP BY p.portfolio_id;

CREATE VIEW transactions_summary AS
SELECT user_id, portfolio_id, transaction_type, stock_symbol, SUM(quantity) AS total_quantity, SUM(quantity * execution_price) AS total_amount
FROM user_transactions
GROUP BY user_id, portfolio_id, transaction_type, stock_symbol;
