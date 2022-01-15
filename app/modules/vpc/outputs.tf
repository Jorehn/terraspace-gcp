output "id" {
  description = "vpc id"
  value       = google_compute_network.this.id
}

output "name" {
    description = "vpc name"
    value       = google_compute_network.this.name
}
