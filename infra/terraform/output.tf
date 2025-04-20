output "cloud_run_url" {
  description = "Cloud Run のデフォルト URL (デバッグ用)"
  value       = google_cloud_run_v2_service.app.uri
}

output "load_balancer_ip" {
  description = "HTTPS ロードバランサの公開 IP"
  value       = google_compute_global_forwarding_rule.https_rule.ip_address
}

output "service_account" {
  description = "アプリケーション用サービスアカウント"
  value       = google_service_account.app_sa.email
}

output "cloud_sql_instance" {
  description = "Cloud SQL インスタンス名"
  value       = google_sql_database_instance.pg.name
}
