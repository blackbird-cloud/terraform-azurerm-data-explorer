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
