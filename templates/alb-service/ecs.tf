module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 5.6"

  name        = var.name
  cluster_arn = data.aws_ecs_cluster.main.arn

  # supports external task def deployments
  # by ignoring changes to task definition and desired count
  ignore_task_definition_changes = true
  desired_count                  = 1

  # Task Definition
  enable_execute_command = false

  container_definitions = {
    (var.container_name) = {

      image = var.image

      port_mappings = [
        {
          protocol      = "tcp",
          containerPort = var.container_port
        }
      ]

      environment = [
        {
          "name" : "PORT",
          "value" : var.container_port
        },
        {
          "name" : "HEALTHCHECK",
          "value" : var.health_check
        },
      ]

      readonly_root_filesystem = false
    }
  }

  service_registries = {
    registry_arn = aws_service_discovery_service.this.arn
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["ecs-task"].arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  subnet_ids = data.aws_subnets.service.ids
  security_group_rules = {
    ingress_alb_service = {
      type                     = "ingress"
      from_port                = var.container_port
      to_port                  = var.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = var.tags
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "default.${var.name}.local"
  description = "Service discovery namespace.clustername.local"
  vpc         = data.aws_vpc.vpc.id

  tags = var.tags
}

resource "aws_service_discovery_service" "this" {
  name = var.name

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name = var.name

  # For example only
  enable_deletion_protection = false

  vpc_id  = data.aws_vpc.vpc.id
  subnets = data.aws_subnets.alb.ids

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = { for subnet in data.aws_subnet.service :
    (subnet.availability_zone) => {
      ip_protocol = "-1"
      cidr_ipv4   = subnet.cidr_block
    }
  }

  listeners = {
    http = {
      port     = "80"
      protocol = "HTTP"

      forward = {
        target_group_key = "ecs-task"
      }
    }
  }

  target_groups = {
    ecs-task = {
      backend_protocol = "HTTP"
      backend_port     = var.container_port
      target_type      = "ip"

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 10
        matcher             = "200-299"
        path                = var.health_check
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # There's nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }

  tags = var.tags
}
