#!/bin/sh

# PORTが設定されていない場合はデフォルト値を使用
export PORT=${PORT:-8080}

# Nginxの設定ファイルを動的に生成
envsubst '${PORT}' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp
mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf

# Next.jsビルド
cd /app/frontend && npm install && npm run build &
# FastAPI起動
cd /app/backend && pip install -r requirements.txt && uvicorn main:app --host 0.0.0.0 --port 8000 &
# Nginx起動
nginx -g "daemon off;"