# terraform-fargate

Provision and deploy Fargate apps using a collection of Terraform templates and Bash scripts.


## Features

- Several well-architected example templates using [terraform-aws-modules](https://registry.terraform.io/namespaces/terraform-aws-modules)

- Allows separation of infrastructure and application deployments (by having terraform ignore changes to service's task definition and desired count)

- Fast initial deployment using a tiny default backend container

## Usage

This repo includes both Terraform templates as well as simple sample app that can be deployed using the Docker CLI and a bash script.

### Deploy cloud resources

Optionally, create an s3 bucket to store terraform state

```sh
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
BUCKET=tf-state-${ACCOUNT}
aws s3 mb s3://${BUCKET}
```

Deploy the app stack

```sh
cd templates/vpc-cluster-alb-service

# name your app
export APP=my-app

# create a variables input file
cat << EOF > terraform.tfvars
name = "${APP}"
container_port = 8080
health_check = "/health"
EOF

# run terraform
terraform init -backend-config="bucket=${BUCKET}" -backend-config="key=${APP}.tfstate"
terraform apply
```

terraform will output the endpoint of your web app
```sh
...
endpoint = "http://my-app-123456789012.us-east-1.elb.amazonaws.com"
...
```

### Deploy web app

```sh
cd ../../app
./deploy.sh ${APP} linux/amd64
```

Note that you can continue to use terraform to make changes to the infrastructure, however it will no longer deploy new task definitions to the service or change the desired count. Instead, you can use the deploy script to build/deploy new container images. Desired task count is generally managed by auto-scaling going forward.


## Templates

- [vpc-cluster-alb-service](./templates/vpc-cluster-alb-service/README.md) - Deploy all-in-one HTTP endpoint (provisions VPC, ECR, ECS Cluster, ALB, and ECS Service)

- cluster-alb-service - Deploy HTTP endpoint into existing VPC (provisions ECR, ECS Cluster, ALB, and ECS Service)

- alb-service - Deploy HTTP endpoint into existing VPC and Cluster (provisions ALB and ECS Service)

- service - Deploy long running container (no load balancer) into existing VPC and Cluster (provisions ECR and ECS Service)
