variable "ROUTE53_ZONE_ID" {
  description = "AWS Route 53 Zone ID"
}

variable "ROUTE53_LB_NAME" {
  description = "* Record to be used for Ingress"
  default     = "*.eks"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.gitops-demo-eks.token
}

data "kubernetes_service" "nginx" {
  depends_on = [helm_release.managed-apps-ingress]
  metadata {
    name      = "${helm_release.managed-apps-ingress.name}-controller"
    namespace = helm_release.managed-apps-ingress.namespace
  }
}

output "ingress-ouput" {
  value = data.kubernetes_service.nginx.status.0.load_balancer.0.ingress.0.hostname
}

resource "aws_route53_record" "ingress_nginx" {
  zone_id         = var.ROUTE53_ZONE_ID
  name            = var.ROUTE53_LB_NAME
  type            = "CNAME"
  ttl             = 300
  records         = [data.kubernetes_service.nginx.status.0.load_balancer.0.ingress.0.hostname]
  allow_overwrite = true
}