locals {
  cluster_name    = var.create_cluster ? azurerm_kusto_cluster.default[0].name : data.azurerm_kusto_cluster.default[0].name
  cluster_id      = var.create_cluster ? azurerm_kusto_cluster.default[0].id : data.azurerm_kusto_cluster.default[0].id
  encrypt_cluster = try(var.encryption_key.name, "") != ""
  database_assignments = {
    for assignment in flatten([
      for database_key, database in var.databases : [
        for assignment_key, assignment in database.principal_assignments : merge(assignment, {
          assignment_key = assignment_key
          database_key   = database_key
          database_name  = database.name
          }
        )
      ]
    ]) : "${assignment.database_key}-${assignment.assignment_key}" => assignment
  }
  databases_with_scripts = compact([
    for key, database in var.databases : try(database.script.name, "") == "" ? "" : key
  ])
  database_scripts = {
    for database_key in local.databases_with_scripts : "${database_key}" => merge(var.databases[database_key].script, { database_key : database_key })
  }
}

resource "azurerm_kusto_cluster" "default" {
  count = var.create_cluster ? 1 : 0

  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = var.sku_name
    capacity = var.sku_capacity
  }

  dynamic "identity" {
    for_each = try(var.identity.type, "") == "" ? [] : [var.identity]
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  allowed_ip_ranges             = var.allowed_ip_ranges
  disk_encryption_enabled       = var.disk_encryption_enabled
  public_network_access_enabled = var.public_network_access_enabled
  auto_stop_enabled             = var.auto_stop_enabled
  tags                          = var.tags
}

data "azurerm_kusto_cluster" "default" {
  count = var.create_cluster ? 0 : 1

  name                = var.cluster_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_kusto_cluster_customer_managed_key" "default" {
  count = local.encrypt_cluster ? 1 : 0

  cluster_id = local.cluster_id

  key_vault_id = var.encryption_key.key_vault_id
  key_name     = var.encryption_key.key_name
  key_version  = var.encryption_key.key_version
}

resource "azurerm_kusto_cluster_managed_private_endpoint" "default" {
  count = var.data_private_endpoint.create ? 1 : 0

  resource_group_name = var.resource_group_name
  cluster_name        = local.cluster_name

  name                         = var.data_private_endpoint.name
  private_link_resource_id     = var.data_private_endpoint.private_link_resource_id
  private_link_resource_region = var.data_private_endpoint.private_link_resource_region
  group_id                     = var.data_private_endpoint.group_id
  request_message              = var.data_private_endpoint.request_message
}

resource "azurerm_kusto_cluster_principal_assignment" "default" {
  for_each = var.cluster_principal_assignments

  name                = each.key
  resource_group_name = var.resource_group_name
  cluster_name        = local.cluster_name

  tenant_id      = each.value.tenant_id
  principal_id   = each.value.principal_id
  principal_type = each.value.principal_type
  role           = each.value.role
}

resource "azurerm_kusto_database" "default" {
  for_each = var.databases

  resource_group_name = var.resource_group_name
  cluster_name        = local.cluster_name

  name               = each.value.name
  location           = try(each.value.location, var.location)
  hot_cache_period   = each.value.hot_cache_period
  soft_delete_period = each.value.soft_delete_period
}

resource "azurerm_kusto_database_principal_assignment" "default" {
  for_each = local.database_assignments

  name                = each.key
  resource_group_name = var.resource_group_name
  cluster_name        = local.cluster_name

  database_name  = azurerm_kusto_database.default[each.value.database_key].name
  tenant_id      = each.value.tenant_id
  principal_id   = each.value.principal_id
  principal_type = each.value.principal_type
  role           = each.value.role
}

resource "azurerm_kusto_script" "default" {
  for_each = local.database_scripts

  database_id = azurerm_kusto_database.default[each.value.database_key].id

  name                               = each.value.name
  script_content                     = each.value.script_content
  continue_on_errors_enabled         = each.value.continue_on_errors_enabled
  force_an_update_when_value_changed = each.value.force_an_update_when_value_changed
}

resource "azurerm_private_endpoint" "default" {
  count = var.private_endpoint.create ? 1 : 0

  name = "data-explorer-${var.cluster_name}"

  location                      = var.private_endpoint.location
  resource_group_name           = var.private_endpoint.resource_group_name
  subnet_id                     = var.private_endpoint.subnet_id
  custom_network_interface_name = var.private_endpoint.custom_network_interface_name
  tags                          = var.tags
  private_service_connection {
    name                           = "data-explorer-${var.cluster_name}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_kusto_cluster.default[0].id
    subresource_names              = ["cluster"]
  }
}
