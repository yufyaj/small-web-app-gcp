# Cloud Run 用 Serverless NEG
resource "google_compute_region_network_endpoint_group" "app_neg" {
  name                  = "app-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.app.name
  }
}

# Backend Service (Cloud CDN 有効)
resource "google_compute_backend_service" "app_bs" {
  name                  = "app-bs"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  enable_cdn            = true  # 静的ファイルをエッジキャッシュ
  
  # コンテンツキャッシュの設定
  cdn_policy {
    cache_mode = "USE_ORIGIN_HEADERS"
    default_ttl = 3600  # デフォルトのキャッシュ時間（秒）
    signed_url_cache_max_age_sec = 7200  # 署名付きURLのキャッシュ時間（秒）
  }

  backend {
    group = google_compute_region_network_endpoint_group.app_neg.id
  }
  
  # ヘルスチェックは Serverless NEG では不要
  security_policy = google_compute_security_policy.cloud_armor.name
}

# Cloud Armor セキュリティポリシー（DDoS保護）
resource "google_compute_security_policy" "cloud_armor" {
  name = "lb-cloud-armor"
  
  # 基本的なWAFルール
  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-stable')"
      }
    }
    description = "XSS攻撃を防御"
  }
  
  # デフォルトルール（全許可）
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "デフォルトルール"
  }
}

# URL Map — すべて同じ Backend Service へ
resource "google_compute_url_map" "urlmap" {
  name            = "app-map"
  default_service = google_compute_backend_service.app_bs.id
}

# マネージド SSL 証明書（Let's Encrypt 相当を自動発行）
resource "google_compute_managed_ssl_certificate" "cert" {
  name    = "lb-cert"
  managed { domains = [var.domain] }
}

# HTTPS プロキシ
resource "google_compute_target_https_proxy" "proxy" {
  name             = "https-proxy"
  url_map          = google_compute_url_map.urlmap.id
  ssl_certificates = [google_compute_managed_ssl_certificate.cert.id]
}

# グローバル転送ルール（443 番ポート）
resource "google_compute_global_forwarding_rule" "https_rule" {
  name                  = "https-rule"
  port_range            = "443"
  target                = google_compute_target_https_proxy.proxy.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
