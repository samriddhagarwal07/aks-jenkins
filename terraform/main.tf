provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg"{
    name = var.resource_group_name
    location = var.location
}

resource "azurerm_container_registry" "acr" {
  resource_group_name = var.resource_group_name
  location = var.location
  name = var.acr_name
  sku = "Basic"
  admin_enabled = true
}


//az aks create --resource-group rg-docker --name aks-dotnetwebapi --node-count 2 --node-vm-size Standard_B2ms --generate-ssh-keys --attach-acr acrkeshav070425
resource "azurerm_kubernetes_cluster" "aks" {
  location = var.location
  resource_group_name = var.resource_group_name
  name = var.aks_name
  dns_prefix = var.dns_prefix

  default_node_pool {
    vm_size = "Standard_B2ms"
    node_count = 2
    name = "default"
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  depends_on = [ azurerm_container_registry.acr ]
  
  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
  }
}
