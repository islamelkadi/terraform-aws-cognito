# Cognito User Pool Module Outputs

output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.arn
}

output "user_pool_endpoint" {
  description = "Endpoint of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.endpoint
}

output "user_pool_name" {
  description = "Name of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.name
}

output "user_pool_domain" {
  description = "Domain prefix of the Cognito User Pool (if configured)"
  value       = aws_cognito_user_pool.this.domain
}

output "user_pool_creation_date" {
  description = "Creation date of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.creation_date
}

output "user_pool_last_modified_date" {
  description = "Last modified date of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.last_modified_date
}

output "user_pool_estimated_number_of_users" {
  description = "Estimated number of users in the Cognito User Pool"
  value       = aws_cognito_user_pool.this.estimated_number_of_users
}

output "tags" {
  description = "Tags applied to the Cognito User Pool"
  value       = aws_cognito_user_pool.this.tags
}
