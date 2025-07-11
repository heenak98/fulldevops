resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  remote_access {
    ec2_ssh_key               = "my-eks-key"
    source_security_group_ids = [var.security_group_id]
  }

  instance_types = var.instance_types
  tags           = var.tags

  depends_on = [var.cluster_dependency]
}
