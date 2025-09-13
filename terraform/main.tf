# Data sources
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# Generate random suffix for unique resource names
resource "random_id" "suffix" {
  byte_length = 4
}

# Local values for consistent naming and tagging
locals {
  name_prefix = "${var.project_name}-${random_id.suffix.hex}"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "DevOps-Task"
    CreatedBy   = "swayatt-devops-pipeline"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }

  # Common configuration values
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
}
