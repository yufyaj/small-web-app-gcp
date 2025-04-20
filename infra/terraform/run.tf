# Cloud Run v2 単一サービス（Nginx + FastAPI 同居）
resource "google_cloud_run_v2_service" "app" {
  name     = "app-svc"
  location = var.region

  template {
    service_account = google_service_account.app_sa.email

    containers {
      # Artifact Registry に push 済みのイメージ
      image = "REGION-docker.pkg.dev/${var.project_id}/apps/app:latest"
      ports { container_port = 8080 }

      # DB のプライベート IP を環境変数で渡す
      env {
        name  = "DB_HOST"
        value = google_sql_database_instance.pg.private_ip_address
      }
    }

    # VPC Connector で Cloud SQL へ Private IP 接続
    vpc_access {
      connector = google_vpc_access_connector.connector.id
      egress    = "PRIVATE_RANGES_ONLY"
    }
  }
  ingress = "INGRESS_TRAFFIC_ALL"  # 公開
}

# 認証前提の場合は allUsers を外し、IAP or JWT 検証を適用
resource "google_cloud_run_service_iam_member" "invoker" {
  service  = google_cloud_run_v2_service.app.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"  # MVP 向け
}
