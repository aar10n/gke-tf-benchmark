output "kubernetes_endpoint" {
  sensitive = true
  value     = module.gke.endpoint
}

output "client_token" {
  sensitive = true
  value     = base64encode(data.google_client_config.default.access_token)
}

output "ca_certificate" {
  sensitive = true
  value = module.gke.ca_certificate
}

output "service_account_email" {
  value = google_service_account.service_account.email
}

output "storage_bucket" {
  value = google_storage_bucket.bucket.name
}

output "k8s_service_account_name" {
  value = module.workload_identity.k8s_service_account_name
}

output "k8s_service_account_namespace" {
  value = module.workload_identity.k8s_service_account_namespace
}
