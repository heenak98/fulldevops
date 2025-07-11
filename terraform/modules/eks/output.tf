output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_dependency" {
  description = "Dummy output to enforce dependency on the cluster creation"
  value       = aws_eks_cluster.this.id
}
