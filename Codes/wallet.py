import pymysql
from typing import Optional
from auth import get_conn

def get_wallet(user_id: str) -> Optional[float]:
    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT wallet FROM users WHERE user_id=%s", (user_id,))
            r = cur.fetchone()
            return float(r[0]) if r else None
    finally:
        conn.close()

def update_wallet(user_id: str, delta: float) -> bool:
    conn = get_conn()
    try:
        conn.begin()
        with conn.cursor() as cur:
            cur.execute("SELECT wallet FROM users WHERE user_id=%s FOR UPDATE", (user_id,))
            r = cur.fetchone()
            if not r:
                conn.rollback()
                return False
            new_wallet = float(r[0]) + delta
            if new_wallet < 0:
                conn.rollback()
                return False
            cur.execute("UPDATE users SET wallet=%s WHERE user_id=%s", (new_wallet, user_id))
        conn.commit()
        return True
    except Exception:
        conn.rollback()
        return False
    finally:
        conn.close()
