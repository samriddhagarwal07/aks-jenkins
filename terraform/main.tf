provider "azurerm" {
  features {}
  subscription_id = "4a6f3be4-14cd-451b-97b0-d315131d91cd"

}

resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup"
  location = "East US"
}

resource "azurerm_container_registry" "acr" {
  name                = "myacrname123"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "myAKSCluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "myaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}
