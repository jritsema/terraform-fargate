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
