


output "vpc_id" {
value = aws_vpc.this.id
}
 
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
 
output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "eks_node_sg_id" {
  value = aws_security_group.eks_node_sg.id
}
