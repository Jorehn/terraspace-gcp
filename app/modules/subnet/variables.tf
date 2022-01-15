variable "name" {
  description = "subnet name (required)"
  type        = string
}
variable "network" {
    description     = "subnet network (required)"
    type            = string
}
variable ip_cidr_range {
  description   = "subnet cidr (required)"
  type          = string
}