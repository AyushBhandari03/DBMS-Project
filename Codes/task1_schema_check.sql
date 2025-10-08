-- Task 1: Validate schema - check required tables exist
SELECT 'stock_catalog' AS table_name, COUNT(*) AS exists
FROM information_schema.tables
WHERE table_schema = DATABASE() AND table_name = 'stock_catalog';

SELECT 'market_prices' AS table_name, COUNT(*) AS exists
FROM information_schema.tables
WHERE table_schema = DATABASE() AND table_name = 'market_prices';

SELECT 'login_credentials' AS table_name, COUNT(*) AS exists
FROM information_schema.tables
WHERE table_schema = DATABASE() AND table_name = 'login_credentials';

SELECT 'user' AS table_name, COUNT(*) AS exists
FROM information_schema.tables
WHERE table_schema = DATABASE() AND table_name = 'user';

SELECT 'user_portfolio' AS table_name, COUNT(*) AS exists
FROM information_schema.tables
WHERE table_schema = DATABASE() AND table_name = 'user_portfolio';

SELECT 'user_transactions' AS table_name, COUNT(*) AS exists
FROM information_schema.tables
WHERE table_schema = DATABASE() AND table_name = 'user_transactions';

SELECT 'user_holdings' AS table_name, COUNT(*) AS exists
FROM information_schema.tables
WHERE table_schema = DATABASE() AND table_name = 'user_holdings';
