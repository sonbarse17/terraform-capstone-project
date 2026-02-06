variable "notebook_name" {
  type = string
}

variable "instance_type" {
  type = string
  default = "ml.t3.medium"
}

variable "role_arn" {
  type = string
}

variable "subnet_id" {
  type = string
}
variable "security_group_ids" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}