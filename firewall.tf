resource "google_compute_firewall" "allow-http" {
  name    = "http"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"

}

resource "google_compute_firewall" "allow-ssh" {
  name     = "ssh"
  network  = google_compute_network.vpc_network.self_link
  disabled = false

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
}

resource "google_compute_firewall" "allow-k8s-api" {
  name     = "k8s-api"
  network  = google_compute_network.vpc_network.self_link
  disabled = false

  allow {
    protocol = "tcp"
    ports    = ["6443","2379","2380","10250","10251","10252","10255"]
  }
  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
}

resource "google_compute_firewall" "allow-calico" {
  name     = "calico"
  network  = google_compute_network.vpc_network.self_link
  disabled = false

  allow {
    protocol = "tcp"
    ports    = ["179","4789","51820","51821"]
  }
  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
}

resource "google_compute_firewall" "allow-nodeport" { 
  name     = "nodeport" 
  network  = google_compute_network.vpc_network.self_link
  disabled = false

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }
  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
}