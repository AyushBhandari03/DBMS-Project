DELIMITER $$
CREATE PROCEDURE sp_execute_trade(
    IN p_txn_id VARCHAR(64),
    IN p_user_id VARCHAR(50),
    IN p_portfolio_id VARCHAR(50),
    IN p_stock_symbol VARCHAR(32),
    IN p_type ENUM('BUY','SELL'),
    IN p_quantity BIGINT,
    IN p_price DECIMAL(15,4)
)
BEGIN
    DECLARE v_hid VARCHAR(64);
    DECLARE v_qty BIGINT;
    DECLARE v_avg DECIMAL(15,4);

    IF p_type = 'BUY' THEN
        INSERT INTO user_transactions (transaction_id, user_id, portfolio_id, stock_symbol, transaction_type, quantity, execution_price)
        VALUES (p_txn_id, p_user_id, p_portfolio_id, p_stock_symbol, 'BUY', p_quantity, p_price);
        SELECT holding_id, quantity, average_cost INTO v_hid, v_qty, v_avg FROM user_holdings WHERE portfolio_id=p_portfolio_id AND stock_symbol=p_stock_symbol FOR UPDATE;
        IF v_hid IS NOT NULL THEN
            SET v_qty = v_qty + p_quantity;
            SET v_avg = ((v_qty - p_quantity) * v_avg + p_quantity * p_price) / v_qty;
            UPDATE user_holdings SET quantity=v_qty, average_cost=v_avg WHERE holding_id=v_hid;
        ELSE
            SET v_hid = UUID();
            INSERT INTO user_holdings (holding_id, user_id, portfolio_id, stock_symbol, quantity, average_cost)
            VALUES (v_hid, p_user_id, p_portfolio_id, p_stock_symbol, p_quantity, p_price);
        END IF;
    ELSE
        INSERT INTO user_transactions (transaction_id, user_id, portfolio_id, stock_symbol, transaction_type, quantity, execution_price)
        VALUES (p_txn_id, p_user_id, p_portfolio_id, p_stock_symbol, 'SELL', p_quantity, p_price);
        SELECT holding_id, quantity INTO v_hid, v_qty FROM user_holdings WHERE portfolio_id=p_portfolio_id AND stock_symbol=p_stock_symbol FOR UPDATE;
        IF v_hid IS NULL OR v_qty < p_quantity THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient holdings';
        END IF;
        SET v_qty = v_qty - p_quantity;
        IF v_qty = 0 THEN
            DELETE FROM user_holdings WHERE holding_id=v_hid;
        ELSE
            UPDATE user_holdings SET quantity=v_qty WHERE holding_id=v_hid;
        END IF;
    END IF;
END$$
DELIMITER ;

-- Trigger: when a transaction is inserted directly, update holdings
DELIMITER $$
CREATE TRIGGER trg_after_insert_transaction
AFTER INSERT ON user_transactions
FOR EACH ROW
BEGIN
    IF NEW.transaction_type = 'BUY' THEN
        INSERT INTO user_holdings (holding_id, user_id, portfolio_id, stock_symbol, quantity, average_cost)
        SELECT UUID(), NEW.user_id, NEW.portfolio_id, NEW.stock_symbol, NEW.quantity, NEW.execution_price
        WHERE NOT EXISTS (SELECT 1 FROM user_holdings WHERE portfolio_id=NEW.portfolio_id AND stock_symbol=NEW.stock_symbol);
        -- If exists, update
        UPDATE user_holdings SET quantity = quantity + NEW.quantity,
            average_cost = ((quantity - NEW.quantity) * average_cost + NEW.quantity * NEW.execution_price) / (quantity)
        WHERE portfolio_id=NEW.portfolio_id AND stock_symbol=NEW.stock_symbol;
    ELSE
        -- SELL: deduct quantity
        UPDATE user_holdings SET quantity = quantity - NEW.quantity WHERE portfolio_id=NEW.portfolio_id AND stock_symbol=NEW.stock_symbol;
        DELETE FROM user_holdings WHERE quantity <= 0;
    END IF;
END$$
DELIMITER ;
