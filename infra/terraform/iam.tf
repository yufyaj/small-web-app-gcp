# Cloud Run 用サービスアカウント
resource "google_service_account" "app_sa" {
  account_id   = "app-sa"
  display_name = "Cloud Run (アプリ/フロント共用)"
}

# Cloud Run が Cloud SQL に接続できるようにする
resource "google_project_iam_member" "run_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}
