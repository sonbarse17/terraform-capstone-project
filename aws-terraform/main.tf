module "vpc" {
  source = "./modules/vpc"

  vpc_name          = local.vpc_name
  vpc_cidr          = var.vpc_cidr
  public_subnets    = var.public_subnets
  private_subnets   = var.private_subnets
  availability_zone = var.availability_zone

  tags = local.tags
}

module "s3" {
  source                    = "./modules/s3"
  bucket_name               = local.bucket_name
  tags                      = local.tags
  enable_versioning         = var.enable_versioning
  block_public_access       = var.block_public_access
  enable_lifecycle          = var.enable_lifecycle
  lifecycle_transition_days = var.lifecycle_transition_days
  lifecycle_expiration_days = var.lifecycle_expiration_days
}

module "sg" {
  source        = "./modules/security-group"
  sg_name       = local.sg_name
  vpc_id        = module.vpc.vpc_id
  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules
  tags          = local.tags
}

module "ec2" {
  source              = "./modules/ec2"
  instance_name       = local.ec2_instance_name
  ami_id              = var.ami_id
  instance_type       = var.instance_type
  subnet_id           = module.vpc.public_subnets_ids[0]
  associate_public_ip = var.associate_public_ip
  security_group_ids  = [module.sg.security_group_ids]
  key_name            = var.key_name
  user_data           = var.user_data
  tags                = local.tags
}

locals {
  ec2_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  eks_cluster_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  eks_node_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts.AssumeRole"
    }]
  })

  sagemaker_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "sagemaker.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

module "iam" {
  source             = "./modules/iam"
  role_name          = "EC2-role"
  assume_role_policy = local.ec2_assume_role_policy
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          module.s3.bucket_arn,
          "${module.s3.bucket_arn}/*"
        ]
      }
    ]
  })
  tags = local.tags
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = local.ecr_repo_name
  tags            = local.tags
}

module "iam_eks_cluster" {
  source = "./modules/iam"

  role_name          = "eks-cluster-role"
  assume_role_policy = local.eks_cluster_assume_role_policy
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["eks:*"]
      Resource = "*"
    }]
  })
  tags = {
    Env     = "dev"
    Project = "Capstone"
  }
}

module "iam_eks_node" {
  source = "./modules/iam"

  role_name          = "eks-node-role"
  assume_role_policy = local.eks_node_assume_role_policy

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "eks:DescribeCluster",
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      }
    ]
  })
}

module "eks_sg" {
  source  = "./modules/security-group"
  sg_name = local.eks_sg_name
  vpc_id  = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]
  tags = local.tags
}

module "eks" {
  source              = "./modules/eks"
  cluster_name        = local.eks_cluster_name
  cluster_role_arn    = module.iam_eks_cluster.role_arn
  node_instance_types = var.node_instance_types
  node_role_arn       = module.iam_eks_node.role_arn
  subnet_ids          = module.vpc.private_subnets_ids
  security_group_ids  = [module.eks_sg.security_group_ids]

  desired_size = var.desired_size
  min_size     = var.min_size
  max_size     = var.max_size

  tags = local.tags
}

module "aws_cloudwatch_dashboard" {
  source         = "./modules/cloudwatch-dashboards"
  dashboard_name = "${local.tags["Project"]}-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      ##ec2 cpu
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = ["AWS/EC2", "CPUUtilization", "InstanceId", module.ec2.instance_id]
          period  = 300
          stat    = "Sum"
          region  = "ap-south-1"
          title   = "EC2 Network In"
        }
      },
      ##eks cluser cpu (nodes)
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6

        properties = {
          metrics = ["ContainerInsights", "node_cpu_utilization", "ClusterName", module.eks.cluster_name]
          period  = 300
          stat    = "Average"
          region  = "ap-south-1"
          title   = "EKS node Cpu utilization"
        }
      }
    ]
  })
}

module "iam_sagemaker" {
  source = "./modules/iam"

  role_name          = "${local.sagemaker_notebook_name}-sg"
  assume_role_policy = local.sagemaker_assume_role_policy

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListObject"
        ]
        Resource = [module.s3.bucket_arn, "${module.s3.bucket_arn}/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreatLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
  tags = local.tags
}

module "sagemaker_sg" {
  source = "./modules/security-group"

  sg_name       = local.sagemaker_sg_name
  vpc_id        = module.vpc.vpc_id
  ingress_rules = []
  egress_rules = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  tags = local.tags
}

module "sagemaker_notebook" {
  source             = "./modules/sagemake-notebooks"
  notebook_name      = local.sagemaker_notebook_name
  role_arn           = module.iam_sagemaker.role_arn
  subnet_id          = module.vpc.private_subnets_ids[0]
  security_group_ids = [module.sagemaker_sg.security_group_ids]
  tags               = local.tags
}