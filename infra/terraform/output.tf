output "cloud_run_url" {
  description = "Cloud Run のデフォルト URL (デバッグ用)"
  value       = google_cloud_run_v2_service.app.uri
}

output "load_balancer_ip" {
  description = "HTTPS ロードバランサの公開 IP"
  value       = google_compute_global_forwarding_rule.https_rule.ip_address
}
