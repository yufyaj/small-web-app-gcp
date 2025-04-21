from fastapi import FastAPI, APIRouter

# メインアプリケーション
app = FastAPI()

# APIルーター
api_router = APIRouter()

@api_router.get("/")
def read_api_root():
    return {"message": "Welcome to the API!"}

@api_router.get("/items")
def read_items():
    return {"items": [{"id": 1, "name": "Item 1"}, {"id": 2, "name": "Item 2"}]}

@api_router.get("/health")
def health_check():
    return {"status": "ok"}

# ルートレベルのエンドポイント
@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI!"}

# APIルーターをマウント（/apiプレフィックスを追加）
app.include_router(api_router, prefix="/api")

# デバッグ用：すべてのルートを表示
@app.get("/debug/routes")
def debug_routes():
    routes = []
    for route in app.routes:
        routes.append({
            "path": route.path,
            "name": route.name,
            "methods": route.methods
        })
    return {"routes": routes}
