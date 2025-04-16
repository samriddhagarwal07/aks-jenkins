variable "subscription_id" {
  description = "Subscription id of the account"
  type = string
  default = "4a6f3be4-14cd-451b-97b0-d315131d91cd"
}

variable "location" {
    description = "location of service"
    type = string
    default = "eastus"
}

variable "resource_group_name" {
  description = "resource group name"
  type = string
  default = "myResourceGroup"
}

variable "acr_name" {
  description = "Name of the service plan"
  type = string
  default = "myacrsam"
}

variable "os" {
  description = "Operating system"
  type = string
  default = "Linux"
}

variable "aks_name" {
    description = "Name of the service plan"
    type = string
    default = "myAKSCluster"
}

variable "dns_prefix"{
  default = "my-akscluster"
}
