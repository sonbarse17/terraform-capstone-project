variable "location" {

}

variable "project" {

}

variable "environment" {

}

variable "vnet_cidr" {

}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}


variable "vm_size" {

}

variable "aks_node_count" {

}

variable "aks_vm_size" {

}