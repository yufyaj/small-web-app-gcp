# Cloud SQL (PostgreSQL) を最小構成で作成
resource "google_sql_database_instance" "pg" {
  name             = "app-postgres"
  region           = var.region
  database_version = "POSTGRES_15"
  deletion_protection = false       # 使い捨て環境なら false

  settings {
    tier = "db-f1-micro"            # 最小プラン
    disk_size = 10                  # GB単位、最小値
    availability_type = "ZONAL"     # 開発環境なら ZONAL で十分
    
    backup_configuration {
      enabled = true
      point_in_time_recovery_enabled = true
    }
    
    ip_configuration {
      ipv4_enabled    = false       # パブリック IP を無効化
      private_network = google_compute_network.main.id
    }
  }
  depends_on = [google_service_networking_connection.vpc_connection]
}

# デフォルトデータベースの作成
resource "google_sql_database" "default" {
  name     = "app"
  instance = google_sql_database_instance.pg.name
}
