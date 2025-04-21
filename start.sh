#!/bin/sh

# PORTが設定されていない場合はデフォルト値を使用
export PORT=${PORT:-8080}
echo "PORT environment variable is set to: $PORT"

# Nginxの設定ファイルを動的に生成
if [ "$PORT" = "8080" ]; then
  # 8080がデフォルトの場合は、固定ポートを使用
  cat > /etc/nginx/conf.d/default.conf << EOF
server {
  listen 8080;

  location /api {
    proxy_pass http://localhost:8000;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
  }

  location / {
    proxy_pass http://localhost:3000;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}
EOF
else
  # 動的にポートを設定
  envsubst '${PORT}' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp
  mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf
fi

# Nginx設定を確認
echo "Nginx configuration:"
cat /etc/nginx/conf.d/default.conf

# Nginxのメイン設定ファイルを確認
echo "Checking nginx.conf user directive..."
# userディレクティブを完全に削除する方法（rootとして実行）
sed -i '/^\s*user/d' /etc/nginx/nginx.conf

# nginx.confの内容を表示
echo "Current nginx.conf:"
cat /etc/nginx/nginx.conf

# 環境のバージョン確認
echo "Node version: $(node -v)"
echo "NPM version: $(npm -v)"
command -v npx && echo "NPX found at $(which npx)" || echo "NPX not found"

# FastAPI起動
echo "Starting FastAPI..."
cd /app/backend && pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!

# バックエンドが起動するまで待機
echo "Waiting for FastAPI to start..."
start_time=$(date +%s)
while ! nc -z localhost 8000; do
  sleep 1
  if [ $(($(date +%s) - start_time)) -gt 30 ]; then
    echo "Failed to connect to FastAPI server after 30 seconds"
    exit 1
  fi
done
echo "FastAPI started successfully on port 8000"

# Next.jsの起動
echo "Starting Next.js..."
cd /app/frontend
if [ ! -d "node_modules" ]; then
  echo "Installing Next.js dependencies..."
  npm install
fi

# プロダクションビルドを起動
echo "Building and starting Next.js production server..."
if [ ! -d ".next" ]; then
  echo "Building Next.js application..."
  npm run build
fi

# 直接nodeを使用してNext.jsサーバーを起動
echo "Starting Next.js server on port 3000..."
NODE_ENV=production node node_modules/next/dist/bin/next start -p 3000 &
FRONTEND_PID=$!

# フロントエンドが起動するまで待機
echo "Waiting for Next.js to start..."
start_time=$(date +%s)
while ! nc -z localhost 3000; do
  sleep 1
  if [ $(($(date +%s) - start_time)) -gt 60 ]; then
    echo "Failed to connect to Next.js server after 60 seconds"
    exit 1
  fi
done
echo "Next.js started successfully on port 3000"

# Nginx起動
echo "Starting Nginx on port $PORT..."
# Nginxのデーモンモードをオフにして実行
nginx -g "daemon off;"