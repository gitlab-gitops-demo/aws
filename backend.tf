terraform {
  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/14379215/terraform/state/aws"
    lock_address   = "https://gitlab.com/api/v4/projects/14379215/terraform/state/aws/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/14379215/terraform/state/aws/lock"
    username       = "tf"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = "5"
  }
}