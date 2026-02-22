region      = "ap-south-1"
project     = "Capstone"
environment = "dev"

## VPC
vpc_cidr          = "10.0.0.0/16"
public_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets   = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zone = ["ap-south-1a", "ap-south-1b"]

## S3
enable_versioning         = false
block_public_access       = false
enable_lifecycle          = false
lifecycle_transition_days = 30
lifecycle_expiration_days = 60

## Security Group
ingress_rules = [{
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  },
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

## EC2
ami_id              = "value"
instance_type       = "t2.micro"
associate_public_ip = true
key_name            = "demo-key"
user_data           = null

## EKS
node_instance_types = ["t3.micro"]
desired_size        = 1
min_size            = 1
max_size            = 2

