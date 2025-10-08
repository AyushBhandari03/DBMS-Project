-- 1. MARKET DATA TABLES

CREATE TABLE stock_catalog (
    stock_symbol VARCHAR(10) PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    industry VARCHAR(100),
    exchange VARCHAR(50)
);

CREATE TABLE market_prices (
    stock_symbol VARCHAR(10) PRIMARY KEY,
    current_price DECIMAL(10, 4) NOT NULL,
    volume INT UNSIGNED,
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CHECK (current_price >= 0.00),
    FOREIGN KEY (stock_symbol) REFERENCES stock_catalog(stock_symbol)
);


-- 2. CORE AUTHENTICATION AND USER DATA

CREATE TABLE login_credentials (
    login_id VARCHAR(50) PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    dob DATE NOT NULL,
    last_login TIMESTAMP,

    CHECK (DATEDIFF(CURRENT_DATE(), dob) / 365.25 >= 18)

);

CREATE TABLE user (
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

CREATE TABLE user_portfolio (
    portfolio_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    portfolio_name VARCHAR(100) NOT NULL,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pamount DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);


-- 3. TRADING AND HOLDINGS DATA

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

    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (stock_symbol) REFERENCES stock_catalog(stock_symbol)
);

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

    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (portfolio_id) REFERENCES user_portfolio(portfolio_id),
    FOREIGN KEY (stock_symbol) REFERENCES stock_catalog(stock_symbol),

    UNIQUE KEY uk_user_portfolio_stock (user_id, portfolio_id, stock_symbol)
);
