resource "google_compute_network" "vpc_network" {
  project                 = "devops-443521"
  name                    = "vpc-devops"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_network" {
  name          = "subnet-devops-01"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}