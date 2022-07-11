variable "CI_PROJECT_ID" {
    type: string
    description: "GitLab Project ID"
}

resource "gitlab_cluster_agent" "eks" {
  project = var.CI_PROJECT_ID
  name    = "agent"
}