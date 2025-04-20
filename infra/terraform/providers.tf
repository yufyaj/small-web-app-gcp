# デフォルトプロジェクト／リージョンを指定
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# リモートステート用のバックエンド設定（必要に応じてコメント解除して使用）
# terraform {
#   backend "gcs" {
#     bucket = "terraform-state-[YOUR-PROJECT]"
#     prefix = "terraform/state"
#   }
# }