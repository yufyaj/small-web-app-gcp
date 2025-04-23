# 小規模 Web アプリケーション GCP デプロイ例

このリポジトリは、Google Cloud Platform (GCP) にデプロイする小規模な Web アプリケーションの例です。

## アーキテクチャ

- **フロントエンド**: Next.js
- **バックエンド**: Python FastAPI
- **ウェブサーバー**: Nginx
- **インフラ**: Terraform で GCP リソースを管理
- **CI/CD**: GitHub Actions

## 前提条件

- Git
- Docker
- Google Cloud Platform アカウント
- Google Cloud SDK (gcloud)
- Terraform
- Node.js と npm
- Python 3.11 以上

## セットアップ手順

### 1. リポジトリのクローン

```bash
git clone <リポジトリURL>
cd small-web-app-gcp
```

### 2. GCP プロジェクトの設定

1. GCP コンソールで新しいプロジェクトを作成します

### 3. 初期設定:

1. `infra/terraform/env/<環境名>/terraform.tfvars` を編集して必要な変数を設定:

```hcl
project_id     = "your-gcp-project-id"
region         = "asia-northeast1"
repository_id  = "your-repo-name"
image_name     = "small-web-app"
image_tag      = "latest"
```

### 4.  必要な API を有効にします:

```bash
# Linux/Mac
bash infra/terraform_services_enable.sh dev

# Windows
powershell -ExecutionPolicy Bypass -File infra/terraform_services_enable.ps1 -Env dev
```

### 5. Terraform によるインフラのデプロイとサービスアカウントの設定

1. Terraform でインフラをデプロイ（サービスアカウントも自動作成されます）:

```bash
# Linux/Mac
bash infra/terraform_build.sh dev

# Windows
powershell -ExecutionPolicy Bypass -File infra/terraform_build.ps1 -Environment dev
```

2. デプロイ後、GCP コンソールからサービスアカウントのJSONキーを取得:
   - GCP コンソールの「IAM と管理」→「サービスアカウント」に移動
   - Terraform で作成されたサービスアカウントを選択
   - 「鍵」タブから「鍵を作成」→「JSON」を選択
   - ダウンロードされたJSONファイルは安全に保管してください

3. GitHub リポジトリに以下のシークレットを設定:
   - `GCP_SA_KEY_DEV`: 開発環境用のサービスアカウントキー（JSONファイルの内容）
   - `GCP_SA_KEY_STAGING`: ステージング環境用のサービスアカウントキー（JSONファイルの内容）
   - `GCP_SA_KEY_PRODUCTION`: 本番環境用のサービスアカウントキー（JSONファイルの内容）

### 4. ローカル開発環境のセットアップ

#### バックエンド

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
# バックエンドは http://localhost:8000 で実行されます
```

#### フロントエンド

```bash
cd frontend
npm install
npm run dev
# フロントエンドは http://localhost:3000 で実行されます
```

### 5. ローカルでのDockerビルドとテスト

```bash
docker build -t small-web-app:local .
docker run -p 8080:8080 small-web-app:local
# アプリケーションは http://localhost:8080 でアクセス可能になります
```

## CI/CD パイプライン

このプロジェクトは GitHub Actions を使用して CI/CD を自動化しています:

1. `main` ブランチへのプッシュで自動的にビルドとデプロイが実行されます
2. 手動でワークフローを実行して特定の環境（dev/staging/production）にデプロイすることも可能です

## 環境変数

アプリケーションは以下の環境変数を使用します:

- `PORT`: アプリケーションが実行されるポート（デフォルト: 8080）
- `ENVIRONMENT`: 実行環境（dev/staging/production）

## トラブルシューティング

- **デプロイに失敗する場合**: GCP サービスアカウントの権限を確認してください
- **コンテナが起動しない場合**: `start.sh` スクリプトのログを確認してください
- **APIエラー**: バックエンドのログを確認してください

## ライセンス

[ライセンス情報を記載]
