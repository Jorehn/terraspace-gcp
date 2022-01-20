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



resource "kubectl_manifest" "cert-manager" {
    yaml_body = file("cert-manager.yml")
}
#apiVersion: cert-manager.io/v1
#kind: ClusterIssuer
#metadata:
#  name: letsencrypt-staging
#spec:
#  acme:
#    server: https://acme-staging-v02.api.letsencrypt.org/directory
#    email: john@ishetstuk.nl
#    privateKeySecretRef:
#      name: letsencrypt-staging
#    solvers:
#      - http01:
#          ingress:
#            class: nginx 120
#    autoFailoverServerGroup: false
#YAML
#}


#resource "kubectl_manifest" "cert-manager" {
#    yaml_body = <<YAML
#apiVersion: cert-manager.io/v1
#kind: ClusterIssuer
#metadata:
#  name: letsencrypt-staging
#spec:
#  acme:
#    server: https://acme-staging-v02.api.letsencrypt.org/directory
#    email: john@ishetstuk.nl
#    privateKeySecretRef:
#      name: letsencrypt-staging
#    solvers:
#      - http01:
#          ingress:
#            class: nginx 120
#    autoFailoverServerGroup: false
#YAML
#}


#module "cert_manager" {
#  source        = "terraform-iaac/cert-manager/kubernetes"
#  namespace_name                         = "cert-manager"
#  create_namespace                       = true
#  cluster_issuer_server                  = "https://acme-v02.api.letsencrypt.org/directory"

#  cluster_issuer_email                   = "john@ishetstuk.nl"
#  cluster_issuer_name                    = "letsencrypt"
#  cluster_issuer_private_key_secret_name = "cert-manager-private-key"
#}

#resource "kubernetes_service" "example" {
#  metadata {
#    name = "ingress-service"
#  }
#  spec {
#    port {
#      port = 80
#      target_port = 80
#      protocol = "TCP"
#    }
#    type = "NodePort"
#  }
#}


resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "scalable-nginx"
    labels = {
      App = "ScalableNginx"
    }
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        App = "ScalableNginx"
      }
    }
    template {
      metadata {
        labels = {
          App = "ScalableNginx"
        }
      }
      spec {
        container {
          image = "nginx:1.7.8"
          name  = "example"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx-ingress-svc" {
  metadata {
    name = "ingress-service"
  }
  spec {
    selector = {
      App = kubernetes_deployment.nginx.spec.0.template.0.metadata[0].labels.App
    }    
    port {
      port = 80
      target_port = 80
      protocol = "TCP"
    }
    type = "NodePort"
  }
}

resource kubernetes_ingress ingress {

  metadata {
    name = "ingress"


    annotations = {
 #     "cert-manager.io/cluster-issuer" = "letsencrypt"
      "kubernetes.io/ingress.class" = "nginx"

    }
  }

  spec {
    backend {
      service_name = "nginx-ingress-svc"

      service_port = 80
    }

    rule {
      host = "demo.ishetstuk.nl"
      http {
        path {
          backend {
            service_name = "nginx-ingress-svc"
            service_port = 80
          }
          path = "/"
        }
      }
    }

#    tls {
#      hosts = ["demo.ishetstuk.nl"]

#      secret_name = "demo.ishetstuk.nl-ssl-cert"
 #   }
  }
}
