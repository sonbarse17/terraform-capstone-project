variable "role_name" {
  type = string
}

variable "assume_role_policy" {
  type = string
}

variable "policy_json" {
  type = string
}

variable "tags" {
  type = map(string)
  default = { }
}