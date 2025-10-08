import uuid
import pymysql
from auth import get_conn
from wallet import update_wallet

def buy(user_id: str, portfolio_id: str, stock_symbol: str, quantity: int, price: float) -> bool:
    conn = get_conn()
    try:
        conn.begin()
        with conn.cursor() as cur:
            total = quantity * price
            cur.execute("SELECT wallet FROM users WHERE user_id=%s FOR UPDATE", (user_id,))
            r = cur.fetchone()
            if not r or float(r[0]) < total:
                conn.rollback()
                return False
            # deduct wallet
            cur.execute("UPDATE users SET wallet = wallet - %s WHERE user_id=%s", (total, user_id))
            # insert transaction
            txn_id = str(uuid.uuid4())
            cur.execute(
                "INSERT INTO user_transactions (transaction_id, user_id, portfolio_id, stock_symbol, transaction_type, quantity, execution_price) VALUES (%s,%s,%s,%s,'BUY',%s,%s)",
                (txn_id, user_id, portfolio_id, stock_symbol, quantity, price)
            )
            # update holdings: either insert or update
            cur.execute("SELECT holding_id, quantity, average_cost FROM user_holdings WHERE portfolio_id=%s AND stock_symbol=%s FOR UPDATE", (portfolio_id, stock_symbol))
            holding = cur.fetchone()
            if holding:
                holding_id, old_qty, old_cost = holding
                new_qty = old_qty + quantity
                new_avg = ((old_qty * float(old_cost)) + (quantity * price)) / new_qty
                cur.execute("UPDATE user_holdings SET quantity=%s, average_cost=%s WHERE holding_id=%s", (new_qty, new_avg, holding_id))
            else:
                hid = str(uuid.uuid4())
                cur.execute("INSERT INTO user_holdings (holding_id, user_id, portfolio_id, stock_symbol, quantity, average_cost) VALUES (%s,%s,%s,%s,%s,%s)", (hid, user_id, portfolio_id, stock_symbol, quantity, price))
        conn.commit()
        return True
    except Exception:
        conn.rollback()
        return False
    finally:
        conn.close()

def sell(user_id: str, portfolio_id: str, stock_symbol: str, quantity: int, price: float) -> bool:
    conn = get_conn()
    try:
        conn.begin()
        with conn.cursor() as cur:
            # check holdings
            cur.execute("SELECT holding_id, quantity, average_cost FROM user_holdings WHERE portfolio_id=%s AND stock_symbol=%s FOR UPDATE", (portfolio_id, stock_symbol))
            holding = cur.fetchone()
            if not holding or holding[1] < quantity:
                conn.rollback()
                return False
            holding_id, old_qty, old_cost = holding
            new_qty = old_qty - quantity
            if new_qty == 0:
                cur.execute("DELETE FROM user_holdings WHERE holding_id=%s", (holding_id,))
            else:
                cur.execute("UPDATE user_holdings SET quantity=%s WHERE holding_id=%s", (new_qty, holding_id))
            # credit wallet
            total = quantity * price
            cur.execute("UPDATE users SET wallet = wallet + %s WHERE user_id=%s", (total, user_id))
            # insert transaction
            txn_id = str(uuid.uuid4())
            cur.execute(
                "INSERT INTO user_transactions (transaction_id, user_id, portfolio_id, stock_symbol, transaction_type, quantity, execution_price) VALUES (%s,%s,%s,%s,'SELL',%s,%s)",
                (txn_id, user_id, portfolio_id, stock_symbol, quantity, price)
            )
        conn.commit()
        return True
    except Exception:
        conn.rollback()
        return False
    finally:
        conn.close()
