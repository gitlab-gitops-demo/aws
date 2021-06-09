module "eks" {
  source           = "terraform-aws-modules/eks/aws"
  cluster_name     = "gitops-demo-eks"
  cluster_version  = "1.19"
  subnets          = module.vpc.public_subnets
  write_kubeconfig = "false"
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      instance_type = "m4.large"
      asg_max_size  = 5
      tags = [{
        key                 = "Terraform"
        value               = "true"
        propagate_at_launch = true
      }]
    }
  ]
}

output "env-dynamic-url" {
  value = module.eks.cluster_endpoint
}
