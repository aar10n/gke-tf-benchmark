data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}


module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "28.0.0"

  project_id = var.project_id
  name       = var.cluster
  region     = var.region
  zones      = var.zones

  network           = google_compute_network.main.name
  subnetwork        = google_compute_subnetwork.main.name
  ip_range_pods     = google_compute_subnetwork.main.secondary_ip_range[0].range_name
  ip_range_services = google_compute_subnetwork.main.secondary_ip_range[1].range_name

  http_load_balancing = true
  gcs_fuse_csi_driver = true
  gce_pd_csi_driver   = true
  datapath_provider   = "ADVANCED_DATAPATH" # dataplane v2

  create_service_account   = false
  remove_default_node_pool = true
  node_pools = [
    {
      name            = "pool-1"
      machine_type    = "c2d-standard-32"
      disk_type       = "pd-ssd"
      node_count      = 1
      enable_gcfs     = true
      autoscaling     = false
      service_account = google_service_account.service_account.email
    }
  ]
}

resource "google_storage_bucket" "bucket" {
  project  = var.project_id
  name     = var.bucket
  location = var.region

  force_destroy               = true
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}
