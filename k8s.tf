module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = "gitops-eks"
  subnets      = "${module.vpc.public_subnets}"
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
  vpc_id = "${module.vpc.vpc_id}"

  worker_groups = [
    {
      instance_type = "m4.large"
      asg_max_size  = 2
      tags = [{
        key                 = "Teraform"
        value               = "true"
        propagate_at_launch = true
      }]
    }
  ]
}