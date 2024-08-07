module "eks" {
  source                                   = "terraform-aws-modules/eks/aws"
  cluster_name                             = "gitops-demo-eks"
  cluster_version                          = "1.30" # https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html#kubernetes-release-calendar
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  subnet_ids                               = module.vpc.public_subnets
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
  vpc_id = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    disk_size      = 50
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.large"]
      #capacity_type  = "SPOT"
    }
  }
}

data "aws_eks_cluster_auth" "gitops-demo-eks" {
  name = module.eks.cluster_name
}

output "env-dynamic-url" {
  value = module.eks.cluster_endpoint
}
