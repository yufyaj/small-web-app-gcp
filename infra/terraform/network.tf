# VPC ネットワーク（default を使わず明示作成）
resource "google_compute_network" "main" {
  name                    = "app-vpc"
  auto_create_subnetworks = false  # 無駄なサブネットを作らない
}

# /24 のサブネット（必要に応じてサイズを拡張）
resource "google_compute_subnetwork" "main" {
  name          = "app-subnet"
  region        = var.region
  network       = google_compute_network.main.id
  ip_cidr_range = "10.10.0.0/24"
}

# Cloud Run → VPC 通信用 Serverless VPC Access Connector
resource "google_vpc_access_connector" "connector" {
  name          = "run-sql-connector"
  region        = var.region
  ip_cidr_range = "10.8.0.0/28"    # /28 で十分
  network       = google_compute_network.main.name
}

# Private Service Access: Cloud SQL をプライベート IP で使うための設定
resource "google_compute_global_address" "sql_range" {
  name          = "sql-private-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16               # /16 を予約
  network       = google_compute_network.main.id
}

resource "google_service_networking_connection" "vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.sql_range.name]
}
