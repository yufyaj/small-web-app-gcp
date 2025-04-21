resource "google_artifact_registry_repository" "unified" {
  provider      = google
  location      = var.region
  repository_id = "apps-unified"
  format        = "DOCKER"
  description   = "Unified app container repository for Cloud Run"

  docker_config {
    immutable_tags = false
  }
} 