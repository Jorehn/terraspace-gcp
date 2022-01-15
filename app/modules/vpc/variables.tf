variable "name" {
  description = "vpc name (required)"
  type        = string
}

variable "auto_create_subnetworks" {
    description     = "auto create the subnets"
    type            = bool
    default         = false
}