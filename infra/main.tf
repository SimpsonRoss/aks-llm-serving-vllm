resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "vllm"

default_node_pool {
  name       = "system"
  vm_size    = var.system_vm_size
  node_count = var.system_node_count
}

  identity {
    type = "SystemAssigned"
  }

  # RBAC
  role_based_access_control_enabled = true


}

# GPU Node Pool
resource "azurerm_kubernetes_cluster_node_pool" "gpu" {
  name                  = "gpunp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.gpu_vm_size
  node_count            = var.gpu_node_count
  mode                  = "User"

  node_labels = {
    sku = "gpu"
  }

  node_taints = ["sku=gpu:NoSchedule"]
}
