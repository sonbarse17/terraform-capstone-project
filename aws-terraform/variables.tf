variable "region" {
  type = string
}

## VPC

variable "vpc_cidr" {

}

variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}

variable "availability_zone" {
  type = list(string)
}
##############

### EC2

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "project" {
  
}
variable "environment" {
  
}
variable "key_name" {
  type = string
}

variable "associate_public_ip" {
  type = bool
}

variable "user_data" {
  type    = string
  default = null
}
#########################
## S3

variable "enable_versioning" {
  type    = bool
  default = true
}

variable "block_public_access" {
  type    = bool
  default = true
}

variable "enable_lifecycle" {
  type    = bool
  default = false
}

variable "lifecycle_transition_days" {
  type    = number
  default = 30
}

variable "lifecycle_expiration_days" {
  type    = number
  default = 365
}
#############

##ECR
variable "image_tag_mutability" {
  type    = string
  default = "IMMUTABLE"
}

variable "scan_on_push" {
  type    = bool
  default = true
}

variable "max_image_count" {
  type    = number
  default = 10
}

### EKS


variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "desired_size" {
  type = number
}
variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

## SAGEMAKER NOTEBOOK

## Security Group


variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

#########################
