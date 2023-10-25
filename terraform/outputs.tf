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
  value     = module.gke.ca_certificate
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

output "vm_public_ip" {
  value = google_compute_instance.benchmark.network_interface[0].access_config[0].nat_ip
}

output "ssh_public_key" {
  value = tls_private_key.ssh_key.public_key_openssh
}

output "ssh_private_key" {
  sensitive = true
  value     = tls_private_key.ssh_key.private_key_pem
}
