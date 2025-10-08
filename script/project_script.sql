CREATE DATABASE IF NOT EXISTS `Stock Portfolio Management`;
USE `Stock Portfolio Management`;

CREATE TABLE stock_catalog (
    stock_symbol VARCHAR(10) PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    industry VARCHAR(100),
    exchange VARCHAR(50)
);
desc stock_catalog;

CREATE TABLE market_prices (
    stock_symbol VARCHAR(10) PRIMARY KEY,
    current_price DECIMAL(10, 4) NOT NULL,
    open_price DECIMAL(10, 4) NOT NULL,
    percent_change DECIMAL(10, 4) NOT NULL,
    volume INT UNSIGNED,
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CHECK (current_price >= 0.00),
    FOREIGN KEY (stock_symbol) REFERENCES stock_catalog(stock_symbol)
);
desc market_prices;

CREATE TABLE login_credentials (
    login_id VARCHAR(50) PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    dob DATE NOT NULL,
    last_login TIMESTAMP NULL
);
desc login_credentials;

drop table users;
CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY,
    login_ref VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    contact_number VARCHAR(20) UNIQUE,
    wallet DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    registration_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (wallet >= 0.00),
    FOREIGN KEY (login_ref) REFERENCES login_credentials(login_id)
);
desc users;

drop table user_portfolio;
CREATE TABLE user_portfolio (
    portfolio_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    portfolio_name VARCHAR(100) NOT NULL,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pamount DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
desc user_portfolio;

drop table user_transactions;
CREATE TABLE user_transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    stock_symbol VARCHAR(10) NOT NULL,
    transaction_type VARCHAR(10) NOT NULL, 
    quantity INT UNSIGNED NOT NULL,
    execution_price DECIMAL(10, 4) NOT NULL,
    execution_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CHECK (quantity >= 1),
    CHECK (execution_price > 0.00),

    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (stock_symbol) REFERENCES stock_catalog(stock_symbol)
);
desc user_transactions;

CREATE TABLE user_holdings (
    holding_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    portfolio_id VARCHAR(50) NOT NULL,
    stock_symbol VARCHAR(10) NOT NULL,
    quantity INT NOT NULL,
    average_cost DECIMAL(10, 4) NOT NULL,
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CHECK (quantity >= 0),
    CHECK (average_cost >= 0.00),

    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (portfolio_id) REFERENCES user_portfolio(portfolio_id),
    FOREIGN KEY (stock_symbol) REFERENCES stock_catalog(stock_symbol),

    UNIQUE KEY uk_user_portfolio_stock (user_id, portfolio_id, stock_symbol)
);
desc user_holdings;



-- Import stock_catalog.csv into stock_catalog
LOAD DATA LOCAL INFILE 'E:/Project/DBMS/files/stock_catalog.csv'
INTO TABLE stock_catalog
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(stock_symbol, company_name, industry, `exchange`);

-- Import market_prices.csv into market_prices
LOAD DATA LOCAL INFILE 'E:/Project/DBMS/files/market_prices.csv'
INTO TABLE market_prices
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(stock_symbol, current_price, volume, open_price, @percentage_change, last_updated)
SET percent_change = @percentage_change;