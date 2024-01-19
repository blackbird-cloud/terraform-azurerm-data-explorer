variable "location" {
  type        = string
  description = "(Required) The location where the Kusto Cluster should be created. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Specifies the Resource Group where the Kusto Cluster should exist. Changing this forces a new resource to be created."
}

variable "sku_name" {
  type        = string
  description = "(Required) The name of the SKU."
}

variable "sku_capacity" {
  type        = number
  description = "(Optional) Specifies the node count for the cluster. Boundaries depend on the SKU name."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) A mapping of tags to assign to the resource."
}

variable "allowed_ip_ranges" {
  type        = list(string)
  default     = []
  description = "(Optional) The list of ips in the format of CIDR allowed to connect to the cluster."
}

variable "create_cluster" {
  type        = bool
  default     = true
  description = "(Optional) Set this to false if you have already created the Kusto Cluster and you want to manage it with this module. Defaults to `true`."
}

variable "cluster_name" {
  type        = string
  description = "(Required) The name of the Kusto Cluster to create. Only lowercase Alphanumeric characters allowed, starting with a letter. Changing this forces a new resource to be created."
}

variable "data_private_endpoint" {
  type = object({
    create                       = bool
    name                         = string
    private_link_resource_id     = string
    group_id                     = string
    private_link_resource_region = optional(string)
    request_message              = optional(string)
  })
  default = {
    create                   = false
    name                     = ""
    private_link_resource_id = ""
    group_id                 = ""
  }
  description = "Configuration for the creation of a private link between the data source and the kusto cluster."
}

variable "private_endpoint" {
  type = object({
    create                        = bool
    location                      = string
    resource_group_name           = string
    subnet_id                     = string
    custom_network_interface_name = optional(string)
  })
  default = {
    create              = false
    subnet_id           = ""
    resource_group_name = ""
    location            = ""
  }
  description = "Configuration for the creation of a private endpoint for the kusto cluster."
}

variable "encryption_key" {
  type = object({
    key_name     = string
    key_vault_id = string
    key_version  = string
  })
  default     = null
  description = "(Optional) Specifies the encryption key to use for the cluster."
}

variable "identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = {
    type = "SystemAssigned"
  }
  description = "(Optional) Specifies the type of Managed Service Identity, and optionally a list of User Assigned Managed Identity IDs to be assigned to this Kusto Cluster."
}

variable "cluster_principal_assignments" {
  type = map(object({
    role           = string
    principal_type = string
    principal_id   = string
    tenant_id      = string
  }))
  default     = {}
  description = "(Optional) Specifies the role assignments for the cluster."
}

variable "databases" {
  type = map(object({
    name               = string
    location           = optional(string)
    soft_delete_period = optional(string)
    hot_cache_period   = optional(string)
    principal_assignments = optional(map(object({
      role           = string
      principal_type = string
      principal_id   = string
      tenant_id      = string
    })), {})
    script = optional(object({
      name                               = string
      script_content                     = string
      continue_on_errors_enabled         = optional(bool)
      force_an_update_when_value_changed = optional(string)
    }), { name = "", script_content = "" })
  }))
  default     = {}
  description = "(Optional) Specifies the databases to create in the cluster."
}

variable "disk_encryption_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Specifies if the cluster's disks are encrypted. Defaults to `true`."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Is the public network access enabled? Defaults to true."
}

variable "auto_stop_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Specifies if the cluster could be automatically stopped (due to lack of data or no activity for many days). Defaults to true."
}
