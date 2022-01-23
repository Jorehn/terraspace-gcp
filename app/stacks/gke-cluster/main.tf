locals {
  vpc-name = "${var.project}-vpc"
  subnet-name = "${var.project}-subnet"
  firewall-name = "${var.project}-firewall"
  cluster-name = "${var.project}-cluster"
}

# VPC
module "vpc" {
  source = "../../modules/vpc"
  name   = local.vpc-name
}

# Subnet
module "subnet" {
  source  = "../../modules/subnet"
  name    = local.subnet-name
  network = module.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

# Firewall
module "firewall" {
  source  = "../../modules/firewall"
  name    = local.firewall-name
  network = module.vpc.name
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

provider "kubectl" {
  host                   = "https://${module.gke-cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke-cluster.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke-cluster.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke-cluster.cluster_ca_certificate)
  }
}

terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.13.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.3.0"
    }
  }
}

data "google_client_config" "default" {
}



module "cert_manager" {
  source        = "terraform-iaac/cert-manager/kubernetes"
  namespace_name                         = "cert-manager"
  create_namespace                       = true
  cluster_issuer_server                  = "https://acme-v02.api.letsencrypt.org/directory"
  cluster_issuer_name                    = "letsencrypt"
  cluster_issuer_email                   = "john@ishetstuk.nl"
  cluster_issuer_private_key_secret_name = "cert-manager-private-key"
}




resource "google_compute_address" "ingress_ip_address" {
  name = "nginx-controller"
}

module "nginx-controller" {
  source  = "terraform-iaac/nginx-controller/helm"

  ip_address = google_compute_address.ingress_ip_address.address
}


resource kubernetes_ingress ingress {

  metadata {
    name = "ingress"


    annotations = {
      "cert-manager.io/cluster-issuer" = module.cert_manager.cluster_issuer_name
      "kubernetes.io/ingress.class" = "nginx"

    }
  }

  spec {
    backend {
      service_name = "whats-the-time"

      service_port = 80
    }

    rule {
      host = "assessment.ishetstuk.nl"
      http {
        path {
          backend {
            service_name = "whats-the-time"
            service_port = 8666
          }
          path = "/"
        }
      }
    }

    tls {
      hosts = ["assessment.ishetstuk.nl"]

      secret_name = "assessment.ishetstuk.nl-ssl-cert"
    }
  }
}
