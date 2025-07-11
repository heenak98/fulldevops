# eks-terraform-project/outputs.tf
 
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
 
output "public_subnet_ids" {
  description = "The public subnet IDs"
  value       = module.vpc.public_subnet_ids
}
 
output "private_subnet_ids" {
  description = "The private subnet IDs"
  value       = module.vpc.private_subnet_ids
}
 
output "eks_cluster_name" {
  value = module.eks_cluster.eks_cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks_cluster.eks_cluster_endpoint
}
