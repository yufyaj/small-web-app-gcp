# Cloud Run v2 単一サービス（Nginx + FastAPI 同居）
resource "google_cloud_run_v2_service" "app" {
  name     = "app-svc"
  location = var.region
  depends_on = [
    google_vpc_access_connector.connector
  ]

  template {
    service_account = google_service_account.app_sa.email
    timeout         = "300s"     # リクエストタイムアウト5分（最新構文では単位必須）
    revision        = "app-svc-revision-001"

    containers {
      # Artifact Registry に push 済みのイメージ
      image = "${var.region}-docker.pkg.dev/${var.project_id}/apps/app:${var.image_tag}"
      
      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
      
      ports {
        container_port = 8080
      }

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
  deletion_protection = false      # 開発中は削除保護を無効化
}

# 認証前提の場合は allUsers を外し、IAP or JWT 検証を適用
resource "google_cloud_run_service_iam_member" "invoker" {
  service  = google_cloud_run_v2_service.app.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"  # MVP 向け
}
