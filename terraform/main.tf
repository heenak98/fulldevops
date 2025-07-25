terraform {
  backend "s3" {
    bucket         = "heena-devops-tfstate"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "heena-devops-tf-locks"
    encrypt        = true
  }
}


provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
 
module "vpc" {
  source             = "./modules/vpc"
  region             = var.region
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  cluster_name       = var.cluster_name
  availability_zones = ["us-east-1a", "us-east-1b"]  # ✅ Add this line
}

 
module "eks_cluster" {
  source             = "./modules/eks_cluster"
  cluster_name       = "my-eks-cluster-new16"
  cluster_role_arn   = module.iam_cluster_role.iam_role_arn
  subnet_ids         = module.vpc.private_subnet_ids
  kubernetes_version = "1.27"
  tags = {
    Environment = "dev"
    Project     = "fulldevops"
  }
}


module "iam_cluster_role" {
  source    = "./modules/iam_cluster_role"
  role_name = "eks-cluster-role"
  tags = {
    Environment = "dev"
    Project     = "fulldevops"
  }
}


module "iam_node_role" {
  source = "./modules/iam_node_role"
}


# module "eks" {
#   source            = "./modules/eks"
#   cluster_name      = var.cluster_name
#   cluster_version   = var.cluster_version
#   subnet_ids        = module.vpc.private_subnet_ids
#   cluster_role_arn  = module.iam_cluster_role.iam_role_arn
# }



 
module "node_group" {
  source              = "./modules/node_group"
  cluster_name        = module.eks_cluster.eks_cluster_name
  node_group_name     = "${var.cluster_name}-node-group"
  node_role_arn       = module.iam_node_role.node_group_role_arn
  subnet_ids          = module.vpc.private_subnet_ids
  cluster_dependency  = module.eks_cluster.cluster_dependency
  security_group_id = module.vpc.eks_node_sg_id

}
