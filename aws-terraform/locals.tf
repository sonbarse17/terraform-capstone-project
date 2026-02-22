locals {
  name = "${var.project}-${var.environment}"

  vpc_name                = "${local.name}-vpc"
  eks_sg_name             = "${local.name}-eks-sg"
  sagemaker_sg_name       = "${local.name}-sagemaker-sg"
  bucket_name             = "${local.name}-bucket"
  ecr_repo_name           = "${local.name}-repo"
  eks_cluster_name        = "${local.name}-cluster"
  ec2_instance_name       = "${local.name}-ec2"
  sagemaker_notebook_name = "${local.name}-sagemaker-notebook"
  sg_name                 = "${local.name}-sg"
  tags = {
    Project = var.project
    ENV     = var.environment
  }
}
