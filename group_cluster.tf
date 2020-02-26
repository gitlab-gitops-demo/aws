data "gitlab_group" "gitops-demo-apps" {
  full_path = "gitops-demo/apps"
}

provider "gitlab" {
  version = "~> 2.4.0"
}
resource "gitlab_group_cluster" "aws_cluster" {
  group              = data.gitlab_group.gitops-demo-apps.id
  name               = module.eks.cluster_id
  domain             = "eks.gitops-demo.com"
  environment_scope  = "eks/*"
  kubernetes_api_url = module.eks.cluster_endpoint
  kubernetes_token   = data.kubernetes_secret.gitlab-admin-token.data.token
  kubernetes_ca_cert = trimspace(base64decode(module.eks.cluster_certificate_authority_data))

}

# Work Around for lack of `management_project_id` in gitlab_group_cluster
locals {
  group_cluster_api_url = join("", ["https://gitlab.com/api/v4/", "groups/", gitlab_group_cluster.aws_cluster.group, "/clusters/", split(":", gitlab_group_cluster.aws_cluster.id)[1]])
  curl_cmd = join("", ["curl -s --header \"Private-Token: $GITLAB_TOKEN\" ",
    local.group_cluster_api_url,
  " -H 'Content-Type:application/json' --request PUT --data '{\"management_project_id\":\"'$CLUSTER_MANAGEMENT_PROJECT_ID'\"}'"])
}

resource "null_resource" "gitlab-management-cluster-associate" {
  triggers = { cluster_id = gitlab_group_cluster.aws_cluster.id }

  provisioner "local-exec" {
    command = local.curl_cmd
  }
  depends_on = [gitlab_group_cluster.aws_cluster]
}