resource "aws_ecs_cluster" "my_cluster" {
  name = "cluster-nest-fiap"
}

resource "aws_ecs_task_definition" "my_task" {
  family                   = "task-nest-fiap"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = jsonencode([
    {
      name      = "container-nest-fiap"
      image     = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/${var.container_image}" // Replace with your ECR repository URI
      essential = true
      portMappings = [{
        name          = "container-nest-fiap-3000-tcp"
        containerPort = 3000,
        hostPort      = 3000,
        protocol      = "tcp",
        appProtocol : "http"
      }],
      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "PORT"
          value = "3000"
        },
        {
          name  = "DATABASE_HOST"
          value = "${element(split(":", aws_db_instance.default.endpoint), 0)}"
        },
        {
          name  = "DATABASE_PORT"
          value = "3306"
        },
        {
          name  = "DATABASE_USERNAME"
          value = var.username
        },
        {
          name  = "DATABASE_PASSWORD"
          value = var.password
        },
        {
          name  = "DATABASE_SCHEMA"
          value = var.db_name
        },
        {
          name  = "JWT_SECRET"
          value = "c6532e91-4867-421d-96ed-fd7c6400a0f7"
        }
      ],

      "logConfiguration" = {
        "logDriver" = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.aplicacao.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
          awslogs-create-group  = "true"
        }
      }
    }
  ])
}


resource "aws_security_group" "ecs" {
  name        = "fiap-sg-ecs"
  description = "Cluster Security Group"
  vpc_id      = local.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 3000
    to_port         = 3000
    security_groups = [aws_security_group.security_group_alb.id]
    cidr_blocks     = ["10.0.0.0/16"]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 3000
    to_port         = 3000
    security_groups = [aws_security_group.security_group_alb.id]
    cidr_blocks     = ["${chomp(data.http.myip.response_body)}/32"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "my_service" {
  name            = "service-nest-fiap"
  cluster         = aws_ecs_cluster.my_cluster.name
  task_definition = aws_ecs_task_definition.my_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {

    subnets          = aws_subnet.private_subnet.*.id
    security_groups  = [aws_security_group.ecs.id] // Replace with your security group IDs
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my_load_balancer_target_group.arn
    container_name   = "container-nest-fiap"
    container_port   = 3000 # Match with the container port
  }

  depends_on = [aws_ecs_task_definition.my_task, aws_db_instance.default]
}


################################################################################
# IAM Roles
################################################################################
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  count      = length(var.iam_policy_arn)
  policy_arn = var.iam_policy_arn[count.index]
}


