location    = "eastus"
project     = "capstone"
environment = "dev"

vnet_cidr       = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24"]
private_subnets = ["10.0.2.0/24"]

vm_size = "Standard_B2s"

aks_node_count = 2
aks_vm_size    = "Standard_B2s"
