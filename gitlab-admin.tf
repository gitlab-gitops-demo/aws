data "aws_eks_cluster" "my-cluster" {
  name = "${module.eks.cluster_id}"
}

data "aws_eks_cluster_auth" "my-auth" {
  name = "${module.eks.cluster_id}"
}

provider "kubernetes" {
  version                = "~> 1.9"
  host                   = "${data.aws_eks_cluster.my-cluster.endpoint}"
  cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.my-cluster.certificate_authority.0.data)}"
  token                  = "${data.aws_eks_cluster_auth.my-auth.token}"
  load_config_file       = false
}

resource "kubernetes_service_account" "gitlab-admin" {
  metadata {
    name      = "gitlab-admin"
    namespace = "kube-system"
  }
}

resource "kubernetes_secret" "gitlab-admin" {
  metadata {
    name      = "gitlab-admin"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = "${kubernetes_service_account.gitlab-admin.metadata.0.name}"
    }
  }
  lifecycle {
    ignore_changes = [
      "data"
    ]
  }
  type = "kubernetes.io/service-account-token"
}

data "kubernetes_secret" "gitlab-admin-token" {
  metadata {
    name      = "${kubernetes_service_account.gitlab-admin.default_secret_name}"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "gitlab-admin" {
  metadata {
    name = "gitlab-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "gitlab-admin"
    namespace = "kube-system"
  }
}

locals {
  # GitLab API expects the cert in PEM format with \r\n and no carriage returns.
  # https://docs.gitlab.com/ee/api/project_clusters.html
  cert-one-line = "${replace(base64decode(module.eks.cluster_certificate_authority_data), "\n", "\\r\\n")}"

  gitlab-config = <<EOT
{"name":"${module.eks.cluster_id}",
"platform_kubernetes_attributes":
{"api_url":"${module.eks.cluster_endpoint}",
"token":"${data.kubernetes_secret.gitlab-admin-token.data.token}",
"ca_cert":"${local.cert-one-line}"}
}
  EOT
}

resource "local_file" "gitlab-config" {
  sensitive_content = local.gitlab-config
  filename          = "gitlab-k8s-config"
}
