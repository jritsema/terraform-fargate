output "ecs_cluster_name" {
  description = "The name of the ecs cluster that was created or referenced"
  value       = module.ecs_cluster.name
}

output "ecs_cluster_arn" {
  description = "The arn of the ecs cluster that was created or referenced"
  value       = module.ecs_cluster.arn
}

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

output "cloudfront_domain_name" {
  description = "The CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "cloudfront_distribution_id" {
  description = "The CloudFront distribution ID"
  value       = aws_cloudfront_distribution.this.id
}

output "endpoint" {
  description = "The https endpoint (CloudFront)"
  value       = "https://${aws_cloudfront_distribution.this.domain_name}"
}
