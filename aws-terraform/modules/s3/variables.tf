variable "bucket_name" {
  type = string
}

variable "enable_versioning" {
  type = bool
  default = true
}

variable "block_public_access" {
  type = bool
  default = true
}

variable "enable_lifecycle" {
  type = bool
  default = false
}

variable "lifecycle_transition_days" {
  type = number
  default = 30
}

variable "lifecycle_expiration_days" {
  type = number
  default = 365
}

variable "tags" {
  type = map(string)
}

