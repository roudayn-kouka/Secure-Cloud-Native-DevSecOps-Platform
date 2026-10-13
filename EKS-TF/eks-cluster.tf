resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster-name
  role_arn = aws_iam_role.EKSClusterRole.arn
  vpc_config {
    subnet_ids         = concat([data.aws_subnet.subnet.id, aws_subnet.public-subnet2.id], aws_subnet.private[*].id)
    security_group_ids = [data.aws_security_group.sg-default.id]
  }

  version = 1.33

  # Kubernetes Secrets are encrypted at rest with a customer-managed KMS key
  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.main.arn
    }
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy]
}