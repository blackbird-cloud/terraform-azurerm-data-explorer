output "kusto_cluster" {
  value = azurerm_kusto_cluster.default
}

output "private_endpoint" {
  value = azurerm_kusto_cluster_managed_private_endpoint.default
}

output "databases" {
  value = azurerm_kusto_database.default
}
