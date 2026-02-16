################################################################################
# ECS Cluster
################################################################################

module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "5.12.0"

  cluster_name = local.name

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = local.tags
}

################################################################################
# Service Discovery (Cloud Map)
################################################################################

resource "aws_service_discovery_http_namespace" "this" {
  name        = local.name
  description = "CloudMap namespace for ${local.name}"
  tags        = local.tags
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = var.dns_namespace
  description = "Private DNS namespace for ${var.dns_namespace}"
  vpc        = module.vpc.vpc_id
}

################################################################################
# TC API ECS Service
################################################################################

module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.12.0"

  depends_on = [module.db, aws_ssm_parameter.database_url]

  name        = local.name
  cluster_arn = module.ecs_cluster.arn

  cpu    = var.fargate_cpu
  memory = var.fargate_memory

  # Allow task execution role to read SSM parameters (injected as secrets)
  task_exec_ssm_param_arns = [
    aws_ssm_parameter.tc_api_url.arn,
    aws_ssm_parameter.tc_api_search_id.arn,
    aws_ssm_parameter.tc_api_username.arn,
    aws_ssm_parameter.tc_api_password.arn,
    aws_ssm_parameter.database_url.arn,
    aws_ssm_parameter.database_username.arn,
    aws_ssm_parameter.database_password.arn,
    aws_ssm_parameter.mongo_url.arn,
    aws_ssm_parameter.batch_chunk_size.arn,
    aws_ssm_parameter.batch_page_size.arn,
    aws_ssm_parameter.batch_max_read_skips.arn,
    aws_ssm_parameter.batch_fetch_delay_millis.arn,
  ]

  # Enables ECS Exec
  enable_execute_command = true

  # Container definition(s) – secrets from SSM; no sensitive env vars in task def
  container_definitions = {

    (local.container_name) = {
      cpu       = var.fargate_cpu
      memory    = var.fargate_memory
      essential = true

      image = "${aws_ecr_repository.repo.repository_url}:${var.image_tag}"
      port_mappings = [
        {
          name          = local.container_name
          containerPort = local.container_port
          hostPort      = local.container_port
          protocol      = "tcp"
        }
      ]

      # Injected from SSM (path: /${var.project_name}/${var.environment}/...)
      # Env var names must match application.yml ${...} placeholders exactly
      secrets = [
        { name = "TC_API_URL", valueFrom = aws_ssm_parameter.tc_api_url.arn },
        { name = "TC_SEARCH_ID", valueFrom = aws_ssm_parameter.tc_api_search_id.arn },
        { name = "TC_USERNAME", valueFrom = aws_ssm_parameter.tc_api_username.arn },
        { name = "TC_PASSWORD", valueFrom = aws_ssm_parameter.tc_api_password.arn },
        { name = "DATABASE_URL", valueFrom = aws_ssm_parameter.database_url.arn },
        { name = "DATABASE_USERNAME", valueFrom = aws_ssm_parameter.database_username.arn },
        { name = "DATABASE_PASSWORD", valueFrom = aws_ssm_parameter.database_password.arn },
        { name = "MONGO_URL", valueFrom = aws_ssm_parameter.mongo_url.arn },
        { name = "BATCH_CHUNK_SIZE", valueFrom = aws_ssm_parameter.batch_chunk_size.arn },
        { name = "BATCH_PAGE_SIZE", valueFrom = aws_ssm_parameter.batch_page_size.arn },
        { name = "BATCH_MAX_READ_SKIPS", valueFrom = aws_ssm_parameter.batch_max_read_skips.arn },
        { name = "BATCH_FETCH_DELAY_MILLIS", valueFrom = aws_ssm_parameter.batch_fetch_delay_millis.arn },
      ]

      # Example image used requires access to write to root filesystem
      readonly_root_filesystem = false

      enable_cloudwatch_logging = true
      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/fargate/service/${local.name}-fargate-log"
          awslogs-stream-prefix = "ecs"
          awslogs-region        = local.region
        }
      }

      linux_parameters = {
        capabilities = {
          add = []
          drop = [
            "NET_RAW"
          ]
        }
      }

      memory_reservation = 100
    }
  }

  service_connect_configuration = {
    namespace = aws_service_discovery_private_dns_namespace.this.arn
    services = [{
      discovery_name = local.container_name
      port_name      = local.container_name
      client_aliases = []
    }]
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["ex_ecs"].arn
      container_name   = local.container_name
      container_port   = local.container_port
    }
  }

  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
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

  service_tags = {
    Name = "${local.name}-service"
  }

  tags = local.tags
}

################################################################################
# Application Load Balancer
################################################################################

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.14.0"

  name = local.name

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  enable_deletion_protection = false

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  listeners = {
    ex_http = {
      port     = 80
      protocol = "HTTP"

      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex_https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-2016-08"
      certificate_arn = aws_acm_certificate_validation.this.certificate_arn

      forward = {
        target_group_key = "ex_ecs"
      }
    }
  }

  target_groups = {
    ex_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = local.container_port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 2
        interval            = 60
        matcher             = "200"
        path                = var.health_check_path
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 10
        unhealthy_threshold = 5
      }

      create_attachment = false
    }
  }

  tags = local.tags
}
