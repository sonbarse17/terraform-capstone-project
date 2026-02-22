# Capstone IaC Project

Terraform infrastructure for both AWS and Azure, organized as two independent stacks:

- `aws-terraform/` provisions VPC, EC2, ECR, EKS, S3, IAM, SageMaker Notebook, and CloudWatch dashboard resources.
- `azure-terraform/` provisions Resource Group, VNet/Subnets, VM, AKS, ACR, Key Vault, Storage Account, and Azure ML Workspace resources.

## Repository Layout

- `aws-terraform/`: AWS root module and reusable AWS modules.
- `azure-terraform/`: Azure root module and reusable Azure modules.
- `.gitignore`: Terraform local artifacts and secrets patterns.

## Directory Structure

```text
.
├── README.md
├── aws-terraform
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── locals.tf
│   ├── terraform.tfvars
│   └── modules
│       ├── cloudwatch-dashboards
│       ├── ec2
│       ├── ecr
│       ├── eks
│       ├── iam
│       ├── s3
│       ├── sagemake-notebooks
│       ├── security-group
│       └── vpc
├── azure-terraform
│   ├── main.tf
│   ├── variables.tf
│   ├── locals.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── modules
│       ├── acr
│       ├── aks
│       ├── azure-ml-workspace
│       ├── keyvault
│       ├── storage-accounts
│       ├── vm
│       └── vnet
└── iac-capstone-project.docx
```

## Prerequisites

- Terraform `>= 1.5.0`
- Cloud credentials configured for the target provider(s)
- Optional: `tflint` for lint checks

## Authentication

### AWS

Configure credentials using one of these methods before running Terraform:

- `aws configure`
- environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`)
- SSO/profile-based auth

### Azure

Use one of these methods before running Terraform:

- `az login`
- service principal environment variables (`ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, optionally `ARM_SUBSCRIPTION_ID`)

`azure-terraform` supports `subscription_id` as an input variable. If unset (`null`), provider context can come from your Azure auth/session.

## Quick Start

Run stacks independently from repo root.

### 1. AWS Stack

```bash
terraform -chdir=aws-terraform init
terraform -chdir=aws-terraform plan
terraform -chdir=aws-terraform apply
```

Key config file: `aws-terraform/terraform.tfvars`

Important before apply:

- Set a valid AMI ID in `aws-terraform/terraform.tfvars` (`ami_id` is currently a placeholder).
- Verify `key_name` exists in your AWS account/region.
- Review ingress rules and S3 public access settings for your security requirements.

### 2. Azure Stack

```bash
terraform -chdir=azure-terraform init
terraform -chdir=azure-terraform plan
terraform -chdir=azure-terraform apply
```

Key config file: `azure-terraform/terraform.tfvars`

Optional: provide subscription explicitly during plan/apply:

```bash
terraform -chdir=azure-terraform plan -var="subscription_id=<your-subscription-id>"
```

## Validate and Lint

```bash
terraform fmt -check -recursive aws-terraform azure-terraform
terraform -chdir=aws-terraform validate
terraform -chdir=azure-terraform validate

# optional
tflint --chdir aws-terraform
tflint --chdir azure-terraform
```

## Outputs

Azure root outputs are defined in `azure-terraform/outputs.tf`:

- `resource_group_name`
- `aks_name`
- `acr_login_server`
- `ml_workspace_name`

## Destroy

```bash
terraform -chdir=aws-terraform destroy
terraform -chdir=azure-terraform destroy
```

## Notes

- State is currently local (no remote backend configured).
- Keep secrets out of `*.tfvars` in shared repositories.
- Current Terraform variables in both stacks are intended for a dev environment baseline and should be reviewed for production use.
