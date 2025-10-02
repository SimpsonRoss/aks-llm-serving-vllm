variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-aks-vllm-eastus"
}

variable "aks_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-vllm-eastus"
}

variable "system_vm_size" {
  description = "VM size for the AKS system node pool"
  type        = string
  default     = "Standard_D4s_v4"
}

variable "gpu_vm_size" {
  description = "VM size for GPU node pool"
  type        = string
  default     = "Standard_NC24ads_A100_v4" # 1x A100
}


variable "gpu_node_count" {
  description = "Number of GPU nodes"
  type        = number
  default     = 1
}

variable "system_node_count" {
  description = "Number of system (CPU) nodes"
  type        = number
  default     = 1
}
