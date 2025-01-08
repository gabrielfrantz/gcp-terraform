output "instance_ip_address_k8s_master_01" {
  description = "IP da instance_k8s_master_01"
  value       = google_compute_instance.instance_k8s_master_01.network_interface.0.access_config.0.nat_ip
}

output "instance_ip_address_k8s_node_01" {
  description = "IP da instance_k8s_node_01"
  value       = google_compute_instance.instance_k8s_node_01.network_interface.0.access_config.0.nat_ip
}

output "instance_ip_address_k8s_node_02" {
  description = "IP da instance_k8s_node_02"
  value       = google_compute_instance.instance_k8s_node_02.network_interface.0.access_config.0.nat_ip
}

output "instance_ip_address_k8s_rancher_01" {
  description = "IP da instance_k8s_rancher_01"
  value       = google_compute_instance.instance_k8s_rancher_01.network_interface.0.access_config.0.nat_ip
}


