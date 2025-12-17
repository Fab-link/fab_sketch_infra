# EC2 Instance for FabSketch Backend
resource "aws_instance" "fabsketch_backend" {
  ami           = "ami-0c2acfcb2ac4d02a0" # Amazon Linux 2023
  instance_type = "t3.medium"
  
  vpc_security_group_ids = [aws_security_group.fabsketch_backend.id]
  subnet_id              = aws_subnet.fabsketch_public.id
  
  key_name = aws_key_pair.fabsketch_key.key_name
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_host     = aws_db_instance.fabsketch_postgres.endpoint
    db_name     = aws_db_instance.fabsketch_postgres.db_name
    db_user     = aws_db_instance.fabsketch_postgres.username
    db_password = var.db_password
    s3_bucket   = "fab-sketch-media-xp8zu198"
  }))
  
  iam_instance_profile = aws_iam_instance_profile.fabsketch_ec2_profile.name
  
  tags = {
    Name = "fabsketch-backend"
  }
}

# Security Group
resource "aws_security_group" "fabsketch_backend" {
  name_description = "FabSketch Backend Security Group"
  vpc_id          = aws_vpc.fabsketch_vpc.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Key Pair
resource "aws_key_pair" "fabsketch_key" {
  key_name   = "fabsketch-backend-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# IAM Role for EC2
resource "aws_iam_role" "fabsketch_ec2_role" {
  name = "fabsketch-ec2-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "fabsketch_ec2_policy" {
  name = "fabsketch-ec2-policy"
  role = aws_iam_role.fabsketch_ec2_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::fab-sketch-media-xp8zu198/*"
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = "arn:aws:lambda:ap-northeast-2:377449795629:function:fabsketch-gen"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "fabsketch_ec2_profile" {
  name = "fabsketch-ec2-profile"
  role = aws_iam_role.fabsketch_ec2_role.name
}
