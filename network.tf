resource "google_compute_network" "main" {
  project                 = var.project_id
  name                    = var.network
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = var.network
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.main.id
  ip_cidr_range = "10.0.0.0/17"

  secondary_ip_range {
    range_name    = "${var.cluster}-pod-range"
    ip_cidr_range = "192.168.0.0/18"
  }

  secondary_ip_range {
    range_name    = "${var.cluster}-svc-range"
    ip_cidr_range = "192.168.64.0/18"
  }
}
