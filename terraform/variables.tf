variable "location" {
  default = "East US"
}

variable "resource_group_name" {
  default = "myResourceGroup"
}

variable "acr_name" {
  default = "myacrregistrysam"  # must be globally unique and lowercase
}

variable "aks_name" {
  default = "myAKSCluster"
}