resource "google_compute_firewall" "this" {
  name          = var.name
  network       = var.network
  allow {
    protocol  = "tcp"
    ports     = ["80", "443"]
  }
  source_ranges = ["0.0.0.0"]
}