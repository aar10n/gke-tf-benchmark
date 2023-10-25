resource "google_compute_instance" "benchmark" {
  project        = var.project_id
  name           = var.vm_name
  zone           = var.zones[0]
  machine_type   = "c2d-standard-32"

  tags           = [var.vm_name]
  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      type  = "pd-ssd"
    }
  }

  network_interface {
    network    = google_compute_network.main.self_link
    subnetwork = google_compute_subnetwork.main.self_link
    access_config {}
  }

  service_account {
    email  = google_service_account.service_account.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${replace(tls_private_key.ssh_key.public_key_openssh, "\n", "")} ${var.vm_user}"
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_firewall" "ssh-rule" {
  project = var.project_id
  name = "ssh"
  network = google_compute_network.main.name
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  target_tags = [var.vm_name]
  source_ranges = ["0.0.0.0/0"]
}
