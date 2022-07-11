variable "CI_PROJECT_ID" {
  type        = string
  description = "GitLab Project ID"
}

resource "gitlab_cluster_agent" "agent" {
  project = var.CI_PROJECT_ID
  name    = "agent"
}

resource "gitlab_cluster_agent_token" "agent" {
  project     = gitlab_cluster_agent.agent.project
  agent_id    = gitlab_cluster_agent.agent.agent_id
  name        = "agent-token"
  description = "agent token"
}