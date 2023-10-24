resource "google_service_account" "service_account" {
  project    = var.project_id
  account_id = "${var.cluster}-sa"
}

resource "google_storage_bucket_iam_member" "service_account_bucket_admin" {
  bucket = var.bucket
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.service_account.email}"
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

module "workload_identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  project_id          = var.project_id
  name                = google_service_account.service_account.account_id
  use_existing_gcp_sa = true
}
