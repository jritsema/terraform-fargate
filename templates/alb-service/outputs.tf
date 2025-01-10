output "ecs_service_name" {
  description = "The arn of the fargate ecs service that was created"
  value       = module.ecs_service.name
}

output "lb_arn" {
  description = "The arn of the load balancer"
  value       = module.alb.arn
}

output "lb_dns" {
  description = "The load balancer DNS name"
  value       = module.alb.dns_name
}

output "endpoint" {
  description = "The http endpoint"
  value       = "http://${module.alb.dns_name}"
}
