variable "GITOPS_AGENT_PROJECTID" {
  type        = string
  description = "Project ID Number where the gitops-agent lives. Should be in the same group as apps"
}

resource "gitlab_cluster_agent" "agent" {
  project = var.GITOPS_AGENT_PROJECTID
  name    = "agent" # This name maps to the file .gitlab/agents/{name}/config.yaml
}

resource "gitlab_cluster_agent_token" "agent" {
  project     = gitlab_cluster_agent.agent.project
  agent_id    = gitlab_cluster_agent.agent.agent_id
  name        = "agent-token"
  description = "agent token"
}

data "aws_eks_cluster" "gitops-demo-eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "gitops-demo-eks" {
  name = module.eks.cluster_id
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.gitops-demo-eks.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

resource "helm_release" "gitlab-agent" {
  name = "gitlab-agent"

  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-agent"
  namespace        = "gitlab-agent"
  create_namespace = true

  set {
    name  = "config.token"
    value = gitlab_cluster_agent_token.agent.token
  }
  set {
    name  = "config.kasAddress"
    value = "wss://kas.gitlab.com"
  }
}