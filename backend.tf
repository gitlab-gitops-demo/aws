terraform {
  backend "s3" {
    bucket = "magic7s"
    key    = "gitops-demo/infra/aws/aws.tfstate"
    region = "us-west-2"
  }
}