# Cognito User Pool Client Module Outputs

output "client_id" {
  description = "ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.this.id
}

output "client_secret" {
  description = "Client secret (only available if generate_secret is true). Marked as sensitive."
  value       = aws_cognito_user_pool_client.this.client_secret
  sensitive   = true
}

output "client_name" {
  description = "Name of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.this.name
}

output "user_pool_id" {
  description = "ID of the associated Cognito User Pool"
  value       = aws_cognito_user_pool_client.this.user_pool_id
}

output "allowed_oauth_flows" {
  description = "List of allowed OAuth flows"
  value       = aws_cognito_user_pool_client.this.allowed_oauth_flows
}

output "allowed_oauth_scopes" {
  description = "List of allowed OAuth scopes"
  value       = aws_cognito_user_pool_client.this.allowed_oauth_scopes
}

output "callback_urls" {
  description = "List of allowed callback URLs"
  value       = aws_cognito_user_pool_client.this.callback_urls
}

output "logout_urls" {
  description = "List of allowed logout URLs"
  value       = aws_cognito_user_pool_client.this.logout_urls
}

output "supported_identity_providers" {
  description = "List of supported identity providers"
  value       = aws_cognito_user_pool_client.this.supported_identity_providers
}

output "token_validity" {
  description = "Token validity configuration"
  value = {
    refresh_token_validity = aws_cognito_user_pool_client.this.refresh_token_validity
    access_token_validity  = aws_cognito_user_pool_client.this.access_token_validity
    id_token_validity      = aws_cognito_user_pool_client.this.id_token_validity
  }
}
