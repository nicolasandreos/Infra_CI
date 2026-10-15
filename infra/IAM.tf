resource "aws_iam_role" "cargo" {
  name = "${var.cargoIAM}_cargo"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com",
          "ecs-tasks.amazonaws.com"]
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "ecs_ecr" {
  name = "ecs_ecr"
  role = aws_iam_role.cargo.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_exec" {
  role       = aws_iam_role.cargo.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_instance_profile" "perfil" {
  name = "${var.cargoIAM}_perfil"
  role = aws_iam_role.cargo.name
}
