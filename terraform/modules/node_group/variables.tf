variable "cluster_name" {}
variable "node_group_name" {}
variable "node_role_arn" {}
variable "subnet_ids" {
  type = list(string)
}
variable "desired_size" {
  default = 2
}
variable "max_size" {
  default = 3
}
variable "min_size" {
  default = 1
}
variable "instance_types" {
  default = ["t3.medium"]
}
variable "tags" {
  type = map(string)
  default = {}
}
variable "cluster_dependency" {
  description = "Dependency to ensure cluster is created before node group"
}

variable "security_group_id" {
  description = "Security group ID for SSH access"
}
