terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}
