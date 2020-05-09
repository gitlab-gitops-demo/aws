# Terraform for Kubernetes Cluster on AWS

## GitOps Demo Group
See [Global Readme file](https://gitlab.com/gitops-demo/readme/-/blob/master/README.md) for the full details.

```
├── .vault/envconsul.hcl # envconsul configuration file for Vault secrets
├── backend.tf           # State file Location Configuration
├── eks.tf               # Amazon EKS Configuration
├── gitlab-admin.tf      # Adding kubernetes service account
├── group_cluster.tf     # Registering kubernetes cluster to GitLab `apps` Group
└── vpc.tf               # AWS VPC Configuration
```
