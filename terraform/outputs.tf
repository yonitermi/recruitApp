output "eks_cluster_name" {
  value = module.eks.cluster_id
  description = "The name of the EKS cluster"
}
