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
  }
  required_version = "~> 1.0.0"
}
