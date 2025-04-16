variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "myResourceGroup"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique and lowercase)"
  type        = string
  default     = "myacrsam"
}

variable "aks_name" {
  description = "Name of the Azure Kubernetes Service cluster"
  type        = string
  default     = "myAKSCluster"
}
