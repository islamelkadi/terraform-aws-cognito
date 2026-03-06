# Outputs for User Pool Client example

output "client_id" {
  description = "User Pool Client ID"
  value       = module.user_pool_client.client_id
}

output "client_name" {
  description = "User Pool Client name"
  value       = module.user_pool_client.client_name
}

output "client_secret" {
  description = "User Pool Client secret (sensitive)"
  value       = module.user_pool_client.client_secret
  sensitive   = true
}
