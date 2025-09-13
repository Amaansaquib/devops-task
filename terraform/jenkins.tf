# Data source for Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create SSH key pair resource
resource "aws_key_pair" "jenkins" {
  key_name   = "${local.name_prefix}-jenkins-key"
  public_key = var.ssh_public_key

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-jenkins-key"
  })
}

# Jenkins EC2 instance
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.jenkins_instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  key_name               = aws_key_pair.jenkins.key_name
  iam_instance_profile   = aws_iam_instance_profile.jenkins.name

  user_data = base64encode(templatefile("${path.module}/jenkins-userdata.sh", {
    ecr_repository_uri = aws_ecr_repository.app.repository_url
    ecs_cluster_name   = aws_ecs_cluster.main.name
    ecs_service_name   = aws_ecs_service.app.name
    aws_region         = var.aws_region
  }))

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true

    tags = merge(local.tags, {
      Name = "${local.name_prefix}-jenkins-root-volume"
    })
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-jenkins-server"
  })

  depends_on = [aws_internet_gateway.main]
}

# Security group for Jenkins
resource "aws_security_group" "jenkins" {
  name        = "${local.name_prefix}-jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = aws_vpc.main.id

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Jenkins web interface
  ingress {
    description = "Jenkins Web"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-jenkins-sg"
  })
}

# IAM Role for Jenkins EC2 instance
resource "aws_iam_role" "jenkins" {
  name = "${local.name_prefix}-jenkins-role"

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

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-jenkins-role"
  })
}

# IAM Policy for Jenkins
resource "aws_iam_role_policy" "jenkins" {
  name = "${local.name_prefix}-jenkins-policy"
  role = aws_iam_role.jenkins.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeClusters",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:ListTasks",
          "ecs:DescribeTasks"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Instance Profile for Jenkins
resource "aws_iam_instance_profile" "jenkins" {
  name = "${local.name_prefix}-jenkins-profile"
  role = aws_iam_role.jenkins.name

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-jenkins-profile"
  })
}

# Elastic IP for Jenkins (optional but recommended)
resource "aws_eip" "jenkins" {
  instance = aws_instance.jenkins.id
  domain   = "vpc"

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-jenkins-eip"
  })

  depends_on = [aws_internet_gateway.main]
}
