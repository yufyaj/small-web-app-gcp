variable "project_id" { description = "GCP プロジェクト ID" }
variable "region" {
  description = "デフォルトリージョン"
  default     = "asia-northeast1"
}
variable "domain"     { description = "公開用ドメイン (例: example.com)" }