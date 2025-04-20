#!/bin/sh
# Next.jsビルド
cd /app/frontend && npm install && npm run build &
# FastAPI起動
cd /app/backend && pip install -r requirements.txt && uvicorn main:app --host 0.0.0.0 --port 8000 &
# Nginx起動
nginx -g "daemon off;"