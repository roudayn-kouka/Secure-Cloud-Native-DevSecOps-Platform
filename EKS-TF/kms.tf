data "aws_caller_identity" "current" {}

# One customer-managed key encrypts EKS secrets, the RDS storage and the ECR repositories.
resource "aws_kms_key" "main" {
  description             = "${var.cluster-name} encryption key"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags                    = { Name = "${var.cluster-name}-kms" }
}

resource "aws_kms_alias" "main" {
  name          = "alias/${lower(var.cluster-name)}"
  target_key_id = aws_kms_key.main.key_id
}
