variable "vpc-name" {}
variable "igw-name" {}
variable "rt-name2" {}
variable "subnet-name" {}
variable "subnet-name2" {}
variable "security-group-name" {}
variable "iam-role-eks" {}
variable "iam-role-node" {}
variable "iam-policy-eks" {}
variable "iam-policy-node" {}
variable "cluster-name" {}
variable "eksnode-group-name" {}

variable "availability-zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "private-subnet-cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "db-name" {
  type    = string
  default = "tetris"
}

variable "db-username" {
  type    = string
  default = "tetris_admin"
}

variable "db-instance-class" {
  type    = string
  default = "db.t4g.micro"
}

variable "db-multi-az" {
  type    = bool
  default = false
}

variable "db-deletion-protection" {
  type    = bool
  default = true
}

variable "ecr-repositories" {
  type    = list(string)
  default = ["tetris-frontend", "tetris-backend"]
}
