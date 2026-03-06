# Cognito Identity Pool Module Outputs

output "identity_pool_id" {
  description = "ID of the Cognito Identity Pool"
  value       = aws_cognito_identity_pool.this.id
}

output "identity_pool_arn" {
  description = "ARN of the Cognito Identity Pool"
  value       = aws_cognito_identity_pool.this.arn
}

output "identity_pool_name" {
  description = "Name of the Cognito Identity Pool"
  value       = aws_cognito_identity_pool.this.identity_pool_name
}

output "authenticated_role_arn" {
  description = "ARN of the IAM role for authenticated users"
  value       = var.authenticated_role_arn != null ? var.authenticated_role_arn : try(aws_iam_role.authenticated[0].arn, null)
}

output "authenticated_role_name" {
  description = "Name of the IAM role for authenticated users"
  value       = var.authenticated_role_arn != null ? null : try(aws_iam_role.authenticated[0].name, null)
}

output "unauthenticated_role_arn" {
  description = "ARN of the IAM role for unauthenticated users"
  value       = var.unauthenticated_role_arn != null ? var.unauthenticated_role_arn : try(aws_iam_role.unauthenticated[0].arn, null)
}

output "unauthenticated_role_name" {
  description = "Name of the IAM role for unauthenticated users"
  value       = var.unauthenticated_role_arn != null ? null : try(aws_iam_role.unauthenticated[0].name, null)
}

output "tags" {
  description = "Tags applied to the Cognito Identity Pool"
  value       = aws_cognito_identity_pool.this.tags
}
