locals {
  vpc-name = "${var.project}-vpc"
  subnet-name = "${var.project}-subnet"
  cluster-name = "${var.project}-cluster"
}

# VPC
module "vpc" {
  source = "../../modules/vpc"
  name                        = local.vpc-name
}

# Subnet
module "subnet" {
  source  = "../../modules/subnet"
  name    = local.subnet-name
  network = module.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

# cluster
module "gke-cluster"  {
  source        = "../../modules/gke-cluster"
  name          = local.cluster-name
  network       = module.vpc.name
  subnetwork    = module.subnet.name
  gke_num_nodes = 3
  project       = "var.project"
}


provider "kubernetes" {
  host                   = "https://${module.gke-cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke-cluster.cluster_ca_certificate)
}

data "google_client_config" "default" {
}

resource "kubernetes_pod" "nginx-example" {
  metadata {
    name = "nginx-example"

    labels = {
      maintained_by = "terraform"
      app           = "nginx-example"
    }
  }

  spec {
    container {
      image = "nginx:1.7.9"
      name  = "nginx-example"
    }
  }

  depends_on = [module.gke-cluster]
}

resource "kubernetes_service" "nginx-example" {
  metadata {
    name = "terraform-example"
  }

  spec {
    selector = {
      app = kubernetes_pod.nginx-example.metadata[0].labels.app
    }

    session_affinity = "ClientIP"

    port {
      port        = 8080
      target_port = 80
    }

    type = "LoadBalancer"
  }

  depends_on = [module.gke-cluster]
}
