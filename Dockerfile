# Next.js build
FROM node:20-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm install
COPY frontend .
RUN npm run build

# Python build
FROM python:3.11-slim AS backend-builder
WORKDIR /app/backend
COPY backend/requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt
COPY backend .

# Nginx
FROM nginx:alpine AS nginx
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Final image
FROM python:3.11-slim

WORKDIR /app

# Nginx and required packages
RUN apt-get update && apt-get install -y nginx gettext-base && rm -rf /var/lib/apt/lists/*
COPY --from=nginx /etc/nginx /etc/nginx

# Next.js
COPY --from=frontend-builder /app/frontend/.next /app/frontend/.next
COPY --from=frontend-builder /app/frontend/public /app/frontend/public
COPY --from=frontend-builder /app/frontend/node_modules /app/frontend/node_modules
COPY --from=frontend-builder /app/frontend/package.json /app/frontend/package.json

# Backend
COPY --from=backend-builder /app/backend /app/backend

# スタートスクリプト
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]