resource "google_service_account" "service_account" {
  project    = var.project_id
  account_id = "${var.cluster}-sa"
}

resource "google_project_iam_member" "service_account_bucket_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.service_account.email}"
  condition {
    title      = "Grant access only to benchmark bucket"
    expression = "resource.name.startsWith(\"projects/_/buckets/${var.bucket}\")"
  }
}

resource "google_project_iam_member" "service_account_metrics" {
  project = var.project_id
  member = "serviceAccount:${google_service_account.service_account.email}"
  role = each.value

  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
  ])
}

resource "google_project_iam_member" "service_account_registry_access" {
  for_each = toset(var.registry_project_ids)
  project  = each.key
  role     = "roles/artifactregistry.reader"
  member   = "serviceAccount:${google_service_account.service_account.email}"
}
