import pymysql
import bcrypt
from typing import Optional

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'your_database_name',
    'charset': 'utf8mb4',
}

def get_conn():
    return pymysql.connect(**DB_CONFIG)

def register_user(login_id: str, username: str, plain_password: str, dob: str) -> bool:
    pw_hash = bcrypt.hashpw(plain_password.encode(), bcrypt.gensalt()).decode()
    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute("INSERT INTO login_credentials (login_id, username, password_hash, dob) VALUES (%s,%s,%s,%s)",
                        (login_id, username, pw_hash, dob))
        conn.commit()
        return True
    except pymysql.err.IntegrityError:
        return False
    finally:
        conn.close()

def login_user(username: str, plain_password: str) -> Optional[str]:
    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT login_id, password_hash FROM login_credentials WHERE username=%s", (username,))
            row = cur.fetchone()
            if not row:
                return None
            login_id, pw_hash = row
            if bcrypt.checkpw(plain_password.encode(), pw_hash.encode()):
                return login_id
            return None
    finally:
        conn.close()
