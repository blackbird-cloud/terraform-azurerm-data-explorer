<!-- BEGIN_TF_DOCS -->
# Terraform Azurerm Data Explorer Module
Terraform module to create an Azure Data Explorer

[![blackbird-logo](https://raw.githubusercontent.com/blackbird-cloud/terraform-module-template/main/.config/logo_simple.png)](https://blackbird.cloud)

## Example
```hcl
provider "azurerm" {
  features {
    key_vault {
      purge_soft_deleted_secrets_on_destroy = true
      recover_soft_deleted_secrets          = true
    }
  }
}

module "data_explorer" {
  source  = "blackbird-cloud/data-explorer/azurerm"
  version = "~> 1"

  location            = "West Europe"
  resource_group_name = "my-resource-group-name"

  cluster_name = "my-cluster"

  auto_stop_enabled = true
  sku_name          = "Dev(No SLA)_Standard_E2a_v4"
  sku_capacity      = 1

  allowed_ip_ranges = ["my-ip/32"]

  databases = {
    my_datebase = {
      name     = "my_datebase"
      location = "West Europe"
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.8 |

## Resources

| Name | Type |
|------|------|
| [azurerm_kusto_cluster.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_cluster) | resource |
| [azurerm_kusto_cluster_customer_managed_key.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_cluster_customer_managed_key) | resource |
| [azurerm_kusto_cluster_managed_private_endpoint.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_cluster_managed_private_endpoint) | resource |
| [azurerm_kusto_cluster_principal_assignment.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_cluster_principal_assignment) | resource |
| [azurerm_kusto_database.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_database) | resource |
| [azurerm_kusto_database_principal_assignment.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_database_principal_assignment) | resource |
| [azurerm_kusto_script.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kusto_script) | resource |
| [azurerm_private_endpoint.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_kusto_cluster.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kusto_cluster) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ip_ranges"></a> [allowed\_ip\_ranges](#input\_allowed\_ip\_ranges) | (Optional) The list of ips in the format of CIDR allowed to connect to the cluster. | `list(string)` | `[]` | no |
| <a name="input_auto_stop_enabled"></a> [auto\_stop\_enabled](#input\_auto\_stop\_enabled) | (Optional) Specifies if the cluster could be automatically stopped (due to lack of data or no activity for many days). Defaults to true. | `bool` | `true` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | (Required) The name of the Kusto Cluster to create. Only lowercase Alphanumeric characters allowed, starting with a letter. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_cluster_principal_assignments"></a> [cluster\_principal\_assignments](#input\_cluster\_principal\_assignments) | (Optional) Specifies the role assignments for the cluster. | <pre>map(object({<br>    role           = string<br>    principal_type = string<br>    principal_id   = string<br>    tenant_id      = string<br>  }))</pre> | `{}` | no |
| <a name="input_create_cluster"></a> [create\_cluster](#input\_create\_cluster) | (Optional) Set this to false if you have already created the Kusto Cluster and you want to manage it with this module. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_data_private_endpoint"></a> [data\_private\_endpoint](#input\_data\_private\_endpoint) | Configuration for the creation of a private link between the data source and the kusto cluster. | <pre>object({<br>    create                       = bool<br>    name                         = string<br>    private_link_resource_id     = string<br>    group_id                     = string<br>    private_link_resource_region = optional(string)<br>    request_message              = optional(string)<br>  })</pre> | <pre>{<br>  "create": false,<br>  "group_id": "",<br>  "name": "",<br>  "private_link_resource_id": ""<br>}</pre> | no |
| <a name="input_databases"></a> [databases](#input\_databases) | (Optional) Specifies the databases to create in the cluster. | <pre>map(object({<br>    name               = string<br>    location           = optional(string)<br>    soft_delete_period = optional(string)<br>    hot_cache_period   = optional(string)<br>    principal_assignments = optional(map(object({<br>      role           = string<br>      principal_type = string<br>      principal_id   = string<br>      tenant_id      = string<br>    })), {})<br>    script = optional(object({<br>      name                               = string<br>      script_content                     = string<br>      continue_on_errors_enabled         = optional(bool)<br>      force_an_update_when_value_changed = optional(string)<br>    }), { name = "", script_content = "" })<br>  }))</pre> | `{}` | no |
| <a name="input_disk_encryption_enabled"></a> [disk\_encryption\_enabled](#input\_disk\_encryption\_enabled) | (Optional) Specifies if the cluster's disks are encrypted. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_encryption_key"></a> [encryption\_key](#input\_encryption\_key) | (Optional) Specifies the encryption key to use for the cluster. | <pre>object({<br>    key_name     = string<br>    key_vault_id = string<br>    key_version  = string<br>  })</pre> | `null` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | (Optional) Specifies the type of Managed Service Identity, and optionally a list of User Assigned Managed Identity IDs to be assigned to this Kusto Cluster. | <pre>object({<br>    type         = string<br>    identity_ids = optional(list(string))<br>  })</pre> | <pre>{<br>  "type": "SystemAssigned"<br>}</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) The location where the Kusto Cluster should be created. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint) | Configuration for the creation of a private endpoint for the kusto cluster. | <pre>object({<br>    create                        = bool<br>    location                      = string<br>    resource_group_name           = string<br>    subnet_id                     = string<br>    custom_network_interface_name = optional(string)<br>    private_dns_zone_groups = optional(list(object({<br>      name                 = string,<br>      private_dns_zone_ids = list(string)<br>    })), [])<br>  })</pre> | <pre>{<br>  "create": false,<br>  "location": "",<br>  "resource_group_name": "",<br>  "subnet_id": ""<br>}</pre> | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | (Optional) Is the public network access enabled? Defaults to true. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Specifies the Resource Group where the Kusto Cluster should exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_sku_capacity"></a> [sku\_capacity](#input\_sku\_capacity) | (Optional) Specifies the node count for the cluster. Boundaries depend on the SKU name. | `number` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | (Required) The name of the SKU. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_databases"></a> [databases](#output\_databases) | n/a |
| <a name="output_kusto_cluster"></a> [kusto\_cluster](#output\_kusto\_cluster) | n/a |
| <a name="output_private_endpoint"></a> [private\_endpoint](#output\_private\_endpoint) | n/a |

## About

We are [Blackbird Cloud](https://blackbird.cloud), Amsterdam based cloud consultancy, and cloud management service provider. We help companies build secure, cost efficient, and scale-able solutions.

Checkout our other :point\_right: [terraform modules](https://registry.terraform.io/namespaces/blackbird-cloud)

## Copyright

Copyright © 2017-2024 [Blackbird Cloud](https://blackbird.cloud)
<!-- END_TF_DOCS -->