data "gitlab_group" "gitops-demo-apps" {
  full_path = "gitops-demo/apps"
}

provider "gitlab" {
  alias   = "use-pre-release-plugin"
  version = "v2.99.0"
}
resource "gitlab_group_cluster" "aws_cluster" {
  provider           = "gitlab.use-pre-release-plugin"
  group              = "${data.gitlab_group.gitops-demo-apps.id}"
  name               = "${module.eks.cluster_id}"
  domain             = "eks.gitops-demo.com"
  environment_scope  = "old/"
  kubernetes_api_url = "${module.eks.cluster_endpoint}"
  kubernetes_token   = "${data.kubernetes_secret.gitlab-admin-token.data.token}"
  kubernetes_ca_cert = "${trimspace(base64decode(module.eks.cluster_certificate_authority_data))}"

}