output "cluster_endpoint" {
  value = module.gke-cluster.endpoint
} 

output "ca_cert" {
    value = module.gke-cluster.cluster_ca_certificate
}

output "client_cert" {
    value = module.gke-cluster.client_certificate
}

output "client_key" {
    value = module.gke-cluster.client_key
    sensitive = true
}

output "cluster_name" {
    value = module.gke-cluster.cluster_name
}

output "cluster_zone" {
    value = module.gke-cluster.cluster_zone
}