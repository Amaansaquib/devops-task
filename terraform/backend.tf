terraform {
  backend "s3" {
    bucket         = "swayatt-terraform-state-662810865233-20250913-0911"
    key            = "swayatt-devops-task/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "swayatt-terraform-locks"
    encrypt        = true
  }

  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "DevOps-Task"
      CreatedBy   = "swayatt-devops-pipeline"
    }
  }
}

provider "random" {
  # Configuration options
}
