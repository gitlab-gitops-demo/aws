variable "CI_PROJECT_ID" {
  type        = string
  description = "GitLab Project ID"
}

resource "gitlab_cluster_agent" "agent" {
  project = var.CI_PROJECT_ID
  name    = "agent"
}