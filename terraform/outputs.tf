output "eks_cluster_name" {
  value = module.eks.cluster_name
  description = "The name of the EKS cluster"
}
