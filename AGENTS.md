# AGENTS.md

## Product Overview

terraform-fargate is a collection of Terraform templates and Bash scripts for provisioning and deploying containerized applications on AWS ECS Fargate.

It provides reusable, well-architected Terraform templates at varying levels of infrastructure scope, paired with a sample Python/Flask app and a deployment script (`deploy.sh`) that handles container image builds, ECR pushes, task definition registration, and ECS service updates.

The project separates infrastructure provisioning (Terraform) from application deployment (Docker + bash), allowing teams to manage each lifecycle independently.

## Tech Stack

### Infrastructure

- Terraform >= 1.5.7 (managed via asdf, currently pinned to 1.14.6)
- AWS provider ~> 6.0
- S3 backend for Terraform state
- Community modules from `terraform-aws-modules`:
  - `terraform-aws-modules/ecs/aws` ~> 7.0 (cluster and service)
  - `terraform-aws-modules/alb/aws` ~> 10.0
  - `terraform-aws-modules/vpc/aws` ~> 6.0

### Application

- Python 3.13 (Docker) / 3.9.1 (local dev via asdf)
- Flask web framework
- Docker for containerization
- direnv for local environment activation (.envrc sources virtualenv)

### Tooling

- asdf for CLI version management (terraform, python, direnv)
- pre-commit with terraform hooks: `terraform_fmt`, `terraform_validate`, `terraform_docs`, `terraform_tflint`
- tflint rules enforced: naming conventions, pinned sources, required versions/providers, typed variables, documented variables/outputs, standard module structure
- Make for task running in both `app/` and each template directory

## Common Commands

### Terraform templates (run from a `templates/<template>/` directory)

```sh
make init       # install asdf tools + register pre-commit hook
make checks     # run all pre-commit checks (fmt, validate, docs, tflint)
terraform init -backend-config="bucket=$BUCKET" -backend-config="key=$APP.tfstate"
terraform apply
```

### Application (run from `app/`)

```sh
make init       # create python virtualenv
make install    # pip install dependencies
make start      # run Flask app locally on port 8080
make deploy app=my-app  # build container + deploy to ECS
./deploy.sh <app-name> <platform>  # direct deploy script usage
```

## Project Structure

```
.
├── app/                          # Sample Python/Flask application
│   ├── main.py                   # Flask app (routes: / and /health)
│   ├── requirements.txt          # Python dependencies
│   ├── Dockerfile                # Container image definition
│   ├── deploy.sh                 # ECS deployment script (build, push, register, update)
│   ├── Makefile                  # Dev commands: init, install, start, deploy
│   ├── .envrc                    # direnv config (activates virtualenv)
│   └── .tool-versions            # asdf version pins (python, direnv)
│
├── templates/                    # Terraform templates at different scope levels
│   ├── vpc-cluster-alb-service/  # Full stack: VPC + ECS Cluster + ALB + Service + ECR
│   ├── cluster-alb-service/      # Into existing VPC: ECS Cluster + ALB + Service + ECR
│   └── alb-service/              # Into existing VPC+Cluster: ALB + Service + ECR
│
└── .kiro/steering/               # AI assistant steering rules
```

### Template File Convention

Each Terraform template follows a consistent file layout:

- `main.tf` — Provider configuration
- `variables.tf` — Input variables with descriptions, types, and defaults
- `outputs.tf` — Output values
- `versions.tf` — Terraform and provider version constraints, S3 backend
- `ecs.tf` — ECS cluster, service, ALB, and service discovery resources
- `ecr.tf` — ECR repository
- `data.tf` — Data sources (availability zones, VPC/subnet lookups)
- `vpc.tf` — VPC module (only in vpc-cluster-alb-service)
- `Makefile` — Template-level make targets (init, checks)
- `.pre-commit-config.yaml` — Pre-commit hook configuration
- `.tool-versions` — asdf version pins for terraform
- `terraform.tfvars.example` — Example variable values

### Template Hierarchy

Templates are layered by how much infrastructure they provision:

1. `vpc-cluster-alb-service` — provisions everything (VPC, cluster, ALB, service, ECR)
2. `cluster-alb-service` — assumes existing VPC, provisions cluster + ALB + service + ECR
3. `alb-service` — assumes existing VPC and cluster, provisions ALB + service + ECR

All templates share the same ECS service pattern: Fargate launch type, service discovery, ALB target group, and `ignore_task_definition_changes = true` to support external deployments via `deploy.sh`.
