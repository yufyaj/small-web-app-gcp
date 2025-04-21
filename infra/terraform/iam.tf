# Cloud Run 用サービスアカウント
resource "google_service_account" "app_sa" {
  account_id   = "app-sa"
  display_name = "Cloud Run (アプリ/フロント共用)"
  description  = "アプリケーション実行用のサービスアカウント"
}

# Artifact Registry/Cloud Run 管理用サービスアカウント
resource "google_service_account" "cicd_sa" {
  account_id   = "cicd-sa"
  display_name = "CI/CD 用サービスアカウント"
  description  = "Artifact RegistryやCloud Runの管理権限を持つCI/CD用サービスアカウント"
}

# Cloud Run が Cloud SQL に接続できるようにする
resource "google_project_iam_member" "run_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}

# Artifact Registry 読み取り権限の付与
resource "google_project_iam_member" "run_ar_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}

# Artifact Registry 管理権限の付与（CI/CD用）
resource "google_project_iam_member" "cicd_ar_admin" {
  project = var.project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.cicd_sa.email}"
}

# Cloud Run 管理権限の付与（CI/CD用）
resource "google_project_iam_member" "cicd_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.cicd_sa.email}"
}

# サービスアカウントトークン作成権限（GitHub Actions等からのデプロイ用）
resource "google_project_iam_member" "cicd_sa_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.cicd_sa.email}"
}

# Artifact Registry Writer権限の付与（CI/CD用: uploadArtifacts専用）
resource "google_project_iam_member" "cicd_ar_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cicd_sa.email}"
}
