# SSM Parameters for secrets
resource "aws_ssm_parameter" "secret_key" {
  name  = "/${var.project_name}/SECRET_KEY"
  type  = "SecureString"
  value = var.django_secret_key

  tags = {
    Name = "${var.project_name}-secret-key"
  }
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project_name}/DB_PASSWORD"
  type  = "SecureString"
  value = var.db_password

  tags = {
    Name = "${var.project_name}-db-password"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-logs"
  }
}
