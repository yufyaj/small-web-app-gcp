variable "project_id" { 
  description = "GCP プロジェクト ID"
  type        = string
}

variable "region" {
  description = "デフォルトリージョン"
  type        = string
  default     = "asia-northeast1"
}

variable "domain" { 
  description = "公開用ドメイン (例: example.com)" 
  type        = string
}

variable "image_tag" {
  description = "デプロイするコンテナイメージのタグ"
  type        = string
  default     = "latest"
}

variable "repository_id" {
  description = "Artifact Registry のリポジトリID"
  type        = string
  default     = "apps-unified"
}

variable "image_name" {
  description = "コンテナイメージ名"
  type        = string
  default     = "app"
}