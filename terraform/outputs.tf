# Output for ECR Repository Name
output "ecr_repository_name" {
  value = aws_ecr_repository.recruiters.name
  description = "The name of the ECR repository"
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
  description = "The name of the EKS cluster"
}
