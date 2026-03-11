data "aws_availability_zones" "available" {}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}

# Look up the security group that CloudFront automatically creates for VPC origin ENIs
data "aws_security_group" "cloudfront_vpc_origin" {
  depends_on = [aws_cloudfront_vpc_origin.alb]

  filter {
    name   = "group-name"
    values = ["CloudFront-VPCOrigins-Service-SG"]
  }

  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }
}
