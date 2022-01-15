variable "name" {
  description = "gke cluster name (required)"
  type        = string 
}

variable "network" {
  description = "network"
  type        = string
}

variable "subnetwork" {
  description = "subnet"
  type        = string
}

variable "gke_username" {
  description = "gke cluster username"
  default     = ""
  type        = string 
}

variable "gke_password" {
  description = "gke cluster password"
  type        = string
  default     = ""
}

variable "gke_num_nodes" {
  description = "number of gke nodes"
  type        = number
  default     = 2
}

variable "project" {
  description = "project for the cluster"
  default     = "test"
  type        = string
}


