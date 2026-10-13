output "cluster_name" { value = aws_eks_cluster.eks-cluster.name }
output "ecr_repository_urls" { value = { for k, r in aws_ecr_repository.repo : k => r.repository_url } }
output "rds_endpoint" { value = aws_db_instance.mysql.address }
output "rds_secret_arn" { value = aws_db_instance.mysql.master_user_secret[0].secret_arn }
output "account_id" { value = data.aws_caller_identity.current.account_id }
