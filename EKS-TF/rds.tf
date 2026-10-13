resource "aws_db_subnet_group" "db" {
  name       = "${lower(var.cluster-name)}-db"
  subnet_ids = aws_subnet.private[*].id
  tags       = { Name = "${var.cluster-name}-db-subnet-group" }
}

# Only the EKS worker nodes (cluster security group) may reach MySQL.
resource "aws_security_group" "rds" {
  name        = "${var.cluster-name}-rds"
  description = "MySQL access from EKS nodes only"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description     = "MySQL from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_eks_cluster.eks-cluster.vpc_config[0].cluster_security_group_id]
  }

  tags = { Name = "${var.cluster-name}-rds-sg" }
}

# Force TLS for every client connection
resource "aws_db_parameter_group" "mysql" {
  name   = "${lower(var.cluster-name)}-mysql8"
  family = "mysql8.0"

  parameter {
    name  = "require_secure_transport"
    value = "1"
  }
}

resource "aws_db_instance" "mysql" {
  identifier     = "${lower(var.cluster-name)}-mysql"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db-instance-class

  db_name  = var.db-name
  username = var.db-username
  # The master password is generated and stored in AWS Secrets Manager (never in Terraform code or state files).
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.main.arn

  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.main.arn

  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.mysql.name
  publicly_accessible    = false
  multi_az               = var.db-multi-az

  backup_retention_period         = 7
  copy_tags_to_snapshot           = true
  auto_minor_version_upgrade      = true
  deletion_protection             = var.db-deletion-protection
  skip_final_snapshot             = !var.db-deletion-protection
  final_snapshot_identifier       = var.db-deletion-protection ? "${lower(var.cluster-name)}-final" : null
  enabled_cloudwatch_logs_exports = ["error", "slowquery"]

  tags = { Name = "${var.cluster-name}-mysql" }
}

# Lets the External Secrets Operator (running on the nodes) read ONLY the database secret.
resource "aws_iam_role_policy" "node-read-db-secret" {
  name = "read-db-secret"
  role = aws_iam_role.NodeGroupRole.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = aws_db_instance.mysql.master_user_secret[0].secret_arn
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = aws_kms_key.main.arn
      }
    ]
  })
}
