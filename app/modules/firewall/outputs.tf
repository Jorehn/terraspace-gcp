output "id" {
  description = "firewall id"
  value       = google_compute_firewall.this.id
}

output "name" {
    description = "subnet name"
    value       = google_compute_firewall.this.name
}
