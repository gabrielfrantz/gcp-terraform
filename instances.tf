resource "google_compute_address" "static_instance_k8s_master_01" {
  name         = "ipv4-address-instance-k8s-master-01"
  address_type = "EXTERNAL"
}

resource "google_compute_address" "static_instance_k8s_node_01" {
  name         = "ipv4-address-instance-k8s-node-01"
  address_type = "EXTERNAL"
}

resource "google_compute_address" "static_instance_k8s_node_02" {
  name         = "ipv4-address-instance-k8s-node-02"
  address_type = "EXTERNAL"
}

resource "google_compute_address" "static_instance_k8s_rancher_01" {
  name         = "ipv4-address-instance-k8s-rancher-01"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "instance_k8s_master_01" {
  name         = "k8s-master-01"
  zone         = var.zone
  machine_type = "n2-standard-4"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet_network.id
    access_config {
      nat_ip = google_compute_address.static_instance_k8s_master_01.address
    }
  }

  metadata_startup_script = file("install_containerd_kubernetes_master.sh")
}

resource "google_compute_instance" "instance_k8s_node_01" {
  name         = "k8s-node-01"
  zone         = var.zone
  machine_type = "n2d-standard-2"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet_network.id
    access_config {
      nat_ip = google_compute_address.static_instance_k8s_node_01.address
    }
  }

  metadata_startup_script = file("install_containerd_kubernetes_workers.sh")
}

resource "google_compute_instance" "instance_k8s_node_02" {
  name         = "k8s-node-02"
  zone         = var.zone
  machine_type = "n2d-standard-2"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }
  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet_network.id
    access_config {
      nat_ip = google_compute_address.static_instance_k8s_node_02.address
    }
  }

  metadata_startup_script = file("install_containerd_kubernetes_workers.sh")
}

resource "google_compute_instance" "instance_k8s_rancher_01" {
  name         = "k8s-rancher-01"
  zone         = var.zone
  machine_type = "n2d-standard-4"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }
  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet_network.id
    access_config {
      nat_ip = google_compute_address.static_instance_k8s_rancher_01.address
    }
  }

  metadata_startup_script = file("install_rancher.sh")
}

