# Terraform とプロバイダのバージョンを固定
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google      = { source = "hashicorp/google",      version = ">= 6.24.0" } # Google 本体
    google-beta = { source = "hashicorp/google-beta", version = ">= 6.24.0" } # 先行機能用
  }
}