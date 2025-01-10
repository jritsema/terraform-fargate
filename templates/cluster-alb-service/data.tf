data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "alb" {
  filter {
    name   = "tag:Name"
    values = var.alb_subnet_names
  }
}

data "aws_subnets" "service" {
  filter {
    name   = "tag:Name"
    values = var.service_subnet_names
  }
}

data "aws_subnet" "service" {
  for_each = toset(data.aws_subnets.service.ids)
  id       = each.value
}
