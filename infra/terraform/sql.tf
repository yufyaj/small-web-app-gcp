# Cloud SQL (PostgreSQL) を最小構成で作成
resource "google_sql_database_instance" "pg" {
  name             = "app-postgres"
  region           = var.region
  database_version = "POSTGRES_15"
  deletion_protection = false       # 使い捨て環境なら false

  settings {
    tier = "db-f1-micro"            # 最小プラン
    ip_configuration {
      ipv4_enabled    = false       # パブリック IP を無効化
      private_network = google_compute_network.main.id
    }
  }
}
