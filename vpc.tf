// Configure AWS VPC, Subnets, and Routes
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "gitops-vpc"
  cidr = "172.21.0.0/16"

  azs            = ["us-west-2a", "us-west-2b"]
  public_subnets = ["172.21.0.0/20", "172.21.16.0/20"]

  enable_nat_gateway                = false
  enable_vpn_gateway                = true
  propagate_public_route_tables_vgw = true

  tags = {
    Terraform                          = "true"
    Environment                        = "dev"
    "kubernetes.io/cluster/gitops-eks" = "shared"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/gitops-eks" = "shared"
  }
}
