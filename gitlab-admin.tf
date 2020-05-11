data "aws_eks_cluster" "my-cluster" {
  name = "${module.eks.cluster_id}"
}

data "aws_eks_cluster_auth" "my-auth" {
  name = "${module.eks.cluster_id}"
}

resource "null_resource" "wait_for_cluster" {
  provisioner "local-exec" {
    command = "until wget --no-check-certificate -O - -q $ENDPOINT/apis/rbac.authorization.k8s.io/v1/clusterrolebindings >/dev/null; do sleep 4; done"
    environment = {
      ENDPOINT = data.aws_eks_cluster.my-cluster.endpoint
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.my-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.my-cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.my-auth.token
  load_config_file       = false
}

resource "kubernetes_service_account" "gitlab-admin" {
  metadata {
    name      = "gitlab-admin"
    namespace = "kube-system"
  }
  depends_on = [null_resource.wait_for_cluster]
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
      data
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
