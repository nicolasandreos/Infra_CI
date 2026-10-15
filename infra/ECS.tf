module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "7.6.1"

  cluster_name = var.ambiante

  cluster_capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 100
    }
  }
}

resource "aws_ecs_task_definition" "Go-API" {
  family                   = "Go-API"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.cargo.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode(
    [
      {
        "name"      = "homolog"
        "image"     = var.imagem
        "cpu"       = 256
        "memory"    = 512
        "essential" = true
        "portMappings" = [
          {
            "containerPort" = local.app_port
            "hostPort"      = local.app_port
          }
        ]
        "environment" = [
          {
            "name"  = "DATABASE_HOST"
            "value" = tostring(aws_db_instance.default.address)
          },
          {
            "name"  = "DATABASE_PORT"
            "value" = tostring(aws_db_instance.default.port)
          },
          {
            "name"  = "DATABASE_USER"
            "value" = tostring(aws_db_instance.default.username)
          },
          {
            "name"  = "DATABASE_PASSWORD"
            "value" = local.db_password
          },
          {
            "name"  = "DATABASE_NAME"
            "value" = local.db_name
          },
          {
            "name"  = "DATABASE_SSLMODE"
            "value" = "require"
          },
          {
            "name"  = "PORT"
            "value" = tostring(local.app_port)
          }
        ]
      }
    ]
  )

  depends_on = [
    aws_iam_role_policy_attachment.ecs_exec,
    aws_iam_role_policy.ecs_ecr
  ]
}


resource "aws_ecs_service" "Go-API" {
  name            = "Go-API"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.Go-API.arn
  desired_count   = 1

  health_check_grace_period_seconds = 120
  wait_for_steady_state             = true

  load_balancer {
    target_group_arn = aws_lb_target_group.alvo.arn
    container_name   = "homolog"
    container_port   = local.app_port
  }

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.privado.id]
    assign_public_ip = false
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }

  depends_on = [
    aws_lb_listener.http,
    module.ecs,
    module.vpc
  ]
}
