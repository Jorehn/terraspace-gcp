output "cluster_name" {
    description = "name of the cluster"
    value       = google_container_cluster.primary.name
}

output "id" {
    description = "id of the cluster"
    value       = google_container_cluster.primary.id
}

output "endpoint" {
  description = "endpoint for the gke cluster"
  value       = google_container_cluster.primary.endpoint
}

output "client_certificate" {
  description = "client certificate for the gke cluster"
  value       = google_container_cluster.primary.master_auth.0.client_certificate
}

output "client_key" {
  description = "client key for the gke cluster"
  value       = google_container_cluster.primary.master_auth.0.client_key
}

output "cluster_ca_certificate" {
  description = "ca certificate for the gke cluster"
  value       = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
}

output "cluster_zone" {
    description = "zone the cluster resides"
    value       = google_container_cluster.primary.location
}
