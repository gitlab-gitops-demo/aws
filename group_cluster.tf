data "gitlab_group" "gitops-demo-apps" {
  full_path = "gitops-demo/apps"
}

# This is a hack until terraform provider supports group clusters
# https://github.com/terraform-providers/terraform-provider-gitlab/issues/138
resource "null_resource" "aws_cluster" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = "${base64decode(data.aws_eks_cluster.my-cluster.certificate_authority.0.data)}"
  }

  provisioner "local-exec" {
    command = <<EOT
curl --silent --show-error --fail --header "Private-Token: $GITLAB_TOKEN" https://gitlab.com/api/v4/groups/${data.gitlab_group.gitops-demo-apps.id}/clusters/user \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
-X POST --data '${local.gitlab-config}'
EOT
  }
}