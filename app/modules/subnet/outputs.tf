output "id" {
  description = "subnet id"
  value       = google_compute_subnetwork.this.id
}

output "name" {
    description = "subnet name"
    value       = google_compute_subnetwork.this.name
}
