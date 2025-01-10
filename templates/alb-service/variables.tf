variable "name" {
  description = "The name of this template (e.g., my-app-prod)"
  type        = string
}

variable "region" {
  description = "The AWS region to deploy to (e.g., us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "container_name" {
  description = "The name of the container"
  type        = string
  default     = "app"
}

variable "health_check" {
  description = "A map containing configuration for the health check"
  type        = string
  default     = "/health"
}

# The port the container will listen on, used for load balancer health check
# Best practice is that this value is higher than 1024 so the container processes
# isn't running at root.
variable "container_port" {
  description = "The port the container will listen on, used for load balancer health check. Best practice is that this value is higher than 1024 so the container processes isn't running at root."
  type        = number
  default     = 8080
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "image" {
  description = "container image to initially bootstrap. future images can be deployed using a separate mechanism"
  type        = string
  default     = "public.ecr.aws/jritsema/defaultbackend"
}

variable "vpc_name" {
  description = "The name of the VPC you want to deploy the service into."
  type        = string
}

variable "alb_subnet_names" {
  description = "The list of subnet names you wan to deploy the ALB into"
  type        = list(string)
}

variable "service_subnet_names" {
  description = "The list of subnet names you wan to deploy the service into. Note that these subnets will need network access to ECR."
  type        = list(string)
}

variable "cluster_name" {
  description = "The name of the ECS cluster you want to add the service to."
  type        = string
}
