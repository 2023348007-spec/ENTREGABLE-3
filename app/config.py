# config.py
import os
from dotenv import load_dotenv
load_dotenv()

DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_HOST = os.getenv("DB_HOST", "127.0.0.1")
DB_NAME = os.getenv("DB_NAME", "paquexpress_db")

SECRET_KEY = os.getenv("SECRET_KEY", "CAMBIA_ESTO_POR_ALGO_SEGURO")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60*24  # 1 día
MEDIA_DIR = os.getenv("MEDIA_DIR", "./media")
API_PREFIX = "/api/v1"
