terraform {
  backend "s3" {
    bucket       = "roudayna-tf-state-bucket"
    region       = "us-east-1"
    key          = "tetris-devsecops-platform/Jenkins-Server-TF/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
  required_version = ">=1.13.3"
  required_providers {
    aws = {
      version = ">= 6.23.0"
      source  = "hashicorp/aws"
    }
  }
}